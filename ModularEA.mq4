//+------------------------------------------------------------------+
//|                                                   ModularEA.mq4 |
//|                        Copyright 2018, Professional EA Developer |
//|                                https://github.com/your-username |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Professional EA Developer"
#property link      "https://github.com/your-username"
#property version   "1.00"
#property strict

// Include modular components
#include "include/trade_utils.mqh"
#include "include/risk_management.mqh"
#include "include/entry_logic.mqh"
#include "include/common_defines.mqh"

//--- Input parameters
input double   RiskPercent = 1.0;        // Risk percentage per trade
input int      MagicNumber = 12345;      // Magic number for this EA
input int      MaxOpenTrades = 3;        // Maximum concurrent trades
input int      MinTradeInterval = 60;    // Minimum seconds between trades
input bool     EnableBuyTrades = true;   // Enable buy trades
input bool     EnableSellTrades = true;  // Enable sell trades
input double   TakeProfitPips = 100.0;   // Take profit in pips
input double   StopLossPips = 50.0;      // Stop loss in pips
input bool     EnableTrailing = true;    // Enable trailing stop
input double   TrailingStopPips = 30.0;  // Trailing stop distance in pips
input bool     ShowInfoPanel = true;     // Show information panel

//--- Global variables
datetime lastTradeTime = 0;
TradeUtils tradeUtils;
RiskManager riskManager;
EntryLogic entryLogic;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("ModularEA v1.00 - Initializing...");
    
    // Initialize trade utilities
    if(!tradeUtils.Initialize(MagicNumber, TakeProfitPips, StopLossPips, TrailingStopPips))
    {
        Print("ERROR: Failed to initialize TradeUtils module");
        return(INIT_FAILED);
    }
    
    // Initialize risk manager
    if(!riskManager.Initialize(RiskPercent))
    {
        Print("ERROR: Failed to initialize RiskManager module");
        return(INIT_FAILED);
    }
    
    // Initialize entry logic
    if(!entryLogic.Initialize())
    {
        Print("ERROR: Failed to initialize EntryLogic module");
        return(INIT_FAILED);
    }
    
    Print("ModularEA initialized successfully");
    Print("Configuration: Risk=", RiskPercent, "%, MaxTrades=", MaxOpenTrades);
    Print("TP=", TakeProfitPips, "pips, SL=", StopLossPips, "pips");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("ModularEA deinitialized. Reason code: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Update trailing stops for existing positions
    if(EnableTrailing)
    {
        tradeUtils.UpdateTrailingStops();
    }
    
    // Check if we can open new trades
    if(!CanOpenNewTrade())
        return;
    
    // Check entry conditions
    int signal = entryLogic.GetEntrySignal();
    
    if(signal == SIGNAL_BUY && EnableBuyTrades)
    {
        OpenBuyTrade();
    }
    else if(signal == SIGNAL_SELL && EnableSellTrades)
    {
        OpenSellTrade();
    }
    
    // Show info panel if enabled
    if(ShowInfoPanel)
    {
        ShowInformationPanel();
    }
}

//+------------------------------------------------------------------+
//| Check if we can open a new trade                                 |
//+------------------------------------------------------------------+
bool CanOpenNewTrade()
{
    // Check maximum open trades
    if(tradeUtils.GetOpenTradesCount() >= MaxOpenTrades)
        return false;
    
    // Check minimum time interval
    if(TimeCurrent() - lastTradeTime < MinTradeInterval)
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Open a buy trade                                                 |
//+------------------------------------------------------------------+
void OpenBuyTrade()
{
    double lotSize = riskManager.CalculatePositionSize(StopLossPips);
    
    if(lotSize > 0)
    {
        if(tradeUtils.OpenBuyOrder(lotSize))
        {
            lastTradeTime = TimeCurrent();
            Print("Buy order opened: ", lotSize, " lots");
        }
        else
        {
            Print("Failed to open buy order");
        }
    }
    else
    {
        Print("Invalid lot size calculated for buy trade");
    }
}

//+------------------------------------------------------------------+
//| Open a sell trade                                                |
//+------------------------------------------------------------------+
void OpenSellTrade()
{
    double lotSize = riskManager.CalculatePositionSize(StopLossPips);
    
    if(lotSize > 0)
    {
        if(tradeUtils.OpenSellOrder(lotSize))
        {
            lastTradeTime = TimeCurrent();
            Print("Sell order opened: ", lotSize, " lots");
        }
        else
        {
            Print("Failed to open sell order");
        }
    }
    else
    {
        Print("Invalid lot size calculated for sell trade");
    }
}

//+------------------------------------------------------------------+
//| Show information panel on chart                                  |
//+------------------------------------------------------------------+
void ShowInformationPanel()
{
    string info = "";
    info += "ModularEA v1.00\n";
    info += "Risk: " + DoubleToStr(RiskPercent, 1) + "%\n";
    info += "Open: " + IntegerToString(tradeUtils.GetOpenTradesCount()) + "/" + IntegerToString(MaxOpenTrades) + "\n";
    info += "Balance: $" + DoubleToStr(AccountBalance(), 2) + "\n";
    info += "Equity: $" + DoubleToStr(AccountEquity(), 2) + "\n";
    info += "Margin: $" + DoubleToStr(AccountFreeMargin(), 2) + "\n";
    info += "Spread: " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 1) + " pips\n";
    
    Comment(info);
}

//+------------------------------------------------------------------+ 