# permanente-Fahrzeuge

Ein FiveM Script zur dauerhaften Speicherung von Fahrzeugpositionen. Nach einem Serverneustart erscheinen Fahrzeuge genau dort wieder, wo sie abgestellt wurden – inklusive Lackierung, Tuning, Schaden und Besitzerdaten.

## Features

- ✅ Automatische Speicherung der Fahrzeugposition für alle Fahrzeuge in der `owned_vehicles` Datenbank
- ✅ Wiederherstellung der Fahrzeuge nach Server-Restart an der exakten Position
- ✅ **Automatisches Respawnen von gelöschten Fahrzeugen** (Neu in v1.1)
- ✅ Speicherung und Wiederherstellung von Fahrzeugschäden (Karosserie, Motor, Tank, Fenster, Türen, Reifen)
- ✅ Periodische Aktualisierung der Position (konfigurierbar)
- ✅ Keine Löschung von Fahrzeugen - sie bleiben persistent
- ✅ Kompatibel mit ESX und QBCore Frameworks

## Installation

1. **Ressource installieren**
   ```bash
   cd resources
   git clone https://github.com/janmueller97jml-cmd/permanente-Fahrzeuge.git
   ```

2. **Datenbank-Migration ausführen**
   
   Führe die SQL-Datei `sql/migration.sql` in deiner Datenbank aus. Dies fügt die notwendigen Spalten zur `owned_vehicles` Tabelle hinzu:
   - `parking_position` - JSON Daten für Position (x, y, z, heading)
   - `parking_damage` - JSON Daten für Fahrzeugschäden
   - `last_parked` - Zeitstempel der letzten Parkposition

3. **Ressource zur server.cfg hinzufügen**
   ```
   ensure permanente-Fahrzeuge
   ```

4. **Konfiguration anpassen** (optional)
   
   Bearbeite `config.lua` um die Einstellungen anzupassen:
   ```lua
   Config.SaveInterval = 300000  -- Speicherintervall in Millisekunden (Standard: 5 Minuten)
   Config.Debug = false          -- Debug-Modus für zusätzliche Logs
   ```

## Funktionsweise

### Automatische Position-Speicherung

Das Script prüft automatisch, ob ein Fahrzeug in der `owned_vehicles` Tabelle existiert. Wenn ja:
- Wird die Position alle X Minuten gespeichert (konfigurierbar über `Config.SaveInterval`)
- Wird die Position beim Verlassen des Fahrzeugs gespeichert
- Werden Schadensdaten mit gespeichert

### Wiederherstellung nach Restart

Beim Server-Start:
1. Lädt das Script alle Fahrzeuge aus `owned_vehicles` mit gespeicherter `parking_position`
2. Benachrichtigt alle verbundenen Clients, dass Fahrzeuge bereit zum Spawnen sind
3. Clients fordern die Fahrzeugliste an und spawnen die Fahrzeuge an ihrer letzten Position
4. Stellt den Schadenszustand wieder her

**Hinweis:** Das Script verwendet ein Retry-System, um sicherzustellen, dass Fahrzeuge auch dann korrekt spawnen, wenn Clients sich verbinden bevor der Server die Fahrzeuge aus der Datenbank geladen hat.

**Neu in v1.1:** Das System überwacht kontinuierlich alle gespawnten Fahrzeuge. Falls ein Fahrzeug durch andere Scripts, Game-Engine-Cleanup oder manuelle Löschung entfernt wird, wird es automatisch innerhalb von 5 Sekunden an seiner letzten gespeicherten Position respawnt. Dies stellt sicher, dass geparkte Fahrzeuge niemals verloren gehen, auch ohne Server-Neustart.

### Datenstruktur

**parking_position** (JSON):
```json
{
  "x": 123.45,
  "y": 234.56,
  "z": 30.5,
  "heading": 180.0
}
```

**parking_damage** (JSON):
```json
{
  "bodyHealth": 1000.0,
  "engineHealth": 1000.0,
  "tankHealth": 1000.0,
  "dirtLevel": 0.0,
  "windows": {},
  "doors": {},
  "tyres": {}
}
```

## Technische Details

### Server Events

- `permanente-fahrzeuge:saveVehiclePosition` - Speichert Fahrzeugposition in DB
- `permanente-fahrzeuge:requestVehicleSpawn` - Fordert Spawn eines geparkten Fahrzeugs an
- `permanente-fahrzeuge:requestParkedVehicles` - Fordert Liste aller geparkten Fahrzeuge an
- `permanente-fahrzeuge:vehicleSpawned` - Markiert Fahrzeug als gespawnt
- `permanente-fahrzeuge:removeVehicle` - Entfernt Fahrzeug aus Tracking

### Client Events

- `permanente-fahrzeuge:spawnVehicle` - Spawnt ein Fahrzeug mit Position und Schaden
- `permanente-fahrzeuge:receiveParkedVehicles` - Empfängt Liste der zu spawnenden Fahrzeuge
- `permanente-fahrzeuge:vehiclesReady` - Benachrichtigt Clients, dass Server Fahrzeuge geladen hat
- `permanente-fahrzeuge:vehiclesNotReady` - Signalisiert, dass Server noch nicht bereit ist (Client wird automatisch wiederholen)
- `permanente-fahrzeuge:removeVehicleFromTracking` - Entfernt ein Fahrzeug aus dem Client-Tracking (Neu in v1.1)

## Anforderungen

- FiveM Server
- MySQL Datenbank
- mysql-async Resource
- Existierende `owned_vehicles` Tabelle (ESX/QBCore)

## Kompatibilität

Das Script ist konzipiert für:
- ✅ ESX Framework
- ✅ QBCore Framework
- ✅ Andere Frameworks mit `owned_vehicles` Tabelle

## Debug-Modus

Aktiviere den Debug-Modus in `config.lua` für detaillierte Logs:
```lua
Config.Debug = true
```

Dies zeigt zusätzliche Informationen über:
- Gespeicherte Fahrzeugpositionen
- Gespawnte Fahrzeuge
- Tracking-Status

## Support

Bei Problemen oder Fragen, erstelle bitte ein Issue auf GitHub.

## Lizenz

Dieses Projekt ist Open Source.