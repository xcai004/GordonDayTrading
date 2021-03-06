//+------------------------------------------------------------------+
//|                                           GordonDayTradingEA.mq4 |
//|                                             Copyright 2019, EFDT |
//|                                             https://www.mql5.com |
//|                                                          Author: |
//|                                                  Kristy Cardenas |
//|                                                       Xujing Cai |
//|                                               Luana Okino Sawada |
//|                                                 Alexander Monaco |
//|                                                    Vishnu Poonai |
//|                                           Mentor: Masoud Sadjadi |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers    0



#import "user32.dll"
   int  RegisterWindowMessageW(string MessageName);
   int  PostMessageW(int hwnd,int msg,int wparam,uchar &Name[]);
   int  FindWindowW(string lpszClass,string lpszWindow);
#import

#define VK_RETURN 13 //ENTER key

void StartCustomIndicator(int hWnd,string IndicatorName,bool AutomaticallyAcceptDefaults=true)
{
   Sleep(100);
   uchar name2[];
   StringToCharArray(IndicatorName,name2,0,StringLen(IndicatorName));
   int MessageNumber=RegisterWindowMessageW("MetaTrader4_Internal_Message");
   int r=PostMessageW(hWnd,MessageNumber,15,name2);
   Sleep(100);
   if(AutomaticallyAcceptDefaults) {
      int ind_settings = FindWindowW(NULL, "Custom Indicator - "+IndicatorName);
      PostMessageW(ind_settings,0x100,VK_RETURN,name2);
   }
}

void StartCustomIndicator2(int hWnd,string IndicatorName,bool AutomaticallyAcceptDefaults=true)
{
   Sleep(100);
   uchar name22[];
   StringToCharArray(IndicatorName,name22,0,StringLen(IndicatorName));
   int MessageNumber=RegisterWindowMessageW("MetaTrader4_Internal_Message");
   int r=PostMessageW(hWnd,MessageNumber,15,name22);
   Sleep(100);
   if(AutomaticallyAcceptDefaults) {
      int ind_settings = FindWindowW(NULL, "Custom Indicator - "+IndicatorName);
      PostMessageW(ind_settings,0x100,VK_RETURN,name22);
   }
}




//--- Input parameters
input int      test=5;
double highLine;
double lowLine;
//+------------------------------------------------------------------+
//| Extern parameters                                                |
//+------------------------------------------------------------------+
extern color fiboColor = Yellow;             
extern double fiboWidth = 1;
extern  double fiboStyle = 0;
extern color unretracedZoneColor = Green;
extern bool showUnretracedZone = true;

extern int RSIPeriod = 14;
extern int BANDPeriod = 20;
extern double deviation = 2;

extern double lots = 0.1;
extern int Fast_EMA = 47; 
extern int Slow_EMA = 166; 
extern int Signal_MA = 11;

extern double stopLoss = 0;
string headerString = "AutoFibo_";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
int hWnd = WindowHandle(Symbol(), 0);
   
   StartCustomIndicator2(hWnd, "MACD");
   
 //  StartCustomIndicator(hWnd, "RSI");
   
   StartCustomIndicator(hWnd, "Bands");
   
   
   Sleep(100);
   
   StartCustomIndicator(hWnd, "RSI");
   
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{ 
  
//--- Draw horizontal lines for resistance and support ---
  createHLines();
  
//--- Creating Fibonacci ---
  createFibo();
  
//--- Close all open orders ---
  //closeOrders();

//--- Strategy One Trading ---
  strategyRSIBandsMACD();

////--- Strategy Two Trading ---
//  strategyRSISMA();
  
//// Not sure how we decide if it shoudl use strategy I or II....  
////--- Strategy One Trading ---
////change strategyRSIBandsMACD to bool
//  if (!strategyRSIBandsMACD())
//    //--- Strategy Two Trading ---
//    strategyRSISMA();  
  
}
//+------------------------------------------------------------------+ 
//| Create Horizotional line                                         | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
{ 
  

//--- if the price is not set, set it at the current Bid price level ---
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      
//--- reset the error value ---
   ResetLastError();
    
//--- create a horizontal line ---
//ERR_OBJECT_ALREADY_EXISTS 	4200 	Object already exists.
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
   { 
      Print(__FUNCTION__, ": failed to create a horizontal line! Error code = ",GetLastError()); 
      return(false); 
   }
   
//--- set line color ---
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
    
//--- set line display style ---
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
    
//--- set line width ---
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
    
//--- display in the foreground (false) or background (true) ---
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   
//+------------------------------------------------------------------------------------+ 
//+ enable (true) or disable (false) the mode of moving the line by mouse              +
//+ when creating a graphical object using ObjectCreate function, the object cannot be +
//+ highlighted and moved by default. Inside this method, selection parameter          +
//+ is true by default making it possible to highlight and move the object             + 
//+------------------------------------------------------------------------------------+ 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   
//--- hide (true) or display (false) graphical object name in the object list ---
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
    
//--- set the priority for receiving the event of a mouse click in the chart ---
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
    
//--- successful execution ---
   return(true); 
}
 
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
{ 
//--- if the line price is not set, move it to the current Bid price level ---
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      
//--- reset the error value ---
   ResetLastError();
   
//--- move a horizontal line ---
   if(!ObjectMove(chart_ID,name,0,0,price)) 
   { 
      Print(__FUNCTION__, ": failed to move the horizontal line! Error code = ",GetLastError()); 
      return(false); 
   }
   
//--- successful execution ---
   return(true); 
}

