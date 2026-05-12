# Grass Gobbler Cow Contest

A Roblox prototype experience where players are cows competing to eat as much grass as possible.

## Core loop

- Players spawn as cow-suited avatars in a fenced farm.
- Everyone starts with 60 seconds.
- Touch/eat grass to score and add time.
- Every 20 grass increases the time multiplier.
- Golden grass gives bigger score/time bonuses.
- The field can run low, so players need smart routing to keep their timer alive.
- Runs can theoretically continue indefinitely if players keep eating efficiently.

## Build

```powershell
D:\Openclaw\tools\bin\rojo.exe build D:\Openclaw\GRASS_GOBBLER_COW_CONTEST\default.project.json -o D:\Openclaw\GRASS_GOBBLER_COW_CONTEST\build\Grass-Gobbler-Cow-Contest.rbxlx
```

## Publish

Create or choose a Roblox place/universe first, then publish with `rbxcloud`:

```powershell
D:\Openclaw\tools\bin\rbxcloud.exe experience publish --filename D:\Openclaw\GRASS_GOBBLER_COW_CONTEST\build\Grass-Gobbler-Cow-Contest.rbxlx --place-id <PLACE_ID> --universe-id <UNIVERSE_ID> --version-type published --api-key <API_KEY> --pretty
```

Do not overwrite Clawdia's Claw Machine unless explicitly intended.
