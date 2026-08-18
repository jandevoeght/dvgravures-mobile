# DV Gravures Mobile v0.1.6

## Correctie na App Store Connect validatiefout 90683

Apple weigerde v0.1.5 omdat `NSCameraUsageDescription` niet in de
uiteindelijke `Runner.app/Info.plist` aanwezig was.

v0.1.6:
- gebruikt camera package `0.12.0+2`;
- genereert eerst de iOS releaseconfiguratie;
- schrijft daarna de privacykeys via Python `plistlib` rechtstreeks naar
  `ios/Runner/Info.plist`;
- vereist Camera én Microphone purpose strings zoals de officiële Flutter
  camera-plugin documentatie voorschrijft;
- controleert na het maken van de IPA opnieuw de `Info.plist` in
  `Payload/Runner.app`;
- Codemagic faalt vóór Publishing als de vereiste camerakey ontbreekt.

De eigen DV Gravures-camera uit v0.1.5 blijft behouden.