//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
{ 
//--- reset the error value ---
   ResetLastError();
   
//--- delete a horizontal line ---
//ERR_OBJECT_DOES_NOT_EXIST 	4202 	Object does not exist.
   if(!ObjectDelete(chart_ID,name)) 
   { 
      Print(__FUNCTION__, ": failed to delete a horizontal line! Error code = ",GetLastError()); 
      return(false); 
   }
   
//--- successful execution ---
   return(true); 
}

//+------------------------------------------------------------------+ 
//| Create Horizontal Lines                                          | 
//+------------------------------------------------------------------+ 
void createHLines()
{
  double avgDailyPips;
   
//--- Get Yesterday's High and Low ---
  double YesterdayHigh=iHigh(_Symbol,PERIOD_D1,1); // Yesterday high
  //Print(YesterdayHigh); //Debug purposes
  
  double YesterdayLow = iLow(_Symbol, PERIOD_D1, 1); //Yesterday low
  //Print(YesterdayLow); //Debug purposes
  
  //--- Remove Last Existing Line ---
  deleteObjects();
  avgDailyPips = iATR(_Symbol,0,PERIOD_D1,20);
  //Print("avgDailyPips = ", string(avgDailyPips)); //Debug purposes

//--- Create New Resistance and Support Lines ---
  // Use previous day's high less average daily pips (20 days)  
  highLine = YesterdayHigh - avgDailyPips;
  //Print("YesterdayHigh-avgDailyPips = ", string(YesterdayHigh), " - ", string(avgDailyPips), " = ", string(highLine)); //Debug purposes
  HLineCreate(0 , "High Line", 0, highLine, 255, 0, 1, false, true, true, 0);
  
  // Use previous day's low plus average daily pips (20 days)
  lowLine = YesterdayLow + avgDailyPips;
  //Print("YesterdayLow+avgDailyPips = ", string(YesterdayLow), " + ", string(avgDailyPips), " = ", string(lowLine)); //Debug purposes
  HLineCreate(0 , "Low Line", 0, lowLine, 255, 0, 1, false, true, true, 0);  
}

//+------------------------------------------------------------------+ 
//| Check if is a Downtrend                                          | 
//+------------------------------------------------------------------+ 
bool checkIsDownTrend()
{
//--- Get first bar in the main chart window ---
   int bar = WindowFirstVisibleBar();
   
//--- lowest value of the previous bar shifted - 1 ---
   int shiftLowest  = iLowest( NULL, 0, MODE_LOW, bar - 1, 1 );
   
//--- highest value of the previous bar shifted - 1 ---
   int shiftHighest = iHighest( NULL, 0, MODE_HIGH, bar - 1, 1 );

//--- equation determines if EA is currently in a down or up trend ---
   bool   isDownTrend = shiftHighest > shiftLowest;
   return isDownTrend;
}

