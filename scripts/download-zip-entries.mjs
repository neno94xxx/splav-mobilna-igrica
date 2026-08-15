import {
  createReadStream,
  createWriteStream,
  existsSync,
  mkdirSync,
  renameSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { basename, join } from "node:path";
import { pipeline } from "node:stream/promises";
import { createInflateRaw } from "node:zlib";

const [url, outputDirectory, patternText] = process.argv.slice(2);
if (!url || !outputDirectory || !patternText) {
  console.error("Usage: node download-zip-entries.mjs <zip-url> <output-dir> <regex>");
  process.exit(2);
}

const pattern = new RegExp(patternText);
const CHUNK_SIZE = 16 * 1024 * 1024;

async function fetchRange(start, end) {
  const response = await fetch(url, {
    headers: {
      Range: `bytes=${start}-${end}`,
      "User-Agent": "IgricaSetup/1.0",
    },
  });
  if (response.status !== 206) {
    throw new Error(`Range ${start}-${end} failed with HTTP ${response.status}`);
  }
  return Buffer.from(await response.arrayBuffer());
}

async function archiveInfo() {
  const probe = await fetchRange(0, 0);
  const contentRange = "bytes 0-0/";
  // A one-byte request gives us the total length through Content-Range, but
  // fetchRange deliberately returns only the body. Make a small direct request
  // here to retain the headers.
  const response = await fetch(url, {
    headers: { Range: "bytes=0-0", "User-Agent": "IgricaSetup/1.0" },
  });
  const value = response.headers.get("content-range") ?? "";
  await response.arrayBuffer();
  if (!value.startsWith(contentRange)) throw new Error("Server did not return archive size");
  return Number(value.slice(contentRange.length));
}

function findEndOfCentralDirectory(buffer) {
  for (let offset = buffer.length - 22; offset >= 0; offset -= 1) {
    if (buffer.readUInt32LE(offset) === 0x06054b50) return offset;
  }
  throw new Error("ZIP end-of-central-directory record was not found");
}

function readEntries(buffer) {
  const entries = [];
  let offset = 0;
  while (offset + 46 <= buffer.length) {
    if (buffer.readUInt32LE(offset) !== 0x02014b50) break;
    const method = buffer.readUInt16LE(offset + 10);
    const compressedSize = buffer.readUInt32LE(offset + 20);
    const uncompressedSize = buffer.readUInt32LE(offset + 24);
    const nameLength = buffer.readUInt16LE(offset + 28);
    const extraLength = buffer.readUInt16LE(offset + 30);
    const commentLength = buffer.readUInt16LE(offset + 32);
    const localOffset = buffer.readUInt32LE(offset + 42);
    const name = buffer.subarray(offset + 46, offset + 46 + nameLength).toString("utf8");
    entries.push({ name, method, compressedSize, uncompressedSize, localOffset });
    offset += 46 + nameLength + extraLength + commentLength;
  }
  return entries;
}

async function downloadEntry(entry) {
  const localHeader = await fetchRange(entry.localOffset, entry.localOffset + 29);
  if (localHeader.readUInt32LE(0) !== 0x04034b50) {
    throw new Error(`Invalid local header for ${entry.name}`);
  }
  const nameLength = localHeader.readUInt16LE(26);
  const extraLength = localHeader.readUInt16LE(28);
  const dataStart = entry.localOffset + 30 + nameLength + extraLength;
  const compressedPath = join(outputDirectory, `${basename(entry.name)}.compressed.partial`);
  const outputPath = join(outputDirectory, basename(entry.name));
  if (existsSync(compressedPath)) rmSync(compressedPath);
  if (existsSync(outputPath)) rmSync(outputPath);

  const output = createWriteStream(compressedPath);
  let downloaded = 0;
  while (downloaded < entry.compressedSize) {
    const amount = Math.min(CHUNK_SIZE, entry.compressedSize - downloaded);
    const chunk = await fetchRange(dataStart + downloaded, dataStart + downloaded + amount - 1);
    if (!output.write(chunk)) await new Promise((resolve) => output.once("drain", resolve));
    downloaded += chunk.length;
    console.log(`${entry.name}: ${Math.floor((downloaded / entry.compressedSize) * 100)}%`);
  }
  await new Promise((resolve, reject) => output.end((error) => (error ? reject(error) : resolve())));

  if (entry.method === 0) {
    renameSync(compressedPath, outputPath);
  } else if (entry.method === 8) {
    await pipeline(createReadStream(compressedPath), createInflateRaw(), createWriteStream(outputPath));
    rmSync(compressedPath);
  } else {
    throw new Error(`Unsupported ZIP compression method ${entry.method} for ${entry.name}`);
  }

  const size = statSync(outputPath).size;
  if (size !== entry.uncompressedSize) {
    throw new Error(`${entry.name} has ${size} bytes; expected ${entry.uncompressedSize}`);
  }
  console.log(`Saved ${outputPath} (${size} bytes)`);
}

mkdirSync(outputDirectory, { recursive: true });
const totalSize = await archiveInfo();
const tailSize = Math.min(256 * 1024, totalSize);
const tail = await fetchRange(totalSize - tailSize, totalSize - 1);
const eocdOffset = findEndOfCentralDirectory(tail);
const centralSize = tail.readUInt32LE(eocdOffset + 12);
const centralOffset = tail.readUInt32LE(eocdOffset + 16);
const central = await fetchRange(centralOffset, centralOffset + centralSize - 1);
const matches = readEntries(central).filter((entry) => pattern.test(entry.name));

if (matches.length === 0) throw new Error(`No ZIP entries matched ${pattern}`);
console.log(`Selected ${matches.length} entries from ${totalSize}-byte archive`);
for (const entry of matches) {
  console.log(`${entry.name}: ${entry.uncompressedSize} bytes, method ${entry.method}`);
  await downloadEntry(entry);
}

writeFileSync(join(outputDirectory, "version.txt"), "4.7.1.stable\n", "utf8");
