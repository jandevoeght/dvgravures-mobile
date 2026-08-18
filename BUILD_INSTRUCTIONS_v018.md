# DV Gravures v0.6.7.7 + Mobile v0.1.8

## 1. Eerst web/API v0.6.7.7 installeren
Geen SQL-update nodig.

Dit is nodig omdat `api/v1/tasks.php` facturatietaken nu server-side uitsluit.

## 2. Mobile v0.1.8 naar GitHub
1. Pak `dv_gravures_mobile_v018.zip` uit.
2. GitHub -> `dvgravures-mobile`.
3. `Add file -> Upload files`.
4. Upload de INHOUD van de map.
5. Bestaande bestanden vervangen.
6. Commit naar `main`.
7. Committekst:
   `DV Gravures Mobile v0.1.8 - takenfilter en tegelkleuren`

Controleer:
- pubspec `version: 0.1.8+1`
- codemagic `APP_VERSION: 0.1.8`

## 3. Codemagic
Applications -> dvgravures-mobile -> codemagic.yaml -> main -> refresh -> Start new build.
Workflow: `DV Gravures iOS TestFlight`.

Controleer dat:
- Privacyrechten in definitieve IPA controleren groen is;
- IPA bouwen groen is;
- Publishing groen is.

## 4. TestFlight
Wacht tot 0.1.8 verschijnt, controleer groep `DV Gravures Testers`, update op iPhone.

## 5. Testen
- Vandaag/Taken: geen facturatietaken.
- Volledige taaktegel is gekleurd:
  - actief geel;
  - toekomstig blauw;
  - geblokkeerd grijs;
  - afgewerkt groen.
- Camera-preview blijft correct.
