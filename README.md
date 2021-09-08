# Novy Napló

[![time tracker](https://wakatime.com/badge/github/NovySoft/novyNaplo.svg)](https://wakatime.com/badge/github/NovySoft/novyNaplo)
[![flutter](https://github.com/NovySoft/novyNaplo/workflows/flutter/badge.svg)](https://github.com/NovySoft/novyNaplo/actions)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/0fadb7414f4d4ba4a4975b9362d7ebb7)](https://www.codacy.com/gh/NovySoft/novyNaplo/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=NovySoft/novyNaplo&amp;utm_campaign=Badge_Grade)
[![Maintainability](https://api.codeclimate.com/v1/badges/48e75a94f1484016fa8a/maintainability)](https://codeclimate.com/github/NovySoft/novyNaplo/maintainability)
[![CodeScene Code Health](https://codescene.io/projects/11066/status-badges/code-health)](https://codescene.io/projects/11066)
[![CodeScene System Mastery](https://codescene.io/projects/11066/status-badges/system-mastery)](https://codescene.io/projects/11066)
[![Discord](https://img.shields.io/discord/737612284389621845.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/TJYpV2E)
[![Open Source Helpers](https://www.codetriage.com/novysoft/novynaplo/badges/users.svg)](https://www.codetriage.com/novysoft/novynaplo)


Novy teljesen nem eredeti kréta kliense.

## Kréta DMCA

A kréta március elsején távolította el az alkalmazást a play áruházból... Mi ezután nem sokkal írtunk egy levelet a DMCA-ban található email címre, melyre azóta sem jött válasz. Az alkalmazás fejlesztését, nem hagyjuk abba, viszont **sajnos le kellet mondanunk az applikáció áruházakban való jelenlétünkről.**

### Letöltés

GitHub-ról: [![GitHub release (latest by date)](https://img.shields.io/github/downloads/NovySoft/NovyNaplo/latest/total)](https://github.com/NovySoft/novyNaplo/releases/latest)

F-droid-ról: [![Fdroid release](https://img.shields.io/badge/F--droid-latest-brightgreen)](https://fdroid.novy.software/)

## Jelenlegi funkciók

- Jegyek megtekintése
- Bejelentett dolgozatok megtekintése
- Átlagok megtekintése
- Feljegyzések megtekintése
- Órarend megtekintése
- Átlagok grafikonon való megtekintése
- Jegy számoló - **[HUNCUT2016](https://github.com/huncut2016)** és **[LŐRINC](https://github.com/lordlorinc)** közreműködésével
- Mi van ha, virtuális jegyszámoló
- Statisztika oldal
- Értesítések
- Offline mód
- Faliújság megtekintése
- Fordítások (Angol, Magyar)
- Éves, féléves, és negyedéves értesítők megetekintése
- Hiányzások és késések
- Több felhasználós támogatás

## **HAMAROSAN**

- Tanulói házifeladat felírása
- Házifeladat TODO lista szerűség
- E-Ügyintézés
- Támogatók oldal - **Gáti Úr** közreműködésével
- Szuper egyedi és egyéni beállítások (**Már most is** van sok, de több lesz)

## Tervezve **(nem biztos hogy meg lesz valósítva)**

- BKK integráció
- Integrált chat felület
- Házifeladat segédletek
- **Wear OS** kompatibilitás (feltehetőleg teljesen másik applikáció keretében)

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
- **material_design_icons_flutter**: Ikon kiegészítő csomag
- **sqflite**: Kliens oldali sql (adattárolás)
- **animations**: Animációk kezelése
- **flutter_html**: Html objektumok megjelenítése (Házifeladat)
- **flutter_slidable**: A húzható kártyák
- **customgauge**: A kis sebbeség óra szerüség
- **flutter_local_notifications**: Értesítések küldése
- **android_alarm_manager**: Háttér lekérések időzítése

## Felhasznált kódok

- **Bejelentkezési oldal:** [https://github.com/putraxor/flutter-login-ui](https://github.com/putraxor/flutter-login-ui)
- **Háttér logika, néhány design ötlet:** [https://github.com/boapps/Szivacs-Naplo](https://github.com/boapps/Szivacs-Naplo)
- **Api lekérések:** [https://github.com/boapps/e-kreta-api-docs](https://github.com/boapps/e-kreta-api-docs)
- **Az új api V3:** [https://github.com/filc/naplo](https://github.com/filc/naplo)

## Betűtípusok

- **Nunito**

## Ismert hibák

- **Lassú betöltés/leragadás a homokóránál** a lassú krétás válasz miatt történik (amennyiben nem, akkor hibakódot kell látnod)
- **Hibás tanár/tantárgy név** az eredeti krétában van elírva a tanár/tantárgy neve, ez nem az applikáció hibája

### Nem látod a hibádat? Csinálj egy hiba ticketet

## Kód íráshoz használt pluginok

- [WakaTime](https://wakatime.com/) Ajánlott a letöltése, így összegezni tudjuk, hogy mennyi fölösleges órát tölttöttünk kód írással ;)
- [Better comments](https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments) Az én kis komment kiemelő pluginom, mert különböző kommenteket különböztetek meg
- [TabNine](https://marketplace.visualstudio.com/items?itemName=TabNine.tabnine-vscode) Egy kis kód kiegesztő plugin, ajánlom a használatát
