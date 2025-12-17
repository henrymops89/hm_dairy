# 🐄 HM Dairy - Milchfarm System

<div align="center">

![Version](https://img.shields.io/badge/version-4.0.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)
![License](https://img.shields.io/badge/license-Custom-orange.svg)

**Ein vollständiges, konfigurierbares Milchfarm-System für FiveM**

*Realistische Milchproduktion mit moderner UI, automatischem Kuh-Spawning und vollständiger Config-Unterstützung*

[Features](#-features) • [Installation](#-installation) • [Konfiguration](#%EF%B8%8F-konfiguration) • [Support](#-support)

</div>

---

## 📋 Übersicht

HM Dairy ist ein umfassendes Milchfarm-System, das Spielern ermöglicht, Kühe zu melken und Rohmilch zu produzieren. Das System bietet eine moderne, benutzerfreundliche UI, automatisches Kuh-Spawning an konfigurierbaren Positionen und ein ausgeklügeltes Cooldown-System für realistische Gameplay-Mechaniken.

### ✨ Highlights

- 🎨 **Moderne UI** - Schönes, responsive Design mit Light/Dark Mode
- 🗺️ **Map-Blip** - Spieler finden die Farm einfach
- 🐄 **Auto-Spawning** - Kühe spawnen automatisch an deinen Positionen
- ⚙️ **Vollständig Konfigurierbar** - Alle Einstellungen in einer Config-Datei
- 🎯 **ox_target Integration** - Intuitive Interaktion mit Kühen
- ⏱️ **Cooldown-System** - Jede Kuh hat individuellen Cooldown
- 📦 **ox_inventory Support** - Items werden benötigt und gegeben
- 🔧 **Debug-Modus** - Umfangreiche Debug-Tools für Testing

---

## 🚀 Features

### Gameplay-Features

- **Individuelle Kühe** - Jede Kuh ist einzigartig mit eigenem Cooldown-Timer
- **Realistische Mechaniken** - Benötige Melkeimer und Melkschemel zum Melken
- **Progress Bar** - Visuelles Feedback während des Melkens (mit Animation)
- **Cooldown-System** - Verhindert Exploitation (Standard: 15 Minuten pro Kuh)
- **Item-Output** - Erhalte Rohmilch nach erfolgreichem Melken
- **Distanz-Check** - Verhindert Melken aus der Ferne

### UI-Features

- **Single-Cow Display** - Zeigt nur die Kuh die du ansiehst (kein generisches UI)
- **Status-Anzeige** - Sehe sofort ob Kuh melkbar ist oder Cooldown hat
- **Cooldown-Timer** - Zeigt verbleibende Zeit bis Kuh wieder gemolken werden kann
- **Produktionsrate** - Visualisierung der Milchproduktion
- **Light/Dark Mode** - Toggle zwischen hellem und dunklem Design
- **Multiple Schließ-Methoden** - ESC, Backspace, X-Button oder `/dairyclose`
- **Responsive Design** - Funktioniert auf allen Bildschirmgrößen

### Technische Features

- **Automatisches Spawning** - Kühe spawnen/despawnen basierend auf Spieler-Distanz
- **Performance-optimiert** - Kühe werden nur geladen wenn Spieler in der Nähe
- **ox_target Integration** - Moderne, saubere Interaktion
- **Config-System** - Zentrale Konfigurationsdatei für alle Einstellungen
- **Debug-Modus** - Umfangreiche Logging- und Test-Commands
- **Map-Blip** - Konfigurierbare Markierung auf der Map
- **Mehrsprachig vorbereitet** - Einfach anzupassen

---

## 📦 Abhängigkeiten

### Erforderlich:
- [ox_lib](https://github.com/overextended/ox_lib) - Fortschrittsbalken & UI-Funktionen
- [ox_target](https://github.com/overextended/ox_target) - Interaktionssystem
- [ox_inventory](https://github.com/overextended/ox_inventory) - Item-Management

### Optional:
- Kein Framework erforderlich! Funktioniert standalone.

---

## 🔧 Installation

### Schritt 1: Ressource herunterladen

Lade die neueste Version herunter und entpacke sie in deinen `resources/` Ordner.

```
resources/
└── hm_dairy/
```

### Schritt 2: Items zu ox_inventory hinzufügen

Öffne `ox_inventory/data/items.lua` und füge hinzu:

```lua
['milk_bucket'] = {
    label = 'Melkeimer',
    weight = 500,
    stack = true,
    close = true,
    description = 'Ein Eimer zum Melken von Kühen'
},

['milk_stool'] = {
    label = 'Melkschemel',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Ein kleiner Schemel zum Melken'
},

['raw_milk'] = {
    label = 'Rohmilch',
    weight = 1000,
    stack = true,
    close = true,
    description = 'Frische Rohmilch direkt von der Kuh'
},
```

### Schritt 3: server.cfg anpassen

Füge zu deiner `server.cfg` hinzu:

```cfg
ensure ox_lib
ensure ox_target
ensure ox_inventory
ensure hm_dairy
```

### Schritt 4: Kuh-Positionen einstellen

⚠️ **WICHTIG:** Die Config enthält Beispiel-Koordinaten für Grapeseed!

Öffne `hm_dairy/config.lua` und passe die Koordinaten an deine Farm an:

```lua
Config.CowSpawns = {
    Enabled = true,
    Model = 'a_c_cow',
    SpawnDistance = 100.0,
    DeleteDistance = 150.0,
    
    Locations = {
        -- ERSETZE MIT DEINEN KOORDINATEN!
        { coords = vector4(x, y, z, heading), scenario = 'WORLD_COW_GRAZING' },
        { coords = vector4(x, y, z, heading), scenario = 'WORLD_COW_GRAZING' },
        -- Füge beliebig viele hinzu...
    }
}
```

**Koordinaten bekommen:**
```lua
-- Temporär in client/main.lua hinzufügen:
RegisterCommand('getpos', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    print(string.format("{ coords = vector4(%.2f, %.2f, %.2f, %.2f), scenario = 'WORLD_COW_GRAZING' },", 
        coords.x, coords.y, coords.z, heading))
end)
```

### Schritt 5: Server neustarten

```
restart ox_inventory
restart hm_dairy
```

---

## ⚙️ Konfiguration

Alle Einstellungen befinden sich in `config.lua`:

### Grundeinstellungen

```lua
Config.Debug = true  -- Debug-Modus (false für Production)
```

### Kuh-Spawning

```lua
Config.CowSpawns = {
    Enabled = true,              -- Automatisches Spawning aktivieren?
    Model = 'a_c_cow',           -- Kuh-Model
    SpawnDistance = 100.0,       -- Spawne wenn Spieler in 100m Nähe
    DeleteDistance = 150.0,      -- Lösche wenn Spieler >150m entfernt
    
    Locations = {
        -- Deine Kuh-Positionen hier
    }
}
```

### Melk-Einstellungen

```lua
Config.Milking = {
    RequireItems = true,         -- Items erforderlich?
    RequiredItems = {
        bucket = 'milk_bucket',
        stool = 'milk_stool'
    },
    
    Duration = 10000,            -- Melk-Dauer in ms (10 Sekunden)
    Cooldown = 15,               -- Cooldown in Minuten
    
    Output = {
        item = 'raw_milk',
        amount = 1,
        label = 'Rohmilch'
    },
    
    Animation = {
        dict = 'amb@world_human_bum_wash@male@low@base',
        clip = 'base'
    }
}
```

### UI-Einstellungen

```lua
Config.UI = {
    ShowAllCows = false,         -- false = Nur die eine Kuh zeigen
    MaxDistance = 3.0,           -- Max Distanz zur Kuh
}
```

### Map-Blip

```lua
Config.Blip = {
    Enabled = true,
    Coords = vector3(x, y, z),   -- Farm-Zentrum
    Sprite = 273,                -- Kuh-Symbol
    Color = 2,                   -- Grün
    Scale = 0.8,
    Name = 'Milchfarm'
}
```

### ox_target

```lua
Config.Target = {
    Enabled = true,
    Distance = 2.5,
    Label = 'Kuh melken',
    Icon = 'fa-solid fa-cow'
}
```

---

## 🎮 Verwendung

### Für Spieler:

1. **Gehe zur Farm** - Nutze den Map-Blip um die Farm zu finden
2. **Kühe spawnen automatisch** - Wenn du in 100m Nähe kommst
3. **Items besorgen** - Benötige Melkeimer und Melkschemel
4. **Zur Kuh gehen** - Gehe zu einer Kuh
5. **E drücken** - Wähle "Kuh melken"
6. **UI öffnet sich** - Mit der ausgewählten Kuh
7. **Melken klicken** - Progress Bar startet (10 Sekunden)
8. **Rohmilch erhalten** - +1 Rohmilch im Inventar
9. **Cooldown** - Diese Kuh kann 15 Minuten nicht gemolken werden
10. **Andere Kühe** - Können sofort gemolken werden!

### Für Admins:

```bash
# Debug-Commands (wenn Config.Debug = true):
/testblip        # Blip manuell erstellen
/blipherenow     # Blip an aktueller Position
/checkcoords     # Koordinaten und Distanz checken
/dairyui         # UI mit allen Kühen öffnen (Test)
/dairyclose      # UI schließen (Notfall)
/dairystatus     # UI-Status anzeigen
```

---

## 🎨 Screenshots
![alt text]([http://url/to/img.png](https://i.epvpimg.com/Y1Cveab.png))


---

## 🐛 Troubleshooting

### Kühe spawnen nicht

**Lösung:**
- Checke ob `Config.CowSpawns.Enabled = true`
- Stelle sicher dass du echte Koordinaten eingetragen hast (nicht die Beispiele)
- Bist du in 100m Nähe der Positionen?
- F8 Console: Siehst du `[HM Dairy Cows] Kuh #X gespawnt`?

### ox_target funktioniert nicht

**Lösung:**
- Ist ox_target installiert? `ensure ox_target` in server.cfg
- `Config.Target.Enabled = true` in config.lua
- Gehe direkt zur Kuh (< 2.5m) und drücke E

### Items werden nicht gegeben

**Lösung:**
- Sind die Items in ox_inventory eingetragen?
- `restart ox_inventory` gemacht?
- F8 Console auf Errors checken

### UI zeigt alle Kühe statt nur eine

**Lösung:**
- `Config.UI.ShowAllCows = false` in config.lua setzen
- `restart hm_dairy`

### Map-Blip wird nicht angezeigt

**Lösung:**
- `Config.Blip.Enabled = true` checken
- Koordinaten korrekt? Nicht 0, 0, 0
- Teste mit `/testblip` Command (Debug-Modus)
- Siehe Datei `client/blip.lua` - nutze die FIXED Version

### Error: "attempt to index a nil value (global 'Config')"

**Lösung:**
- Stelle sicher dass `config.lua` im Root-Verzeichnis liegt
- fxmanifest.lua muss `config.lua` in shared_scripts haben
- Keine alte `server/main.lua` mehr verwenden!

---

## 📝 Changelog

### Version 4.0.0 (Current)
- ✅ Single-Cow System - UI zeigt nur die ausgewählte Kuh
- ✅ Automatisches Kuh-Spawning über Config
- ✅ Vollständiges Config-System
- ✅ Map-Blip Integration
- ✅ Verbesserte ox_target Integration
- ✅ Debug-Commands für Testing
- ✅ Performance-Optimierungen

### Version 3.0.0
- ✅ Items-System mit ox_inventory
- ✅ Cooldown-System pro Kuh
- ✅ ox_target Support

### Version 2.0.0
- ✅ Moderne UI mit Light/Dark Mode
- ✅ Multiple Schließ-Methoden
- ✅ Bug-Fixes (Stack Overflow, Stuck Problem)

### Version 1.0.0
- ✅ Initiales Release
- ✅ Basis-Melk-System

---

## 🤝 Support

### Discord Community
*Füge hier deinen Discord-Link ein*

### Bug Reports
Falls du einen Bug findest, erstelle bitte ein detailliertes Report mit:
- Beschreibung des Problems
- Schritte zum Reproduzieren
- F8 Console Logs
- Deine Config-Einstellungen

### Feature Requests
Hast du Ideen für neue Features? Teile sie mit uns!

---

## 📄 License

**Custom License**  
Dieses Script darf verwendet, aber nicht ohne Erlaubnis weiterverkauft oder re-uploaded werden.

---

## 👨‍💻 Credits

**Entwickelt von:** HM Scripts  
**Unterstützung:** KI 
**UI Design:** Custom Design System  

**Besonderer Dank an:**
- ox_lib Team
- ox_target Team
- ox_inventory Team
- FiveM Community

---

## 🔮 Geplante Features

- [ ] Mehrsprachigkeit (EN/DE/FR/ES)
- [ ] Milch-Verarbeitung (Butter, Käse, etc.)
- [ ] Upgrade-System für Kühe
- [ ] Statistiken & Leaderboard
- [ ] Job-Integration
- [ ] Kuh-Zucht System
- [ ] Mobile App Integration

---

<div align="center">

**⭐ Wenn dir das Script gefällt, lass einen Stern da! ⭐**

Made with ❤️ for the FiveM Community

[Nach oben](#-hm-dairy---milchfarm-system)

</div>
