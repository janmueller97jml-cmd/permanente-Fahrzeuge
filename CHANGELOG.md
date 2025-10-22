# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

## [1.0.0] - 2025-10-22

### Hinzugefügt
- Initiale Implementierung des permanenten Fahrzeug-Persistenz-Systems
- Automatische Speicherung von Fahrzeugpositionen für Fahrzeuge in der `owned_vehicles` Tabelle
- Periodische Position-Updates (konfigurierbar, Standard: 5 Minuten)
- Position-Speicherung beim Verlassen des Fahrzeugs
- Wiederherstellung von Fahrzeugen nach Server-Restart an exakter Position
- Vollständige Schadenspersistenz:
  - Karosseriegesundheit
  - Motorgesundheit
  - Tankgesundheit
  - Verschmutzungsgrad
  - Fensterschäden
  - Türschäden
  - Reifenschäden
- Datenbank-Migration für `owned_vehicles` Tabelle
- Konfigurationsdatei mit anpassbaren Einstellungen
- Debug-Modus für detaillierte Logs
- Umfassende Dokumentation (README, INSTALLATION, Beispiele)
- Kompatibilität mit ESX und QBCore Frameworks

### Funktionen
- Server-seitige Verwaltung der Fahrzeugpositionen
- Client-seitige Verfolgung und Schadenserkennung
- Automatisches Tracking von befahrenen Fahrzeugen
- Verhinderung von Fahrzeugverlust durch dauerhafte Speicherung
- Keine Löschung von Fahrzeugen - vollständige Persistenz

### Technische Details
- FiveM Resource mit `fx_version 'cerulean'`
- Nutzung von mysql-async für Datenbankzugriff
- JSON-basierte Speicherung von Position und Schadensdaten
- Event-basierte Kommunikation zwischen Client und Server
