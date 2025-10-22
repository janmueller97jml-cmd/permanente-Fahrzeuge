# Quick Start Guide

Schnelleinstieg für das permanente-Fahrzeuge System.

## In 5 Minuten einsatzbereit

### 1. Installation (2 Minuten)
```bash
cd /pfad/zu/server/resources
git clone https://github.com/janmueller97jml-cmd/permanente-Fahrzeuge.git
```

### 2. Datenbank (1 Minute)
Führe `sql/migration.sql` in deiner MySQL-Datenbank aus.

### 3. Server Config (1 Minute)
Füge zur `server.cfg` hinzu:
```
ensure permanente-Fahrzeuge
```

### 4. Restart (1 Minute)
Starte deinen FiveM Server neu.

## Fertig! ✅

Das System funktioniert jetzt automatisch:
- Fahrzeuge in `owned_vehicles` werden alle 5 Minuten gespeichert
- Nach Server-Restart erscheinen sie wieder an ihrer letzten Position
- Schäden bleiben erhalten

## Optionale Anpassungen

**Speicherintervall ändern:**
Bearbeite `config.lua`:
```lua
Config.SaveInterval = 180000  -- 3 Minuten statt 5
```

**Debug-Modus aktivieren:**
```lua
Config.Debug = true  -- Zeigt detaillierte Logs
```

## Support

- 📖 Vollständige Anleitung: siehe INSTALLATION.md
- 🧪 Testszenarios: siehe TESTING.md
- ❓ Probleme: siehe INSTALLATION.md → Fehlerbehebung

## Was wird gespeichert?

✅ Position (x, y, z, heading)
✅ Karosserieschaden
✅ Motorschaden
✅ Tankschaden
✅ Verschmutzung
✅ Fensterschäden
✅ Türschäden
✅ Reifenschäden

## Wichtige Hinweise

⚠️ Nur Fahrzeuge aus `owned_vehicles` werden gespeichert
⚠️ Nach Migration ist Server-Neustart erforderlich
⚠️ Stelle sicher, dass mysql-async läuft
✅ Keine Fahrzeuge werden gelöscht - volle Persistenz garantiert
