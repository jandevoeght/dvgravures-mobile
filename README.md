# DV Gravures Mobile v0.1.2

Tweede TestFlight-versie van de mobiele DV Gravures-app.

## Nieuw in v0.1.2
- foto-URL's uit de PHP API worden nu correct omgezet naar volledige HTTPS-URL's;
- foto's in bestaande opdrachtdossiers kunnen daardoor op iPhone/iPad geladen worden;
- kleuren zijn afgestemd op de desktopapp:
  - donkerblauw `#123F78`
  - middenblauw `#236FB8`
  - accentblauw `#2F7FE5`
  - lichtblauwe achtergrond `#EEF6FF`
- het bestaande DV Gravures-logo uit de desktopapp is toegevoegd;
- logo zichtbaar op login en in de hoofdnavigatie;
- TestFlight export-compliance wordt via `ITSAppUsesNonExemptEncryption=false` in de iOS Info.plist vastgelegd.

## API
`https://www.dvgravures.be/app/api/v1`

## Build
Bundle ID: `be.dvgravures.mobile`

Codemagic workflow:
`DV Gravures iOS TestFlight`
