# Bijeg splavom — prvi Godot prototip

Jednostavna igriva verzija ideje za Android igru. Grafika je zasad namjerno nacrtana jednostavnim oblicima kako bismo prvo provjerili je li osnovna petlja zabavna.

## Pokretanje

- Dvaput kliknite `POKRENI_IGRU.bat` za igru.
- Dvaput kliknite `OTVORI_U_GODOTU.bat` za Godot editor.
- U editoru: `F6` pokreće trenutačnu scenu, a `F5` cijelu igru.

Godot 4.7.1, OpenJDK 17, Android command-line alati i Godotovi Android export predlošci nalaze se prijenosno u `.tools` direktoriju. Nisu instalirani globalno u Windows.

## Android — jednokratni završni korak

1. Pokrenite `DOVRSI_ANDROID_POSTAVLJANJE.bat`.
2. Pročitajte i, ako se slažete, prihvatite Googleovu Android SDK licencu kada se pojavi.
3. Nakon dovršetka pokrenite `IZRADI_ANDROID_APK.bat`.
4. APK će biti u `builds/bijeg-splavom-debug.apk`.

Za izravno pokretanje iz Godota na telefonu uključite **Developer options** i **USB debugging**, spojite telefon USB kabelom i prihvatite poruku za autorizaciju računala. Zatim otvorite projekt pomoću `OTVORI_U_GODOTU.bat`; Android ikona za one-click deploy pojavit će se u gornjem desnom kutu.

## Kontrole

- Miš/dodir: držite i povlačite lijevo-desno.
- Tipkovnica: `A`/`D` ili strelice.
- `Enter`/`Space`: pokretanje ili ponovni pokušaj.
- `U`: nadogradnja na ekranu rezultata, ako imate dovoljno resursa.

## Što prototip sadrži

- kratku početnu animaciju guranja i uskakanja na splav
- automatsku plovidbu i upravljanje lijevo-desno
- užad i daske iz brodskih olupina
- stijene i oštećenje splava
- ograničen domet svake razine splava
- povratak strujom i spremanje napretka
- tri razine splava i završnu scenu bijega

Napredak se sprema u Godotovom `user://` direktoriju, izvan projektne mape.
