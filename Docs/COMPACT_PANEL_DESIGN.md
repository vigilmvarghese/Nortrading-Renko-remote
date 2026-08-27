# Compact Panel Design - Renko Remote Control v2

## Overview

Version 2.0 introduces a **compact OVO-style panel** similar to the main Renko generator, with no user-configurable settings and a clean, minimal interface.

## Design Philosophy

### Key Principles
1. **No Configuration** - Zero input parameters, all settings hardcoded
2. **Compact by Default** - 24px height indicator window
3. **Expand on Demand** - Click chart type to show options
4. **Auto-Collapse** - Shrinks back after selection
5. **Quick Navigation** - FEED button to jump to source chart

## Visual Design

### Collapsed State (Default - 24px height)

```
┌──────────────────────────────────────────────────────────┐
│ [Mean Renko]  600 pts  1847  [FEED]                     │ ← 24px
└──────────────────────────────────────────────────────────┘
```

**Elements:**
- **Mean Renko** - Clickable label (blue highlight)
- **600 pts** - Current brick size
- **1847** - Total brick count
- **FEED** - Button to jump to source chart

### Expanded State (72px height)

```
┌──────────────────────────────────────────────────────────┐
│ [Mean Renko]  600 pts  1847  [FEED]                     │ ← 24px
│                                                           │
│   ● Mean Renko                                           │ ← 20px (selected)
│   ○ Regular Renko                                        │ ← 20px
│                                                           │ ← 8px padding
└──────────────────────────────────────────────────────────┘
```

**Additional Elements:**
- **● Mean Renko** - Selected radio button (blue background)
- **○ Regular Renko** - Unselected radio button (gray background)

## User Interaction Flow

### Workflow 1: Change Chart Type

```
1. User sees compact panel: "Mean Renko  600 pts  1847  FEED"
2. User clicks "Mean Renko" label
3. Panel expands to show:
   ● Mean Renko
   ○ Regular Renko
4. User clicks "○ Regular Renko"
5. Command sent to generator
6. Panel auto-collapses back to 24px
7. Label updates: "Regular Renko  600 pts  1847  FEED"
```

**Duration:** ~2 seconds from click to collapse

### Workflow 2: Jump to Source Chart

```
1. User on Renko chart: US30.M61
2. User clicks "FEED" button
3. MT5 brings US30 source chart to front
4. User sees the OVO_Renko_Generator panel
```

**Purpose:** Quick navigation between Renko chart and generator chart

## Technical Implementation

### No Input Parameters

```cpp
// NO input parameters defined
// All settings hardcoded for simplicity
```

**Rationale:** 
- Eliminates configuration complexity
- Consistent behavior across all instances
- Cleaner user experience

### Fixed Dimensions

```cpp
const int PANEL_HEIGHT_COLLAPSED = 24;    // Compact mode
const int PANEL_HEIGHT_EXPANDED = 72;     // With radio buttons
const int FONT_SIZE = 8;                  // Small, readable
```

### Dynamic Height Control

```cpp
// On init - compact
IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_COLLAPSED);

// On expand
IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_EXPANDED);

// On collapse
IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_COLLAPSED);
```

**Key Property:** `INDICATOR_HEIGHT` dynamically adjusts window size

### Panel State Management

```cpp
bool g_panel_expanded = false;  // Current state

void TogglePanelExpansion()
{
   g_panel_expanded = !g_panel_expanded;
   
   if(g_panel_expanded)
   {
      IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_EXPANDED);
      ShowRadioButtons();
   }
   else
   {
      IndicatorSetInteger(INDICATOR_HEIGHT, PANEL_HEIGHT_COLLAPSED);
      HideRadioButtons();
   }
}
```

### Radio Button Rendering

```cpp
void CreateRadioButton(string name, int x, int y, string text, bool selected)
{
   // Use button with custom text
   string display_text = (selected ? "● " : "○ ") + text;
   
   // Color code: selected = blue, unselected = gray
   color bg_color = selected ? HIGHLIGHT_COLOR : BUTTON_COLOR;
   
   ObjectCreate(...OBJ_BUTTON...);
   ObjectSetString(name, OBJPROP_TEXT, display_text);
   ObjectSetInteger(name, OBJPROP_BGCOLOR, bg_color);
}
```

**Visual Indicators:**
- `●` - Filled circle (selected)
- `○` - Empty circle (unselected)
- Blue background = selected
- Gray background = unselected

### Feed Button Implementation

```cpp
void OnFeedButtonClicked()
{
   string source_symbol = g_generator.GetSourceSymbol();
   
   // Iterate through all open charts
   long chart_id = ChartFirst();
   while(chart_id >= 0)
   {
      if(ChartSymbol(chart_id) == source_symbol)
      {
         // Found it - bring to front
         ChartSetInteger(chart_id, CHART_BRING_TO_TOP, 0, true);
         return;
      }
      chart_id = ChartNext(chart_id);
   }
   
   Alert("Source chart not found");
}
```

