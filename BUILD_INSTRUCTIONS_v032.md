# DV Gravures Mobile v0.3.2

Deze mobiele update vereist nog steeds server/API **DV Gravures v0.6.8.12**. Er is geen nieuwe SQL-update nodig ten opzichte van Mobile v0.3.1.

## Installatie en build

1. Pak `dv_gravures_mobile_v032.zip` lokaal uit.
2. Vervang de bestanden in GitHub-repository `dvgravures-mobile` door de inhoud van het pakket.
3. Commit naar branch `main`, bijvoorbeeld: `Mobile v0.3.2 - groeperen per taaktype`.
4. Controleer `version: 0.3.2+1` in `pubspec.yaml` en `APP_VERSION: 0.3.2` in `codemagic.yaml`.
5. Synchroniseer het project in Codemagic.
6. Start workflow **DV Gravures iOS TestFlight** op branch `main`.
7. Werk de app na verwerking bij via TestFlight.

## Praktijktest

1. Open het tabblad **Taken**.
2. Kies **Groeperen → Per taaktype**.
3. Controleer dat gelijknamige taken samen staan en het aantal per groep zichtbaar is.
4. Controleer ook de bestaande keuzes **Per begraafplaats** en **Per datum**.
