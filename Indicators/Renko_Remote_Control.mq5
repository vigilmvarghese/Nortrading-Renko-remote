//+------------------------------------------------------------------+
//|                                       Renko_Remote_Control.mq5   |
//|                        Copyright 2024, Nortrading Renko Project  |
//|                                      https://github.com/vigilm   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Nortrading Renko Project"
#property link      "https://github.com/vigilmvarghese/Nortrading-Renko-Remote"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

//--- Include files
// Paths assume flat installation: files copied to MQL5/Include/RenkoRemote/
#include <RenkoRemote/RemoteTypes.mqh>
#include <RenkoRemote/ChartSymbolParser.mqh>
#include <RenkoRemote/GeneratorInterface.mqh>

//+------------------------------------------------------------------+
//| Input Parameters - HIDDEN (No user configuration)               |
//+------------------------------------------------------------------+
// All settings are hardcoded for simplicity - no inputs visible to user

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CGeneratorInterface  g_generator;                   // Generator interface
int                  g_last_brick_count = 0;        // Last brick count
bool                 g_last_direction = true;       // Last direction
datetime             g_last_update_time = 0;        // Last update time

// UI Configuration (hardcoded)
const int PANEL_HEIGHT_COLLAPSED = 24;              // Compact panel height
const int PANEL_HEIGHT_EXPANDED = 72;               // Expanded with radio buttons
const color PANEL_COLOR = C'40,40,40';              // Dark gray
const color TEXT_COLOR = clrWhite;                  // White text
const color HIGHLIGHT_COLOR = C'70,130,180';        // Steel blue
const int FONT_SIZE = 8;                            // Small font

// UI State
bool g_panel_expanded = false;                      // Is panel expanded
int g_current_panel_height = PANEL_HEIGHT_COLLAPSED; // Current height

// UI Object Names - Compact OVO-style panel
string g_label_chart_name = "RemotePanel_ChartName";      // Clickable chart type label
string g_label_brick_size = "RemotePanel_BrickSize";      // Brick size display
string g_label_brick_count = "RemotePanel_BrickCount";    // Brick count display
string g_btn_feed = "RemotePanel_BtnFeed";                // Feed button

// Expanded view objects (only visible when expanded)
string g_radio_mean = "RemotePanel_RadioMean";            // Mean Renko radio
string g_radio_regular = "RemotePanel_RadioRegular";      // Regular Renko radio
string g_label_select_type = "RemotePanel_SelectTypeLabel"; // "Select type:" label

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize generator interface
   if(!g_generator.Initialize())
   {
      Print("ERROR: Failed to initialize generator interface");
      Print("This indicator must be attached to a Renko custom symbol chart (e.g., US30.M61)");
      return INIT_FAILED;
   }
   
   Print("Remote Control initialized for: ", g_generator.GetCustomSymbol());
   Print("Source symbol: ", g_generator.GetSourceSymbol());
   Print("Period token: ", g_generator.GetPeriodToken());
   
   // Set update interval
   g_generator.SetReadInterval(InpUpdateIntervalMS);
   
   // Create UI
   if(InpShowControlPanel)
      CreateControlPanel();
   
   // Set timer for updates
   EventSetTimer(1);  // Update every second
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Kill timer
   EventKillTimer();
   
   // Clean up UI
   DestroyControlPanel();
   
   Print("Remote Control deinitialized");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   // This indicator doesn't plot anything
   // All logic is in timer and chart events
   return rates_total;
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Update generator state
   g_generator.UpdateState();
   
   // Update UI
   if(InpShowControlPanel)
      UpdateControlPanel();
   
   // Check for brick changes and alerts
   CheckBrickChanges();
}

//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Handle button clicks
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == g_btn_rebuild)
      {
         OnRebuildClicked();
         ObjectSetInteger(0, g_btn_rebuild, OBJPROP_STATE, false);
      }
      else if(sparam == g_btn_switch_type)
      {
         OnSwitchTypeClicked();
         ObjectSetInteger(0, g_btn_switch_type, OBJPROP_STATE, false);
      }
      else if(sparam == g_btn_apply_bricksize)
      {
         OnApplyBrickSizeClicked();
         ObjectSetInteger(0, g_btn_apply_bricksize, OBJPROP_STATE, false);
      }
      
      ChartRedraw();
   }
   
   // Handle custom events from generator
   if(id == EVENT_RENKO_BRICK_COMPLETED)
   {
      OnBrickCompleted((int)lparam, dparam > 0);
   }
   else if(id == EVENT_RENKO_REVERSAL)
   {
      OnReversalDetected((int)lparam, dparam > 0);
   }
   else if(id == EVENT_RENKO_MULTI_BRICK)
   {
      OnMultiBrickDetected((int)lparam);
   }
}

