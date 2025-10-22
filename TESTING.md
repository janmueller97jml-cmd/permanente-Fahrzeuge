# Testing Guide

Dieses Dokument beschreibt, wie du das permanente-Fahrzeuge System testen kannst.

## Vorbereitungen

1. Stelle sicher, dass die Resource installiert ist (siehe INSTALLATION.md)
2. Aktiviere den Debug-Modus in `config.lua`:
   ```lua
   Config.Debug = true
   ```
3. Starte den Server neu

## Test 1: Grundlegende Funktionalität

### Schritt 1: Fahrzeug spawnen und parken
1. Starte deinen FiveM Client
2. Spawne ein Fahrzeug, das in der `owned_vehicles` Tabelle existiert
3. Fahre zu einer markanten Position (z.B. vor dem Rathaus)
4. Verlasse das Fahrzeug
5. Prüfe die Server-Logs - du solltest sehen:
   ```
   [permanente-Fahrzeuge] Saved position for vehicle: ABC123
   ```

### Schritt 2: Datenbank prüfen
```sql
SELECT plate, parking_position, last_parked 
FROM owned_vehicles 
WHERE parking_position IS NOT NULL;
```

Du solltest einen Eintrag mit JSON-Daten sehen:
```json
{"x":123.45,"y":234.56,"z":30.5,"heading":180.0}
```

### Schritt 3: Server-Restart
1. Stoppe den Server: `stop permanente-Fahrzeuge` oder Neustart
2. Starte den Server neu
3. Verbinde dich wieder mit dem Server
4. Gehe zur Position, wo du das Fahrzeug geparkt hast
5. Das Fahrzeug sollte dort stehen

### Erwartetes Ergebnis
✅ Fahrzeug erscheint an der exakten Position nach Restart

## Test 2: Schadenspersistenz

### Schritt 1: Fahrzeug beschädigen
1. Spawne ein Fahrzeug
2. Beschädige es absichtlich:
   - Fahre gegen eine Wand (Karosserieschaden)
   - Schieße auf Fenster (Fensterschaden)
   - Schieße auf Reifen (Reifenschaden)
3. Verlasse das Fahrzeug
4. Warte 5 Minuten (oder kürzer, wenn SaveInterval angepasst)

### Schritt 2: Datenbank prüfen
```sql
SELECT plate, parking_damage 
FROM owned_vehicles 
WHERE plate = 'DEIN_KENNZEICHEN';
```

Du solltest Schadensdaten sehen:
```json
{
  "bodyHealth": 850.0,
  "engineHealth": 1000.0,
  "windows": {"0": true, "1": true},
  "tyres": {"0": {"burst": true, "completely": false}}
}
```

### Schritt 3: Server-Restart
1. Starte den Server neu
2. Verbinde dich wieder
3. Gehe zum Fahrzeug

### Erwartetes Ergebnis
✅ Fahrzeug hat die gleichen Schäden wie vor dem Restart:
- Gleiche Karosserie-Dellen
- Gleiche kaputte Fenster
- Gleiche platte Reifen

## Test 3: Periodisches Speichern

### Schritt 1: Kontinuierliches Fahren
1. Reduziere `Config.SaveInterval` auf 60000 (1 Minute) für schnelleres Testen
2. Starte den Server neu
3. Steige in ein Fahrzeug
4. Fahre kontinuierlich durch die Stadt
5. Beobachte die Logs

### Erwartetes Ergebnis
✅ Alle 1 Minute (oder dein konfiguriertes Intervall) solltest du sehen:
```
[permanente-Fahrzeuge] Saved position for vehicle: ABC123
```

### Schritt 2: Position-Updates prüfen
```sql
SELECT plate, parking_position, last_parked 
FROM owned_vehicles 
WHERE plate = 'ABC123'
ORDER BY last_parked DESC;
```

Das `last_parked` Feld sollte sich alle 1 Minute aktualisieren.

## Test 4: Mehrere Fahrzeuge

### Schritt 1: Mehrere Fahrzeuge spawnen
1. Spawne 3-5 verschiedene Fahrzeuge (alle in owned_vehicles)
2. Parke sie an verschiedenen Positionen in der Stadt
3. Verlasse jedes Fahrzeug

### Schritt 2: Server-Restart
1. Starte den Server neu
2. Verbinde dich wieder

### Erwartetes Ergebnis
✅ Alle Fahrzeuge sollten an ihren jeweiligen Positionen stehen
✅ Server-Log sollte zeigen:
```
[permanente-Fahrzeuge] Loaded X parked vehicles
```

## Test 5: Nicht-eigene Fahrzeuge

### Schritt 1: Fremdes Fahrzeug spawnen
1. Spawne ein Fahrzeug, das NICHT in owned_vehicles existiert
2. Fahre damit herum
3. Verlasse es

### Schritt 2: Datenbank prüfen
```sql
SELECT COUNT(*) FROM owned_vehicles WHERE plate = 'FREMDES_KENNZEICHEN';
```

### Erwartetes Ergebnis
✅ Fahrzeug sollte NICHT in owned_vehicles sein
✅ Nach Restart sollte es NICHT wieder erscheinen
✅ Debug-Log kann zeigen: "Attempted to save non-owned vehicle"

## Test 6: Performance unter Last

