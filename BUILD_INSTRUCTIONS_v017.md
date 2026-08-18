# DV Gravures Mobile v0.1.7 — Buildinstructies

Voor deze versie hoef je de desktop/webapp NIET opnieuw te installeren.

## 1. GitHub bijwerken

1. Pak `dv_gravures_mobile_v017.zip` uit.
2. Open GitHub -> repository `dvgravures-mobile`.
3. Kies `Add file -> Upload files`.
4. Upload de INHOUD van de uitgepakte map.
5. Laat bestaande bestanden vervangen.
6. Commit rechtstreeks naar `main`.
7. Committekst bijvoorbeeld:
   `DV Gravures Mobile v0.1.7 - camera preview en statuskleuren`

Controleer in GitHub:
- `pubspec.yaml` bevat `version: 0.1.7+1`
- `codemagic.yaml` bevat `APP_VERSION: 0.1.7`
- `lib/camera_capture_screen.dart` is gewijzigd
- `lib/home_screen.dart` is gewijzigd
- `lib/task_detail_screen.dart` is gewijzigd

## 2. Codemagic

1. Applications -> `dvgravures-mobile`.
2. Tab `codemagic.yaml`.
3. Branch `main`.
4. Klik refresh.
5. Klik `Start new build`.
6. Branch: `main`.
7. Workflow: `DV Gravures iOS TestFlight`.
8. Start build.

Controleer:
- Flutter packages ophalen groen
- Privacyrechten in definitieve IPA controleren groen
- IPA bouwen groen
- Publishing groen

## 3. TestFlight

1. App Store Connect -> DV Gravures -> TestFlight.
2. Wacht tot Version `0.1.7` met de nieuwe build verschijnt.
3. Controleer dat de build bij `DV Gravures Testers` staat.
4. Open TestFlight op je iPhone.
5. Kies `Update`.

## 4. Testen

1. Open `Foto -> Foto maken`.
2. De live camera-preview moet nu het scherm vullen zonder verticale vervorming.
3. Maak een foto; de uiteindelijke foto moet nog steeds correct zijn.
4. Open `Vandaag` en `Taken`.
5. Controleer de statuskleuren:
   - Actief = geel
   - Toekomstig = blauw
   - Geblokkeerd = grijs
   - Afgewerkt = groen
6. Open een taakdetail en controleer ook daar de gekleurde status.
