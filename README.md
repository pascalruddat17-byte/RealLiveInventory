# RealLife Inventory

RealLife Inventory ist eine erste funktionsfähige Flutter-Version einer mobilen Inventar-App. Die App verwaltet echte Gegenstände, ordnet sie Räumen und Containern zu, zeigt sie in einer einfachen 3D-Raumansicht und hilft beim Wiederfinden über eine lokale, gewichtete Suche.

## Features

- Moderne Startseite mit Statistiken, Schnellaktionen und Demo-Daten
- Gegenstände mit erweiterbarem Datenmodell
- Container-System mit verschachtelten Gegenständen und Schutz vor Endlosschleifen
- Mock-Scan-Workflow mit austauschbarem `ItemRecognitionService`
- Mock-Raumscan mit austauschbarem `RoomScanService`
- Einfache 3D-Raumansicht mit Boden, Wänden, Zoom, Auswahl und Platzierung
- Primitive Modelle: Box, Kugel, Quader und Zylinder
- Lokale Suche mit Normalisierung, Teiltreffern, Fuzzy Matching und Ranking
- Suchergebnisse werden im Raum hervorgehoben
- Besitzstatus inklusive verkauft, verschenkt, verloren, kaputt und entsorgt
- Historie mit Verkaufs-/Verschenkungsdaten und Statistiken
- Lokale Offline-Speicherung über SQLite/Sqflite hinter einem Repository-Interface
- Dark Mode und touchfreundliche UI

## Screenshots

Platzhalter fuer Screenshots:

- `docs/screenshots/home.png`
- `docs/screenshots/room.png`
- `docs/screenshots/search.png`

## Voraussetzungen

- Flutter SDK 3.22 oder neuer
- Dart SDK, normalerweise im Flutter SDK enthalten
- Git
- Android Studio oder Xcode, falls auf Emulatoren oder echten Geräten getestet wird

Diese Umgebung hatte Flutter nicht installiert. Der Quellcode ist vorbereitet; mit installiertem Flutter kann das Projekt direkt eingerichtet und gestartet werden.

## Installation

```bash
cd RealLifeInventory
flutter pub get
```

Falls Android-/iOS-Projektdateien fehlen, weil das Projekt ohne lokale Flutter-Installation erstellt wurde:

```bash
flutter create .
flutter pub get
```

`flutter create .` ergänzt die nativen Plattformordner, ohne die vorhandene App-Logik in `lib/` und `test/` zu ersetzen.

## Projekt starten

```bash
flutter run
```

## Tests

```bash
dart format .
flutter analyze
flutter test
```

## Projektstruktur

```text
lib/
  core/          App-weite Controller, Theme und Enums
  models/        Datenmodelle fuer Items, Räume, Positionen und Historie
  services/      Scan- und Recognition-Abstraktionen mit Mock-Implementierungen
  repositories/  Persistenz-Abstraktion, SQLite-Repository und JSON-Fallback
  database/      Demo-Daten und lokale Speicher-Seed-Logik
  features/      Screens fuer Home, Scan, Suche, Raum und Historie
  widgets/       Wiederverwendbare UI-Bausteine
  three_d/       Einfache Raumdarstellung und Objektzeichnung
test/            Modell-, Such-, Container-, Besitzstatus- und Repository-Tests
```

## Aktueller Stand

V1 ist als lokale, offline nutzbare App umgesetzt. Die 3D-Ansicht ist eine leichte Flutter-Raumdarstellung statt einer nativen AR/3D-Engine. Die Datenbank ist SQLite/Sqflite hinter einem Repository-Interface, damit später Drift, Indizes für größere Datenmengen oder Cloud-Sync angeschlossen werden können.

## Noch nicht implementierte Funktionen

- Echte KI-Bilderkennung
- ARCore-/ARKit-/LiDAR-Raumscan
- Import eigener 3D-Modelle
- Cloud-Synchronisierung
- Plattformordner, falls Flutter in der Erstellungsumgebung nicht installiert war

## Geplante Features fuer Version 2

- Drift/SQLite als produktive lokale Datenbank
- ARCore/ARKit-Adapter fuer echte Raumscans
- Bildbasierte Item-Erkennung mit lokalem Modell oder optionalem API-Adapter
- Mehrbenutzer- und Cloud-Sync
- Export/Backup der Inventardaten
- Präzisere 3D-Manipulation mit Gesten und Objekt-Gizmos

## GitHub

Der Ordner ist als Git-Projekt vorbereitet. In GitHub Desktop:

1. `File`
2. `Add local repository`
3. Ordner `RealLifeInventory` auswählen
4. `Publish repository`

Die `.gitignore` verhindert, dass Build-Ordner, IDE-Caches, lokale Daten, Logs oder Secrets versioniert werden.
