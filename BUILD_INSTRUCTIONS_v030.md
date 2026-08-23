# DV Gravures v0.6.8.11 + Mobile v0.3.0

## A. Eerst de server/API bijwerken
1. Maak voor de zekerheid een backup van de huidige web/app-bestanden.
2. Upload de **inhoud** van `dv_gravures_app_v06811.zip` over de bestaande DV Gravures app-map op one.com.
3. Laat de bestaande `uploads`-map altijd staan; deze zit niet in het releasepakket.
4. Er is **geen SQL-update** nodig.
5. Meld één keer aan op de desktopapp en controleer dat Opdrachten en Planning nog openen.
6. De knop `Historiek importeren` hoort niet meer zichtbaar te zijn.

## B. Mobile v0.3.0 naar GitHub
1. Pak `dv_gravures_mobile_v030.zip` lokaal uit.
2. Open GitHub repository `dvgravures-mobile`.
3. Vervang de bestaande repositorybestanden door de **inhoud** van de uitgepakte map.
4. Commit naar branch `main`, bijvoorbeeld:
   `Mobile v0.3.0 - dagplanning en fotogalerij`
5. Controleer in GitHub:
   - `pubspec.yaml` bevat `version: 0.3.0+1`
   - `codemagic.yaml` bevat `APP_VERSION: 0.3.0`

## C. Build in Codemagic
1. Open Codemagic en kies project `dvgravures-mobile`.
2. Refresh/synchroniseer de repository zodat de nieuwe commit zichtbaar is.
3. Kies **Start new build**.
4. Workflow: `DV Gravures iOS TestFlight`.
5. Branch: `main`.
6. Start de build.
7. Controleer dat deze stappen groen worden:
   - Flutter packages
   - iOS-project/configuratie
   - Privacyrechten
   - Pods
   - Code signing
   - IPA bouwen
   - Privacycontrole definitieve IPA
   - Publishing naar App Store Connect

Codemagic gebruikt `${BUILD_NUMBER}` als iOS-buildnummer. Je hoeft dus niet zelf een nieuw buildnummer in `pubspec.yaml` te verzinnen voor iedere TestFlight-build.

## D. App Store Connect / TestFlight
1. Open App Store Connect.
2. Ga naar **Mijn apps → DV Gravures → TestFlight**.
3. Wacht tot versie **0.3.0** met de nieuwe build verwerkt is. Dit kan enkele minuten duren.
4. Voeg de build indien nodig toe aan je interne TestFlight-groep.
5. Open TestFlight op de iPhone/iPad en tik **Werk bij** bij DV Gravures.

## E. Korte praktijktest
1. Start de app: bovenaan moet `DV Gravures` en `Mobile v0.3.0` staan.
2. Open Vandaag en controleer de taken van vandaag.
3. Swipe naar gisteren en morgen; test ook de pijltjes.
4. Tik op de datum en kies een andere dag.
5. Test `Groeperen` per begraafplaats.
6. Open een taak en controleer opdrachtomschrijving/gravuregegevens en navigatie.
7. Open een opdracht met meerdere foto's.
8. Open foto 2 en swipe naar foto 1/3; test ook de pijltjes.
9. Pas het commentaar van één foto aan.
10. Maak een testfoto en controleer daarna op desktop of de foto aanwezig is.
