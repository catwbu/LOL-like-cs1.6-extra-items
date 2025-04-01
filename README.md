# CS1.6 AMX Mod X 插件集 - LOL 技能模擬

這是一個針對 **Counter-Strike 1.6 (CS1.6)** 的 AMX Mod X 插件集合，模擬《英雄聯盟》中「閃現」、「中婭沙漏」和「妖夢鬼刀」的技能，為遊戲增添趣味性與策略性。以下是插件的詳細介紹。

## 插件列表

1. [FLASH 插件](#1-flash-插件)
2. [Zhonya's Hourglass 插件](#2-zhonyas-hourglass-插件)
3. [妖夢鬼刀 插件](#3-妖夢鬼刀-插件)

---

## 1. FLASH 插件

### 功能介紹
模擬《英雄聯盟》的「閃現」技能，讓玩家瞬間傳送到瞄準方向的指定距離，並帶有冷卻時間與視覺效果。

- **指令**：`flash_use` - 啟動閃現。
- **傳送距離**：默認 500 單位（可通過 `zp_blink_range` 調整）。
- **冷卻時間**：默認 0 秒（可通過 `zp_blink_cooldown` 調整）。
- **無法攻擊時間**：閃現後短暫無法攻擊（默認 0 秒，可通過 `zp_blink_no_atk_time` 調整）。
- **視覺效果**：
  - 使用 `shockwave.spr` 顯示傳送起點與終點的黃色圓形光環。
  - 播放隨機音效（`flash_startX.wav` 和 `flash_overX.wav`）。
- **自動脫困**：
  - 啟用後檢測並釋放卡住的玩家（可通過 `amx_autounstuck` 控制，默認啟用）。
  - 脫困等待時間默認 7 次檢測（可通過 `amx_autounstuckwait` 調整）。
- **限制**：
  - 若目標位置有障礙物，傳送失敗並顯示「[閃現] 無法使用」。
  - 傳送後若卡住，自動嘗試移至附近空位。
- **用途**：增加移動靈活性，適合娛樂或特殊模式伺服器。

---

## 2. Zhonya's Hourglass 插件

### 功能介紹
模擬《英雄聯盟》中「中婭沙漏」的效果，讓玩家進入無敵並凍結狀態，持續 2.5 秒。

- **指令**：`gold_use` - 啟動沙漏效果。
- **效果**：
  - **無敵**：玩家不受任何傷害。
  - **凍結**：玩家無法移動或攻擊。
  - **持續時間**：固定 2.5 秒，結束後恢復正常。
- **視覺效果**：
  - 玩家被金色光芒包圍（RGB: 250, 250, 0）。
  - 螢幕顯示金色淡入效果，結束時恢復正常。
- **音效**：播放 `Hourglass.wav`。
- **冷卻時間**：短暫防誤觸間隔（0.5 秒）。
- **用途**：用於緊急防禦或戰術性停頓，適合生存或娛樂模式。

---

## 3. 妖夢鬼刀 插件

### 功能介紹
模擬《英雄聯盟》中「妖夢鬼刀」的加速效果，提升玩家移動速度，持續 6 秒。

- **指令**：`Youmuus_on` - 啟動加速效果。
- **效果**：
  - **速度提升**：基礎速度增加 20%（例如從 250 提升至 300）。
  - **最大速度**：設置為 9999，並提升前進、側移、後退速度至 9999。
  - **持續時間**：固定 6 秒，結束後恢復原始速度。
- **音效**：播放 `Youmuus.wav`。
- **限制**：
  - 僅限存活玩家使用。
  - 若武器更換，結束時速度不會恢復（需手動調整）。
- **用途**：提升機動性，適合快速突襲或逃跑，適用於跑圖或娛樂伺服器。

---

## 安裝方法

1. **編譯插件**：
   - 將 `.sma` 文件使用 AMX Mod X 編譯器轉換為 `.amxx` 文件。
2. **放置文件**：
   - 將編譯後的 `.amxx` 文件放入 `amxmodx/plugins` 目錄。
   - 將音效文件（`lol/*.wav`）放入 `sound/lol/` 目錄。
   - 將特效文件（`shockwave.spr`）放入 `sprites/` 目錄。
3. **啟用插件**：
   - 在 `amxmodx/configs/plugins.ini` 中添加插件名稱（例如 `FLASH.amxx`）。
4. **重啟伺服器**：
   - 重啟伺服器或使用 `amx_plugins` 重新載入插件。

---

## 使用說明

### FLASH 插件
- **啟動**：在控制台輸入 `flash_use` 或綁定按鍵（如 `bind "f" "flash_use"`）。
- **調整參數**：
  - `zp_blink_range <距離>`：設置傳送距離（例如 `zp_blink_range 800`）。
  - `zp_blink_cooldown <秒數>`：設置冷卻時間（例如 `zp_blink_cooldown 5`）。
  - `zp_blink_no_atk_time <秒數>`：設置無法攻擊時間（例如 `zp_blink_no_atk_time 2`）。
- **注意**：確保目標位置無障礙，否則傳送失敗。

### Zhonya's Hourglass 插件
- **啟動**：在控制台輸入 `gold_use` 或綁定按鍵（如 `bind "g" "gold_use"`）。
- **注意**：僅限存活玩家使用，每 0.5 秒可使用一次，避免連續觸發。

### 妖夢鬼刀 插件
- **啟動**：在控制台輸入 `Youmuus_on` 或綁定按鍵（如 `bind "h" "Youmuus_on"`）。
- **注意**：效果結束後若更換武器，需重新設置速度。

---

## 注意事項

- **資源需求**：確保伺服器和客戶端擁有必要的音效與特效文件，否則效果可能缺失。
- **平衡性**：這些插件可能影響遊戲平衡，建議在非競技環境使用。
- **相容性**：插件需 AMX Mod X 支援，可能與其他修改速度或狀態的插件衝突。

如需更多幫助，請聯繫作者（`schmurgel1983`, `zhiJIaN`, `Zero`）或參考 AMX Mod X 官方文檔！
