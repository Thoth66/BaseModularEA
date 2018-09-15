//+------------------------------------------------------------------+
//|                                             risk_management.mqh |
//|                        Copyright 2018, Professional EA Developer |
//|                                 https://github.com/your-username |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Professional EA Developer"
#property link      "https://github.com/your-username"
#property strict

#include "common_defines.mqh"

//+------------------------------------------------------------------+
//| Risk Management Class                                            |
//+------------------------------------------------------------------+
class RiskManager
{
private:
    double m_riskPercent;         // Risk percentage per trade
    double m_maxRiskPercent;      // Maximum allowed risk
    double m_minLotSize;          // Minimum lot size
    double m_maxLotSize;          // Maximum lot size
    double m_lotStep;             // Lot step
    
public:
    //--- Constructor
    RiskManager();
    
    //--- Initialization
    bool Initialize(double riskPercent);
    
    //--- Position sizing methods
    double CalculatePositionSize(double stopLossPips);
    double CalculatePositionSizeFixed(double fixedAmount);
    double CalculatePositionSizeByBalance(double lotPerBalance);
    
    //--- Risk validation methods
    bool ValidateRiskParameters();
    bool IsRiskAcceptable(double lotSize, double stopLossPips);
    double GetMaxAllowedLotSize();
    
    //--- Utility methods
    double NormalizeLotSize(double lotSize);
    double GetRiskAmount(double lotSize, double stopLossPips);
    double GetRiskPercent() { return m_riskPercent; }
    
