//+------------------------------------------------------------------+
//|                                                  RemoteTypes.mqh |
//|                        Copyright 2024, Nortrading Renko Project  |
//|                                      https://github.com/vigilm   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Nortrading Renko Project"
#property link      "https://github.com/vigilmvarghese/Nortrading-Renko"
#property version   "1.00"
#property strict

// Include base types from main Nortrading-Renko project
// Path assumes flat installation: MQL5/Include/RenkoRemote/ and MQL5/Include/Renko/
#include <Renko/RenkoTypes.mqh>

//+------------------------------------------------------------------+
//| Remote Command Types                                             |
//+------------------------------------------------------------------+
enum ENUM_REMOTE_COMMAND
{
   CMD_NONE = 0,                    // No command
   CMD_CHANGE_BRICK_SIZE,           // Change brick size
   CMD_CHANGE_CHART_TYPE,           // Change Renko type
   CMD_TRIGGER_REBUILD,             // Trigger rebuild
   CMD_STOP_GENERATOR,              // Stop generator
   CMD_START_GENERATOR,             // Start generator
   CMD_SYNC_BRICK_SIZE,             // Sync brick size across instances
   CMD_SYNC_CHART_TYPE              // Sync chart type across instances
};

//+------------------------------------------------------------------+
//| Command Status                                                   |
//+------------------------------------------------------------------+
enum ENUM_COMMAND_STATUS
{
   CMD_STATUS_SUCCESS = 0,          // Command successful
   CMD_STATUS_PENDING,              // Command pending
   CMD_STATUS_TIMEOUT,              // Command timeout
   CMD_STATUS_ERROR,                // Command error
   CMD_STATUS_REJECTED              // Command rejected by generator
};

//+------------------------------------------------------------------+
//| Alert Types                                                      |
//+------------------------------------------------------------------+
enum ENUM_REMOTE_ALERT_TYPE
{
   ALERT_NONE = 0,                  // No alert
   ALERT_NEW_BRICK,                 // New brick completed
   ALERT_REVERSAL,                  // Trend reversal
   ALERT_MULTI_BRICK,               // Multiple bricks burst
   ALERT_STATE_CHANGE,              // State changed
   ALERT_PERFORMANCE_WARNING,       // Performance issue
   ALERT_ERROR                      // Error condition
};

//+------------------------------------------------------------------+
//| Attached Chart Instance Information                              |
//+------------------------------------------------------------------+
struct AttachedInstanceInfo
{
   string            custom_symbol_name;     // Chart symbol (US30.M61)
   string            source_symbol;          // Parsed source (US30)
   string            period_token;           // Parsed token (M61)
   
   bool              is_valid;               // Valid Renko custom symbol
   bool              generator_active;       // Generator is active
   ENUM_RENKO_STATE  current_state;          // Current state
   ENUM_RENKO_TYPE   chart_type;             // Chart type
   double            brick_size;             // Current brick size
   
   int               total_bricks;           // Total bricks generated
   datetime          last_brick_time;        // Last brick timestamp
   bool              last_brick_bullish;     // Last brick direction
   
   int               build_progress;         // Build progress (0-100)
   long              source_chart_id;        // Source chart ID (generator chart)
   
   datetime          last_update_time;       // Last update from generator
   bool              is_responsive;          // Generator responding
   
   //--- Constructor
   AttachedInstanceInfo()
   {
      custom_symbol_name = "";
      source_symbol = "";
      period_token = "";
      is_valid = false;
      generator_active = false;
      current_state = STATE_INITIALIZING;
      chart_type = RENKO_REGULAR;
      brick_size = 600;
      total_bricks = 0;
      last_brick_time = 0;
      last_brick_bullish = true;
      build_progress = 0;
      source_chart_id = 0;
      last_update_time = 0;
      is_responsive = false;
   }
   
   //--- Get global variable prefix
   string GetGlobalPrefix() const
   {
      return "OVORenko_" + source_symbol + "_" + period_token + "_";
   }
   
   //--- Get instance identifier
   string GetInstanceID() const
   {
      return source_symbol + "." + period_token;
   }
   
