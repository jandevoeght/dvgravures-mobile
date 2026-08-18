# DV Gravures Mobile v0.1.6 — Buildinstructies

Voor deze correctie hoef je de desktop/webapp NIET opnieuw te installeren.

## 1. GitHub

1. Pak `dv_gravures_mobile_v016.zip` uit.
2. Open GitHub -> repository `dvgravures-mobile`.
3. `Add file -> Upload files`.
4. Upload de INHOUD van de uitgepakte map.
5. Laat bestaande bestanden vervangen.
6. Commit rechtstreeks naar `main`.
7. Committekst bijvoorbeeld:
   `DV Gravures Mobile v0.1.6 - iOS camera privacy fix`

Controleer in GitHub:
- `pubspec.yaml` bevat `version: 0.1.6+1`
- `pubspec.yaml` bevat `camera: ^0.12.0+2`
- `codemagic.yaml` bevat `APP_VERSION: 0.1.6`

## 2. Codemagic

1. Applications -> `dvgravures-mobile`.
2. Tab `codemagic.yaml`.
3. Branch `main`.
4. Klik refresh.
5. Klik `Start new build`.
6. Branch: `main`.
7. Workflow: `DV Gravures iOS TestFlight`.
8. Start build.

Let deze keer vooral op de nieuwe stap:

`Privacyrechten in definitieve IPA controleren`

Die MOET groen zijn.

In de log van die stap moet letterlijk een tekst verschijnen onder:
- `NSCameraUsageDescription in definitieve app`
- `NSMicrophoneUsageDescription in definitieve app`
- `NSPhotoLibraryUsageDescription in definitieve app`

Pas daarna mag `Publishing` uitgevoerd worden.

## 3. App Store Connect

1. Open DV Gravures -> TestFlight.
2. Kijk onder `Build Uploads`.
3. De nieuwe upload moet `0.1.6` zijn en uiteindelijk `Complete` worden.
4. Als Apple opnieuw `Failed` toont, open de fout en stuur de fouttekst door.
5. Als de upload Complete is, wacht tot Version 0.1.6 onder iOS Builds verschijnt.
6. Controleer dat de build aan `DV Gravures Testers` gekoppeld is.

## 4. iPhone

1. Open TestFlight.
2. Update DV Gravures naar 0.1.6.
3. Open een opdracht.
4. `Foto -> Uit fotobibliotheek` moet blijven werken.
5. `Foto -> Foto maken`.
6. Nu moet het eigen DV Gravures-camerascherm openen.
7. Maak een foto en controleer de upload.
