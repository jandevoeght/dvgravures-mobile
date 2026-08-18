# Installatie DV Gravures v0.6.7.5 + Mobile v0.1.5

Volg deze volgorde.

## 1. Desktop/webapp v0.6.7.5 installeren

Installeer `dv_gravures_app_v06705.zip`.

Geen SQL-update nodig.

Controleer daarna:
- algemeen `Taken`: geen facturatietaken;
- `Agenda & Planning`: geen facturatietaken in kalender of backlog;
- taken van geannuleerde opdrachten staan niet in de operationele planning.

## 2. Mobile v0.1.5 naar GitHub

1. Pak `dv_gravures_mobile_v015.zip` uit.
2. GitHub -> repository `dvgravures-mobile`.
3. `Add file -> Upload files`.
4. Upload de INHOUD van de uitgepakte map.
5. Bestaande bestanden mogen vervangen worden.
6. Belangrijk nieuw bestand:
   `lib/camera_capture_screen.dart`
7. Commit rechtstreeks naar `main`.
8. Committekst bijvoorbeeld:
   `DV Gravures Mobile v0.1.5 - eigen iOS camera`

Controleer:
- `pubspec.yaml` -> `version: 0.1.5+1`
- `pubspec.yaml` bevat `camera: ^0.12.0+1`
- `codemagic.yaml` -> `APP_VERSION: 0.1.5`
- `lib/camera_capture_screen.dart` bestaat

## 3. Codemagic

1. Applications -> `dvgravures-mobile`.
2. Tab `codemagic.yaml`.
3. Branch `main`.
4. Refresh.
5. `Start new build`.
6. Branch `main`.
7. Workflow `DV Gravures iOS TestFlight`.
8. Start build.

Controleer:
- Flutter packages ophalen groen;
- iOS privacy-instellingen controleren groen;
- Pods installeren groen;
- IPA bouwen groen;
- Publishing groen.

Je hoeft GEEN Apple-certificaten, provisioning profiles, Bundle ID of API-key opnieuw te maken.

## 4. TestFlight

1. App Store Connect -> DV Gravures -> TestFlight.
2. Wacht tot version `0.1.5` verschijnt met de nieuwe build.
3. Controleer dat de build bij `DV Gravures Testers` staat.
4. Open TestFlight op iPhone -> `Update`.

## 5. Testen op iPhone

1. Open een opdracht.
2. Controleer bestaande foto's.
3. `Foto -> Uit fotobibliotheek` moet blijven werken.
4. `Foto -> Foto maken`.
5. Er moet nu een eigen DV Gravures camerascherm openen met live preview.
6. Tik op de ronde camera-knop.
7. Na opname wordt de foto geüpload.
8. Controleer de foto in de mobiele app én desktopapp.

Als de camera niet opent, zou de app nu niet mogen crashen maar een fouttekst in het camerascherm tonen. Noteer die tekst exact.
