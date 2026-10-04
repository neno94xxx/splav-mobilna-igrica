# Raft Escape - Godot igra

Android igra o dvojici brodolomaca koji skupljaju daske i uzad, unapreduju splav i pokusavaju pobjeci s otoka.

## Novo racunalo nakon preuzimanja s GitHuba

1. Pokrenite `POSTAVI_PROJEKT.bat` u mapi projekta (Windows x64, internet).
2. Skripta preuzima Godot 4.7.1, OpenJDK 17.0.20, Android command-line alate i Android export predloske. Provjerava SHA256 preuzetih paketa, instalira Android SDK 36 / Build Tools 36.1.0, postavlja lokalne putanje i ponovno importira slike i zvukove.
3. Procitajte i prihvatite Android SDK licence kada vas Googleov alat pita, ako se slazete.
4. Nakon uspjesnog postavljanja pokrenite `POKRENI_IGRU.bat` ili `OTVORI_U_GODOTU.bat`.

Alati se spremaju u `.tools`, ne instaliraju se globalno i ne zahtijevaju administratorske ovlasti. Prvo potpuno postavljanje preuzima vise od 1.5 GB i moze potrajati. Ponovno pokretanje koristi vec instalirane alate i provjerene preuzete pakete.

Ako zasad zelite samo igrati ili uredjivati igru na Windowsu, u terminalu unutar projekta pokrenite:

```powershell
.\POSTAVI_PROJEKT.bat -OnlyDesktop
```

To preuzima samo Godot i importira projekt. Android postavljanje mozete naknadno dodati pokretanjem iste skripte bez parametra.

U Git idu kod, optimizirani asseti, AdMob dodatak i skripte za postavljanje. `.tools`, `.godot`, `android/build`, `builds` i kljucevi za potpisivanje ostaju u gitignoreu jer se lokalno stvaraju ili obnavljaju. `.godot` cache ne treba prenositi s drugog racunala.

## Pokretanje

- `POKRENI_IGRU.bat` pokrece igru.
- `OTVORI_U_GODOTU.bat` otvara Godot editor; `F5` pokrece igru, a `F6` trenutacnu scenu.
- Prvo pokretanje igre importira slike i zvukove ako jos nema Godotova cachea.

## Android APK i Google Play AAB

Nakon potpunog postavljanja pokrenite `IZRADI_ANDROID_APK.bat`. APK ce biti u `builds/raft-escape-admob-test.apk`. Gradle pri prvom buildu sam preuzima ovisnosti, ukljucujuci Google Mobile Ads i UMP.

`DOVRSI_ANDROID_POSTAVLJANJE.bat` ostaje pomocna skripta za postojece Android alate. Za potpuno novo racunalo koristite `POSTAVI_PROJEKT.bat`.

Za potpisani AAB pokrenite `IZRADI_PLAY_AAB.bat`. Prebacite postojeci `raftescape-upload.jks` iz sigurnosne kopije na novo racunalo. Skripta trazi njegovu putanju ako ga ne pronadje i zatim lozinku. Kljuc se ne preuzima niti generira zamjenski. AAB se sprema u `builds/raft-escape-play.aab`.

Putanju kljuca mozete i izravno zadati:

```powershell
.\IZRADI_PLAY_AAB.bat -KeystorePath "D:\RaftEscapeKeys\raftescape-upload.jks"
```

Za izravno pokretanje na telefonu ukljucite **Developer options** i **USB debugging**, spojite telefon USB kabelom i prihvatite autorizaciju racunala. Otvorite projekt pomocu `OTVORI_U_GODOTU.bat` i koristite Android ikonu za one-click deploy.

Napredak se sprema u Godotovom `user://` direktoriju i ne prenosi se Gitom.
