# DV Gravures v0.6.7.9 + Mobile v0.1.9

## 1. Eerst web/API v0.6.7.9 installeren
Geen SQL-update nodig.

Deze update:
- laat `Vandaag` ook kijken naar `planned_date`;
- voegt beveiligde mobiele fotoacties toe.

## 2. Mobile v0.1.9 naar GitHub
1. Pak `dv_gravures_mobile_v019.zip` uit.
2. GitHub -> `dvgravures-mobile`.
3. `Add file -> Upload files`.
4. Upload de INHOUD van de uitgepakte map.
5. Laat bestaande bestanden vervangen.
6. Commit naar `main`.
7. Committekst bijvoorbeeld:
   `DV Gravures Mobile v0.1.9 - vandaag taakdetail fotoacties`

Controleer:
- `pubspec.yaml`: `version: 0.1.9+1`
- `codemagic.yaml`: `APP_VERSION: 0.1.9`

## 3. Codemagic
Applications -> dvgravures-mobile -> codemagic.yaml -> main -> refresh -> Start new build.
Workflow: `DV Gravures iOS TestFlight`.

Controleer:
- Privacyrechten in definitieve IPA controleren groen;
- IPA bouwen groen;
- Publishing groen.

## 4. TestFlight
Wacht op Version 0.1.9, controleer groep `DV Gravures Testers`, update op iPhone.

## 5. Testen
1. Maak in desktop Agenda & Planning een taak met geplande datum vandaag.
2. Refresh de mobiele tab `Vandaag`: taak moet zichtbaar zijn.
3. Open taakdetail en controleer extra informatie.
4. Open opdrachtdossier -> Foto’s.
5. Tik foto: schermvullend + zoomen.
6. Lang indrukken: acties verschijnen.
7. Pas omschrijving aan en controleer resultaat.
8. Verwijder eventueel een testfoto en controleer dat ze uit het dossier verdwijnt.
