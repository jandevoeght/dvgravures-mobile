# DV Gravures Mobile v0.1.3

## Belangrijk
Deze mobiele versie hoort samen met **DV Gravures web/API v0.6.7.3**.
Installeer eerst de web/API-update en bouw daarna de mobiele TestFlight-versie.

## Opgelost
- bestaande foto’s worden niet meer rechtstreeks uit `/uploads` geladen;
- de mobiele app haalt iedere foto beveiligd op via:
  `GET /api/v1/photo.php?id={photo_id}`;
- dezelfde Bearer-token/X-DV-API-Token authenticatie wordt daarbij gebruikt;
- duidelijke laadindicator en foutmelding per foto;
- knop `Opnieuw` wanneer een foto niet geladen kan worden;
- camera/fotobibliotheek-aanroep is volledig afgevangen met foutmeldingen;
- extra iOS-fotobibliotheektoestemming toegevoegd;
- facturatietaken (`admin_code=INVOICE`) worden niet meer getoond in `Vandaag` en `Open taken`;
- in een opdrachtdossier blijven alle taken wel zichtbaar voor de volledige context.

## Ongewijzigd
- vaste workflow blijft server-side;
- DV Gravures kleuren en logo blijven behouden;
- Bundle ID: `be.dvgravures.mobile`;
- API-basis: `https://www.dvgravures.be/app/api/v1`.
