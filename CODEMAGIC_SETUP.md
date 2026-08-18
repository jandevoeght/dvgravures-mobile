# Codemagic + TestFlight setup voor DV Gravures

Deze repository is voorbereid voor een handmatige eerste TestFlight-build via `codemagic.yaml`.

## Vaste waarden

- Workflow: `DV Gravures iOS TestFlight`
- Bundle ID: `be.dvgravures.mobile`
- Appnaam op iPhone/iPad: `DV Gravures`
- API: `https://www.dvgravures.be/app/api/v1`
- App-versie: `0.1.1`

## Belangrijk vóór de eerste build

### 1. App Store Connect API key maken

In App Store Connect:

`Users and Access -> Integrations -> App Store Connect API`

Maak een nieuwe **Team Key** met bij voorkeur de rol **App Manager**.

Bewaar:
- Issuer ID
- Key ID
- het `.p8`-bestand

De `.p8` private key kan door Apple maar één keer worden gedownload.

### 2. Apple Developer Portal koppelen met Codemagic

In Codemagic:

`Team settings -> Team integrations -> Developer Portal`

Voeg de Apple key toe en geef deze exact de naam:

`DV Gravures App Store Connect`

Die naam staat ook in `codemagic.yaml`.

### 3. Bundle ID registreren

Registreer bij Apple de Bundle ID:

`be.dvgravures.mobile`

### 4. App-record in App Store Connect maken

Maak in **My Apps** een nieuwe app:
- Platform: iOS
- Name: DV Gravures
- Bundle ID: `be.dvgravures.mobile`
- SKU: bijvoorbeeld `DVGRAVURES-MOBILE`

### 5. Signing in Codemagic

Codemagic moet voor `be.dvgravures.mobile` een **Apple Distribution** certificate en een **App Store provisioning profile** kunnen ophalen/gebruiken.

De YAML vraagt automatisch signingbestanden op met:
- distribution type: `app_store`
- bundle identifier: `be.dvgravures.mobile`

### 6. Eerste build

Open de app in Codemagic.

Omdat `codemagic.yaml` in de root staat, kies je de YAML-workflow:

`DV Gravures iOS TestFlight`

Start daarna handmatig de build op branch `main`.

De build:
1. haalt Flutter packages op;
2. genereert de `ios/` map indien die nog niet in GitHub staat;
3. zet de Bundle ID en iOS privacyteksten;
4. installeert CocoaPods;
5. past het signingprofiel toe;
6. bouwt een `.ipa`;
7. uploadt de `.ipa` naar App Store Connect/TestFlight.

## TestFlight

Deze eerste configuratie gebruikt:

`testFlightInternalTestingOnly`

Dat is bewust: de eerste DV Gravures-build is alleen bedoeld voor interne TestFlight-testing en hoeft daardoor niet naar externe beta-review.

Na verwerking door Apple kun je de build in App Store Connect aan een interne tester koppelen.

## iPhone/iPad

Op het toestel is alleen **TestFlight** nodig. Flutter en Xcode hoeven niet op het toestel te staan.
