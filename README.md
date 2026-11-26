# 🌲 Terraria 1.4.6.1 Dedicated Server (24/7 GitHub Actions Cloud Runner)

![Terraria 1.4.6.1](https://img.shields.io/badge/Terraria-1.4.6.1-green.svg)
![World Size](https://img.shields.io/badge/World-Large%20(8400x2400)-blue.svg)
![Uptime](https://img.shields.io/badge/Hosting-24%2F7%20Continuous%20Cloud-gold.svg)
![Zero PC Load](https://img.shields.io/badge/Local%20PC-0%25%20Load-success.svg)

ඔබගේ පරිගණකයේ (Laptop) කිසිදු file එකක් download නොවී, RAM හෝ CPU වැය නොවී, **GitHub Cloud Actions Runners** මත 100% නොමිලේ **Terraria 1.4.6.1 Dedicated Server** එකක් 24/7 අඛණ්ඩව ක්‍රියාත්මක කර ගැනීමට මෙම Repository එක සකසා ඇත.

---

## ✨ ප්‍රධාන විශේෂාංග (Key Features)

* 🌍 **Large World (8400 x 2400 tiles):** උපරිම ඉඩකඩ සහිත අලුත්ම Large World එකක් ස්වයංක්‍රීයව Cloud එකෙහි generate වේ.
* ☁️ **Zero PC Burden:** සියලුම binaries සහ world files ධාවනය වන්නේ GitHub Cloud Server (Ubuntu Runner) එකෙහි පමණි. ඔබගේ ලැප්ටොප් එකට කිසිවක් download නොවේ.
* 🔄 **24/7 Continuous Loop:** GitHub Actions වල පවතින පැය 6 සීමාව (6-hour timeout) කළමනාකරණය කරමින්, ყოველ පැය 5.5 කට වරක් World එක safe-save කර, git repository එකට commit කර, ඊළඟ 24/7 cycle එකට ස්වයංක්‍රීයව trigger වේ. කිසිදු World progress එකක් නැති නොවේ.
* 🌐 **Dual Tunnel Support:**
  * **Playit.gg (Default):** කිසිදු port-forwarding හෝ public IP අවශ්‍ය නැත. Permanent domain එකක් ලැබේ.
  * **ngrok:** `NGROK_AUTHTOKEN` ඇතුළත් කළ විට අධිවේගී low-ping TCP tunnel එකක් ලැබේ.
* 📱 **Cross-Play Ready:** PC සහ Mobile Terraria players ලාට පහසුවෙන් connect විය හැක.

---

## 🚀 සර්වර් එක Start කරන ආකාරය (How to Run - 1 Click)

1. මෙම Repository එකෙහි **Actions** tab එක වෙත යන්න.
2. වම් පස ඇති **"Terraria 24/7 Dedicated Server"** workflow එක click කරන්න.
3. දකුණු පස ඇති **"Run workflow"** නිල් පාට බොත්තම click කරන්න.
4. අවශ්‍ය නම් Settings තෝරා **"Run workflow"** ඔබන්න:
   * **Version:** `1461` (Terraria 1.4.6.1)
   * **World Size:** `3` (Large World)
   * **Difficulty:** `1` (Expert) හෝ `0` (Classic) හෝ `2` (Master)
   * **Auto Restart:** `true` (24/7 දිගටම run වීමට)

---

## 🎮 Server එකට Connect වන ආකාරය (How to Connect)

1. GitHub Actions හි ධාවනය වන job එක click කර **"Launch 24/7 Terraria Dedicated Server & Tunnel"** හෝ **Summary** බලන්න.
2. එහි දිස්වන **Server IP / Host** සහ **Port** (උදාහරණයක් ලෙස: `0.tcp.ngrok.io` සහ port: `14253` හෝ Playit.gg address) සටහන් කර ගන්න.
3. ඔබගේ Terraria Game එක Open කරන්න:
   * **Multiplayer** -> **Join via IP**
   * Server IP එක සහ Port එක ඇතුළත් කරන්න.
   * Large World එකට login වී යහළුවන් සමඟ ක්‍රීඩා කරන්න! 🍿

---

## 🔑 Permanent IP එකක් ලබා ගැනීම (Optional Settings)

Server එක restart වන සෑම අවස්ථාවකම එකම IP / Domain එකක් ලබා ගැනීමට:
1. [playit.gg](https://playit.gg) හි නොමිලේ account එකක් සාදා **Secret Key** එකක් ගන්න (හෝ [ngrok.com](https://ngrok.com) වෙතින් Auth Token එකක් ගන්න).
2. GitHub Repository එකේ **Settings** -> **Secrets and variables** -> **Actions** වෙත යන්න.
3. **New repository secret** click කර:
   * Name: `PLAYIT_SECRET_KEY` (හෝ `NGROK_AUTHTOKEN`)
   * Value: ඔබගේ token එක paste කර save කරන්න.
4. දැන් සර්වර් එක restart වුවද සැමවිටම එකම IP එකෙන් connect විය හැක!

---

## 💾 World Auto-Save & Backup

* සර්වර් එක ක්‍රියාත්මක වන අතරතුර සෑම විනාඩි 10 කට වරක් ලෝකය ස්වයංක්‍රීයව save වේ.
* සෑම restart එකකදීම updated `.wld` file එක මෙම repository එකේ `worlds/` folder එකට git commit එකක් මඟින් sync වේ.
* කිසිදු Building එකක්, Chest එකක් හෝ Item එකක් නැති නොවේ.
