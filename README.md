# DV Gravures Mobile v0.1.0

Eerste Flutter-bronversie voor de mobiele DV Gravures-app.

## Doel van v0.1
Deze versie koppelt rechtstreeks met:

`https://www.dvgravures.be/app/api/v1`

Beschikbaar:
- aanmelden met bestaande DV Gravures-gebruiker;
- Bearer-token veilig bewaren;
- Vandaag;
- Open taken;
- Opdrachten zoeken en openen;
- opdrachtdetail;
- taken in een dossier bekijken;
- foto's in een dossier bekijken;
- foto maken met iPhone/iPad-camera;
- foto uit fotobibliotheek kiezen;
- foto rechtstreeks naar het DV Gravures-dossier uploaden;
- Apple Maps openen voor een begraafplaats;
- handmatige taak afwerken;
- afmelden.

De vaste workflow blijft volledig server-side. De mobiele app probeert die niet opnieuw te implementeren.

## Belangrijk: dit ZIP-bestand is de Flutter-broncode
Er is nog geen ondertekende iPhone-app in dit bestand. Voor iOS moet dit project nog in een macOS/cloud-buildomgeving door Flutter/Xcode worden gegenereerd en ondertekend.

Een buildomgeving kan vanuit deze map eerst uitvoeren:

```bash
flutter create --platforms=ios,android .
flutter pub get
```

Daarna zijn de native iOS/Android-projectbestanden beschikbaar.

## iOS instellingen
Voeg na `flutter create` in `ios/Runner/Info.plist` minstens toe:

```xml
<key>NSCameraUsageDescription</key>
<string>DV Gravures gebruikt de camera om foto's rechtstreeks aan een opdracht toe te voegen.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DV Gravures gebruikt de fotobibliotheek om foto's aan een opdracht toe te voegen.</string>
```

De applicatie gebruikt uitsluitend HTTPS voor de DV Gravures API.

## Afhankelijkheden
- `http`
- `flutter_secure_storage`
- `image_picker`
- `url_launcher`

## Tokenbeveiliging
Het API-token wordt niet in gewone preferences opgeslagen maar via `flutter_secure_storage`, zodat op iOS de beveiligde opslag van het platform wordt gebruikt.

## Volgende stap
1. Broncode in een Git-repository/cloud-builder plaatsen.
2. iOS-project laten genereren.
3. Apple signing/App Store Connect instellen.
4. Eerste TestFlight-build maken.
5. Installeren op iPhone en iPad.
