# DV Gravures Mobile v0.1.2 — Buildinstructies

## A. GitHub bijwerken

1. Pak `dv_gravures_mobile_v012.zip` uit op je Windows-pc.
2. Open GitHub en repository `dvgravures-mobile`.
3. Kies `Add file` -> `Upload files`.
4. Sleep de INHOUD van de uitgepakte v0.1.2-map naar GitHub.
5. Bestaande bestanden mogen vervangen worden.
6. Controleer dat minstens deze wijzigingen aanwezig zijn:
   - `assets/logo.png`
   - `lib/api_client.dart`
   - `lib/order_detail_screen.dart`
   - `lib/login_screen.dart`
   - `lib/home_screen.dart`
   - `lib/theme.dart`
   - `pubspec.yaml`
   - `codemagic.yaml`
7. Commit rechtstreeks naar branch `main`.
8. Commit message:
   `DV Gravures Mobile v0.1.2 - foto's en huisstijl`

## B. Nieuwe Codemagic-build

1. Open Codemagic.
2. `Applications` -> `dvgravures-mobile`.
3. Controleer dat tab `codemagic.yaml` actief is.
4. Branch moet `main` zijn.
5. Klik eventueel eenmaal op refresh zodat de laatste GitHub-commit wordt gelezen.
6. Klik `Start new build`.
7. Kies:
   - Branch: `main`
   - Workflow: `DV Gravures iOS TestFlight`
8. Klik `Start new build`.
9. Wacht tot alle stappen groen zijn en `Status: finished` verschijnt.
10. Controleer dat een `.ipa` artifact is aangemaakt en `Publishing` geslaagd is.

De Apple Distribution certificate en het provisioning profile hoeven NIET opnieuw aangemaakt te worden.

## C. TestFlight

1. Open App Store Connect.
2. `Apps` -> `DV Gravures` -> `TestFlight`.
3. Wacht tot de nieuwe versie/build verwerkt is.
4. De nieuwe build gebruikt automatisch een hoger Codemagic buildnummer.
5. Omdat v0.1.2 `ITSAppUsesNonExemptEncryption=false` toevoegt, zou `Missing Compliance` normaal niet opnieuw gevraagd moeten worden.
6. Open interne groep `DV Gravures Testers`.
7. Voeg de nieuwe build aan de groep toe als dit niet automatisch gebeurt.
8. Open TestFlight op de iPhone.
9. Kies `Update` bij DV Gravures.

## D. Na installatie testen

Controleer in deze volgorde:
1. Login.
2. Vandaag / Taken / Opdrachten.
3. Open een opdracht met bestaande foto's.
4. Controleer dat de foto's zichtbaar zijn.
5. Maak eventueel een testfoto en upload die via de knop `Foto`.
6. Controleer in de desktopapp dat de geüploade foto in hetzelfde dossier staat.
