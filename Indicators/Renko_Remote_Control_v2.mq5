//+------------------------------------------------------------------+
//|                                  Renko_Remote_Control_v2.mq5     |
//|                        Copyright 2024, Nortrading Renko Project  |
//|                                      https://github.com/vigilm   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Nortrading Renko Project"
#property link      "https://github.com/vigilmvarghese/Nortrading-Renko-Remote"
#property version   "2.00"
#property indicator_separate_window  // Create in separate indicator window
#property indicator_plots 0
#property indicator_buffers 0
#property indicator_height 24  // Compact 24px height

//--- Include files
// Paths assume flat installation: files copied to MQL5/Include/RenkoRemote/
#include <RenkoRemote/RemoteTypes.mqh>
#include <RenkoRemote/ChartSymbolParser.mqh>
#include <RenkoRemote/GeneratorInterface.mqh>

//+------------------------------------------------------------------+
//| No Input Parameters - All hardcoded for simplicity              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CGeneratorInterface  g_generator;                   // Generator interface

// UI Configuration (hardcoded)
const int PANEL_HEIGHT_COLLAPSED = 24;              // Compact panel height
const int PANEL_HEIGHT_EXPANDED = 72;               // Expanded with radio buttons
const color PANEL_BG_COLOR = C'40,40,40';           // Dark gray background
const color TEXT_COLOR = clrWhite;                  // White text
const color HIGHLIGHT_COLOR = C'70,130,180';        // Steel blue for clickable
const color BUTTON_COLOR = C'60,60,60';             // Button background
const int FONT_SIZE = 8;                            // Compact font

// UI State
bool g_panel_expanded = false;                      // Is panel showing radio buttons
int g_last_brick_count = 0;                         // For alerts

// UI Object Names - Compact OVO-style panel
const string PREFIX = "RenkoRemote_";
const string g_label_chart_type = PREFIX + "ChartType";      // Clickable: "Mean Renko" or "Regular Renko"
const string g_edit_brick_size = PREFIX + "EditBrickSize";   // Editable brick size field
const string g_btn_brick_decrease = PREFIX + "BtnDecrease";  // ◄ Left arrow (÷2)
const string g_btn_brick_increase = PREFIX + "BtnIncrease";  // ► Right arrow (×2)
const string g_label_brick_count = PREFIX + "BrickCount";    // Brick count display
const string g_btn_feed = PREFIX + "FeedBtn";                // "FEED" button

// Expanded view objects (hidden unless expanded)
const string g_radio_mean = PREFIX + "RadioMean";             // Mean Renko option
const string g_radio_regular = PREFIX + "RadioRegular";       // Regular Renko option

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
   
   // Set compact update interval
   g_generator.SetReadInterval(500);
   
   // Create compact OVO-style panel
   CreateCompactPanel();
   
   // Set timer for updates
   EventSetTimer(1);
   
   // Set indicator window height
   IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_COLLAPSED);
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   DestroyCompactPanel();
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
   return rates_total;
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   g_generator.UpdateState();
   UpdateCompactPanel();
   CheckBrickAlerts();
}

//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      // Chart type label clicked - toggle expand/collapse
      if(sparam == g_label_chart_type)
      {
         TogglePanelExpansion();
         ObjectSetInteger(0, g_label_chart_type, OBJPROP_STATE, false);
      }
      // Left arrow - decrease brick size (÷2)
      else if(sparam == g_btn_brick_decrease)
      {
         OnBrickSizeDecrease();
         ObjectSetInteger(0, g_btn_brick_decrease, OBJPROP_STATE, false);
      }
      // Right arrow - increase brick size (×2)
      else if(sparam == g_btn_brick_increase)
      {
         OnBrickSizeIncrease();
         ObjectSetInteger(0, g_btn_brick_increase, OBJPROP_STATE, false);
      }
      // Feed button clicked
      else if(sparam == g_btn_feed)
      {
         OnFeedButtonClicked();
         ObjectSetInteger(0, g_btn_feed, OBJPROP_STATE, false);
      }
      // Mean Renko radio clicked
      else if(sparam == g_radio_mean)
      {
         OnRadioButtonClicked(RENKO_MEAN);
      }
      // Regular Renko radio clicked
      else if(sparam == g_radio_regular)
      {
         OnRadioButtonClicked(RENKO_REGULAR);
      }
      
      ChartRedraw();
   }
   
   // Edit field changed - manual entry
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      if(sparam == g_edit_brick_size)
      {
         OnBrickSizeManualEdit();
      }
   }
}

