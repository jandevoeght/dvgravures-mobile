# DV Gravures Mobile v0.1.4

## Wijzigingen
- bestaande foto-weergave uit v0.1.3 blijft behouden;
- facturatietaken blijven uit Vandaag/Open taken;
- iOS foto-picker is verder gehard:
  - korte wachttijd na sluiten van het keuzemenu voordat camera/fotobibliotheek opent;
  - `requestFullMetadata=false`;
  - achtercamera als voorkeurscamera;
  - extra iOS privacytekst voor microfoon;
  - Codemagic controleert tijdens de build expliciet of alle privacykeys in Info.plist aanwezig zijn.

Deze versie is bedoeld om de crash bij `Foto maken` / `Uit fotobibliotheek` verder uit te sluiten.

## Vereist
Gebruik samen met DV Gravures web/API **v0.6.7.4**.
