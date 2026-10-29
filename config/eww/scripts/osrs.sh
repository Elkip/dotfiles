#!/usr/bin/env bash
# Fetches OSRS hiscores for an ironman account. Outputs JSON for eww.
# Config in ~/.config/eww/server.secret:
#   OSRS_RSN=YourUsername

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/eww/server.secret"
[[ -f "$CONFIG" ]] && source "$CONFIG"

if [[ -z "$OSRS_RSN" ]]; then
  echo '{"error":"no rsn configured"}'
  exit 0
fi

# URL-encode the RSN (spaces become %20)
RSN_ENC=$(printf '%s' "$OSRS_RSN" | sed 's/ /%20/g')

# Ironman hiscores endpoint
URL="https://secure.runescape.com/m=hiscore_oldschool_ironman/index_lite.ws?player=${RSN_ENC}"

DATA=$(curl -sf --max-time 10 "$URL" 2>/dev/null)
if [[ -z "$DATA" ]]; then
  echo '{"error":"fetch failed"}'
  exit 0
fi

# The API returns CSV: rank,level,xp for each skill (in order), then minigames/bosses
# Skills order: Overall, Attack, Defence, Strength, Hitpoints, Ranged, Prayer, Magic,
#               Cooking, Woodcutting, Fletching, Fishing, Firemaking, Crafting, Smithing,
#               Mining, Herblore, Agility, Thieving, Slayer, Farming, Runecraft, Hunter,
#               Construction

SKILLS=(Overall Attack Defence Strength Hitpoints Ranged Prayer Magic Cooking Woodcutting Fletching Fishing Firemaking Crafting Smithing Mining Herblore Agility Thieving Slayer Farming Runecraft Hunter Construction)

# Parse into JSON
echo "$DATA" | awk -F, -v skills="${SKILLS[*]}" '
BEGIN {
  n = split(skills, sk, " ")
  printf "{\"rsn\":\"'"$OSRS_RSN"'\",\"skills\":{"
}
NR <= 24 {
  rank = $1; level = $2; xp = $3
  if (rank == -1) rank = "unranked"
  gsub(/\r/, "", xp)
  if (NR > 1) printf ","
  printf "\"%s\":{\"rank\":%s,\"level\":%s,\"xp\":%s}", sk[NR], (rank == "unranked" ? "null" : rank), level, xp
}
NR == 24 {
  printf "},\"combat\":{"
  # Combat level formula (approximate display)
}
END {
  printf "}}"
}
' | jq -c '
  .total_level = .skills.Overall.level |
  .total_xp = .skills.Overall.xp |
  .combat_stats = {
    atk: .skills.Attack.level,
    str: .skills.Strength.level,
    def: .skills.Defence.level,
    hp: .skills.Hitpoints.level,
    ranged: .skills.Ranged.level,
    magic: .skills.Magic.level,
    prayer: .skills.Prayer.level
  } |
  # Combat level calculation
  .combat_level = (
    (([.combat_stats.def, .combat_stats.hp, (.combat_stats.prayer / 2 | floor)] | add) * 0.25) +
    ([
      (([.combat_stats.atk, .combat_stats.str] | add) * 0.325),
      ((.combat_stats.ranged * 1.5) * 0.325),
      ((.combat_stats.magic * 1.5) * 0.325)
    ] | max)
  | floor) |
  {
    rsn: .rsn,
    total_level: .total_level,
    total_xp: .total_xp,
    combat_level: .combat_level,
    stats: .combat_stats,
    rank: .skills.Overall.rank
  }
' 2>/dev/null || echo '{"error":"parse failed"}'
