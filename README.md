# ModularEA - Professional MT4 Expert Advisor

A professional-grade modular Expert Advisor for MetaTrader 4, showcasing advanced software architecture and risk management practices developed in 2018.

## Important Notice

**This project demonstrates modular EA architecture and does not contain production trading strategies.**

- Contains simplified demo strategies
- Production algorithms are proprietary
- For educational and portfolio purposes

## Technical Architecture

### Modular Design

```
ModularEA/
├── ModularEA.mq4              # Main EA file
├── include/
│   ├── common_defines.mqh     # Common definitions
│   ├── risk_management.mqh    # Risk management module
│   ├── trade_utils.mqh        # Trading utilities
│   └── entry_logic.mqh        # Entry logic (demo)
├── backtests/                 # Backtest results (demo data)
└── docs/                      # Documentation
```

### Core Modules

#### Risk Management (risk_management.mqh)

- Risk percentage-based position sizing
- Dynamic lot size calculation
- Margin sufficiency checks
- Multiple position sizing methods

#### Trading Utils (trade_utils.mqh)

- Automated order execution
- Trailing stop functionality
- Order retry mechanism
- Trading statistics tracking

#### Entry Logic (entry_logic.mqh)

- Demo trend following strategy
- Demo mean reversion strategy
- Demo pattern recognition
- Market condition analysis framework

## Input Parameters

| Parameter        | Type   | Default | Description               |
| ---------------- | ------ | ------- | ------------------------- |
| RiskPercent      | double | 1.0     | Risk percentage per trade |
| MagicNumber      | int    | 12345   | EA identification number  |
| MaxOpenTrades    | int    | 3       | Maximum concurrent trades |
| TakeProfitPips   | double | 100.0   | Take profit in pips       |
| StopLossPips     | double | 50.0    | Stop loss in pips         |
| TrailingStopPips | double | 30.0    | Trailing stop distance    |

## Risk Management Features

### Dynamic Position Sizing

```mql4
// Risk percentage-based lot calculation
double lotSize = riskManager.CalculatePositionSize(stopLossPips);

// Risk validation
if(riskManager.IsRiskAcceptable(lotSize, stopLossPips)) {
    // Execute trade
}
```

### Multi-layer Risk Control

1. Account-level risk limits
2. Per-trade risk percentage
3. Margin management
4. Maximum position limits

## Code Quality Features

### Object-Oriented Design

- Encapsulated class structures
- Clear separation of responsibilities
- Reusable modular components

### Error Handling

- Complete error code mapping
- Retry mechanisms
- Detailed logging

### Code Standards

- Consistent naming conventions
- Comprehensive function documentation
- Clean code structure

## Installation

1. Copy all files to MT4 MQL4/Experts/ directory
2. Copy include/ folder to MQL4/Include/ directory
3. Compile ModularEA.mq4 in MetaTrader 4

## Configuration

1. Attach EA to chart
2. Adjust risk parameters (recommended: max 2% risk)
3. Set stop loss and take profit targets
4. Enable auto trading

## Monitoring

The EA displays an information panel showing:

- Current risk settings
- Open trade statistics
- Account information summary
- Real-time spread information

## Backtest Information

> Note: Included backtest results are for demonstration purposes using simulated data.

The backtests folder contains:

- Demo equity curve charts
- Simulated trading statistics
- Example risk metrics

## Technical Implementation Highlights

### 2018 Advanced Features

- Modular architecture (component-based design)
- Dynamic risk management (adaptive position sizing)
- Object-oriented programming (OOP concepts in MQL4)
- Error recovery mechanisms (robust exception handling)
- Configuration-driven design (flexible parameter control)

### Extensibility Design

- Easy addition of new trading strategies
- Pluggable risk management strategies
- Modular market analysis components
- Standardized interface design

## System Requirements

- MetaTrader 4 Build 600+
- Windows operating system
- Minimum 1MB available memory

## License

MIT License - See LICENSE file for details

## Contribution

This project serves as a portfolio demonstration and does not accept external contributions. Technical discussions are welcome in Issues.

## Contact

- Author: Professional EA Developer
- Year: 2018
- Purpose: Technical demonstration / Portfolio

---

**Note: This EA uses simplified strategies for demonstration purposes.**