//+------------------------------------------------------------------+
//| Create Control Panel UI                                          |
//+------------------------------------------------------------------+
void CreateControlPanel()
{
   int x = InpPanelX;
   int y = InpPanelY;
   int width = 350;
   int row_height = 20;
   int padding = 5;
   
   // Background panel
   ObjectCreate(0, g_panel_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_YSIZE, 180);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_BGCOLOR, InpPanelColor);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, g_panel_bg, OBJPROP_BACK, false);
   
   int label_y = y + padding;
   
   // Symbol label
   CreateLabel(g_label_symbol, x + padding, label_y, "Symbol: " + g_generator.GetCustomSymbol());
   label_y += row_height;
   
   // State label
   CreateLabel(g_label_state, x + padding, label_y, "State: " + g_generator.GetStateString());
   label_y += row_height;
   
   // Chart type label
   CreateLabel(g_label_type, x + padding, label_y, "Type: " + g_generator.GetChartTypeString());
   label_y += row_height;
   
   // Brick size label
   CreateLabel(g_label_bricksize, x + padding, label_y, 
               StringFormat("Brick Size: %.0f points", g_generator.GetBrickSize()));
   label_y += row_height;
   
   // Total bricks label
   CreateLabel(g_label_bricks, x + padding, label_y, 
               StringFormat("Total Bricks: %d", g_generator.GetTotalBricks()));
   label_y += row_height;
   
   // Last brick label
   CreateLabel(g_label_lastbrick, x + padding, label_y, "Last Brick: ---");
   label_y += row_height + 5;
   
   // Brick size edit box
   CreateEdit(g_edit_bricksize, x + padding, label_y, 80, row_height, 
              DoubleToString(g_generator.GetBrickSize(), 0));
   
   // Apply brick size button
   CreateButton(g_btn_apply_bricksize, x + padding + 85, label_y, 100, row_height, "Apply Brick Size");
   label_y += row_height + 5;
   
   // Switch type button
   CreateButton(g_btn_switch_type, x + padding, label_y, 150, row_height, "Switch Type");
   
   // Rebuild button
   CreateButton(g_btn_rebuild, x + padding + 155, label_y, 100, row_height, "Rebuild");
   label_y += row_height + 5;
   
   // Statistics label (if enabled)
   if(InpShowStatistics)
   {
      CreateLabel(g_label_stats, x + padding, label_y, "Statistics: ---");
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Destroy Control Panel UI                                         |
//+------------------------------------------------------------------+
void DestroyControlPanel()
{
   ObjectDelete(0, g_panel_bg);
   ObjectDelete(0, g_label_symbol);
   ObjectDelete(0, g_label_state);
   ObjectDelete(0, g_label_type);
   ObjectDelete(0, g_label_bricksize);
   ObjectDelete(0, g_label_bricks);
   ObjectDelete(0, g_label_lastbrick);
   ObjectDelete(0, g_label_stats);
   ObjectDelete(0, g_btn_rebuild);
   ObjectDelete(0, g_btn_switch_type);
   ObjectDelete(0, g_edit_bricksize);
   ObjectDelete(0, g_btn_apply_bricksize);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update Control Panel                                             |
//+------------------------------------------------------------------+
void UpdateControlPanel()
{
   const AttachedInstanceInfo &info = g_generator.GetInstanceInfo();
   
   // Update state
   ObjectSetString(0, g_label_state, OBJPROP_TEXT, "State: " + g_generator.GetStateString());
   
   // Update type
   ObjectSetString(0, g_label_type, OBJPROP_TEXT, "Type: " + g_generator.GetChartTypeString());
   
   // Update brick size
   ObjectSetString(0, g_label_bricksize, OBJPROP_TEXT, 
                   StringFormat("Brick Size: %.0f points", info.brick_size));
   
   // Update total bricks
   ObjectSetString(0, g_label_bricks, OBJPROP_TEXT, 
                   StringFormat("Total Bricks: %d", info.total_bricks));
   
   // Update last brick
   if(info.last_brick_time > 0)
   {
      string direction = info.last_brick_bullish ? "Bullish ▲" : "Bearish ▼";
      string time_str = TimeToString(info.last_brick_time, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
      ObjectSetString(0, g_label_lastbrick, OBJPROP_TEXT, 
                      StringFormat("Last Brick: %s at %s", direction, time_str));
   }
   
   // Update statistics
   if(InpShowStatistics)
   {
      datetime elapsed = TimeCurrent() - g_last_update_time;
      if(g_last_update_time == 0 || elapsed == 0)
         elapsed = 1;
      
      double bricks_per_hour = 0;
      if(elapsed > 0)
         bricks_per_hour = (info.total_bricks * 3600.0) / elapsed;
      
      ObjectSetString(0, g_label_stats, OBJPROP_TEXT, 
                      StringFormat("Rate: %.1f bricks/hour", bricks_per_hour));
   }
   
   // Color coding based on state
   color state_color = clrWhite;
   if(info.current_state == STATE_LIVE)
      state_color = clrLime;
   else if(info.current_state == STATE_REBUILDING)
      state_color = clrYellow;
   else if(!info.generator_active)
      state_color = clrRed;
   
   ObjectSetInteger(0, g_label_state, OBJPROP_COLOR, state_color);
}

//+------------------------------------------------------------------+
//| Check for brick changes and alerts                               |
//+------------------------------------------------------------------+
void CheckBrickChanges()
{
   const AttachedInstanceInfo &info = g_generator.GetInstanceInfo();
   
   // Check if brick count changed
   if(info.total_bricks != g_last_brick_count)
   {
      int new_bricks = info.total_bricks - g_last_brick_count;
      
      // New brick alert
      if(InpEnableBrickAlerts && g_last_brick_count > 0)
      {
         Alert(StringFormat("New brick completed on %s", g_generator.GetCustomSymbol()));
      }
      
      // Multi-brick alert
      if(InpEnableMultiBrickAlerts && new_bricks >= InpMultiBrickThreshold)
      {
         Alert(StringFormat("Multi-brick burst: %d bricks on %s", 
                           new_bricks, g_generator.GetCustomSymbol()));
      }
      
      // Reversal alert
      if(InpEnableReversalAlerts && g_last_brick_count > 0)
      {
         if(info.last_brick_bullish != g_last_direction)
         {
            string direction = info.last_brick_bullish ? "BULLISH" : "BEARISH";
            Alert(StringFormat("Trend reversal to %s on %s", 
                              direction, g_generator.GetCustomSymbol()));
         }
      }
      
      g_last_brick_count = info.total_bricks;
      g_last_direction = info.last_brick_bullish;
   }
}

//+------------------------------------------------------------------+
//| Rebuild Button Click Handler                                     |
//+------------------------------------------------------------------+
void OnRebuildClicked()
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   if(g_generator.SendRebuild())
   {
      Print("Rebuild command sent successfully");
   }
   else
   {
      Alert("Failed to send rebuild command");
   }
}

//+------------------------------------------------------------------+
//| Switch Type Button Click Handler                                 |
//+------------------------------------------------------------------+
void OnSwitchTypeClicked()
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   ENUM_RENKO_TYPE current_type = g_generator.GetChartType();
   ENUM_RENKO_TYPE new_type = (current_type == RENKO_MEAN) ? RENKO_REGULAR : RENKO_MEAN;
   
   if(g_generator.SendChangeChartType(new_type))
   {
      string type_name = (new_type == RENKO_MEAN) ? "Mean Renko" : "Regular Renko";
      Print("Chart type change to ", type_name, " sent successfully");
   }
   else
   {
      Alert("Failed to send chart type change command");
   }
}

//+------------------------------------------------------------------+
//| Apply Brick Size Button Click Handler                            |
//+------------------------------------------------------------------+
void OnApplyBrickSizeClicked()
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   string brick_size_str = ObjectGetString(0, g_edit_bricksize, OBJPROP_TEXT);
   double new_brick_size = StringToDouble(brick_size_str);
   
   if(new_brick_size <= 0)
   {
      Alert("Invalid brick size");
      return;
   }
   
   if(g_generator.SendChangeBrickSize(new_brick_size))
   {
      Print("Brick size change to ", new_brick_size, " sent successfully");
   }
   else
   {
      Alert("Failed to send brick size change command");
   }
}

