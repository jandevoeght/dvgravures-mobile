# Installatie DV Gravures Mobile v0.1.3

Volg deze volgorde exact.

## Stap 1 — eerst de web/API-update installeren

Download en installeer `dv_gravures_app_v06703.zip` op dezelfde manier als de andere DV Gravures webversies.

- Versie: **v0.6.7.3**
- Er is **geen SQL-update** nodig.
- De nieuwe API-file is `api/v1/photo.php`.
- De uploads-map wordt niet meegeleverd en mag niet verwijderd worden.

Na installatie kun je optioneel controleren:
`https://www.dvgravures.be/app/api/v1/index.php`

In de endpointlijst moet nu ook staan:
`GET /api/v1/photo.php?id={id}`

## Stap 2 — mobiele v0.1.3 naar GitHub uploaden

1. Pak `dv_gravures_mobile_v013.zip` uit.
2. Open GitHub.
3. Open repository `dvgravures-mobile`.
4. Klik **Add file -> Upload files**.
5. Sleep de **inhoud** van de uitgepakte v0.1.3-map naar GitHub.
6. Laat bestaande bestanden vervangen.
7. Commit rechtstreeks naar `main`.
8. Gebruik bijvoorbeeld committekst:
   `DV Gravures Mobile v0.1.3 - foto fixes en takenfilter`

Controleer daarna minimaal:
- `pubspec.yaml` bevat `version: 0.1.3+1`
- `codemagic.yaml` bevat `APP_VERSION: 0.1.3`
- `lib/api_client.dart` is gewijzigd
- `lib/order_detail_screen.dart` is gewijzigd
- `lib/home_screen.dart` is gewijzigd

## Stap 3 — nieuwe Codemagic-build

1. Open Codemagic.
2. Ga naar **Applications -> dvgravures-mobile**.
3. Zorg dat tab **codemagic.yaml** geselecteerd is.
4. Branch: **main**.
5. Klik één keer op refresh zodat Codemagic de laatste GitHub-commit leest.
6. Klik **Start new build**.
7. Kies:
   - Branch: `main`
   - Workflow: `DV Gravures iOS TestFlight`
8. Klik **Start new build**.
9. Wacht tot de build volledig klaar is.
10. Controleer:
   - Status `finished`
   - `IPA bouwen` groen
   - `.ipa` onder Artifacts
   - `Publishing` groen

Je hoeft GEEN Apple-certificaat, provisioning profile, Bundle ID of API-key opnieuw aan te maken.

## Stap 4 — TestFlight

1. Open **App Store Connect -> DV Gravures -> TestFlight**.
2. Wacht tot **Version 0.1.3** met de nieuwe build verschijnt.
3. Controleer dat de build bij **DV Gravures Testers** staat.
4. Indien niet: voeg de build aan die interne groep toe.
5. Open TestFlight op de iPhone.
6. Kies **Update** bij DV Gravures.

## Stap 5 — na installatie testen

Test in deze volgorde:

1. Login.
2. `Vandaag`: facturatietaken mogen hier niet meer staan.
3. `Taken`: facturatietaken mogen hier niet meer staan.
4. Open een opdracht met bestaande foto’s.
5. Controleer dat de echte foto’s zichtbaar worden.
6. Tik `Foto`.
7. Probeer eerst **Uit fotobibliotheek**.
8. Probeer daarna **Foto maken**.
9. Bij geweigerde rechten moet de app een melding tonen en NIET crashen.
10. Upload een testfoto en controleer in de desktopapp dat die in hetzelfde dossier verschijnt.

Als foto’s nog niet laden, noteer de tekst die in de fototegel staat en gebruik eventueel `Opnieuw`.
