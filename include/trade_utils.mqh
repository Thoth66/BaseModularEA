//+------------------------------------------------------------------+
//|                                                  trade_utils.mqh |
//|                        Copyright 2018, Professional EA Developer |
//|                                 https://github.com/your-username |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Professional EA Developer"
#property link      "https://github.com/your-username"
#property strict

#include "common_defines.mqh"

//+------------------------------------------------------------------+
//| Trade Utilities Class                                            |
//+------------------------------------------------------------------+
class TradeUtils
{
private:
    int m_magicNumber;           // Magic number for EA orders
    double m_takeProfitPips;     // Take profit in pips
    double m_stopLossPips;       // Stop loss in pips
    double m_trailingStopPips;   // Trailing stop distance in pips
    int m_slippage;              // Maximum slippage in points
    
public:
    //--- Constructor
    TradeUtils();
    
    //--- Initialization
    bool Initialize(int magicNumber, double takeProfitPips, double stopLossPips, double trailingStopPips);
    
    //--- Order management methods
    bool OpenBuyOrder(double lotSize);
    bool OpenSellOrder(double lotSize);
    bool CloseOrder(int ticket);
    bool CloseAllOrders();
    
    //--- Position management
    void UpdateTrailingStops();
    bool SetTrailingStop(int ticket, double trailingStopPips);
    
    //--- Information methods
    int GetOpenTradesCount();
    int GetBuyTradesCount();
    int GetSellTradesCount();
    double GetTotalProfit();
    
    //--- Utility methods
    bool IsOrderValid(int ticket);
    double CalculateStopLoss(int orderType, double openPrice);
    double CalculateTakeProfit(int orderType, double openPrice);
    
private:
    //--- Helper methods
    bool ExecuteOrder(int orderType, double lotSize, double price, double stopLoss, double takeProfit, string comment);
    bool RetryOrderExecution(int orderType, double lotSize, double stopLoss, double takeProfit, string comment);
    void LogTradeResult(int ticket, bool success, string operation);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
TradeUtils::TradeUtils()
{
    m_magicNumber = 0;
    m_takeProfitPips = 0.0;
    m_stopLossPips = 0.0;
    m_trailingStopPips = 0.0;
    m_slippage = MAX_SLIPPAGE;
}

//+------------------------------------------------------------------+
//| Initialize the Trade Utils                                       |
//+------------------------------------------------------------------+
bool TradeUtils::Initialize(int magicNumber, double takeProfitPips, double stopLossPips, double trailingStopPips)
{
    Print("TradeUtils: Initializing with Magic Number ", magicNumber);
    
    if(magicNumber <= 0)
    {
        Print("ERROR: Invalid magic number: ", magicNumber);
        return false;
    }
    
    m_magicNumber = magicNumber;
    m_takeProfitPips = takeProfitPips;
    m_stopLossPips = stopLossPips;
    m_trailingStopPips = trailingStopPips;
    
    Print("TP=", m_takeProfitPips, "pips, SL=", m_stopLossPips, "pips, Trailing=", m_trailingStopPips, "pips");
    
    return true;
}

//+------------------------------------------------------------------+
//| Open a buy order                                                 |
//+------------------------------------------------------------------+
bool TradeUtils::OpenBuyOrder(double lotSize)
{
    if(!IsTradingAllowed())
        return false;
    
    double price = Ask;
    double stopLoss = CalculateStopLoss(OP_BUY, price);
    double takeProfit = CalculateTakeProfit(OP_BUY, price);
    
    string comment = "ModularEA Buy " + TimeToStr(TimeCurrent());
    
    return RetryOrderExecution(OP_BUY, lotSize, stopLoss, takeProfit, comment);
}

//+------------------------------------------------------------------+
//| Open a sell order                                                |
//+------------------------------------------------------------------+
bool TradeUtils::OpenSellOrder(double lotSize)
{
    if(!IsTradingAllowed())
        return false;
    
    double price = Bid;
    double stopLoss = CalculateStopLoss(OP_SELL, price);
    double takeProfit = CalculateTakeProfit(OP_SELL, price);
    
    string comment = "ModularEA Sell " + TimeToStr(TimeCurrent());
    
    return RetryOrderExecution(OP_SELL, lotSize, stopLoss, takeProfit, comment);
}

//+------------------------------------------------------------------+
//| Close an order by ticket                                         |
//+------------------------------------------------------------------+
bool TradeUtils::CloseOrder(int ticket)
{
    if(!OrderSelect(ticket, SELECT_BY_TICKET))
    {
        Print("[TradeUtils] ERROR: Cannot select order ", ticket);
        return false;
    }
    
    if(OrderMagicNumber() != m_magicNumber)
    {
        Print("[TradeUtils] ERROR: Order ", ticket, " does not belong to this EA");
        return false;
    }
    
    bool result = false;
    double price = (OrderType() == OP_BUY) ? Bid : Ask;
    
    for(int i = 0; i < RETRY_COUNT; i++)
    {
        result = OrderClose(ticket, OrderLots(), price, m_slippage, clrNONE);
        
        if(result)
        {
            Print("[TradeUtils] Order ", ticket, " closed successfully");
            break;
        }
        else
        {
            int error = GetLastError();
            Print("[TradeUtils] Failed to close order ", ticket, ". Error: ", error, " - ", GetErrorDescription(error));
            
            if(error == ERR_INVALID_PRICE || error == ERR_PRICE_CHANGED)
            {
                price = (OrderType() == OP_BUY) ? Bid : Ask;
                Sleep(RETRY_DELAY);
                continue;
            }
            else
            {
                break;
            }
        }
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Close all orders belonging to this EA                            |
//+------------------------------------------------------------------+
bool TradeUtils::CloseAllOrders()
{
    bool allClosed = true;
    
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == m_magicNumber)
        {
            if(!CloseOrder(OrderTicket()))
            {
                allClosed = false;
            }
        }
    }
    
    return allClosed;
}

//+------------------------------------------------------------------+
//| Update trailing stops for all open positions                     |
//+------------------------------------------------------------------+
void TradeUtils::UpdateTrailingStops()
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == m_magicNumber)
        {
            SetTrailingStop(OrderTicket(), m_trailingStopPips);
        }
    }
}

