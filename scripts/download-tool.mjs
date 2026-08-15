import { createWriteStream, existsSync, mkdirSync, renameSync, rmSync } from "node:fs";
import { dirname } from "node:path";
import { get } from "node:https";

const [url, destination] = process.argv.slice(2);

if (!url || !destination) {
  console.error("Usage: node scripts/download-tool.mjs <url> <destination>");
  process.exit(2);
}

mkdirSync(dirname(destination), { recursive: true });
const partial = `${destination}.partial`;
if (existsSync(partial)) rmSync(partial);

function download(currentUrl, redirectsLeft = 10) {
  get(currentUrl, { headers: { "User-Agent": "IgricaSetup/1.0" } }, (response) => {
    if (
      response.statusCode >= 300 &&
      response.statusCode < 400 &&
      response.headers.location &&
      redirectsLeft > 0
    ) {
      response.resume();
      download(new URL(response.headers.location, currentUrl).toString(), redirectsLeft - 1);
      return;
    }

    if (response.statusCode !== 200) {
      response.resume();
      console.error(`Download failed with HTTP ${response.statusCode}`);
      process.exit(1);
    }

    const total = Number(response.headers["content-length"] ?? 0);
    let received = 0;
    let lastReported = -1;
    const output = createWriteStream(partial);

    response.on("data", (chunk) => {
      received += chunk.length;
      if (total > 0) {
        const percent = Math.floor((received / total) * 100);
        if (percent >= lastReported + 10) {
          lastReported = percent;
          console.log(`${percent}%`);
        }
      }
    });
    response.pipe(output);
    output.on("finish", () => {
      output.close(() => {
        renameSync(partial, destination);
        console.log(`Saved ${destination} (${received} bytes)`);
      });
    });
  }).on("error", (error) => {
    console.error(error.message);
    if (existsSync(partial)) rmSync(partial);
    process.exit(1);
  });
}

download(url);
