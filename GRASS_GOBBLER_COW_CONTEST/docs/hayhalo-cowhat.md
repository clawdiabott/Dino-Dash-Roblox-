# Hayhalo Cowhat

## Item concept
A game-native premium cosmetic for Grass Gobbler Cow Contest.

**Name:** Hayhalo Cowhat  
**Launch price:** 49 grass in-game  
**Recommended Robux price if converted to Game Pass/paid cosmetic:** 49 Robux

## Visual identity
- Floating straw halo / cowboy brim above the cow suit
- Soft milk-white crown
- Tiny neon-gold horns
- Glowing golden grass tuft
- Mini cowbell under the brim

## Implementation status
- Implemented as server-created geometry, so no external mesh upload is required.
- Added `CowhatShop` RemoteEvent.
- Server validates purchase/equip state.
- Client has a shop button in the HUD.
- Current in-game purchase uses earned grass as the currency.

## Files changed
- `src/ServerScriptService/Main.server.lua`
- `src/StarterPlayer/StarterPlayerScripts/Client.client.lua`

## Publishing note
The Rojo build includes the Hayhalo Cowhat and spawn-timing fix. Roblox Open Cloud publish is currently blocked by temporary HTTP 409 server congestion. Retry publishing with:

```powershell
D:\Openclaw\roblox-publisher\roblox-prod.cmd publish grass-gobbler -Yes
```