**Logic:**
1. Get source symbol (e.g., US30 from US30.M61)
2. Search all open charts
3. Find chart with matching symbol
4. Use `CHART_BRING_TO_TOP` to focus it

## Color Scheme

### Compact Style (Dark Theme)

```cpp
const color PANEL_BG_COLOR = C'40,40,40';     // Dark gray #282828
const color TEXT_COLOR = clrWhite;            // White text
const color HIGHLIGHT_COLOR = C'70,130,180';  // Steel blue #4682B4
const color BUTTON_COLOR = C'60,60,60';       // Button gray #3C3C3C
```

**Visual Hierarchy:**
- **Clickable elements** - Blue (HIGHLIGHT_COLOR)
- **Static text** - White
- **Buttons** - Medium gray
- **Background** - Dark gray

## Comparison: v1 vs v2

| Feature | v1.0 (Original) | v2.0 (Compact) |
|---------|-----------------|----------------|
| **Input Parameters** | 13 inputs | 0 inputs |
| **Panel Height** | 180px fixed | 24px / 72px dynamic |
| **Brick Size Edit** | Editable field + Apply button | Not included |
| **Chart Type Switch** | Single button toggle | Expandable radio buttons |
| **Rebuild Button** | Dedicated button | Not included |
| **Statistics Display** | Optional stats row | Not included |
| **Feed Button** | Not included | ✅ Included |
| **Complexity** | High | Minimal |

## Use Cases

### When to Use v2 (Compact)

✅ **Minimal screen space** - 24px vs 180px  
✅ **Quick chart type switching**  
✅ **Navigation between charts**  
✅ **Clean workspace** - no clutter  
✅ **Multiple instances** - less visual noise  

### When to Use v1 (Full)

✅ **Brick size experimentation** - editable field  
✅ **Detailed statistics** - brick rate, timing  
✅ **Manual rebuilds** - dedicated button  
✅ **Advanced configuration** - input parameters  

## Installation

Both versions can coexist:

```
MQL5/Nortrading-Renko-remote/Indicators/
├── Renko_Remote_Control.mq5      (v1 - Full featured)
└── Renko_Remote_Control_v2.mq5   (v2 - Compact)
```

**Attach the one that fits your workflow.**

## Future Enhancements

### Planned for v2.1

- [ ] Configurable panel position (left/right/center)
- [ ] Optional brick size display toggle
- [ ] Keyboard shortcuts (Ctrl+Click for quick toggle)
- [ ] Animation for expand/collapse
- [ ] Remember last expanded state

### Considering for v3.0

- [ ] Multi-chart dashboard mode
- [ ] Drag-and-drop panel positioning
- [ ] Custom color themes
- [ ] Panel opacity control
- [ ] Floating detachable panel

## Technical Notes

### Indicator Window Height

MT5 property `INDICATOR_HEIGHT` controls the indicator subwindow height:

```cpp
#property indicator_height 24  // Initial height

// Dynamic change at runtime
IndicatorSetInteger(INDICATOR_HEIGHT, new_height);
```

**Limitation:** Minimum height is ~20px

### Chart Navigation

`ChartSetInteger(chart_id, CHART_BRING_TO_TOP, ...)` brings chart to front:

- Works across multiple monitors
- Doesn't change chart order in Navigator
- User can still use Ctrl+Tab to cycle

**Alternative methods:**
- `ChartNavigate(chart_id, CHART_BEGIN)` - scroll to start
- `ChartSetSymbolPeriod(chart_id, symbol, period)` - change symbol

### Radio Button Pattern

MT5 doesn't have native radio buttons, so we simulate:

```cpp
// On click, update both buttons
void OnRadioButtonClicked(ENUM_RENKO_TYPE selected)
{
   // Delete old buttons
   ObjectDelete(g_radio_mean);
   ObjectDelete(g_radio_regular);
   
   // Recreate with updated selection
   CreateRadioButton(g_radio_mean, ..., selected == RENKO_MEAN);
   CreateRadioButton(g_radio_regular, ..., selected == RENKO_REGULAR);
}
```

**Challenge:** MT5 buttons don't have "checked" state  
**Solution:** Visual indicators (●/○) + color coding

## Summary

The compact v2 design achieves:

✅ **Minimal footprint** - 92% less height (24px vs 180px)  
✅ **Zero configuration** - No inputs to configure  
✅ **Intuitive interaction** - Click to expand, auto-collapse  
✅ **Quick navigation** - FEED button for workflow efficiency  
✅ **Clean aesthetics** - OVO-style consistency  

**Perfect for traders who want remote control without screen clutter.**
