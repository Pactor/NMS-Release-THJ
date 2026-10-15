# Client mod (RoF2)

This server uses the **RoF2** EverQuest client. You must supply your own RoF2 client — the
copyrighted game files are **not** distributed here.

To connect a stock RoF2 client to this server, drop these into the client's root folder:

| File | Where it comes from | Purpose |
|---|---|---|
| `dinput8.dll` | this folder (community connector mod) | hooks the client so it reaches the emulated login/world |
| `eqhost.txt` | copy `eqhost.txt.example`, set the server IP | points the client at the login server |
| `spells_us.txt` | server's `export/spells_us.txt` (run `export_client_files.exe` on the server first) | custom spell names/data; also deploy to `<client>\Resources\` |

Notes
- `eqhost.txt` host is the **login server** address:port (default login port **5999** for this client).
- Re-export and redeploy `spells_us.txt` whenever custom spells change.
- Everything else in a working client (eqgame.exe, graphics DLLs, assets) is the user's own RoF2 install.