    //--- Account information methods
    double GetAccountRiskAmount();
    double GetFreeMarginPercent();
    bool IsMarginSufficient(double lotSize);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
RiskManager::RiskManager()
{
    m_riskPercent = 1.0;
    m_maxRiskPercent = MAX_RISK_PERCENT;
    m_minLotSize = 0.0;
    m_maxLotSize = 0.0;
    m_lotStep = 0.0;
}

//+------------------------------------------------------------------+
//| Initialize the Risk Manager                                      |
//+------------------------------------------------------------------+
bool RiskManager::Initialize(double riskPercent)
{
    Print("RiskManager: Initializing with ", riskPercent, "% risk");
    
    // Validate risk percent
    if(riskPercent < MIN_RISK_PERCENT || riskPercent > MAX_RISK_PERCENT)
    {
        Print("ERROR: Invalid risk percent: ", riskPercent);
        return false;
    }
    
    m_riskPercent = riskPercent;
    
    // Get symbol information
    m_minLotSize = MarketInfo(Symbol(), MODE_MINLOT);
    m_maxLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
    m_lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    
    Print("Lot settings: Min=", m_minLotSize, ", Max=", m_maxLotSize, ", Step=", m_lotStep);
    
    return ValidateRiskParameters();
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk percentage                 |
//+------------------------------------------------------------------+
double RiskManager::CalculatePositionSize(double stopLossPips)
{
    if(stopLossPips <= 0)
    {
        Print("[RiskManager] ERROR: Invalid stop loss pips: ", stopLossPips);
        return 0.0;
    }
    
    // Calculate risk amount in account currency
    double riskAmount = GetAccountRiskAmount();
    
    // Convert stop loss pips to points
    double stopLossPoints = PIPS_TO_POINTS(stopLossPips);
    
    // Calculate tick value
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    if(tickValue == 0)
    {
        Print("[RiskManager] ERROR: Unable to get tick value");
        return 0.0;
    }
    
    // Calculate lot size
    double lotSize = riskAmount / (stopLossPoints * tickValue);
    
    // Normalize and validate lot size
    lotSize = NormalizeLotSize(lotSize);
    
    Print("[RiskManager] Calculated lot size: ", lotSize, " for SL: ", stopLossPips, " pips");
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Calculate position size with fixed amount                        |
//+------------------------------------------------------------------+
double RiskManager::CalculatePositionSizeFixed(double fixedAmount)
{
    if(fixedAmount <= 0 || fixedAmount > AccountBalance())
    {
        Print("[RiskManager] ERROR: Invalid fixed amount: ", fixedAmount);
        return 0.0;
    }
    
    // This is a simplified calculation - in real trading, you'd need
    // to consider the specific stop loss distance
    double lotSize = fixedAmount / 1000.0; // Example calculation
    
    return NormalizeLotSize(lotSize);
}

//+------------------------------------------------------------------+
//| Calculate position size based on balance ratio                   |
//+------------------------------------------------------------------+
double RiskManager::CalculatePositionSizeByBalance(double lotPerBalance)
{
    if(lotPerBalance <= 0)
    {
        Print("[RiskManager] ERROR: Invalid lot per balance ratio: ", lotPerBalance);
        return 0.0;
    }
    
    double balance = AccountBalance();
    double lotSize = (balance / 1000.0) * lotPerBalance; // 1 lot per 1000 units
    
    return NormalizeLotSize(lotSize);
}

//+------------------------------------------------------------------+
//| Validate risk management parameters                              |
//+------------------------------------------------------------------+
bool RiskManager::ValidateRiskParameters()
{
    if(m_minLotSize <= 0 || m_maxLotSize <= 0 || m_lotStep <= 0)
    {
        Print("[RiskManager] ERROR: Invalid lot parameters from broker");
        return false;
    }
    
    if(m_minLotSize > m_maxLotSize)
    {
        Print("[RiskManager] ERROR: Min lot size is greater than max lot size");
        return false;
    }
    
    if(AccountBalance() <= 0)
    {
        Print("[RiskManager] ERROR: Invalid account balance");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if risk is acceptable for the trade                        |
//+------------------------------------------------------------------+
bool RiskManager::IsRiskAcceptable(double lotSize, double stopLossPips)
{
    double riskAmount = GetRiskAmount(lotSize, stopLossPips);
    double maxRiskAmount = AccountBalance() * (m_maxRiskPercent / 100.0);
    
    if(riskAmount > maxRiskAmount)
    {
        Print("[RiskManager] WARNING: Risk amount ", riskAmount, " exceeds maximum allowed: ", maxRiskAmount);
        return false;
    }
    
    return IsMarginSufficient(lotSize);
}

//+------------------------------------------------------------------+
//| Get maximum allowed lot size                                     |
//+------------------------------------------------------------------+
double RiskManager::GetMaxAllowedLotSize()
{
    double maxByRisk = (AccountBalance() * m_maxRiskPercent / 100.0) / 100.0; // Simplified
    double maxByBroker = m_maxLotSize;
    double maxByMargin = AccountFreeMargin() / MarketInfo(Symbol(), MODE_MARGINREQUIRED);
    
    double maxLot = MathMin(maxByRisk, MathMin(maxByBroker, maxByMargin));
    
    return NormalizeLotSize(maxLot);
}

//+------------------------------------------------------------------+
//| Normalize lot size according to broker requirements              |
//+------------------------------------------------------------------+
double RiskManager::NormalizeLotSize(double lotSize)
{
    if(lotSize < m_minLotSize)
        return 0.0; // Too small to trade
    
    if(lotSize > m_maxLotSize)
        lotSize = m_maxLotSize;
    
    // Round to lot step
    double normalizedLot = MathRound(lotSize / m_lotStep) * m_lotStep;
    
    return NORMALIZE_LOT(normalizedLot);
}

//+------------------------------------------------------------------+
//| Calculate risk amount for given lot size and stop loss          |
//+------------------------------------------------------------------+
double RiskManager::GetRiskAmount(double lotSize, double stopLossPips)
{
    double stopLossPoints = PIPS_TO_POINTS(stopLossPips);
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    
    return lotSize * stopLossPoints * tickValue;
}

//+------------------------------------------------------------------+
//| Get account risk amount based on risk percentage                 |
//+------------------------------------------------------------------+
double RiskManager::GetAccountRiskAmount()
{
    return AccountBalance() * (m_riskPercent / 100.0);
}

//+------------------------------------------------------------------+
//| Get free margin percentage                                       |
//+------------------------------------------------------------------+
double RiskManager::GetFreeMarginPercent()
{
    double equity = AccountEquity();
    if(equity <= 0) return 0.0;
    
    return (AccountFreeMargin() / equity) * 100.0;
}

//+------------------------------------------------------------------+
//| Check if margin is sufficient for the trade                      |
//+------------------------------------------------------------------+
bool RiskManager::IsMarginSufficient(double lotSize)
{
    double marginRequired = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * lotSize;
    double freeMargin = AccountFreeMargin();
    
    if(marginRequired > freeMargin * 0.8) // Use 80% of free margin as safety buffer
    {
        Print("[RiskManager] WARNING: Insufficient margin. Required: ", marginRequired, ", Available: ", freeMargin);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+ 