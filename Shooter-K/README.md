# Shooter-K

Low-poly 3D FPS arena shooter, 2-6 players, LAN + relay co-op multiplayer (PvP arena).

## Status: Step 1 — single-player movement + look in an empty arena (no shooting/networking yet)

## How to push this into your repo

1. Clone your empty repo locally (or download this as a zip and extract into it):
   ```
   git clone https://github.com/NotKT/Shooter-K.git
   ```
2. Copy all files from this package into the repo folder (keep the same structure).
3. Commit and push:
   ```
   git add .
   git commit -m "Initial project: movement + empty arena + Android CI build"
   git push
   ```
4. Go to the repo's **Actions** tab on GitHub — a build will start automatically.
   Once it finishes, download the APK from the workflow run's **Artifacts** section
   and install it on your phone to test.

## What's in this build
- Empty low-poly arena (floor + 4 walls)
- Player: move (left joystick) + look (right touch-drag), no shooting yet
- GitHub Actions workflow that builds a debug APK on every push to `main`

## Next steps
- Add fire input + first weapon (pistol)
- Add weapon pickups
- Add LAN multiplayer (host/join by IP)
- Add relay multiplayer
- Add arena size variants (small/medium/large based on player count)