//+------------------------------------------------------------------+ 
//| Create Fibonacci                                                 | 
//+------------------------------------------------------------------+ 
void createFibo() 
{
//--- Get first bar in the main chart window ---
   int bar = WindowFirstVisibleBar();
   
//--- lowest value of the previous bar shifted - 1 ---
   int shiftLowest  = iLowest( NULL, 0, MODE_LOW, bar - 1, 1 );
   
//--- highest value of the previous bar shifted - 1 ---
   int shiftHighest = iHighest( NULL, 0, MODE_HIGH, bar - 1, 1 );

//--- equation determines if EA is currently in a down or up trend ---
   bool   isDownTrend = shiftHighest > shiftLowest;
   
//--- Add labels for fibonacci object ---
   string fiboObjectId1 = headerString + "1";
   string fiboObjectHigh = headerString + "High";
   string fiboObjectLow = headerString + "Low";
   string unretracedZoneObject = headerString + "UnretracedZone";
   int shiftMostRetraced;
   
//--- Sets fibonacci line using anchor points relative to trend we are on. --- 
   if ( isDownTrend == true ) 
   {     
      ObjectCreate( fiboObjectId1, OBJ_FIBO,0, Time[shiftHighest], High[shiftHighest], Time[shiftLowest], Low[shiftLowest] );  
//--- Sets width and style of our fibonacci. ---
      ObjectSet( fiboObjectId1, OBJPROP_LEVELWIDTH, fiboWidth );
      ObjectSet( fiboObjectId1, OBJPROP_LEVELSTYLE, fiboStyle );
      
//--- If user chooses to, we create an associated unretraced zone for the indicator. ---
      if ( showUnretracedZone == true ) 
      {
         if ( shiftLowest > 0 ) 
         {
            shiftMostRetraced = iHighest( NULL, 0, MODE_HIGH, shiftLowest - 1, 0 );
            ObjectCreate( unretracedZoneObject, OBJ_RECTANGLE, 0, Time[shiftMostRetraced], High[shiftHighest], Time[0], High[shiftMostRetraced] );      
            ObjectSet( unretracedZoneObject, OBJPROP_COLOR, unretracedZoneColor );     
         } 
      }  
   }
   else 
   {
     ObjectCreate( fiboObjectId1, OBJ_FIBO, 0, Time[shiftLowest], Low[shiftLowest], Time[shiftHighest], High[shiftHighest] );   
     ObjectSet( fiboObjectId1, OBJPROP_LEVELWIDTH, fiboWidth );
     ObjectSet( fiboObjectId1, OBJPROP_LEVELSTYLE, fiboStyle );
     
        if( showUnretracedZone == true ) 
        {
           if ( shiftHighest > 0 ) 
           {
               shiftMostRetraced = iLowest( NULL, 0, MODE_LOW, shiftHighest - 1, 0 );
               ObjectCreate( unretracedZoneObject, OBJ_RECTANGLE, 0, Time[shiftMostRetraced], Low[shiftLowest], Time[0], Low[shiftMostRetraced] );      
               ObjectSet( unretracedZoneObject, OBJPROP_COLOR, unretracedZoneColor );
           }
        }
    }
//--Adds indication labels to our currently drawn fibonacci. ---
   ObjectSet( fiboObjectId1, OBJPROP_LEVELCOLOR, fiboColor );
   ObjectSet( fiboObjectId1, OBJPROP_LEVELSTYLE, fiboStyle );
   ObjectSet( fiboObjectId1, OBJPROP_LEVELWIDTH, fiboWidth );
   ObjectSet( fiboObjectId1, OBJPROP_FIBOLEVELS,7 );
   ObjectSet( fiboObjectId1, OBJPROP_FIRSTLEVEL + 1, 0.00 );
   ObjectSetFiboDescription( fiboObjectId1, 1, "0.00- %$" );
   ObjectSet( fiboObjectId1, OBJPROP_FIRSTLEVEL + 2, 0.236 );
   ObjectSetFiboDescription( fiboObjectId1, 2, "23.6- %$" );
   ObjectSet( fiboObjectId1, OBJPROP_FIRSTLEVEL + 3, 0.382 );
   ObjectSetFiboDescription( fiboObjectId1, 3, "38.2- %$" );
   ObjectSet( fiboObjectId1, OBJPROP_FIRSTLEVEL + 4, 0.50 );
   ObjectSetFiboDescription( fiboObjectId1, 4, "50.0- %$" );
   ObjectSet( fiboObjectId1, OBJPROP_FIRSTLEVEL + 5, 0.618 );
   ObjectSetFiboDescription( fiboObjectId1, 5, "61.8 %$" );
   ObjectSet( fiboObjectId1, OBJPROP_FIRSTLEVEL + 6, 0.786 );
   ObjectSetFiboDescription( fiboObjectId1, 6, "78.6- %$" );
   ObjectSet( fiboObjectId1, OBJPROP_FIRSTLEVEL + 0, 1.00 );
   ObjectSetFiboDescription( fiboObjectId1, 0, "100- %$" );  
}

