//+------------------------------------------------------------------+
//|                                         GeneratorInterface.mqh   |
//|                        Copyright 2024, Nortrading Renko Project  |
//|                                      https://github.com/vigilm   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Nortrading Renko Project"
#property link      "https://github.com/vigilmvarghese/Nortrading-Renko"
#property version   "1.00"
#property strict

#include "RemoteTypes.mqh"
#include "ChartSymbolParser.mqh"

//+------------------------------------------------------------------+
//| Generator Interface Class                                        |
//| Interface to communicate with OVO_Renko_Generator via globals   |
//+------------------------------------------------------------------+
class CGeneratorInterface
{
private:
   CChartSymbolParser   m_parser;                // Symbol parser
   string               m_global_prefix;         // Global variable prefix
   
   datetime             m_last_read_time;        // Last state read time
   int                  m_read_interval_ms;      // Read interval
   
   AttachedInstanceInfo m_instance_info;         // Cached instance info
   
public:
   //--- Constructor
   CGeneratorInterface()
   {
      m_global_prefix = "";
      m_last_read_time = 0;
      m_read_interval_ms = 500;  // Default 500ms read interval
   }
   
   //--- Destructor
   ~CGeneratorInterface() {}
   
   //--- Initialize from current chart
   bool Initialize()
   {
      if(!m_parser.InitFromChart())
      {
         Print("ERROR: Chart symbol is not a valid Renko custom symbol");
         return false;
      }
      
      m_global_prefix = m_parser.GetGlobalPrefix();
      m_instance_info.custom_symbol_name = m_parser.GetChartSymbol();
      m_instance_info.source_symbol = m_parser.GetSourceSymbol();
      m_instance_info.period_token = m_parser.GetPeriodToken();
      m_instance_info.is_valid = true;
      
      // Initial state read
      return ReadGeneratorState();
   }
   
   //--- Read generator state from global variables
   bool ReadGeneratorState()
   {
      // Check if generator is active
      if(!GlobalVariableCheck(m_global_prefix + "Active"))
      {
         m_instance_info.generator_active = false;
         m_instance_info.is_responsive = false;
         return false;
      }
      
      m_instance_info.generator_active = (GlobalVariableGet(m_global_prefix + "Active") > 0.5);
      
      if(!m_instance_info.generator_active)
         return false;
      
      // Read state variables
      if(GlobalVariableCheck(m_global_prefix + "State"))
         m_instance_info.current_state = (ENUM_RENKO_STATE)GlobalVariableGet(m_global_prefix + "State");
      
      if(GlobalVariableCheck(m_global_prefix + "ChartType"))
         m_instance_info.chart_type = (ENUM_RENKO_TYPE)GlobalVariableGet(m_global_prefix + "ChartType");
      
      if(GlobalVariableCheck(m_global_prefix + "BrickSize"))
         m_instance_info.brick_size = GlobalVariableGet(m_global_prefix + "BrickSize");
      
      if(GlobalVariableCheck(m_global_prefix + "TotalBricks"))
         m_instance_info.total_bricks = (int)GlobalVariableGet(m_global_prefix + "TotalBricks");
      
      if(GlobalVariableCheck(m_global_prefix + "LastBrickTime"))
         m_instance_info.last_brick_time = (datetime)GlobalVariableGet(m_global_prefix + "LastBrickTime");
      
      if(GlobalVariableCheck(m_global_prefix + "LastBrickBullish"))
         m_instance_info.last_brick_bullish = (GlobalVariableGet(m_global_prefix + "LastBrickBullish") > 0.5);
      
      if(GlobalVariableCheck(m_global_prefix + "BuildProgress"))
         m_instance_info.build_progress = (int)GlobalVariableGet(m_global_prefix + "BuildProgress");
      
      if(GlobalVariableCheck(m_global_prefix + "ChartID"))
         m_instance_info.source_chart_id = (long)GlobalVariableGet(m_global_prefix + "ChartID");
      
      m_instance_info.last_update_time = TimeCurrent();
      m_instance_info.is_responsive = true;
      m_last_read_time = GetTickCount();
      
      return true;
   }
   
   //--- Update state if enough time passed
   bool UpdateState()
   {
      int elapsed = GetTickCount() - m_last_read_time;
      if(elapsed < m_read_interval_ms)
         return true;  // Not time yet
      
      return ReadGeneratorState();
   }
   
   //--- Send command to change brick size
   bool SendChangeBrickSize(double new_brick_size)
   {
      if(!m_instance_info.is_valid || !m_instance_info.generator_active)
         return false;
      
      GlobalVariableSet(m_global_prefix + "CMD_ChangeBrickSize", new_brick_size);
      GlobalVariableSet(m_global_prefix + "CMD_Timestamp", (double)TimeCurrent());
      
      Print("Command sent: Change brick size to ", new_brick_size);
      return true;
   }
   