//+------------------------------------------------------------------+
//| Create Compact OVO-Style Panel                                   |
//+------------------------------------------------------------------+
void CreateCompactPanel()
{
   int y_base = 2;  // Top margin
   int x_pos = 5;   // Left margin
   
   // Chart Type Label (clickable) - e.g., "Mean Renko"
   CreateClickableLabel(g_label_chart_type, x_pos, y_base, 
                        g_generator.GetChartTypeString(), HIGHLIGHT_COLOR);
   x_pos += 85;
   
   // Left Arrow Button (Divide by 2)
   CreateArrowButton(g_btn_brick_decrease, x_pos, y_base - 2, 20, 20, "◄");
   x_pos += 22;
   
   // Brick Size Edit Field - white background, editable
   CreateEditField(g_edit_brick_size, x_pos, y_base - 2, 60, 20, 
                   StringFormat("%.0f", g_generator.GetBrickSize()));
   x_pos += 62;
   
   // Right Arrow Button (Multiply by 2)
   CreateArrowButton(g_btn_brick_increase, x_pos, y_base - 2, 20, 20, "►");
   x_pos += 25;
   
   // Brick Count - e.g., "1847"
   CreateLabel(g_label_brick_count, x_pos, y_base, 
               StringFormat("%d", g_generator.GetTotalBricks()), TEXT_COLOR);
   x_pos += 50;
   
   // Feed Button
   CreateCompactButton(g_btn_feed, x_pos, y_base - 2, 40, 20, "FEED");
}

//+------------------------------------------------------------------+
//| Destroy Compact Panel                                            |
//+------------------------------------------------------------------+
void DestroyCompactPanel()
{
   ObjectDelete(0, g_label_chart_type);
   ObjectDelete(0, g_edit_brick_size);
   ObjectDelete(0, g_btn_brick_decrease);
   ObjectDelete(0, g_btn_brick_increase);
   ObjectDelete(0, g_label_brick_count);
   ObjectDelete(0, g_btn_feed);
   ObjectDelete(0, g_radio_mean);
   ObjectDelete(0, g_radio_regular);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update Compact Panel                                             |
//+------------------------------------------------------------------+
void UpdateCompactPanel()
{
   // Update chart type label
   ObjectSetString(0, g_label_chart_type, OBJPROP_TEXT, g_generator.GetChartTypeString());
   
   // Update brick size edit field
   ObjectSetString(0, g_edit_brick_size, OBJPROP_TEXT, 
                   StringFormat("%.0f", g_generator.GetBrickSize()));
   
   // Update brick count
   ObjectSetString(0, g_label_brick_count, OBJPROP_TEXT, 
                   StringFormat("%d", g_generator.GetTotalBricks()));
}

//+------------------------------------------------------------------+
//| Toggle Panel Expansion (show/hide radio buttons)                 |
//+------------------------------------------------------------------+
void TogglePanelExpansion()
{
   g_panel_expanded = !g_panel_expanded;
   
   if(g_panel_expanded)
   {
      // Expand - show radio buttons
      IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_EXPANDED);
      ShowRadioButtons();
   }
   else
   {
      // Collapse - hide radio buttons
      IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_COLLAPSED);
      HideRadioButtons();
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Show Radio Buttons (when expanded)                               |
//+------------------------------------------------------------------+
void ShowRadioButtons()
{
   int y_base = 28;  // Below the main compact row
   int x_pos = 10;
   
   ENUM_RENKO_TYPE current_type = g_generator.GetChartType();
   
   // Mean Renko radio button
   CreateRadioButton(g_radio_mean, x_pos, y_base, "Mean Renko", 
                     current_type == RENKO_MEAN);
   
   // Regular Renko radio button
   CreateRadioButton(g_radio_regular, x_pos, y_base + 20, "Regular Renko", 
                     current_type == RENKO_REGULAR);
}

//+------------------------------------------------------------------+
//| Hide Radio Buttons (when collapsed)                              |
//+------------------------------------------------------------------+
void HideRadioButtons()
{
   ObjectDelete(0, g_radio_mean);
   ObjectDelete(0, g_radio_regular);
}

//+------------------------------------------------------------------+
//| Radio Button Clicked - Send command and collapse                 |
//+------------------------------------------------------------------+
void OnRadioButtonClicked(ENUM_RENKO_TYPE new_type)
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   // Send command to change chart type
   if(g_generator.SendChangeChartType(new_type))
   {
      string type_name = (new_type == RENKO_MEAN) ? "Mean Renko" : "Regular Renko";
      Print("Chart type change to ", type_name, " sent successfully");
      
      // Collapse panel after selection
      g_panel_expanded = false;
      IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_COLLAPSED);
      HideRadioButtons();
      ChartRedraw();
   }
   else
   {
      Alert("Failed to send chart type change command");
   }
}

//+------------------------------------------------------------------+
//| Feed Button Clicked - Jump to source chart                       |
//+------------------------------------------------------------------+
void OnFeedButtonClicked()
{
   // Get source chart where generator is attached
   string source_symbol = g_generator.GetSourceSymbol();
   
   // Find chart with source symbol
   long chart_id = ChartFirst();
   while(chart_id >= 0)
   {
      if(ChartSymbol(chart_id) == source_symbol)
      {
         // Found source chart - bring to front
         if(ChartSetInteger(chart_id, CHART_BRING_TO_TOP, 0, true))
         {
            Print("Jumped to source chart: ", source_symbol);
            return;
         }
      }
      chart_id = ChartNext(chart_id);
   }
   
   Alert("Source chart not found: ", source_symbol);
}

