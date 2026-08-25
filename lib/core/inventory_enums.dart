enum ItemCondition {
  newItem('Neu'),
  veryGood('Sehr gut'),
  good('Gut'),
  used('Gebraucht'),
  damaged('Beschädigt');

  const ItemCondition(this.label);
  final String label;
}

enum OwnershipStatus {
  owned('Im Besitz'),
  sold('Verkauft'),
  gifted('Verschenkt'),
  lost('Verloren'),
  broken('Kaputt'),
  disposed('Entsorgt'),
  other('Sonstiges');

  const OwnershipStatus(this.label);
  final String label;

  bool get isOwned => this == OwnershipStatus.owned;
}

enum PrimitiveModel {
  box('Box'),
  cube('Quader'),
  sphere('Kugel'),
  cylinder('Zylinder');

  const PrimitiveModel(this.label);
  final String label;
}

enum ScanStep {
  start('Gegenstand hinzufügen'),
  camera('Kamera/Scan'),
  recognize('Gegenstand erkennen'),
  edit('Daten bearbeiten'),
  saved('Speichern');

  const ScanStep(this.label);
  final String label;
}
