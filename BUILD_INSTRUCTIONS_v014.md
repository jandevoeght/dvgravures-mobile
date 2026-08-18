# Installatie DV Gravures v0.6.7.4 + Mobile v0.1.4

## 1. Desktop/webapp eerst bijwerken

Installeer `dv_gravures_app_v06704.zip`.

Geen SQL-update nodig.

Controleer daarna in de desktopapp:
- `Taken` bevat geen facturatietaken meer;
- taken van geannuleerde opdrachten staan niet meer in het algemene Taken-overzicht.

## 2. Mobiele broncode naar GitHub

1. Pak `dv_gravures_mobile_v014.zip` uit.
2. Open GitHub -> repository `dvgravures-mobile`.
3. `Add file -> Upload files`.
4. Upload de INHOUD van de uitgepakte map.
5. Bestaande bestanden mogen vervangen worden.
6. Commit rechtstreeks naar `main`.
7. Committekst bijvoorbeeld:
   `DV Gravures Mobile v0.1.4 - iOS foto crash fix`

Controleer:
- `pubspec.yaml` -> `version: 0.1.4+1`
- `codemagic.yaml` -> `APP_VERSION: 0.1.4`

## 3. Codemagic

1. Applications -> `dvgravures-mobile`.
2. Tab `codemagic.yaml`.
3. Branch `main`.
4. Refresh.
5. `Start new build`.
6. Branch `main`.
7. Workflow `DV Gravures iOS TestFlight`.
8. Start build.

Controleer dat ook de nieuwe buildstap
`iOS privacy-instellingen controleren`
groen wordt.

Daar moeten in de log vier privacyteksten worden afgedrukt:
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription
- NSMicrophoneUsageDescription

Daarna moeten `IPA bouwen` en `Publishing` groen zijn.

## 4. TestFlight

1. App Store Connect -> DV Gravures -> TestFlight.
2. Wacht op version `0.1.4`.
3. Controleer dat de nieuwe build bij `DV Gravures Testers` staat.
4. Open TestFlight op iPhone en kies `Update`.

## 5. Testvolgorde op iPhone

1. Open een opdracht met bestaande foto's -> die moeten nog steeds zichtbaar zijn.
2. Tik `Foto`.
3. Kies eerst `Uit fotobibliotheek`.
4. Als iOS toestemming vraagt: geef toegang.
5. Controleer of de app actief blijft en een foto kan uploaden.
6. Test daarna `Foto maken`.
7. Als een toestemming ontbreekt, moet de app een melding tonen in plaats van crashen.
8. Controleer de geüploade foto in de desktopapp.

Als de app nog steeds crasht, noteer dan exact:
- crasht hij bij tik op `Foto`;
- bij tik op `Uit fotobibliotheek`;
- bij tik op `Foto maken`;
- na selectie/opname van een foto.
Dat bepaalt de volgende technische stap.
