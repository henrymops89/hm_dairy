# 🐄 HM Dairy System

Ein vollständiges Milchfarm-System für FiveM mit ox_lib Integration, realistischen Animationen und Multi-Framework Support.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

---

## 📋 Features

- ✅ **ox_lib Progress Bar** - Moderne Kreis-UI mit Prozentanzeige
- ✅ **Realistische Animationen** - Kniende Position beim Melken
- ✅ **Multi-Framework Support** - QBox, QBCore & ESX
- ✅ **Dynamisches Kuh-Spawning** - Kühe spawnen basierend auf Spieler-Distanz
- ✅ **Cooldown-System** - Individual pro Spieler und Kuh (15 Minuten Standard)
- ✅ **Item-Requirements** - Melkeimer & Schemel erforderlich
- ✅ **Server-seitige Validierung** - Anti-Cheat mit Cooldown-Management
- ✅ **ox_target Integration** - Einfache Interaktion mit Kühen
- ✅ **Map-Blip** - Farm-Location auf der Map markiert
- ✅ **Hochgradig konfigurierbar** - Alle Settings in config.lua
- ✅ **Debug-Modus** - Umfangreiche Logs für Entwicklung

---

## 📦 Dependencies

### Erforderlich:
- [ox_lib](https://github.com/overextended/ox_lib) - Core Library
- [ox_target](https://github.com/overextended/ox_target) - Target System
- [ox_inventory](https://github.com/overextended/ox_inventory) - Inventory System

### Framework (eines davon):
- [QBox](https://github.com/Qbox-project/qbx_core) oder
- [QBCore](https://github.com/qbcore-framework/qb-core) oder
- [ESX](https://github.com/esx-framework/esx-core)

---

## 🚀 Installation

### 1. Download & Extract
```bash
cd resources
git clone https://github.com/yourusername/hm_dairy.git
```

### 2. Dependencies sicherstellen
In deiner `server.cfg`:
```lua
ensure ox_lib
ensure ox_target
ensure ox_inventory
ensure hm_dairy
```

### 3. Items hinzufügen
Füge diese Items zu deinem Inventory hinzu:

**ox_inventory** (`ox_inventory/data/items.lua`):
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

### 4. Konfiguration anpassen
Bearbeite `config.lua`:
```lua
-- Framework wird automatisch erkannt (auto)
Config.Framework = 'auto'

-- Kuh-Spawn Locations anpassen
Config.CowSpawns.Locations = {
    {
        coords = vector4(2447.24, 4784.11, 34.18, 45.0),
        scenario = 'WORLD_COW_GRAZING'
    },
    -- Weitere Locations hinzufügen...
}

-- Blip-Position anpassen
Config.Blip.Coords = vector3(2447.24, 4784.11, 34.18)
```

### 5. Server starten
```bash
restart hm_dairy
```

---

## ⚙️ Konfiguration

### Grundeinstellungen

```lua
-- Debug-Modus (für Entwicklung)
Config.Debug = false

-- Framework (auto-detect empfohlen)
Config.Framework = 'auto' -- 'auto', 'qbox', 'qbcore', 'esx'
```

### Melk-Einstellungen

```lua
Config.Milking = {
    -- Benötigte Items
    RequiredItems = {
        bucket = 'milk_bucket',
        stool = 'milk_stool'
    },
    
    -- Dauer der Animation (Millisekunden)
    Duration = 10000, -- 10 Sekunden
    
    -- Cooldown pro Spieler pro Kuh (Minuten)
    Cooldown = 15,
    
    -- Output
    Output = {
        item = 'raw_milk',
        amount = 1,
        label = 'Rohmilch'
    },
    
    -- Animation
    Animation = {
        dict = 'amb@world_human_bum_wash@male@low@base',
        clip = 'base',
        offset = vector3(0.8, 0.0, -0.3),
        heading = 90.0
    }
}
```

### Kuh-Spawning

```lua
Config.CowSpawns = {
    Enabled = true,
    Model = 'a_c_cow',
    
    -- Spawn-Distanz
    SpawnDistance = 100.0,
    DeleteDistance = 150.0,
    
    -- Locations
    Locations = {
        -- Deine Kuh-Spawn Punkte
    }
}
```

### Map-Blip

```lua
Config.Blip = {
    Enabled = true,
    Coords = vector3(2447.24, 4784.11, 34.18),
    Sprite = 273, -- Kuh-Symbol
    Color = 2,    -- Grün
    Scale = 0.8,
    Name = 'Milchfarm'
}
```

---

## 🎮 Verwendung

### Für Spieler:

1. **Items besorgen:**
   - Melkeimer (`milk_bucket`)
   - Melkschemel (`milk_stool`)

2. **Zur Farm gehen:**
   - Folge dem grünen Kuh-Blip auf der Map

3. **Kuh melken:**
   - Gehe zu einer Kuh
   - Drücke E (ox_target)
   - Wähle "Kuh melken"
   - Warte 10 Sekunden
   - Erhalte Rohmilch!

4. **Cooldown beachten:**
   - Jede Kuh kann nur alle 15 Minuten gemolken werden (pro Spieler)

### Debug-Commands:

Nur verfügbar wenn `Config.Debug = true`:

```lua
/dairy_spawncows   -- Alle Kühe sofort spawnen
/dairy_deletecows  -- Alle Kühe entfernen
/dairy_listcows    -- Liste aller gespawnten Kühe
```

---

## 🎨 Animationen

Das System bietet 8 verschiedene Animationen zur Auswahl:

1. **Kniende Position** (Standard) - `amb@world_human_bum_wash@male@low@base`
2. **Yoga/Sitzend** - `amb@world_human_yoga@male@base`
3. **Mechaniker** - `anim@amb@clubhouse@tutorial@bkr_tut_ig3@`
4. **Push-ups** - `amb@world_human_push_ups@male@base`
5. **Medizinische Position** - `amb@medic@standing@kneel@base`
6. **Sit-ups** - `amb@world_human_sit_ups@male@base`
7. **Gärtner** - `amb@world_human_gardener_plant@male@base`
8. **Schweißer** - `amb@world_human_welding@male@base`

Alle Animationen sind in `config.lua` kommentiert und können einfach gewechselt werden.

---

## 📁 Dateistruktur

```
hm_dairy/
├── client/
│   └── main.lua           # Client-seitige Logik
├── server/
│   └── main.lua           # Server-seitige Validierung
├── bridge/
│   ├── framework.lua      # Framework-Bridge
│   └── inventory.lua      # Inventory-Bridge
├── config.lua             # Alle Einstellungen
├── fxmanifest.lua         # Resource Manifest
└── README.md              # Diese Datei
```

---

## 🔧 Anpassungen

### Eigene Kuh-Locations hinzufügen:

```lua
Config.CowSpawns.Locations = {
    {
        coords = vector4(x, y, z, heading),
        scenario = 'WORLD_COW_GRAZING'
    },
    -- Weitere hinzufügen...
}
```

### Cooldown-Zeit ändern:

```lua
Config.Milking.Cooldown = 30 -- 30 Minuten
```

### Output-Menge ändern:

```lua
Config.Milking.Output = {
    item = 'raw_milk',
    amount = 3,  -- 3 Rohmilch pro Melkvorgang
    label = 'Rohmilch'
}
```

---

## 🐛 Troubleshooting

### Problem: Kühe spawnen nicht
**Lösung:**
1. Checke ob `Config.CowSpawns.Enabled = true`
2. Stelle sicher dass du innerhalb der `SpawnDistance` bist
3. Prüfe F8 Console auf Errors

### Problem: Progress Bar erscheint nicht
**Lösung:**
1. Stelle sicher dass ox_lib korrekt installiert ist
2. Checke ob ox_lib VOR hm_dairy gestartet wird
3. Aktiviere `Config.Debug = true` für Logs

### Problem: Items fehlen
**Lösung:**
1. Füge die Items zu ox_inventory hinzu (siehe Installation)
2. Restart ox_inventory: `restart ox_inventory`
3. Restart hm_dairy: `restart hm_dairy`

### Problem: "Kuh wurde kürzlich gemolken"
**Lösung:**
- Das ist normal! Warte die Cooldown-Zeit ab (Standard: 15 Min)
- Oder passe `Config.Milking.Cooldown` an

---

## 🤝 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/hm_dairy/issues)
- **Discord:** Dein Discord Server
- **Documentation:** [Wiki](https://github.com/yourusername/hm_dairy/wiki)

---

## 📝 Changelog

### Version 1.0.0 (2024)
- ✅ Initial Release
- ✅ ox_lib Progress Bar Integration
- ✅ Multi-Framework Support
- ✅ Dynamisches Kuh-Spawning
- ✅ Cooldown-System
- ✅ Map-Blip
- ✅ 8 Animationen

---

## 📄 Lizenz

MIT License

Copyright (c) 2024 HM Scripts

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## 🌟 Credits

- **Entwickler:** Dein Name
- **ox_lib:** [overextended](https://github.com/overextended)
- **Inspiration:** FiveM Community

---

## ⭐ Star das Repo!

Wenn dir dieses Script gefällt, gib dem Repository einen Stern! ⭐

Es hilft anderen Entwicklern, das Script zu finden!

---

**Made with ❤️ for the FiveM Community**
