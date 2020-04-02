# Novy Napló
[![time tracker](https://wakatime.com/badge/github/NovySoft/novyNaplo.svg)](https://wakatime.com/badge/github/NovySoft/novyNaplo)
[![Build Status](https://travis-ci.com/NovySoft/novyNaplo.svg?branch=master)](https://travis-ci.com/NovySoft/novyNaplo)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/f08d8ae48160409997ea32cf95d1a64f)](https://www.codacy.com/manual/Legolaszstudio/novyNaplo?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=NovySoft/novyNaplo&amp;utm_campaign=Badge_Grade)
[![HitCount](http://hits.dwyl.io/NovySoft/novyNaplo.svg)](http://hits.dwyl.io/NovySoft/novyNaplo)
[![Discord](https://img.shields.io/discord/340112709628592139.svg)](http://discord.gg/rmjC4d4)

Novy Csodálatos béta verzióban lévő teljesen nem eredeti kréta kliense.

**Jelenlegi funkciók:**
*  Jegyek megtekintése
*  Átlagok megtekintése
*  Feljegyzések megtekintése
*  Órarend megtekintése
*  Átlagok grafikonon való megtekintése
*  Jegy számoló - **[HUNCUT2016](https://github.com/huncut2016)** közreműködésével

**HAMAROSAN:**
*  ~~Feljegyzések~~
*  ~~Órarend~~
*  ~~Házifeladat~~
*  Hiányzások
*  ~~Grafikonok~~
*  Értesítések
*  ~~Jegy számoló - **[HUNCUT2016](https://github.com/huncut2016)** közreműködésével~~
*  Támogatók oldal - **Gáti Úr** közreműködésével
*  Szuper egyedi és egyéni beállítások (**Már most is** van sok, de több lesz)
*  **Wear OS** kompatibilitás (felthetőleg teljesen másik applikáció keretében)

## Modulok
*  **Flutter:** Evvel a frameworkkel készült az applikáció
*  **cupertino_icons**: Az ios ikonokért felel
*  **permission_handler**: A későbbiekben a jogokért fog felelni
*  **http**: Hálózati kérésekért felel
*  **flutter_launcher_icons**: Az applikáció ikonjáért felel
*  **shared_preferences**: Az adatok tárolásáért felelős
*  **english_words**: Véleltlen angol szavakat generál
*  **encrypt**: Az adatok titkosításáért felel
*  **connectivity**: Az internet elérhetőségét figyeli
*  **package_info**: Ennek a segítségével nézi meg az applikáció saját verzióját
*  **flutter_spinkit**: A kis homokóráért felelős
*  **diacritic**: A magyar betűk angol megfelelőit tárolja
*  **dynamic_theme**: A sötét és fehér téma közt vált
*  **charts_flutter**: A grafikonokat rajzolja ki
*  **firebase_crashlytics**: Applikáció összeomlás esetén jelenti a fontos összeonlási adatokat
*  **firebase_analytics**: Az applikáció használatáról jelent fontos adatokat (ki melyik gombot nyomja meg, milyen gyors az api válasz és egyebek)
*  **firebase_performance**: Az internet lekérések sebbeségét figyeli
*  **firebase_admob**: Alsó reklám csík megjelnítése
*  **admob_flutter**: Natív reklámok
*  **material_design_icons_flutter**: Ikon kiegészítő csomag
*  **background_fetch**: Háttér lekérések
*  **sqflite**: Kliens oldali sql (adattárolás)
*  **animations**: Animációk kezelése
*  **flutter_html**: Html objektumok megjelenítése (Házifeladat)

## Felhasznált kódok:
*  **Bejelentkezési oldal:** [https://github.com/putraxor/flutter-login-ui](https://github.com/putraxor/flutter-login-ui)
*  **Háttér logika, néhány design ötlet:** [https://github.com/boapps/Szivacs-Naplo](https://github.com/boapps/Szivacs-Naplo)
*  **Api lekérések:** [https://github.com/boapps/e-kreta-api-docs](https://github.com/boapps/e-kreta-api-docs)


## Betűtípusok
*  **Nunito**

## Ismert hibák
*  **A ticker was started twice.** jelenleg flutter framework hibának néz ki (Animációs framework)
*  **Lassú betöltés/leragadás a homokóránál** a lassú krétás válasz miatt történik (amennyiben nem, akkor hibakódot kell látnod)
*  **Hibás tanár/tantárgy név** az eredeti krétában van elírva a tanár/tantárgy neve, ez nem az applikáció hibája
*  **Tantárgy nézet bugos**, szétesnek és/vagy összekeverednek a tárgyak.
*  **Sárgával alá van húzva a szöveg** hibás animációk miatt van. (Már dolgozok rajta)