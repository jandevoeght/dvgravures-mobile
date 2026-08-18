# DV Gravures v0.6.8.1 + Mobile v0.2.1

1. Installeer eerst web/API `dv_gravures_app_v06801.zip`. Geen SQL-update.
2. Pak `dv_gravures_mobile_v021.zip` uit.
3. Upload de INHOUD naar GitHub repository `dvgravures-mobile` en vervang bestaande bestanden.
4. Commit naar `main`, bv. `Mobile v0.2.1 - administratieve besteltaken filteren`.
5. Controleer `pubspec.yaml`: `version: 0.2.1+1`.
6. Controleer `codemagic.yaml`: `APP_VERSION: 0.2.1`.
7. Codemagic -> refresh -> Start new build -> workflow `DV Gravures iOS TestFlight`.
8. Controleer dat privacycontrole, IPA build en Publishing groen zijn.
9. TestFlight -> update naar 0.2.1.
10. Test: `Bestellingen uitvoeren` mag niet voorkomen in Vandaag of Taken.