   //--- Send command to change chart type
   bool SendChangeChartType(ENUM_RENKO_TYPE new_type)
   {
      if(!m_instance_info.is_valid || !m_instance_info.generator_active)
         return false;
      
      GlobalVariableSet(m_global_prefix + "CMD_ChangeChartType", (double)new_type);
      GlobalVariableSet(m_global_prefix + "CMD_Timestamp", (double)TimeCurrent());
      
      string type_name = (new_type == RENKO_MEAN) ? "Mean Renko" : "Regular Renko";
      Print("Command sent: Change chart type to ", type_name);
      return true;
   }
   
   //--- Send command to trigger rebuild
   bool SendRebuild()
   {
      if(!m_instance_info.is_valid || !m_instance_info.generator_active)
         return false;
      
      GlobalVariableSet(m_global_prefix + "CMD_Rebuild", 1.0);
      GlobalVariableSet(m_global_prefix + "CMD_Timestamp", (double)TimeCurrent());
      
      Print("Command sent: Trigger rebuild");
      return true;
   }
   
   //--- Send command to stop generator
   bool SendStop()
   {
      if(!m_instance_info.is_valid || !m_instance_info.generator_active)
         return false;
      
      GlobalVariableSet(m_global_prefix + "CMD_Stop", 1.0);
      GlobalVariableSet(m_global_prefix + "CMD_Timestamp", (double)TimeCurrent());
      
      Print("Command sent: Stop generator");
      return true;
   }
   
   //--- Check command acknowledgment
   bool CheckCommandAck(datetime command_timestamp)
   {
      if(!GlobalVariableCheck(m_global_prefix + "ACK_Timestamp"))
         return false;
      
      datetime ack_time = (datetime)GlobalVariableGet(m_global_prefix + "ACK_Timestamp");
      return (ack_time >= command_timestamp);
   }
   
   //--- Get command status
   ENUM_COMMAND_STATUS GetCommandStatus()
   {
      if(!GlobalVariableCheck(m_global_prefix + "ACK_Status"))
         return CMD_STATUS_PENDING;
      
      return (ENUM_COMMAND_STATUS)GlobalVariableGet(m_global_prefix + "ACK_Status");
   }
   
   //--- Get instance info
   const AttachedInstanceInfo& GetInstanceInfo() const
   {
      return m_instance_info;
   }
   
   //--- Get source symbol
   string GetSourceSymbol() const
   {
      return m_parser.GetSourceSymbol();
   }
   
   //--- Get period token
   string GetPeriodToken() const
   {
      return m_parser.GetPeriodToken();
   }
   
   //--- Get custom symbol name
   string GetCustomSymbol() const
   {
      return m_parser.GetChartSymbol();
   }
   
   //--- Check if generator is active
   bool IsGeneratorActive() const
   {
      return m_instance_info.generator_active;
   }
   
   //--- Check if generator is responsive
   bool IsGeneratorResponsive() const
   {
      return m_instance_info.is_responsive;
   }
   
   //--- Get current state
   ENUM_RENKO_STATE GetCurrentState() const
   {
      return m_instance_info.current_state;
   }
   
   //--- Get state string
   string GetStateString() const
   {
      switch(m_instance_info.current_state)
      {
         case STATE_INITIALIZING:      return "INITIALIZING";
         case STATE_PANEL_ONLY:        return "PANEL ONLY";
         case STATE_REBUILD_REQUESTED: return "REBUILD REQUESTED";
         case STATE_REBUILDING:        return StringFormat("REBUILDING %d%%", m_instance_info.build_progress);
         case STATE_PUBLISHING:        return "PUBLISHING";
         case STATE_LIVE:              return "LIVE";
         case STATE_STOPPING:          return "STOPPING";
         default:                      return "UNKNOWN";
      }
   }
   
   //--- Get current brick size
   double GetBrickSize() const
   {
      return m_instance_info.brick_size;
   }
   
   //--- Get current chart type
   ENUM_RENKO_TYPE GetChartType() const
   {
      return m_instance_info.chart_type;
   }
   
   //--- Get chart type string
   string GetChartTypeString() const
   {
      return (m_instance_info.chart_type == RENKO_MEAN) ? "Mean Renko" : "Regular Renko";
   }
   
   //--- Get total bricks
   int GetTotalBricks() const
   {
      return m_instance_info.total_bricks;
   }
   
   //--- Get last brick time
   datetime GetLastBrickTime() const
   {
      return m_instance_info.last_brick_time;
   }
   
   //--- Get last brick direction
   bool IsLastBrickBullish() const
   {
      return m_instance_info.last_brick_bullish;
   }
   
   //--- Get build progress
   int GetBuildProgress() const
   {
      return m_instance_info.build_progress;
   }
   
   //--- Set read interval
   void SetReadInterval(int interval_ms)
   {
      m_read_interval_ms = interval_ms;
   }
};

//+------------------------------------------------------------------+