//+------------------------------------------------------------------+
//| Set trailing stop for a specific order                           |
//+------------------------------------------------------------------+
bool TradeUtils::SetTrailingStop(int ticket, double trailingStopPips)
{
    if(!OrderSelect(ticket, SELECT_BY_TICKET))
        return false;
    
    if(OrderType() != OP_BUY && OrderType() != OP_SELL)
        return false;
    
    double trailingStopPoints = PIPS_TO_POINTS(trailingStopPips);
    double newStopLoss = 0.0;
    
    if(OrderType() == OP_BUY)
    {
        newStopLoss = Bid - trailingStopPoints;
        
        // Only move stop loss up (in profit direction)
        if(OrderStopLoss() == 0.0 || newStopLoss > OrderStopLoss())
        {
            newStopLoss = NORMALIZE_PRICE(newStopLoss);
            
            if(OrderModify(ticket, OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, clrNONE))
            {
                Print("[TradeUtils] Trailing stop updated for Buy order ", ticket, " to ", newStopLoss);
                return true;
            }
        }
    }
    else if(OrderType() == OP_SELL)
    {
        newStopLoss = Ask + trailingStopPoints;
        
        // Only move stop loss down (in profit direction)
        if(OrderStopLoss() == 0.0 || newStopLoss < OrderStopLoss())
        {
            newStopLoss = NORMALIZE_PRICE(newStopLoss);
            
            if(OrderModify(ticket, OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, clrNONE))
            {
                Print("[TradeUtils] Trailing stop updated for Sell order ", ticket, " to ", newStopLoss);
                return true;
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Get count of open trades for this EA                             |
//+------------------------------------------------------------------+
int TradeUtils::GetOpenTradesCount()
{
    int count = 0;
    
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == m_magicNumber)
        {
            count++;
        }
    }
    
    return count;
}

//+------------------------------------------------------------------+
//| Get count of buy trades                                           |
//+------------------------------------------------------------------+
int TradeUtils::GetBuyTradesCount()
{
    int count = 0;
    
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == m_magicNumber && OrderType() == OP_BUY)
        {
            count++;
        }
    }
    
    return count;
}