### Schritt 1: Viele Fahrzeuge
1. Füge 50-100 Fahrzeuge in owned_vehicles ein
2. Setze für alle `parking_position` auf verschiedene Werte
3. Starte den Server neu

### Schritt 2: Performance messen
1. Messe die Server-Startzeit
2. Prüfe Server-RAM-Nutzung
3. Prüfe Client-FPS während die Fahrzeuge spawnen

### Erwartetes Ergebnis
✅ Server startet ohne Verzögerung
✅ Kein signifikanter FPS-Drop beim Spawnen
✅ Alle Fahrzeuge werden korrekt geladen

## Test 7: Fahrzeug Respawn (Neu)

### Schritt 1: Fahrzeug löschen
1. Aktiviere Debug-Modus (`Config.Debug = true`)
2. Spawne ein Fahrzeug, das in `owned_vehicles` existiert
3. Fahre zu einer Position und verlasse das Fahrzeug
4. Warte bis das Fahrzeug gespawnt ist (Server-Log prüfen)
5. Verwende einen Admin-Befehl oder andere Methode um das Fahrzeug zu löschen (z.B. `/dv` oder andere Delete-Befehle)

### Schritt 2: Respawn beobachten
1. Warte maximal 5-10 Sekunden
2. Prüfe die Client-Logs

### Erwartetes Ergebnis
✅ Client-Log zeigt: "Vehicle [PLATE] was deleted, respawning..."
✅ Fahrzeug erscheint wieder an der gleichen Position
✅ Schäden werden wiederhergestellt
✅ Dies geschieht automatisch ohne Server-Restart

### Schritt 3: Mehrfaches Löschen
1. Lösche das Fahrzeug erneut
2. Warte wieder 5-10 Sekunden

### Erwartetes Ergebnis
✅ Fahrzeug respawnt wieder
✅ Kein Crash oder Fehler
✅ Performance bleibt stabil

## Test 8: Fahrzeug bewegen und Respawn

### Schritt 1: Geparktes Fahrzeug bewegen
1. Spawne ein Fahrzeug an Position A
2. Steige ein und fahre zu Position B
3. Verlasse das Fahrzeug an Position B
4. Warte 5 Minuten (oder kürzer je nach SaveInterval)

### Schritt 2: Fahrzeug löschen
1. Lösche das Fahrzeug an Position B
2. Warte 5-10 Sekunden

### Erwartetes Ergebnis
✅ Fahrzeug respawnt an Position B (nicht an der ursprünglichen Position A)
✅ Debug-Log zeigt: "Updated parked vehicle position: [PLATE]"

## Test 9: Fahrzeug-Entfernung aus System

### Schritt 1: Fahrzeug aus Tracking entfernen
1. Spawne ein Fahrzeug
2. Verwende den Server-Event `permanente-fahrzeuge:removeVehicle` mit dem Kennzeichen
3. Beobachte die Logs

### Schritt 2: Prüfe Datenbank
```sql
SELECT parking_position FROM owned_vehicles WHERE plate = 'TEST123';
```

### Erwartetes Ergebnis
✅ `parking_position` ist NULL in der Datenbank
✅ Fahrzeug wird vom Client gelöscht
✅ Fahrzeug respawnt NICHT wieder
✅ Client-Log zeigt: "Removed vehicle from tracking: [PLATE]"

## Fehlerbehebung während des Tests

### Problem: Fahrzeuge werden nicht gespeichert
**Lösung:**
- Prüfe `Config.OwnedVehiclesTable` - stimmt der Name?
- Prüfe ob mysql-async läuft
- Aktiviere Debug-Modus und prüfe Logs

### Problem: Fahrzeuge spawnen nicht nach Restart
**Lösung:**
- Prüfe Server-Logs auf Fehler
- Stelle sicher, dass parking_position nicht NULL ist in DB
- Prüfe ob Resource nach Framework geladen wird

### Problem: Fahrzeuge respawnen nicht nach Löschung (Neu)
**Lösung:**
- Aktiviere Debug-Modus und prüfe Logs
- Stelle sicher, dass der Client-Thread läuft
- Prüfe ob das Fahrzeug in ParkedVehiclesData gespeichert ist
- Fahrzeug sollte innerhalb von 5 Sekunden respawnen

### Problem: Schäden werden nicht wiederhergestellt
**Lösung:**
- Prüfe ob parking_damage JSON-Daten enthält
- Aktiviere Debug-Modus
- Prüfe Client-Logs

## Erfolgreiche Tests bestätigen

Nach erfolgreichen Tests solltest du:
- ✅ Fahrzeuge können gespeichert werden
- ✅ Positionen bleiben nach Restart erhalten
- ✅ Schäden werden korrekt wiederhergestellt
- ✅ Periodisches Speichern funktioniert
- ✅ Nur owned_vehicles werden gespeichert
- ✅ Mehrere Fahrzeuge funktionieren gleichzeitig
- ✅ Performance ist akzeptabel
- ✅ Fahrzeuge respawnen automatisch nach Löschung (Neu)
- ✅ Fahrzeugpositionen werden aktualisiert wenn bewegt (Neu)
- ✅ Fahrzeuge können korrekt aus dem System entfernt werden (Neu)

Wenn alle Tests bestehen, kannst du:
1. `Config.Debug = false` setzen
2. `Config.SaveInterval` auf Produktionswert setzen (300000 empfohlen)
3. Die Resource in Produktion verwenden