//+-------------------------------------------------------------------+ 
//| Removes all objects in order to prevent existing object exception.|                                        | 
//+-------------------------------------------------------------------+ 
void deleteObjects() 
{
   
   HLineDelete(0, "High Line");
   HLineDelete(0, "Low Line");

   for ( int i = ObjectsTotal() - 1;  i >= 0;  i-- ) 
   {
      string name = ObjectName( i );
      if ( StringSubstr( name, 0, StringLen( headerString ) ) == headerString )
         ObjectDelete( name );
   }
}

//+------------------------------------------------------------------+ 
//| Strategy 1 - RSI + Bollinger Bands + MACD                        | 
//+------------------------------------------------------------------+ 
//bool strategyRSIBandsMACD()
void strategyRSIBandsMACD()
{
    
//-- At this point, we successfully created our fibo lines and high/low lines, now to trade using Bollinger Strategy ---
//-- string representing the signal to be sent ---
    string signal = "";
    
//-- Get numerical value for bollinger bands using our current symbol, period, candles (default is 20), shifted 2 deviations and we get the first candle result
    double lowerBollinger = iBands(_Symbol, _Period, BANDPeriod, deviation, 0, PRICE_CLOSE, MODE_LOWER, 1);
    double upperBollinger = iBands(_Symbol, _Period, BANDPeriod, deviation, 0, PRICE_CLOSE, MODE_UPPER, 1);
    
//-- Get numerical value for bollinger bands using our current symbol, period, candles (default is 20), shifted 2 deviations and we get the previous candle to compare
    double lowerBollingerPrev = iBands(_Symbol, _Period, BANDPeriod, deviation, 0, PRICE_CLOSE, MODE_LOWER, 2);
    double upperBollingerPrev = iBands(_Symbol, _Period, BANDPeriod, deviation, 0, PRICE_CLOSE, MODE_UPPER, 2);
    
//-- Get numerical value for Moving Average Convergence Divergence  using our current symbol, period, fast ema, slow ema, signal moving average and we get the current candle
    double MACD = iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_MA,PRICE_CLOSE,MODE_MAIN,0);

    double RSI = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE, 1);
    Comment("Signal: ", signal, "\n", "RSI: ", RSI);
    
    if((RSI < 33.33) && (Close[2] < lowerBollingerPrev) && (Close[1] > lowerBollinger) && (MACD < 0))
    {
      signal = "sell";
    }
    else if ((RSI < 50) && (Close[2] < lowerBollingerPrev) && (Close[1] > lowerBollinger) && (MACD == 0))
    {
      signal = "buy";
    }
     
    if((RSI > 66.66) && (Close[2] > upperBollingerPrev) && (Close[1] < upperBollinger) && (MACD > 0))
    {
      signal = "buy";
    }
    else if ((RSI > 50) && (Close[2] > upperBollingerPrev) && (Close[1] < upperBollinger) && (MACD ==0))
    {
      signal = "sell";
    }
       
    int order;
    
    //-- If we have a buy signal and no open trades, then we send a buy order  
    if(signal=="buy" && OrdersTotal() == 0)
    {
      order = OrderSend(_Symbol, OP_BUY, 1, Ask, 3, 0, Ask+150 *_Point, NULL, 0,0,Green);
    }
    
    //-- If we have a sell signal and no open trades, then we send a sell order  
    if(signal=="sell" && OrdersTotal() == 0)
    {
      order = OrderSend(_Symbol, OP_SELL, 1, Bid, 3, 0, Bid-150 *_Point, NULL, 0,0,Green);
    }
    
    //-- Check if there was any error in the order
    if(order < 0)
    {
        Print("OrderSend Error: ", GetLastError());
        //return false;
    }
    //return True;
    
}
    
