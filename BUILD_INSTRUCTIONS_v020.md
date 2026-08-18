# DV Gravures v0.6.8.0 + Mobile v0.2.0

## 1. Eerst web/API v0.6.8.0
Installeer `dv_gravures_app_v06800.zip`.
Geen SQL-update nodig.

## 2. Mobile v0.2.0 naar GitHub
1. Pak `dv_gravures_mobile_v020.zip` uit.
2. Open GitHub -> `dvgravures-mobile`.
3. Add file -> Upload files.
4. Upload de INHOUD van de uitgepakte map.
5. Laat bestaande bestanden vervangen.
6. Commit naar `main`.
7. Committekst: `DV Gravures Mobile v0.2.0 - werfversie`

Controleer:
- pubspec.yaml: `version: 0.2.0+1`
- codemagic.yaml: `APP_VERSION: 0.2.0`

## 3. Codemagic
Applications -> dvgravures-mobile -> codemagic.yaml -> main -> refresh -> Start new build.
Workflow: `DV Gravures iOS TestFlight`.

Controleer dat Privacyrechten in definitieve IPA, IPA bouwen en Publishing groen zijn.

## 4. TestFlight
Wacht op Version 0.2.0, koppel indien nodig aan `DV Gravures Testers`, update op iPhone.

## 5. Belangrijkste tests
- taak die desktop op vandaag gepland is staat onder Vandaag;
- Vandaag toont aantal taken en begraafplaatsen;
- facturatietaken ontbreken;
- taakdetail toont geen adres van begraafplaats;
- Navigeren werkt wel;
- notitie toevoegen/wijzigen werkt;
- taak afwerken werkt voor handmatige taken;
- opdracht zoeken werkt;
- foto's openen/zoomen/omschrijving/verwijderen werkt;
- camera blijft correct schermvullend werken.
