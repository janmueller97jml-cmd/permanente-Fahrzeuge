# Installation Guide

## Schritt-für-Schritt Anleitung

### 1. Voraussetzungen prüfen

Stelle sicher, dass dein Server folgende Anforderungen erfüllt:
- FiveM Server (empfohlen: neueste Version)
- MySQL Datenbank
- `mysql-async` Resource (oder `oxmysql` mit entsprechender Anpassung)
- ESX oder QBCore Framework (oder eine eigene `owned_vehicles` Tabelle)

### 2. Resource herunterladen

```bash
cd /pfad/zu/deinem/server/resources
git clone https://github.com/janmueller97jml-cmd/permanente-Fahrzeuge.git
```

### 3. Datenbank konfigurieren

Führe die SQL-Migration aus:

```sql
-- Öffne die Datei sql/migration.sql in deinem MySQL-Client
-- oder führe sie direkt aus:
source /pfad/zu/permanente-Fahrzeuge/sql/migration.sql
```

Diese fügt folgende Spalten zur `owned_vehicles` Tabelle hinzu:
- `parking_position` - Speichert die Position des Fahrzeugs (JSON)
- `parking_damage` - Speichert den Schadenszustand (JSON)
- `last_parked` - Zeitstempel der letzten Speicherung

### 4. Resource zur server.cfg hinzufügen

Öffne deine `server.cfg` und füge hinzu:

```cfg
ensure permanente-Fahrzeuge
```

**Wichtig:** Stelle sicher, dass die Resource **nach** mysql-async und **nach** deinem Framework (ESX/QBCore) geladen wird:

```cfg
ensure mysql-async
ensure es_extended  # oder qb-core
ensure permanente-Fahrzeuge
```

### 5. Konfiguration anpassen (optional)

Bearbeite `config.lua` nach deinen Wünschen:

```lua
Config = {}

-- Speicherintervall in Millisekunden
-- Standard: 300000 (5 Minuten)
-- Empfohlen: 180000-600000 (3-10 Minuten)
Config.SaveInterval = 300000

-- Debug-Modus für detaillierte Logs
-- Standard: false
-- Setze auf true für Fehlersuche
Config.Debug = false

-- Name der Datenbank-Tabelle
-- Standard: 'owned_vehicles'
Config.OwnedVehiclesTable = 'owned_vehicles'
```

### 6. Server neu starten

```bash
# Starte deinen FiveM Server neu
# oder reloade die Resource:
restart permanente-Fahrzeuge
```

### 7. Testen

1. Starte deinen FiveM Client
2. Spawne ein Fahrzeug, das in der `owned_vehicles` Tabelle eingetragen ist
3. Fahre zu einer bestimmten Position
4. Warte 5 Minuten oder verlasse das Fahrzeug
5. Prüfe die Datenbank - die `parking_position` Spalte sollte jetzt Daten enthalten:
   ```sql
   SELECT plate, parking_position FROM owned_vehicles WHERE parking_position IS NOT NULL;
   ```
6. Starte den Server neu
7. Das Fahrzeug sollte an der gespeicherten Position wieder erscheinen

## Fehlerbehebung

### Fahrzeuge werden nicht gespeichert

- Prüfe, ob die `owned_vehicles` Tabelle die neuen Spalten hat
- Aktiviere Debug-Modus (`Config.Debug = true`) und prüfe die Logs
- Stelle sicher, dass mysql-async korrekt funktioniert

### Fahrzeuge spawnen nicht nach Restart

- Prüfe die Server-Logs auf Fehler
- Stelle sicher, dass die Resource nach dem Framework geladen wird
- Aktiviere Debug-Modus und prüfe, ob Fahrzeuge geladen werden

### Fehler: "table owned_vehicles doesn't exist"

- Stelle sicher, dass dein Framework die `owned_vehicles` Tabelle verwendet
- Bei anderen Tabellennamen: Passe `Config.OwnedVehiclesTable` an

### Performance-Probleme

- Erhöhe `Config.SaveInterval` auf einen höheren Wert (z.B. 600000 für 10 Minuten)
- Bei sehr vielen Fahrzeugen: Überlege, ein Limit für gespeicherte Fahrzeuge einzuführen

## Erweiterte Konfiguration

### Anpassung für andere Frameworks

Wenn du ein anderes Framework verwendest, das eine andere Tabelle nutzt:

1. Passe `Config.OwnedVehiclesTable` in `config.lua` an
2. Stelle sicher, dass die Tabelle eine `plate` Spalte hat
3. Führe die Migration entsprechend an

### Verwendung mit oxmysql

Wenn du `oxmysql` statt `mysql-async` verwendest, ändere in `fxmanifest.lua`:

```lua
server_scripts {
    '@oxmysql/lib/MySQL.lua',  -- Geändert von mysql-async
    'config.lua',
    'server/main.lua'
}
```

Und passe die Server-Queries entsprechend an (oxmysql verwendet eine ähnliche API).

## Support

Bei Problemen:
1. Aktiviere Debug-Modus
2. Prüfe Server- und Client-Logs
3. Erstelle ein Issue auf GitHub mit:
   - Server-Version
   - Framework (ESX/QBCore)
   - Fehlermeldungen
   - Logs (mit Debug-Modus)
