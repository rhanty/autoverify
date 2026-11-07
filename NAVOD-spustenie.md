# AutoVerify – spustenie (databáza + App Store + Google Play)

## 1. Databáza (cca 15 minút, zadarmo na štart)
1. Vytvorte účet na supabase.com a nový projekt (región EÚ).
2. SQL Editor → vložte obsah `schema.sql` → Run.
3. Settings → API: skopírujte **Project URL** a **anon public key**.
4. V `autoverify-production.html` vyplňte riadok `const CFG={url:"...",key:"..."}`.
5. Otvorte súbor v prehliadači a vyskúšajte: zápis od mechanika → vyhľadanie VIN. Dátum doplní server.

Bez prihlásenia môže zapisovať ktokoľvek (aj falošné záznamy). Pred spustením pre verejnosť pridajte aspoň limit počtu zápisov (Cloudflare Turnstile / rate limit) a neskôr overenie servisov.

## 2. Zadarmo online cez GitHub Pages (0 €)
1. github.com → New repository → názov `autoverify` → Public → Create.
2. „uploading an existing file“ → nahrajte `autoverify-production.html` premenovaný na `index.html` (plus `schema.sql` a tento návod) → Commit.
3. Settings → Pages → Source: Deploy from a branch → Branch: `main`, priečinok `/ (root)` → Save.
4. Po 1–2 minútach beží aplikácia na `https://VASE-MENO.github.io/autoverify/`.
5. Na telefóne: otvoriť odkaz → Zdieľať → „Pridať na plochu“. Funguje ako aplikácia bez obchodov.
Kľúč `anon public` v súbore je verejný zámerne (chráni ho zamknutá databáza). Nikdy nevkladajte kľúč `service_role`.

## 3. Balenie do aplikácie (Capacitor)
```
mkdir autoverify-app && cd autoverify-app
npm init -y
npm i @capacitor/core @capacitor/cli @capacitor/ios @capacitor/android
npx cap init AutoVerify sk.autoverify.app --web-dir=www
mkdir www && cp ../autoverify-production.html www/index.html
npx cap add ios && npx cap add android
npx cap sync
```
Pred balením stiahnite React a React DOM do `www/` a zmeňte `<script src>` na lokálne súbory, aby appka nezávisela od CDN.

## 4. Zverejnenie
**App Store (iOS):** Apple Developer účet (cca 99 USD/rok), Mac s Xcode (alebo cloud build, napr. Codemagic) → `npx cap open ios` → Archive → App Store Connect → odoslať na revíziu.
**Google Play:** účet (cca 25 USD jednorazovo) → `npx cap open android` → Build → Android App Bundle (.aab) → Play Console → odoslať na revíziu.
Obe obchody vyžadujú: ikonu a screenshoty, popis, URL zásad ochrany súkromia, vyplnenie formulárov o údajoch (Apple Privacy / Play Data safety).

## 5. Na čo si dať pozor pri revízii
- Tlačidlo „Naskenovať foťákom“ je zatiaľ len simulácia. Obchody môžu odmietnuť falošnú funkciu → doplňte skutočné skenovanie (kamera/OCR plugin) alebo tlačidlo odstráňte.
- Apple môže odmietnuť appku, ktorá je len zabalená webstránka. Pomáha lokálne zabalený kód a natívna funkcia (kamera).
- Odkaz na donate z iOS appky môže Apple odmietnuť; bezpečnejšie je mať ho len vo webovej verzii.
- VIN spojený s osobou je osobný údaj (GDPR): neukladajte údaje o majiteľoch.
