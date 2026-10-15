# THJ — Pactor's fork of NMS-Release

A customized fork of [tunaria/NMS-Release](https://github.com/tunaria/NMS-Release), which builds on
[firestormalpha/TheHeroesJourneyServer](https://github.com/firestormalpha/TheHeroesJourneyServer)
and EQEmu (GPL). Target client: **RoF2** (user-supplied — see `client-mod/`).

## What this fork changes
- **Quest edits** (`Release-NMS-Quests/`):
  - `global/global_player.pl` — live admin teleport / level-set signal handlers (uses a
    `claude_teleport` table in the DB), pending-login actions.
  - `global/global_npc.pl`, `permafrost/Lady_Vox.pl`.
- **Customized database** — the bulk of the work, Classic → Shadows of Luclin (**level 80**):
  the account-wide expansion / level-cap ladder, Luclin zones releveled to the 70–80 band with
  **loot scaled to tier**, custom spells / items / pets, the waypoint + Echo travel network, and
  the Luclin flag bosses. This lives in the **database**, not in files — import the dump attached
  to the GitHub **Release** into a `nms` database. Regenerate with `dump_db.ps1`.
- Planes of Power and beyond (level 90+) are stubbed in the progression system, not yet complete.

## Setup (delta from upstream)
Follow the upstream NMS-Release setup, then import the THJ database dump (Release asset) over the
`nms` database, and apply the RoF2 client connector from `client-mod/`.

## Credits / license
Based on tunaria/NMS-Release + firestormalpha/TheHeroesJourneyServer (EQEmu, **GPL** — source stays
open). Some content originated upstream from RetributionEQ. The EQ client is copyrighted by
Daybreak and is **not** distributed here.
