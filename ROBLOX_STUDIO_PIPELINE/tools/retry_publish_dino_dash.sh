#!/usr/bin/env bash
set -u
cd /mnt/d/Openclaw/ROBLOX_STUDIO_PIPELINE
max_attempts=10
for attempt in $(seq 1 "$max_attempts"); do
  echo "[$(date -Is)] Dino Dash publish attempt ${attempt}/${max_attempts}"
  if python3 tools/publish_place.py dino-dash --version-type published --yes; then
    echo "[$(date -Is)] Dino Dash published successfully."
    python3 - <<'PY'
import json, urllib.request
u='https://games.roblox.com/v1/games?universeIds=10089814885'
with urllib.request.urlopen(u, timeout=20) as r:
    data=json.load(r)
game=data.get('data',[{}])[0]
print('Roblox updated timestamp:', game.get('updated'))
print('Game URL: https://www.roblox.com/games/121490965476892/Dino-Dash')
PY
    exit 0
  fi
  if [ "$attempt" -lt "$max_attempts" ]; then
    echo "Roblox returned busy/conflict; waiting 120 seconds before retry..."
    sleep 120
  fi
done
echo "Dino Dash publish failed after ${max_attempts} attempts. Roblox Open Cloud kept returning busy/conflict. Manual Studio publish may be required."
exit 1
