# 📋 技術規格文檔 - ModularEA

## 🎯 系統概述

ModularEA 是一個展示 2018 年先進軟體工程實踐的 MQL4 專家顧問，採用模組化架構設計，注重代碼品質、錯誤處理和風險管理。

## 🏗️ 架構設計

### 系統架構圖

```
┌─────────────────────────────────────────────────────────────┐
│                    ModularEA.mq4                           │
│                    (主控制器)                                 │
└─────────────────┬───────────────┬───────────────┬───────────┘
                  │               │               │
         ┌────────▼────────┐ ┌───▼────────┐ ┌───▼────────┐
         │  risk_mgmt.mqh  │ │trade_utils │ │entry_logic │
         │   (風險管理)      │ │  (交易工具)  │ │ (進場邏輯)  │
         └─────────────────┘ └────────────┘ └────────────┘
                  │               │               │
         ┌────────▼─────────────────▼───────────────▼────────┐
         │              common_defines.mqh                  │
         │               (通用定義和工具)                      │
         └─────────────────────────────────────────────────┘
```

### 設計模式

#### 1. 模組化設計 (Modular Design)

- **責任分離**：每個模組負責特定功能領域
- **鬆耦合**：模組間依賴最小化
- **高內聚**：模組內功能邏輯緊密相關

#### 2. 物件導向設計 (OOP in MQL4)

- **封裝**：私有成員變數和方法
- **抽象**：清晰的公共接口
- **多型**：統一的方法命名約定

## 📦 模組詳細規格

### 1. 風險管理模組 (`risk_management.mqh`)

#### 類別：`RiskManager`

**職責：**

- 動態倉位計算
- 風險參數驗證
- 保證金管理
- 風險限制控制

**核心方法：**

```mql4
class RiskManager {
public:
    // 初始化
    bool Initialize(double riskPercent);

    // 倉位計算
    double CalculatePositionSize(double stopLossPips);
    double CalculatePositionSizeFixed(double fixedAmount);
    double CalculatePositionSizeByBalance(double lotPerBalance);

    // 風險驗證
    bool IsRiskAcceptable(double lotSize, double stopLossPips);
    bool IsMarginSufficient(double lotSize);

    // 工具方法
    double NormalizeLotSize(double lotSize);
    double GetRiskAmount(double lotSize, double stopLossPips);
};
```

**算法實現：**

```
倉位大小 = 風險金額 / (停損點數 × 點值)
風險金額 = 帳戶餘額 × 風險百分比
```

### 2. 交易工具模組 (`trade_utils.mqh`)

#### 類別：`TradeUtils`

**職責：**

- 訂單執行管理
- 追蹤止損實現
- 交易統計追蹤
- 錯誤處理和重試

**核心方法：**

```mql4
class TradeUtils {
public:
    // 訂單管理
    bool OpenBuyOrder(double lotSize);
    bool OpenSellOrder(double lotSize);
    bool CloseOrder(int ticket);
    bool CloseAllOrders();

    // 追蹤止損
    void UpdateTrailingStops();
    bool SetTrailingStop(int ticket, double trailingStopPips);

    // 統計信息
    int GetOpenTradesCount();
    double GetTotalProfit();
};
```

**錯誤處理機制：**

- 最多 3 次重試
- 價格變動自動重新獲取
- 詳細錯誤日誌記錄

### 3. 進場邏輯模組 (`entry_logic.mqh`)

#### 類別：`EntryLogic`

**職責：**

- 市場分析框架
- 信號生成邏輯
- 條件過濾機制
- 策略組合管理

**注意：** 此模組包含假邏輯，僅作技術展示

**核心方法：**

```mql4
class EntryLogic {
public:
    // 信號生成
    int GetEntrySignal();

    // 市場分析 (演示邏輯)
    bool AnalyzeMarketConditions();
    int GetTrendDirection();
    double GetMarketVolatility();
    bool IsBreakoutCondition();
    bool IsReversalCondition();
};
```

### 4. 通用定義模組 (`common_defines.mqh`)

**功能：**

- 常數定義
- 宏定義
- 錯誤處理函數
- 通用工具函數

**重要常數：**

```mql4
#define SIGNAL_NONE    0
#define SIGNAL_BUY     1
#define SIGNAL_SELL    2

#define POINTS_TO_PIPS(points) (points / (Digits() == 5 || Digits() == 3 ? 10.0 : 1.0))
#define PIPS_TO_POINTS(pips)   (pips * (Digits() == 5 || Digits() == 3 ? 10.0 : 1.0))
```

## 🔄 執行流程

### 主要執行循環

```
OnTick()
├── 更新追蹤止損
├── 檢查是否可開新倉
├── 獲取進場信號
├── 執行風險計算
├── 開倉執行
└── 更新資訊面板
```

### 風險控制流程

```
交易請求
├── 檢查交易許可
├── 計算倉位大小
├── 驗證風險參數
├── 檢查保證金充足性
├── 執行訂單
└── 記錄交易日誌
```

## 📊 性能特徵

### 時間複雜度

- 信號生成：O(n) - n 為技術指標計算週期
- 風險計算：O(1) - 常數時間
- 追蹤止損更新：O(m) - m 為開倉數量

### 空間複雜度

- 記憶體使用：< 1MB
- 歷史數據依賴：最多 100 根 K 線

### 執行效率

- 單次 OnTick 執行時間：< 5ms
- 開倉執行時間：< 100ms（包含重試）
- 系統資源佔用：極低

## 🛡️ 錯誤處理策略

### 分層錯誤處理

1. **MT4 錯誤碼映射**：完整的錯誤代碼描述
2. **重試機制**：網路和價格錯誤自動重試
3. **日誌記錄**：詳細的操作日誌
4. **優雅降級**：非關鍵錯誤不中斷執行

### 錯誤分類

- **致命錯誤**：停止 EA 執行
- **可恢復錯誤**：重試後繼續
- **警告錯誤**：記錄但不影響執行

## 🔧 配置管理

### 輸入參數分類

- **風險參數**：RiskPercent, MaxOpenTrades
- **策略參數**：TakeProfitPips, StopLossPips
- **系統參數**：MagicNumber, MinTradeInterval
- **顯示參數**：ShowInfoPanel

### 參數驗證

- 範圍檢查
- 類型驗證
- 邏輯一致性檢查

## 📈 監控和診斷

### 實時監控指標

- 開倉數量統計
- 風險暴露監控
- 系統性能指標
- 錯誤統計

### 診斷工具

- 詳細日誌系統
- 性能計時器
- 記憶體使用監控

## 🔮 擴展性設計

### 模組擴展點

- 新策略模組：實現 `IEntryLogic` 接口
- 風險管理策略：擴展 `RiskManager` 類別
- 交易執行器：自定義 `TradeUtils` 行為

### 配置擴展

- 外部配置檔案支援
- 動態參數調整
- 策略組合配置

## 📋 部署需求

### 系統需求

- **平台**：MetaTrader 4 Build 600+
- **操作系統**：Windows 7/8/10/11
- **記憶體**：最小 512MB 可用記憶體
- **處理器**：Intel/AMD 雙核以上

### 安裝需求

- MQL4 編譯器
- 管理員權限（首次安裝）
- 穩定的網路連接

---

**技術版本**：1.0  
**文檔版本**：2018.12  
**維護狀態**：作品集展示用途