//+------------------------------------------------------------------+ 
//| Strategy 2 - 50 day SMA, RSI                                     | 
//+------------------------------------------------------------------+ 
void strategyRSISMA()
{
    
//-- string representing the signal to be sent ---
    string signal = "";
    
    double SMA = iMA(_Symbol, PERIOD_D1, 50, 0, MODE_SMA, PRICE_CLOSE, 1);
    
    double RSI = iRSI(_Symbol, _Period, 14, PRICE_CLOSE, 1);
    Comment("Signal: ", signal, "\n", "RSI: ", RSI);
    
    // Probability is high when there is a high above the 50 SMA, the trend is a downtrend, the high is a third wave
    // (i.e. it is a retracement against the trend), and the confirmation signal is an open and close below the high
    // resistance level. In an ideal world, the gap between the close and the 50-day SMA is equal to, or greater than
    // the gap between the close and the high of the confirmation signal.  The RSI should be following the trend.
    // The stop loss will be the high of the confirmation signal. The orders are always selling. Alternatively,
    // if there is a low below the 50-day SMA, the trend is a uptrend, the low is a third wave (i.e. it is a retracement
    // against the trend), and the confirmation signal is an open and close above the low support level. In an ideal world,
    // the gap between the close and the 50-day SMA is equal to, or greater than the gap between the close and the low of
    // the confirmation signal.  The stop loss will be the low of the confirmation signal. The orders are always buying.
    
    // need to add the rest of the comparisons for the logic    
    //is a high above the 50 SMA
    if(SMA < High[0])
    {
      //the trend is a downtrend
      if(checkIsDownTrend())
      {
         //confirmation signal is an open and close below the high resistance level
         if ((Open[0] < highLine) && (Close[0] < highLine))
         {
            //The RSI should be following the trend
            if (RSI < 70)
            {
              //The stop loss will be the high of the confirmation signal
              //stopLoss = NormalizeDouble(High[0],Digits);
              //Print("Sell... stoploss = ", string(stopLoss));
              signal = "sell";
            }
         }
      }      
    }  
    
    // is a low below the 50-day SMA
    if(SMA > High[0])
    {
      //the trend is a uptrend
      if(!checkIsDownTrend())
      {
         //the confirmation signal is an open and close above the low support level
         if ((Open[0] > lowLine) && (Close[0] > lowLine))
         {
            //The RSI should be following the trend
            if (RSI > 30)
            {
              //The stop loss will be the low of the confirmation signal
              //stopLoss = NormalizeDouble(Low[0],Digits);
              //Print("Buy... stoploss = ", string(stopLoss));
              signal = "buy";
            }
         }
      }
    }
  
    int order;
    
    //-- If we have a buy signal and no open trades, then we send a buy order
    if(signal=="buy" && OrdersTotal() == 0 )
    {
     order = OrderSend(_Symbol, OP_BUY, 1, Ask, 3, stopLoss, Ask+150*_Point, NULL, 0,0,Green);
    }
    
    //-- If we have a sell signal and no open trades, then we send a sell order  
    if(signal=="sell" && OrdersTotal() == 0 )
    {
     order = OrderSend(_Symbol, OP_SELL, 1, Bid, 3, stopLoss, Bid-150*_Point, NULL, 0,0,Green);
    }
    
    //-- Check if there was any error in the order
    if(order < 0)
    {
        Print("OrderSend Error: ", GetLastError());
    }
    
}


void closeOrders()
{
   if (Hour() == 0 && Minute() < 2 && OrdersTotal() > 0 && OrderType() == OP_BUY)
   
   {OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
   
   OrderClose(OrderTicket(),OrderLots( ),Bid,5,Green);}
   
   if (Hour() == 0 && Minute() < 2 && OrdersTotal() > 0 && OrderType() == OP_SELL)
   
   {OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
   
   OrderClose(OrderTicket(),OrderLots( ),Ask,5,Yellow);}
}