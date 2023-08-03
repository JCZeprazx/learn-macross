//+------------------------------------------------------------------+
//|                                                     Belajar1.mq5 |
//|                                        Copyright 2023, JCZeprazx.|
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, JCZeprazx Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Header Files                                                     |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+

//Fast MA
input int FastMABars = 20;
input ENUM_MA_METHOD FastMethodMA = MODE_EMA;
input ENUM_APPLIED_PRICE FastAppliedPriceMA = PRICE_CLOSE;

//Slow MA
input int SlowMABars = 50;
input ENUM_MA_METHOD SlowMethodMA = MODE_EMA;
input ENUM_APPLIED_PRICE SlowAppliedPriceMA = PRICE_CLOSE;

//Settings
input double OrderLotSize = 0.01;
input int TakeProfitPoints = 20;
input int StopLossPoints = 20;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double TakeProfit;
double StopLoss;

//Indicator Handle
int FastHandle;
int SlowHandle;
double FastBuffer[];
double SlowBuffer[];

//+------------------------------------------------------------------+
//| Initialize object                                                |
//+------------------------------------------------------------------+
CTrade Trade;

//+------------------------------------------------------------------+
//| Points function                                                  |
//+------------------------------------------------------------------+
double PointsToDouble(int points)
  {
   return points * Point();
  }

//+------------------------------------------------------------------+
//| Checking account function                                        |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   return((bool)MQLInfoInteger(MQL_TRADE_ALLOWED)
          && (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)
          && (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)
          && (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
  }

//+------------------------------------------------------------------+
//| Checking new bar function                                        |
//+------------------------------------------------------------------+
bool IsNewBar(bool first_call = false)
  {
   static bool result = false;
   if(!first_call)
      return(result);

   static datetime previous_time = 0;
   datetime current_time         = iTime(Symbol(), Period(), 0);
   result                        = false;

   if(previous_time != current_time)
     {
      previous_time   = current_time;
      result          = true;
     }

   return (result);
  }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   TakeProfit = PointsToDouble(TakeProfitPoints);
   StopLoss = PointsToDouble(StopLossPoints);

   FastHandle = iMA(Symbol(), Period(), FastMABars, 0, FastMethodMA, FastAppliedPriceMA);
   ArraySetAsSeries(FastBuffer, true);

   SlowHandle = iMA(Symbol(), Period(), SlowMABars, 0, SlowMethodMA, SlowAppliedPriceMA);
   ArraySetAsSeries(SlowBuffer, true);

   if(FastHandle == INVALID_HANDLE || SlowHandle == INVALID_HANDLE)
     {
      return(INIT_FAILED);
     }

   IsNewBar(true);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(FastHandle);
   IndicatorRelease(SlowHandle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsTradeAllowed())
      return;
   if(!IsNewBar(true))
      return;

   if(CopyBuffer(FastHandle, 0, 0, 3, FastBuffer) < 3)
     {
      return;
     }

   if(CopyBuffer(SlowHandle, 0, 0, 3, SlowBuffer) < 3)
     {
      return;
     }
  }

//+------------------------------------------------------------------+
