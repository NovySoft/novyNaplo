# Novy Napló

[![time tracker](https://wakatime.com/badge/github/NovySoft/novyNaplo.svg)](https://wakatime.com/badge/github/NovySoft/novyNaplo)
[![Build Status](https://travis-ci.com/NovySoft/novyNaplo.svg?branch=master)](https://travis-ci.com/NovySoft/novyNaplo)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/f08d8ae48160409997ea32cf95d1a64f)](https://www.codacy.com/manual/Legolaszstudio/novyNaplo?utm_source=github.com&utm_medium=referral&utm_content=NovySoft/novyNaplo&utm_campaign=Badge_Grade)
[![Maintainability](https://api.codeclimate.com/v1/badges/48e75a94f1484016fa8a/maintainability)](https://codeclimate.com/github/NovySoft/novyNaplo/maintainability)
[![CodeScene Code Health](https://codescene.io/projects/11066/status-badges/code-health)](https://codescene.io/projects/11066)
[![CodeScene System Mastery](https://codescene.io/projects/11066/status-badges/system-mastery)](https://codescene.io/projects/11066)
[![HitCount](http://hits.dwyl.io/NovySoft/novyNaplo.svg)](http://hits.dwyl.io/NovySoft/novyNaplo)
[![Discord](https://img.shields.io/discord/737612284389621845.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/TJYpV2E)
[![Open Source Helpers](https://www.codetriage.com/novysoft/novynaplo/badges/users.svg)](https://www.codetriage.com/novysoft/novynaplo)


Novy teljesen nem eredeti kréta kliense.

## Letöltés

- Playstoreból:

[![Szerezd meg: Google Play](https://play.google.com/intl/en_us/badges/static/images/badges/hu_badge_web_generic.png)](https://play.google.com/store/apps/details?id=novy.vip.novynaplo&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1)

### Amennyiben nem zavar, hogy az alkalmazás hibákat tartalmazhat és szeretnél hozzájárulni az applikáció fejlesztéséhez, javasoljuk a béta tesztelést

- Teszt verzió playstoreon:
[Legújabb béta verzió letöltése](https://play.google.com/apps/testing/novy.vip.novynaplo)

### A github releases használata **megszűnt**

## Jelenlegi funkciók

- Jegyek megtekintése
- Bejelentett dolgozatok megtekintése
- Átlagok megtekintése
- Feljegyzések megtekintése
- Órarend megtekintése
- Átlagok grafikonon való megtekintése
- Jegy számoló - **[HUNCUT2016](https://github.com/huncut2016)** közreműködésével
- Mi van ha, virtuális jegyszámoló
- Statisztika oldal
- Értesítések
- Offline mód
- Faliújság megtekintése
- Fordítások (Angol, Magyar)
- Éves, féléves, és negyedéves értesítők megetekintése
- Hiányzások és késések

## **HAMAROSAN**

- Tanulói házifeladat felírása
- Házifeladat TODO lista szerűség
- Több felhasználós támogatás
- E-Ügyintézés
- Támogatók oldal - **Gáti Úr** közreműködésével
- Szuper egyedi és egyéni beállítások (**Már most is** van sok, de több lesz)

## Tervezve **(nem biztos hogy meg lesz valósítva)**

- BKK integráció
- Integrált chat felület
- Házifeladat segédletek
- **Wear OS** kompatibilitás (felthetőleg teljesen másik applikáció keretében)

## Modulok

- **Flutter:** Evvel a frameworkkel készült az applikáció
- **cupertino_icons**: Az ios ikonokért felel
- **permission_handler**: A későbbiekben a jogokért fog felelni
- **http**: Hálózati kérésekért felel
- **flutter_launcher_icons**: Az applikáció ikonjáért felel
- **shared_preferences**: Az adatok tárolásáért felelős
- **english_words**: Véleltlen angol szavakat generál
- **encrypt**: Az adatok titkosításáért felel
- **connectivity**: Az internet elérhetőségét figyeli
- **package_info**: Ennek a segítségével nézi meg az applikáció saját verzióját
- **flutter_spinkit**: A kis homokóráért felelős
- **dynamic_theme**: A sötét és fehér téma közt vált
- **charts_flutter**: A grafikonokat rajzolja ki
- **firebase_crashlytics**: Applikáció összeomlás esetén jelenti a fontos összeonlási adatokat
- **firebase_analytics**: Az applikáció használatáról jelent fontos adatokat (ki melyik gombot nyomja meg, milyen gyors az api válasz és egyebek)
- **firebase_performance**: Az internet lekérések sebbeségét figyeli
- **firebase_admob**: Alsó reklám csík megjelnítése
- **admob_flutter**: Natív reklámok
- **material_design_icons_flutter**: Ikon kiegészítő csomag
- **sqflite**: Kliens oldali sql (adattárolás)
- **animations**: Animációk kezelése
- **flutter_html**: Html objektumok megjelenítése (Házifeladat)
- **flutter_slidable**: A húzható kártyák
- **customgauge**: A kis sebbeség óra szerüség
- **flutter_local_notifications**: Értesítések küldése
- **android_alarm_manager**: Háttér lekérések időzítése
- **in_app_update**: Playstore frissítések jelzése

## Felhasznált kódok

- **Bejelentkezési oldal:** [https://github.com/putraxor/flutter-login-ui](https://github.com/putraxor/flutter-login-ui)
- **Háttér logika, néhány design ötlet:** [https://github.com/boapps/Szivacs-Naplo](https://github.com/boapps/Szivacs-Naplo)
- **Api lekérések:** [https://github.com/boapps/e-kreta-api-docs](https://github.com/boapps/e-kreta-api-docs)

## Betűtípusok

- **Nunito**

## Ismert hibák

- **Lassú betöltés/leragadás a homokóránál** a lassú krétás válasz miatt történik (amennyiben nem, akkor hibakódot kell látnod)
- **Hibás tanár/tantárgy név** az eredeti krétában van elírva a tanár/tantárgy neve, ez nem az applikáció hibája
- **Tantárgy nézet bugos**, szétesnek és/vagy összekeverednek a tárgyak. (FIX hamarosan, meg van a hiba forrása)

### Nem látod a hibádat? Csinálj egy hiba ticketet

## Kód íráshoz használt pluginok

- [WakaTime](https://wakatime.com/) Ajánlott a letöltése, így összegezni tudjuk, hogy mennyi fölösleges órát tölttöttünk kód írással ;)
- [Better comments](https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments) Az én kis komment kiemelő pluginom, mert különböző kommenteket különböztetek meg
- [TabNine](https://marketplace.visualstudio.com/items?itemName=TabNine.tabnine-vscode) Egy kis kód kiegesztő plugin, ajánlom a használatát

### A Google Play és a Google Play-logó a Google LLC védjegyei