   //--- Get display name
   string GetDisplayName() const
   {
      string type_str = (chart_type == RENKO_MEAN) ? "Mean" : "Regular";
      return StringFormat("%s [%s, %.0f pts]", 
                         GetInstanceID(), type_str, brick_size);
   }
   
   //--- Get state string
   string GetStateString() const
   {
      switch(current_state)
      {
         case STATE_INITIALIZING:      return "INIT";
         case STATE_PANEL_ONLY:        return "PANEL";
         case STATE_REBUILD_REQUESTED: return "REBUILD REQ";
         case STATE_REBUILDING:        return StringFormat("REBUILDING %d%%", build_progress);
         case STATE_PUBLISHING:        return "PUBLISHING";
         case STATE_LIVE:              return "LIVE";
         case STATE_STOPPING:          return "STOPPING";
         default:                      return "UNKNOWN";
      }
   }
   
   //--- Check if can send commands
   bool CanSendCommands() const
   {
      return is_active && is_responsive && 
             (current_state == STATE_LIVE || current_state == STATE_PANEL_ONLY);
   }
};

//+------------------------------------------------------------------+
//| Remote Command Structure                                         |
//+------------------------------------------------------------------+
struct RemoteCommand
{
   ENUM_REMOTE_COMMAND  command_type;        // Command type
   string               target_symbol;       // Target symbol
   string               target_token;        // Target token
   
   double               param_double;        // Double parameter (brick size)
   int                  param_int;           // Int parameter (chart type)
   string               param_string;        // String parameter
   
   datetime             timestamp;           // Command timestamp
   ENUM_COMMAND_STATUS  status;              // Command status
   string               error_message;       // Error message if failed
   
   //--- Constructor
   RemoteCommand()
   {
      command_type = CMD_NONE;
      target_symbol = "";
      target_token = "";
      param_double = 0;
      param_int = 0;
      param_string = "";
      timestamp = 0;
      status = CMD_STATUS_PENDING;
      error_message = "";
   }
   
   //--- Get global variable name for command
   string GetCommandVarName() const
   {
      string prefix = "OVORenko_" + target_symbol + "_" + target_token + "_CMD_";
      
      switch(command_type)
      {
         case CMD_CHANGE_BRICK_SIZE:   return prefix + "ChangeBrickSize";
         case CMD_CHANGE_CHART_TYPE:   return prefix + "ChangeChartType";
         case CMD_TRIGGER_REBUILD:     return prefix + "Rebuild";
         case CMD_STOP_GENERATOR:      return prefix + "Stop";
         case CMD_START_GENERATOR:     return prefix + "Start";
         default:                      return "";
      }
   }
   
   //--- Get timestamp variable name
   string GetTimestampVarName() const
   {
      return "OVORenko_" + target_symbol + "_" + target_token + "_CMD_Timestamp";
   }
   
   //--- Get ACK variable name
   string GetAckVarName() const
   {
      return "OVORenko_" + target_symbol + "_" + target_token + "_ACK_Timestamp";
   }
   
   //--- Get status variable name
   string GetStatusVarName() const
   {
      return "OVORenko_" + target_symbol + "_" + target_token + "_ACK_Status";
   }
};

//+------------------------------------------------------------------+
//| Alert Configuration                                              |
//+------------------------------------------------------------------+
struct AlertConfig
{
   bool              enable_brick_alerts;         // Alert on new brick
   bool              enable_reversal_alerts;      // Alert on reversal
   bool              enable_multi_brick_alerts;   // Alert on burst
   bool              enable_state_alerts;         // Alert on state change
   bool              enable_performance_alerts;   // Alert on performance
   
   string            alert_sound_file;            // Sound file name
   bool              push_notifications;          // Send push notifications
   bool              email_notifications;         // Send email notifications
   
   int               multi_brick_threshold;       // Bricks for burst alert
   int               performance_threshold_ms;    // Performance threshold
   
