# RealisticPBR – Minecraft Shaderpack

Ein GLSL-Shaderpack mit Echtzeit-Schatten, Wasser-Reflexionen, Bloom
und dynamischer Tageslichtfarbe für Iris/Sodium (Fabric) oder OptiFine.

## Installation von GitHub

### 1. Repository herunterladen

**Option A – Als ZIP (kein Git nötig):**
1. Oben auf der GitHub-Seite auf **Code → Download ZIP** klicken.
2. ZIP entpacken.

**Option B – Mit Git klonen:**
```bash
git clone https://github.com/DEIN-USERNAME/RealisticPBR.git
```

### 2. Loader installieren (falls noch nicht vorhanden)

Du brauchst zwingend **Iris + Sodium** ODER **OptiFine** – normale
Minecraft-Launcher oder Clients wie Bad Lion können keine
Shaderpacks laden.

- **Iris (empfohlen):** [iris.shaderlabs.org](https://iris.shaderlabs.org) →
  Fabric-Loader installieren → Iris + Sodium als `.jar` in den
  `mods`-Ordner legen.
- **OptiFine:** [optifine.net](https://optifine.net) → Installer
  herunterladen und ausführen, erstellt automatisch ein eigenes Profil.

### 3. Shaderpack in den richtigen Ordner packen

Wichtig: Es muss der **`shaders`-Ordner selbst** (oder ein ZIP davon)
im `shaderpacks`-Verzeichnis landen – nicht der ganze Repo-Ordner
mit README drumherum.

| Betriebssystem | Pfad |
|---|---|
| Windows | `%appdata%\.minecraft\shaderpacks` |
| macOS | `~/Library/Application Support/minecraft/shaderpacks` |
| Linux | `~/.minecraft/shaderpacks` |

Der `shaderpacks`-Ordner existiert nicht automatisch – falls er
fehlt, einfach selbst anlegen.

Zwei Möglichkeiten:
- Den kompletten `shaders`-Ordner aus dem Repo dorthin **kopieren**, oder
- ihn selbst zu `RealisticPBR.zip` packen und diese ZIP-Datei dorthin legen
  (beides funktioniert, OptiFine/Iris lesen sowohl entpackte Ordner
  als auch ZIPs).

### 4. Im Spiel aktivieren

1. Minecraft mit dem Fabric- bzw. OptiFine-Profil starten.
2. **Optionen → Shaderpacks** (Iris) bzw. **Video-Einstellungen →
   Shaders** (OptiFine) öffnen.
3. **RealisticPBR** auswählen.

### 5. Einstellungen anpassen (optional)

Im Shader-Menü (Zahnrad-Symbol neben dem Pack) lassen sich einstellen:

| Option | Wirkung |
|---|---|
| `RENDER_QUALITY` | Interne Auflösung (niedriger = mehr FPS) |
| `SHADOW_QUALITY` | Schärfe der Schatten (1024/2048/4096) |
| `BLOOM_STRENGTH` | Stärke des Leuchteffekts an hellen Stellen |
| `WATER_REFLECTION` | Himmelsreflexion auf Wasser an/aus |
| `FOG_DENSITY` | Nebeldichte |

Bei niedriger FPS: `SHADOW_QUALITY` auf 1024 und `RENDER_QUALITY`
auf 0.75 stellen.

## Ordnerstruktur im Repo

```
shaders/
├── shaders.properties       Zentrale Konfiguration
├── lib/common.glsl          Gemeinsame Beleuchtungsfunktionen
├── gbuffers_terrain.*        Blockbeleuchtung, Wind-Animation
├── gbuffers_water.*          Wasser-Reflexion und -Wellen
├── gbuffers_entities.*       Mobs/Spieler
├── gbuffers_hand.*           Item in der Hand
├── shadow.*                  Shadow-Map-Erzeugung
├── composite*.*               Nebel, Bloom-Pipeline
└── final.*                   Tonemapping, Vignette
```

## Fehlerbehebung

- **Shader taucht nicht in der Liste auf:** Prüfen, ob der Ordner
  `shaders/shaders.properties` direkt enthält (nicht doppelt
  verschachtelt, z.B. `shaderpacks/RealisticPBR/shaders/shaders/...`).
- **Schwarzer Bildschirm/Grafikfehler:** Grafiktreiber aktualisieren,
  Iris/OptiFine-Version muss zur Minecraft-Version passen.
- **Sehr niedrige FPS:** Siehe Einstellungen oben, außerdem in den
  normalen Minecraft-Grafikoptionen die Sichtweite reduzieren.