//+------------------------------------------------------------------+
//| Brick Size Decrease - Divide by 2                                |
//+------------------------------------------------------------------+
void OnBrickSizeDecrease()
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   double current_size = g_generator.GetBrickSize();
   double new_size = current_size / 2.0;
   
   // Minimum brick size check
   if(new_size < 1.0)
   {
      Alert("Brick size too small (minimum: 1)");
      return;
   }
   
   ApplyBrickSize(new_size);
}

//+------------------------------------------------------------------+
//| Brick Size Increase - Multiply by 2                              |
//+------------------------------------------------------------------+
void OnBrickSizeIncrease()
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   double current_size = g_generator.GetBrickSize();
   double new_size = current_size * 2.0;
   
   // Maximum brick size check
   if(new_size > 100000.0)
   {
      Alert("Brick size too large (maximum: 100000)");
      return;
   }
   
   ApplyBrickSize(new_size);
}

//+------------------------------------------------------------------+
//| Brick Size Manual Edit - User typed value                        |
//+------------------------------------------------------------------+
void OnBrickSizeManualEdit()
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   string size_text = ObjectGetString(0, g_edit_brick_size, OBJPROP_TEXT);
   double new_size = StringToDouble(size_text);
   
   // Validate
   if(new_size <= 0 || new_size > 100000)
   {
      Alert("Invalid brick size (must be 1-100000)");
      // Restore previous value
      ObjectSetString(0, g_edit_brick_size, OBJPROP_TEXT, 
                      StringFormat("%.0f", g_generator.GetBrickSize()));
      return;
   }
   
   ApplyBrickSize(new_size);
}

//+------------------------------------------------------------------+
//| Apply Brick Size - Send to generator and update display          |
//+------------------------------------------------------------------+
void ApplyBrickSize(double new_size)
{
   if(g_generator.SendChangeBrickSize(new_size))
   {
      Print("Brick size changed to ", new_size);
      
      // Update display immediately
      ObjectSetString(0, g_edit_brick_size, OBJPROP_TEXT, StringFormat("%.0f", new_size));
   }
   else
   {
      Alert("Failed to send brick size change command");
   }
}

//+------------------------------------------------------------------+
//| Check for brick changes and trigger alerts                       |
//+------------------------------------------------------------------+
void CheckBrickAlerts()
{
   int current_count = g_generator.GetTotalBricks();
   
   if(current_count > g_last_brick_count && g_last_brick_count > 0)
   {
      int new_bricks = current_count - g_last_brick_count;
      
      // Multi-brick alert (3+ bricks)
      if(new_bricks >= 3)
      {
         Alert(StringFormat("Multi-brick burst: %d bricks on %s", 
                           new_bricks, g_generator.GetCustomSymbol()));
      }
   }
   
   g_last_brick_count = current_count;
}

//+------------------------------------------------------------------+
//| Helper: Create Label                                             |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr)
{
   ObjectCreate(0, name, OBJ_LABEL, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FONT_SIZE);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Helper: Create Clickable Label (acts like button)                |
//+------------------------------------------------------------------+
void CreateClickableLabel(string name, int x, int y, string text, color clr)
{
   ObjectCreate(0, name, OBJ_BUTTON, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, 80);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 20);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FONT_SIZE);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Helper: Create Compact Button                                    |
//+------------------------------------------------------------------+
void CreateCompactButton(string name, int x, int y, int width, int height, string text)
{
   ObjectCreate(0, name, OBJ_BUTTON, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FONT_SIZE);
   ObjectSetInteger(0, name, OBJPROP_COLOR, TEXT_COLOR);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, BUTTON_COLOR);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'80,80,80');
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Helper: Create Edit Field (white background, editable)           |
//+------------------------------------------------------------------+
void CreateEditField(string name, int x, int y, int width, int height, string text)
{
   ObjectCreate(0, name, OBJ_EDIT, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FONT_SIZE);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);  // White background
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'128,128,128');
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, name, OBJPROP_READONLY, false);  // Editable
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Helper: Create Arrow Button (for ◄ ►)                            |
//+------------------------------------------------------------------+
void CreateArrowButton(string name, int x, int y, int width, int height, string text)
{
   ObjectCreate(0, name, OBJ_BUTTON, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);  // Slightly larger for arrows
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, C'200,200,200');  // Light gray
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'128,128,128');
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}
void CreateRadioButton(string name, int x, int y, string text, bool selected)
{
   ObjectCreate(0, name, OBJ_BUTTON, ChartWindowFind(), 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, 120);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 18);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   
   string display_text = (selected ? "● " : "○ ") + text;
   ObjectSetString(0, name, OBJPROP_TEXT, display_text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FONT_SIZE);
   ObjectSetInteger(0, name, OBJPROP_COLOR, TEXT_COLOR);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, selected ? HIGHLIGHT_COLOR : BUTTON_COLOR);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'80,80,80');
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
