# 📁 DIESE DATEIEN BRAUCHST DU

## ❌ DAS PROBLEM:

Du hast noch eine **alte `server/main.lua`** die mit der CONFIG-Version kollidiert!

Die CONFIG-Version braucht **KEINE `server/main.lua`** mehr!

---

## ✅ RICHTIGE DATEISTRUKTUR:

```
hm_dairy/
├── config.lua                      ← NEU!
├── fxmanifest.lua                  ← AKTUALISIERT
│
├── html/
│   └── index.html                  ← Wie gehabt
│
├── client/
│   ├── blip.lua                    ← NEU!
│   ├── cows.lua                    ← NEU!
│   ├── main.lua                    ← AKTUALISIERT (siehe unten)
│   └── ui.lua                      ← Wie gehabt
│
└── server/
    └── ui_integration.lua          ← AKTUALISIERT (siehe unten)
    
    ❌ KEINE main.lua hier!          ← WICHTIG!
```

---

## 📝 WICHTIGSTE DATEIEN:

### 1. **server/ui_integration.lua** (NUR DIESE SERVER-DATEI!)

Diese Datei ersetzt deine alte `server/main.lua`!

**Inhalt:** (siehe Datei im ZIP)
- Nutzt `Config` für alle Einstellungen
- Single-Cow Support
- Items-Check mit Config
- Cooldown-System

### 2. **client/main.lua** (AKTUALISIERT)

**Inhalt:** (siehe Datei im ZIP)
- Nutzt `Config` für alle Einstellungen
- ox_target Integration
- Single-Cow Entity-Tracking
- Items-Check mit Config

### 3. **fxmanifest.lua** (WICHTIG!)

**Muss EXAKT so aussehen:**

```lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'                -- Config wird überall geladen!
}

client_scripts {
    'client/blip.lua',          -- Map-Blip
    'client/cows.lua',          -- Kuh-Spawning
    'client/ui.lua',            -- UI Management
    'client/main.lua'           -- Event Handler
}

server_scripts {
    'server/ui_integration.lua' -- NUR DIESE!
    -- KEINE main.lua hier!
}

ui_page 'html/index.html'

files {
    'html/index.html'
}
```

### 4. **config.lua** (NEU!)

**Inhalt:** (siehe Datei im ZIP)
- Alle Einstellungen
- Kuh-Positionen
- Items
- Cooldown
- ox_target

---

## 🔧 INSTALLATION:

### Option A: Sauber (Empfohlen!)

1. **Backup** deine alte `hm_dairy/` (falls du was behalten willst)
2. **Lösche** `resources/hm_dairy/` komplett
3. **Entpacke** `hm_dairy_CONFIG_VERSION.zip`
4. **Kopiere** den `hm_dairy/` Ordner nach `resources/`
5. **Öffne** `config.lua` und trage deine Koordinaten ein
6. **Restart:** `restart hm_dairy`

### Option B: Manuell

1. **Lösche** `server/main.lua`
2. **Ersetze** `server/ui_integration.lua` mit der neuen
3. **Ersetze** `client/main.lua` mit der neuen
4. **Füge hinzu** `config.lua` (root)
5. **Füge hinzu** `client/blip.lua`
6. **Füge hinzu** `client/cows.lua`
7. **Ersetze** `fxmanifest.lua` mit dem neuen
8. **Restart:** `restart hm_dairy`

---

## ✅ NACH DEM RESTART:

**Solltest du sehen:**
```
[HM Dairy Server] UI Integration geladen (Single-Cow Mode: true)
[HM Dairy Cows] Kuh-Spawning System geladen
[HM Dairy Blip] Farm-Blip erstellt
[HM Dairy Client] Client geladen - Gehe zu einer Kuh und drücke E
```

**KEIN ERROR mehr!** 🎉

---

## 🎯 DANN TESTEN:

1. Gehe zu deinen Kuh-Positionen (aus config.lua)
2. Kühe spawnen automatisch
3. Drücke E bei einer Kuh
4. "Kuh melken" Option erscheint
5. UI öffnet sich mit NUR dieser Kuh
6. Funktioniert!

---

## 📦 ALLE DATEIEN IM ZIP:

Ich habe dir das **komplette hm_dairy_CONFIG_VERSION.zip** gegeben:
- Alle Dateien fertig
- Keine alte main.lua mehr
- Config.lua enthalten
- Sofort einsatzbereit!

**Einfach entpacken und kopieren!** 🚀