//+------------------------------------------------------------------+
//| Event: Brick Completed                                           |
//+------------------------------------------------------------------+
void OnBrickCompleted(int brick_count, bool is_bullish)
{
   Print("Brick completed event received: ", brick_count, " direction: ", 
         is_bullish ? "Bullish" : "Bearish");
}

//+------------------------------------------------------------------+
//| Event: Reversal Detected                                         |
//+------------------------------------------------------------------+
void OnReversalDetected(int brick_count, bool new_direction)
{
   string direction = new_direction ? "BULLISH" : "BEARISH";
   Print("Reversal detected: ", direction);
}

//+------------------------------------------------------------------+
//| Event: Multi-Brick Detected                                      |
//+------------------------------------------------------------------+
void OnMultiBrickDetected(int brick_count)
{
   Print("Multi-brick burst detected: ", brick_count, " bricks");
}

//+------------------------------------------------------------------+
//| Helper: Create Label                                             |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
}

//+------------------------------------------------------------------+
//| Helper: Create Button                                            |
//+------------------------------------------------------------------+
void CreateButton(string name, int x, int y, int width, int height, string text)
{
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize - 1);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrSilver);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrGray);
}

//+------------------------------------------------------------------+
//| Helper: Create Edit Box                                          |
//+------------------------------------------------------------------+
void CreateEdit(string name, int x, int y, int width, int height, string text)
{
   ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_CENTER);
}

//+------------------------------------------------------------------+
