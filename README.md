# DV Gravures Mobile v0.1.5

## Belangrijkste wijziging
`Foto maken` gebruikt niet langer de camera-functie van `image_picker`.

De app gebruikt nu het officiële Flutter `camera`-pakket met een eigen camerascherm:
- achtercamera standaard;
- live preview;
- aparte ontspanknop;
- audio uitgeschakeld;
- camera-fouten worden opgevangen in het scherm;
- na opname wordt hetzelfde bestaande uploadproces gebruikt.

`Uit fotobibliotheek` blijft via `image_picker` werken, omdat die route op het echte iPhone-toestel al correct werkte.

## Verder
- bestaande foto-weergave via de beveiligde API blijft behouden;
- facturatietaken blijven uit de mobiele operationele takenlijsten;
- huisstijl/logo blijven behouden.

Gebruik samen met DV Gravures webapp v0.6.7.5.
