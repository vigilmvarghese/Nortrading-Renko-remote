//+------------------------------------------------------------------+
//|                                           ChartSymbolParser.mqh  |
//|                        Copyright 2024, Nortrading Renko Project  |
//|                                      https://github.com/vigilm   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Nortrading Renko Project"
#property link      "https://github.com/vigilmvarghese/Nortrading-Renko"
#property version   "1.00"
#property strict

#include "RemoteTypes.mqh"

//+------------------------------------------------------------------+
//| Chart Symbol Parser Class                                        |
//| Parses custom symbol name to extract source symbol and token    |
//+------------------------------------------------------------------+
class CChartSymbolParser
{
private:
   string            m_chart_symbol;          // Current chart symbol
   string            m_source_symbol;         // Parsed source symbol
   string            m_period_token;          // Parsed period token
   bool              m_is_valid;              // Is valid Renko custom symbol
   
public:
   //--- Constructor
   CChartSymbolParser()
   {
      m_chart_symbol = "";
      m_source_symbol = "";
      m_period_token = "";
      m_is_valid = false;
   }
   
   //--- Destructor
   ~CChartSymbolParser() {}
   
   //--- Initialize from chart
   bool InitFromChart(long chart_id = 0)
   {
      if(chart_id == 0)
         chart_id = ChartID();
      
      m_chart_symbol = ChartSymbol(chart_id);
      return Parse(m_chart_symbol);
   }
   
   //--- Parse custom symbol name
   bool Parse(const string symbol)
   {
      m_chart_symbol = symbol;
      m_is_valid = false;
      m_source_symbol = "";
      m_period_token = "";
      
      // Expected format: SYMBOL.TOKEN (e.g., US30.M61, EURAUD.M2)
      int dot_pos = StringFind(symbol, ".");
      
      if(dot_pos <= 0 || dot_pos >= StringLen(symbol) - 1)
      {
         // No dot found or invalid position - not a Renko custom symbol
         return false;
      }
      
      // Extract source symbol and token
      m_source_symbol = StringSubstr(symbol, 0, dot_pos);
      m_period_token = StringSubstr(symbol, dot_pos + 1);
      
      // Validate token format (should start with M followed by digits)
      if(StringLen(m_period_token) < 2)
         return false;
      
      if(StringGetCharacter(m_period_token, 0) != 'M')
         return false;
      
      // Check if remaining characters are digits
      for(int i = 1; i < StringLen(m_period_token); i++)
      {
         ushort ch = StringGetCharacter(m_period_token, i);
         if(ch < '0' || ch > '9')
            return false;
      }
      
      m_is_valid = true;
      return true;
   }
   
   //--- Get parsed source symbol
   string GetSourceSymbol() const
   {
      return m_source_symbol;
   }
   
   //--- Get parsed period token
   string GetPeriodToken() const
   {
      return m_period_token;
   }
   
   //--- Get chart symbol
   string GetChartSymbol() const
   {
      return m_chart_symbol;
   }
   
   //--- Check if valid Renko custom symbol
   bool IsValid() const
   {
      return m_is_valid;
   }
   
   //--- Get global variable prefix for this instance
   string GetGlobalPrefix() const
   {
      if(!m_is_valid)
         return "";
      
      return "OVORenko_" + m_source_symbol + "_" + m_period_token + "_";
   }
   
   //--- Get display name
   string GetDisplayName() const
   {
      if(!m_is_valid)
         return "Invalid Symbol";
      
      return m_source_symbol + " [" + m_period_token + "]";
   }
   
   //--- Check if source symbol exists
   bool SourceSymbolExists() const
   {
      if(!m_is_valid)
         return false;
      
      return SymbolSelect(m_source_symbol, true);
   }
   
   //--- Static utility: Build custom symbol name
   static string BuildCustomSymbol(const string source, const string token)
   {
      return source + "." + token;
   }
   
   //--- Static utility: Extract source from custom symbol
   static string ExtractSource(const string custom_symbol)
   {
      int dot_pos = StringFind(custom_symbol, ".");
      if(dot_pos <= 0)
         return custom_symbol;
      
      return StringSubstr(custom_symbol, 0, dot_pos);
   }
   
   //--- Static utility: Extract token from custom symbol
   static string ExtractToken(const string custom_symbol)
   {
      int dot_pos = StringFind(custom_symbol, ".");
      if(dot_pos <= 0 || dot_pos >= StringLen(custom_symbol) - 1)
         return "";
      
      return StringSubstr(custom_symbol, dot_pos + 1);
   }
   
   //--- Static utility: Validate custom symbol format
   static bool IsValidCustomSymbol(const string symbol)
   {
      CChartSymbolParser parser;
      return parser.Parse(symbol);
   }
};

//+------------------------------------------------------------------+