//+------------------------------------------------------------------+
//| Get count of sell trades                                          |
//+------------------------------------------------------------------+
int TradeUtils::GetSellTradesCount()
{
    int count = 0;
    
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == m_magicNumber && OrderType() == OP_SELL)
        {
            count++;
        }
    }
    
    return count;
}

//+------------------------------------------------------------------+
//| Get total profit of all open trades                              |
//+------------------------------------------------------------------+
double TradeUtils::GetTotalProfit()
{
    double totalProfit = 0.0;
    
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == m_magicNumber)
        {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
        }
    }
    
    return totalProfit;
}

//+------------------------------------------------------------------+
//| Calculate stop loss price                                        |
//+------------------------------------------------------------------+
double TradeUtils::CalculateStopLoss(int orderType, double openPrice)
{
    if(m_stopLossPips <= 0)
        return 0.0;
    
    double stopLossPoints = PIPS_TO_POINTS(m_stopLossPips);
    double stopLoss = 0.0;
    
    if(orderType == OP_BUY)
    {
        stopLoss = openPrice - stopLossPoints;
    }
    else if(orderType == OP_SELL)
    {
        stopLoss = openPrice + stopLossPoints;
    }
    
    return NORMALIZE_PRICE(stopLoss);
}

//+------------------------------------------------------------------+
//| Calculate take profit price                                      |
//+------------------------------------------------------------------+
double TradeUtils::CalculateTakeProfit(int orderType, double openPrice)
{
    if(m_takeProfitPips <= 0)
        return 0.0;
    
    double takeProfitPoints = PIPS_TO_POINTS(m_takeProfitPips);
    double takeProfit = 0.0;
    
    if(orderType == OP_BUY)
    {
        takeProfit = openPrice + takeProfitPoints;
    }
    else if(orderType == OP_SELL)
    {
        takeProfit = openPrice - takeProfitPoints;
    }
    
    return NORMALIZE_PRICE(takeProfit);
}

//+------------------------------------------------------------------+
//| Execute order with retry mechanism                               |
//+------------------------------------------------------------------+
bool TradeUtils::RetryOrderExecution(int orderType, double lotSize, double stopLoss, double takeProfit, string comment)
{
    bool result = false;
    
    for(int i = 0; i < RETRY_COUNT; i++)
    {
        double price = (orderType == OP_BUY) ? Ask : Bid;
        result = ExecuteOrder(orderType, lotSize, price, stopLoss, takeProfit, comment);
        
        if(result)
            break;
        
        Sleep(RETRY_DELAY);
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Execute order                                                    |
//+------------------------------------------------------------------+
bool TradeUtils::ExecuteOrder(int orderType, double lotSize, double price, double stopLoss, double takeProfit, string comment)
{
    int ticket = OrderSend(Symbol(), orderType, lotSize, price, m_slippage, stopLoss, takeProfit, comment, m_magicNumber, 0, clrNONE);
    
    bool success = (ticket > 0);
    LogTradeResult(ticket, success, (orderType == OP_BUY) ? "BUY" : "SELL");
    
    return success;
}

//+------------------------------------------------------------------+
//| Log trade result                                                 |
//+------------------------------------------------------------------+
void TradeUtils::LogTradeResult(int ticket, bool success, string operation)
{
    if(success)
    {
        Print("[TradeUtils] ", operation, " order opened successfully. Ticket: ", ticket);
    }
    else
    {
        int error = GetLastError();
        Print("[TradeUtils] Failed to open ", operation, " order. Error: ", error, " - ", GetErrorDescription(error));
    }
}

//+------------------------------------------------------------------+ 