# DV Gravures v0.6.8.12 + Mobile v0.3.1

## A. Eerst server en database bijwerken

1. Maak een backup van de database en de bestaande web/app-bestanden.
2. Voer `sql/upgrade_v06812.sql` uit.
3. Upload de inhoud van `dv_gravures_app_v06812.zip` over de bestaande DV Gravures app-map.
4. Laat de bestaande `uploads`-map altijd staan; ze zit niet in het releasepakket.
5. Open Planning, kies een medewerker en versleep de begraafplaatskoppen binnen een dag.

## B. Mobile v0.3.1 naar GitHub

1. Pak `dv_gravures_mobile_v031.zip` lokaal uit.
2. Vervang de bestanden in repository `dvgravures-mobile` door de inhoud van het pakket.
3. Commit naar branch `main`, bijvoorbeeld: `Mobile v0.3.1 - gedeelde dagroute`.
4. Controleer `version: 0.3.1+1` in `pubspec.yaml` en `APP_VERSION: 0.3.1` in `codemagic.yaml`.

## C. Build en TestFlight

1. Synchroniseer het project in Codemagic.
2. Start workflow **DV Gravures iOS TestFlight** op branch `main`.
3. Wacht tot de build en publicatie naar App Store Connect groen zijn.
4. Werk DV Gravures bij via TestFlight op iPhone/iPad.

## D. Praktijktest

1. Zet op desktop voor één medewerker minstens drie begraafplaatsen op dezelfde datum.
2. Versleep de begraafplaatsen naar een herkenbare volgorde.
3. Open of vernieuw die datum in de mobiele app.
4. Controleer dat mobiel exact dezelfde volgorde toont.
5. Voeg een nieuwe begraafplaats aan de dag toe: ze verschijnt onder de reeds ingestelde route en vóór `Zonder begraafplaats`.