   //--- Constructor with defaults
   AlertConfig()
   {
      enable_brick_alerts = false;
      enable_reversal_alerts = true;
      enable_multi_brick_alerts = true;
      enable_state_alerts = false;
      enable_performance_alerts = true;
      
      alert_sound_file = "alert.wav";
      push_notifications = false;
      email_notifications = false;
      
      multi_brick_threshold = 3;
      performance_threshold_ms = 100;
   }
};

//+------------------------------------------------------------------+
//| Remote Control Configuration                                     |
//+------------------------------------------------------------------+
struct RemoteControlConfig
{
   //--- Scanning
   int               scan_interval_seconds;       // How often to scan
   bool              auto_refresh_dashboard;      // Auto-update UI
   
   //--- Alerts
   AlertConfig       alerts;                      // Alert configuration
   
   //--- Performance
   int               max_instances_monitor;       // Max instances
   int               command_timeout_seconds;     // Command timeout
   
   //--- UI
   int               panel_x;                     // Panel X position
   int               panel_y;                     // Panel Y position
   int               panel_width;                 // Panel width
   bool              show_detailed_stats;         // Show details
   
   //--- Filtering
   string            filter_symbol;               // Filter by symbol
   string            filter_token;                // Filter by token
   ENUM_RENKO_TYPE   filter_chart_type;          // Filter by type (-1 = all)
   
   //--- Constructor with defaults
   RemoteControlConfig()
   {
      scan_interval_seconds = 2;
      auto_refresh_dashboard = true;
      
      max_instances_monitor = 20;
      command_timeout_seconds = 5;
      
      panel_x = 10;
      panel_y = 30;
      panel_width = 400;
      show_detailed_stats = true;
      
      filter_symbol = "";
      filter_token = "";
      filter_chart_type = (ENUM_RENKO_TYPE)-1;  // All types
   }
};

//+------------------------------------------------------------------+
//| Statistics Structure                                             |
//+------------------------------------------------------------------+
struct RenkoStatistics
{
   string            instance_id;                 // Instance identifier
   
   int               total_bricks;                // Total bricks
   int               bullish_bricks;              // Bullish bricks
   int               bearish_bricks;              // Bearish bricks
   
   double            avg_brick_duration_sec;      // Average brick time
   double            min_brick_duration_sec;      // Fastest brick
   double            max_brick_duration_sec;      // Slowest brick
   
   int               reversals_count;             // Number of reversals
   int               multi_brick_events;          // Burst events
   
   datetime          session_start_time;          // Statistics start
   datetime          last_reset_time;             // Last reset
   
   //--- Constructor
   RenkoStatistics()
   {
      instance_id = "";
      total_bricks = 0;
      bullish_bricks = 0;
      bearish_bricks = 0;
      avg_brick_duration_sec = 0;
      min_brick_duration_sec = 0;
      max_brick_duration_sec = 0;
      reversals_count = 0;
      multi_brick_events = 0;
      session_start_time = TimeCurrent();
      last_reset_time = session_start_time;
   }
   
   //--- Reset statistics
   void Reset()
   {
      total_bricks = 0;
      bullish_bricks = 0;
      bearish_bricks = 0;
      avg_brick_duration_sec = 0;
      min_brick_duration_sec = 0;
      max_brick_duration_sec = 0;
      reversals_count = 0;
      multi_brick_events = 0;
      last_reset_time = TimeCurrent();
   }
   
   //--- Get brick rate (bricks per hour)
   double GetBrickRate() const
   {
      datetime now = TimeCurrent();
      int elapsed_seconds = (int)(now - session_start_time);
      if(elapsed_seconds <= 0)
         return 0;
      
      return (total_bricks * 3600.0) / elapsed_seconds;
   }
};

//+------------------------------------------------------------------+
//| Custom Chart Events for Inter-Indicator Communication           |
//+------------------------------------------------------------------+
#define EVENT_RENKO_BRICK_COMPLETED     10001
#define EVENT_RENKO_STATE_CHANGED       10002
#define EVENT_RENKO_REVERSAL            10003
#define EVENT_RENKO_MULTI_BRICK         10004
#define EVENT_RENKO_PERFORMANCE_WARNING 10005
#define EVENT_RENKO_ERROR               10006

//+------------------------------------------------------------------+
