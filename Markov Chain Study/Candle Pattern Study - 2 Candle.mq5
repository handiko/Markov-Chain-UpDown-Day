//+------------------------------------------------------------------+
//|                              Candle Pattern Study - 2 Candle.mq5 |
//|                                   Copyright 2025, Handiko Gesang |
//|                                   https://www.github.com/handiko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Handiko Gesang"
#property link      "https://www.github.com/handiko"
#property version   "1.00"

input static ENUM_TIMEFRAMES InpTimeframe = PERIOD_D1;

#define PREVIOUS_CANDLE 2
#define CANDLE (PREVIOUS_CANDLE+1)
#define COMBINATIONS 8

struct Pattern {
     int       count;
     double    probability;
};

struct Price {
     double    o;
     double    c;
};

Pattern pattern[COMBINATIONS];
Price price[CANDLE];
int totalBars;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
     totalBars = iBars(_Symbol, InpTimeframe);

     for(int i = 0; i < COMBINATIONS; i++) {
          pattern[i].count = 0;
          pattern[i].probability = 0.0;
     }

     for(int i = 0; i < CANDLE; i++) {
          price[i].o = 0.0;
          price[i].c = 0.0;
     }

     return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
     Print("................................");
     Print(" ", _Symbol, ",", EnumToString(InpTimeframe));
     Print(" ");

     int totaldata = 0;

     for(int i = 0; i < COMBINATIONS; i++) {
          totaldata += pattern[i].count;
     }

     int minimumCount = (int)(totaldata / COMBINATIONS);
     for(int i = 0; i < COMBINATIONS; i++) {
          PrintResult(i, minimumCount);

          if((i & 1) == 1) {
               Print(" ");
          }
     }

     Print("Total Data = ", totaldata);
     Print("Minimum candle to be statistically significant = ", (int)(totaldata / COMBINATIONS));

     Print(" ");
     Print("Finished");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
     int bars = iBars(_Symbol, InpTimeframe);
     int patt = 0;
     if(bars != totalBars) {
          totalBars = bars;

          for(int i = 0; i < CANDLE; i++) {
               price[i].o = iOpen(_Symbol, InpTimeframe, CANDLE - i);
               price[i].c = iClose(_Symbol, InpTimeframe, CANDLE - i);

               patt += ((price[i].o < price[i].c) ? 1 : 0) << (CANDLE - 1 - i);
          }

          CountPattern(pattern[patt]);
     }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountPattern(Pattern &p) {
     p.count++;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintResult(int c, int &total) {
     if((c & 1) == 1) {
          pattern[c].probability = NormalizeDouble(100.0 * pattern[c].count / (pattern[c].count + pattern[c - 1].count), 0);
     } else {
          pattern[c].probability = NormalizeDouble(100.0 * pattern[c].count / (pattern[c].count + pattern[c + 1].count), 0);
     }

     Print((c >> 2) == 1 ? "U" : "D",
           ((c >> 1) & 1) == 1 ? "U" : "D", "->",
           (c & 1) == 1 ? "U" : "D",

           " Count = ", pattern[c].count,
           " - Probability = ", (int)pattern[c].probability, "%",
           " ", pattern[c].count > total ? "*" : " ");
}
//+------------------------------------------------------------------+
