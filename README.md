# 🌲 Terraria 1.4.6.1 & Modded 24/7 Cloud Server

![Terraria 1.4.6.1](https://img.shields.io/badge/Terraria-1.4.6.1-green.svg)
![World Size](https://img.shields.io/badge/World-Large%20(8400x2400)-blue.svg)
![Free Tunnel](https://img.shields.io/badge/Tunnel-bore.pub%20(100%25%20Free)-orange.svg)
![Zero PC Load](https://img.shields.io/badge/Local%20PC-0%25%20Load-success.svg)

ඔබගේ ලැප්ටොප් පරිගණකයට **කිසිදු file එකක් download නොකර**, කිසිදු **API key හෝ මුදල් ගෙවීමකින් තොරව**, GitHub Actions Cloud Runners මත 24/7 ධාවනය වන Terraria Dedicated Server එක!

👉 **Live IP & Port එක බැලීමට:** [SERVER_STATUS.md](./SERVER_STATUS.md) (හෝ **Actions -> Summary** බලන්න).

---

## 🛠️ Modes & Mods තෝරාගැනීම

1. **`vanilla-1461` (Default - Terraria 1.4.6.1):**
   * නිල Terraria `1.4.6.1` PC / Mobile clients සඳහා **Large World (8400x2400)**.
   * *Optional Mod-like Gameplay:* `seed` එකට `getfixedboi` (Zenith Mega-Seed) හෝ `fortheworthy` දමා Modpack එකක් වැනි අත්දැකීමක් 1.4.6.1 තුළම ලබාගත හැක.
2. **`tmodloader` (Real Mods Mode):**
   * **tModLoader Dedicated Server** (MagicStorage, BossChecklist, RecipeBrowser ස්වයංක්‍රීයව GitHub Releases වලින් cloud එකට download වේ! ඔබට අවශ්‍ය වෙනත් `.tmod` files ඇත්නම් `mods/` folder එකට upload කළ හැක).
   * *සටහන:* tModLoader ධාවනය වන්නේ 1.4.4.9 මත නිසා, මෙම mode එකේදී Steam හි **tModLoader** මඟින් join විය යුතුය (1.4.6.1 client එකෙන් connect වන විට `vanilla-1461` භාවිතා කරන්න).

---

## 🌐 100% නොමිලේ Tunnel (No Payment / No API Key!)

* **Default (`bore.pub`):** කිසිදු Account එකක්, API Key එකක් හෝ Credit Card එකක් අවශ්‍ය නොවේ! Server එක start වූ සැණින් `bore.pub:<PORT>` ලෙස Live IP සහ Port එක **SERVER_STATUS.md** සහ **Actions Summary** හි පෙන්වයි.
* **Backup (`pinggy`):** `pinggy.io` SSH TCP tunnel.
* **Playit.gg (`playit`):** Playit.gg වල API key ගන්න ගෙවන්න අවශ්‍ය නෑ — `tunnel_provider: playit` දුන්නම console එකේ free claim link එකක් එනවා, නමුත් **`bore.pub` තෝරා තැබීමෙන් කිසිම step එකක් නැතිව කෙලින්ම connect වෙන්න පුළුවන්!**

---

## 🚀 Start කරන ආකාරය & Connect වන ආකාරය

1. **Actions** -> **Terraria 24/7 Dedicated Server** -> **Run workflow** click කරන්න.
2. විනාඩි 1-2 කින් [SERVER_STATUS.md](./SERVER_STATUS.md) file එකේ හෝ Actions run එකේ **Summary** හි ඇති:
   * **Server IP:** `bore.pub`
   * **Port:** (එහි පෙන්වන අංක 5 ක Port එක, උදා: `41234`)
3. Terraria Game එකේ **Multiplayer -> Join via IP** ගොස් එම IP සහ Port එක ගසා Join වන්න!
