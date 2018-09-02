//+------------------------------------------------------------------+
//|                                               common_defines.mqh |
//|                        Copyright 2018, Professional EA Developer |
//|                                 https://github.com/your-username |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Professional EA Developer"
#property link      "https://github.com/your-username"
#property strict

//--- Signal types
#define SIGNAL_NONE    0
#define SIGNAL_BUY     1
#define SIGNAL_SELL    2

//--- Trade result codes
#define TRADE_SUCCESS       0
#define TRADE_ERROR_GENERAL 1
#define TRADE_ERROR_PRICE   2
#define TRADE_ERROR_VOLUME  3
#define TRADE_ERROR_MARGIN  4

//--- Common constants
#define POINTS_TO_PIPS(points) (points / (Digits() == 5 || Digits() == 3 ? 10.0 : 1.0))
#define PIPS_TO_POINTS(pips)   (pips * (Digits() == 5 || Digits() == 3 ? 10.0 : 1.0))

//--- Risk management constants
#define MIN_LOT_SIZE       0.01
#define MAX_RISK_PERCENT   10.0
#define MIN_RISK_PERCENT   0.1

//--- Trading constants
#define MAX_SLIPPAGE       3
#define RETRY_COUNT        3
#define RETRY_DELAY        1000  // milliseconds

//--- Utility macros
#define NORMALIZE_PRICE(price)    NormalizeDouble(price, Digits())
#define NORMALIZE_LOT(lot)        NormalizeDouble(lot, 2)

//+------------------------------------------------------------------+
//| Error handling function                                          |
//+------------------------------------------------------------------+
string GetErrorDescription(int errorCode)
{
    string errorDesc = "";
    
    switch(errorCode)
    {
        case ERR_NO_ERROR:
            errorDesc = "No error";
            break;
        case ERR_NO_RESULT:
            errorDesc = "No error, but result is unknown";
            break;
        case ERR_COMMON_ERROR:
            errorDesc = "Common error";
            break;
        case ERR_INVALID_TRADE_PARAMETERS:
            errorDesc = "Invalid trade parameters";
            break;
        case ERR_SERVER_BUSY:
            errorDesc = "Trade server is busy";
            break;
        case ERR_OLD_VERSION:
            errorDesc = "Old version of the client terminal";
            break;
        case ERR_NO_CONNECTION:
            errorDesc = "No connection to trade server";
            break;
        case ERR_NOT_ENOUGH_RIGHTS:
            errorDesc = "Not enough rights";
            break;
        case ERR_TOO_FREQUENT_REQUESTS:
            errorDesc = "Too frequent requests";
            break;
        case ERR_MALFUNCTIONAL_TRADE:
            errorDesc = "Malfunctional trade operation";
            break;
        case ERR_ACCOUNT_DISABLED:
            errorDesc = "Account disabled";
            break;
        case ERR_INVALID_ACCOUNT:
            errorDesc = "Invalid account";
            break;
        case ERR_TRADE_TIMEOUT:
            errorDesc = "Trade timeout";
            break;
        case ERR_INVALID_PRICE:
            errorDesc = "Invalid price";
            break;
        case ERR_INVALID_STOPS:
            errorDesc = "Invalid stops";
            break;
        case ERR_INVALID_TRADE_VOLUME:
            errorDesc = "Invalid trade volume";
            break;
        case ERR_MARKET_CLOSED:
            errorDesc = "Market is closed";
            break;
        case ERR_TRADE_DISABLED:
            errorDesc = "Trade is disabled";
            break;
        case ERR_NOT_ENOUGH_MONEY:
            errorDesc = "Not enough money";
            break;
        case ERR_PRICE_CHANGED:
            errorDesc = "Price changed";
            break;
        case ERR_OFF_QUOTES:
            errorDesc = "Off quotes";
            break;
        case ERR_BROKER_BUSY:
            errorDesc = "Broker is busy";
            break;
        case ERR_REQUOTE:
            errorDesc = "Requote";
            break;
        case ERR_ORDER_LOCKED:
            errorDesc = "Order is locked";
            break;
        case ERR_LONG_POSITIONS_ONLY_ALLOWED:
            errorDesc = "Long positions only allowed";
            break;
        case ERR_TOO_MANY_REQUESTS:
            errorDesc = "Too many requests";
            break;
        default:
            errorDesc = "Unknown error: " + IntegerToString(errorCode);
            break;
    }
    
    return errorDesc;
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                      |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
    if(!IsTradeAllowed())
    {
        Print("Trading not allowed by server");
        return false;
    }
    
    if(!IsConnected())
    {
        Print("No connection to server");
        return false;
    }
    
    if(IsTradeContextBusy())
    {
        Print("Trade context busy");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+ 