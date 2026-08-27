# Nortrading - Renko Remote

A MetaTrader 5 indicator that attaches to generated Renko custom symbol charts and provides interactive control over the associated Renko generator instance.

## Overview

This companion indicator attaches directly to a Renko custom symbol chart (e.g., US30.M61, EURAUD.M2) and allows you to:
- **Control** the brick size, engine type, and rebuild operations for that specific chart
- **Monitor** real-time status, brick counts, and performance metrics
- **Alert** on Renko pattern completions and significant events
- **Display** enhanced chart information and trade overlays
- **Communicate** with the associated OVO_Renko_Generator instance via global variables and chart events

## Features

### 🎛️ Chart-Specific Control Panel
- Compact control panel overlay on the Renko chart
- Quick brick size adjustment with live preview
- One-click switch between Regular and Mean Renko engines
- Instant rebuild trigger button
- Generator status indicator (LIVE, REBUILDING, etc.)

### 📊 Enhanced Chart Display
- Real-time brick statistics overlay
- Current forming brick status indicator
- Brick completion count and rate display
- Last brick timestamp and direction indicator
- Build progress bar during reconstruction

### 🚨 Smart Alerts
- New brick completion alerts for this chart
- Trend reversal detection on this instance
- Multi-brick burst detection (volatility spike)
- Generator state change notifications
- Performance warning alerts

### 📈 Real-Time Analytics
- Bricks per hour rate
- Average brick formation time
- Bullish vs bearish brick ratio
- Reversal frequency
- Session statistics

## Architecture

### Attachment Model

The remote indicator is designed to attach to the **generated Renko custom symbol chart**:
- Attach to: `US30.M61` (the custom symbol chart)
- Reads chart symbol to identify: source symbol = `US30`, token = `M61`
- Communicates with the generator instance running on the source chart (`US30`)

### Communication Methods

The remote indicator communicates with its associated OVO_Renko_Generator instance through:

1. **Global Variables** - Reading state and sending control commands
2. **Chart Events** - Receiving real-time notifications from the generator
3. **Custom Symbol Data** - Reading the Renko bars directly from the chart
4. **Chart ID Detection** - Identifying the associated generator's chart

### Component Structure

```
Nortrading-Renko-Remote/
├── Indicators/
│   └── Renko_Remote_Control.mq5          # Main remote control indicator
├── Include/
│   └── RenkoRemote/
│       ├── RemoteTypes.mqh                # Data structures for remote control
│       ├── ChartSymbolParser.mqh          # Parse custom symbol to get source/token
│       └── GeneratorInterface.mqh         # Interface to generator via global vars
├── Nortrading-Renko/                      # Git submodule (main project)
│   └── Include/
│       └── Renko/
│           └── RenkoTypes.mqh             # Shared types (dependency)
├── .gitignore
├── .gitmodules                            # Submodule configuration
├── LICENSE
├── README.md
└── INSTALLATION.md                        # Detailed installation guide
```

## Installation

### Prerequisites

This indicator requires the main **Nortrading-Renko** project to be installed, as it references shared type definitions.

### Quick Installation

1. **Clone this repository with submodules:**
   ```bash
   git clone --recursive https://github.com/vigilmvarghese/Nortrading-Renko-Remote.git
   ```

2. **Copy to your MT5 installation:**
   ```
   Copy the entire cloned folder to: <MT5_DATA_FOLDER>/MQL5/
   ```

3. **Your folder structure should be:**
   ```
   MQL5/
   ├── Nortrading-Renko-Remote/
   │   ├── Indicators/
   │   │   └── Renko_Remote_Control.mq5
   │   ├── Include/
   │   │   └── RenkoRemote/
   │   └── Nortrading-Renko/              # Git submodule
   │       └── Include/
   │           └── Renko/
   │               └── RenkoTypes.mqh     # Referenced by remote
   ```

4. **Open MetaEditor and compile:**
   - Open `Nortrading-Renko-Remote/Indicators/Renko_Remote_Control.mq5`
   - Press F7 to compile

### Manual Installation (Without Git)

If you prefer not to use git:

1. Download and install **Nortrading-Renko** first:
   - Clone or download: https://github.com/vigilmvarghese/Nortrading-Renko
   - Copy to `<MT5_DATA_FOLDER>/MQL5/`

2. Download **Nortrading-Renko-Remote**:
   - Clone or download this repository
   - Copy to `<MT5_DATA_FOLDER>/MQL5/`

3. **Update the include path** in `Renko_Remote_Control.mq5`:
   ```cpp
   // Change this line:
   #include "../Include/../../Nortrading-Renko/Include/Renko/RenkoTypes.mqh"
   
   // To point to your Nortrading-Renko installation location
   ```

4. Compile in MetaEditor

See [INSTALLATION.md](INSTALLATION.md) for detailed instructions.

## Usage

### Basic Operation

1. **Attach Remote Control Indicator**
   - Open a generated Renko custom symbol chart (e.g., `US30.M61`)
   - Attach the `Renko_Remote_Control` indicator to this chart
   - Control panel appears showing controls for this specific instance
   - Indicator automatically detects source symbol and token from chart name

2. **Monitor Generator Status**
   - View current state: LIVE, REBUILDING, PANEL_ONLY
   - See current brick count and last update time
   - Monitor brick formation rate
   - Check build progress during rebuilds

3. **Control Generator Settings**
   - Modify brick size using the input field
   - Switch between Regular and Mean Renko
   - Click "Rebuild" to trigger chart reconstruction
   - All commands sent to the associated generator instance

### Remote Control Features

#### Change Brick Size
```
1. You're on chart: US30.M61 (currently 600 points)
2. Enter new brick size in control panel: 1200
3. Click "Apply Brick Size"
4. Remote indicator sets global variable: OVORenko_US30_M61_CMD_ChangeBrickSize = 1200
5. OVO_Renko_Generator on US30 source chart detects change and rebuilds
6. US30.M61 chart updates with new brick size
```

#### Switch Engine Type
```
1. Current: Mean Renko at 600 points
2. Click "Switch to Regular" button
3. Remote sets: OVORenko_US30_M61_CMD_ChangeChartType = 0
4. Generator rebuilds with Regular Renko logic
5. Chart updates with new engine type
```

#### Force Rebuild
```
1. Click "Rebuild Now" button
2. Remote sets: OVORenko_US30_M61_CMD_Rebuild = 1.0
3. Generator triggers asynchronous rebuild
4. Progress bar shows rebuild status
5. Chart returns to LIVE state when complete
```

### Alert Configuration

Enable alerts for:
- **New Brick**: Alert on every completed brick
- **Reversal**: Alert when trend changes (bullish ↔ bearish)
- **Multi-Brick Burst**: Alert when 3+ bricks form rapidly (volatility spike)
- **State Change**: Alert on REBUILDING, LIVE, error states
- **Performance Warning**: Alert if processing time exceeds threshold

## Global Variable Protocol

The remote indicator uses a standardized global variable naming scheme:

### State Variables (Read by Remote)
```
OVORenko_<SYMBOL>_<TOKEN>_Active         (1.0 = active, 0.0 = inactive)
OVORenko_<SYMBOL>_<TOKEN>_State          (ENUM_RENKO_STATE)
OVORenko_<SYMBOL>_<TOKEN>_BrickSize      (current brick size)
OVORenko_<SYMBOL>_<TOKEN>_ChartType      (RENKO_REGULAR or RENKO_MEAN)
OVORenko_<SYMBOL>_<TOKEN>_TotalBricks    (brick count)
OVORenko_<SYMBOL>_<TOKEN>_LastBrickTime  (datetime of last brick)
OVORenko_<SYMBOL>_<TOKEN>_BuildProgress  (0-100 percentage)
```

### Command Variables (Written by Remote)
```
OVORenko_<SYMBOL>_<TOKEN>_CMD_ChangeBrickSize    (new size in points)
OVORenko_<SYMBOL>_<TOKEN>_CMD_ChangeChartType    (0 = Regular, 1 = Mean)
OVORenko_<SYMBOL>_<TOKEN>_CMD_Rebuild            (1.0 = trigger rebuild)
OVORenko_<SYMBOL>_<TOKEN>_CMD_Stop               (1.0 = stop generator)
OVORenko_<SYMBOL>_<TOKEN>_CMD_Timestamp          (command timestamp for dedup)
```

### Acknowledgment Variables (Written by Generator)
```
OVORenko_<SYMBOL>_<TOKEN>_ACK_Timestamp          (last command processed)
OVORenko_<SYMBOL>_<TOKEN>_ACK_Status             (0 = success, error code)
```

## Chart Event Protocol

For real-time notifications, custom chart events are used:

```cpp
// Event IDs (must match between indicators)
#define EVENT_RENKO_BRICK_COMPLETED     10001
#define EVENT_RENKO_STATE_CHANGED       10002
#define EVENT_RENKO_REVERSAL            10003
#define EVENT_RENKO_MULTI_BRICK         10004

// Generator sends event when brick completes
EventChartCustom(0, EVENT_RENKO_BRICK_COMPLETED, brick_count, direction, 0);

// Remote receives event
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == EVENT_RENKO_BRICK_COMPLETED)
   {
      int brick_count = (int)lparam;
      bool is_bullish = (dparam > 0);
      // Handle brick completion
   }
}
```

## Integration with Nortrading-Renko

The remote indicator is designed to work seamlessly with the existing Nortrading-Renko project:

### Shared Dependencies
The remote indicator includes the base types from the main project:
```cpp
#include "../Nortrading-Renko/Include/Renko/RenkoTypes.mqh"
```

This ensures:
- Consistent enum definitions (ENUM_RENKO_TYPE, ENUM_RENKO_STATE)
- Compatible data structures
- Unified global variable naming

### Non-Invasive Design
- No modifications needed to OVO_Renko_Generator.mq5
- Uses existing global variable persistence system
- Extends functionality without touching core logic
- Can be added/removed without affecting running generators

### Optional Integration Points
For enhanced integration, the main generator can add:

1. **Command Processing** (optional in main indicator)
   ```cpp
   // Check for remote commands
   if(GlobalVariableCheck(prefix + "CMD_ChangeBrickSize"))
   {
      double new_size = GlobalVariableGet(prefix + "CMD_ChangeBrickSize");
      // Process command...
      GlobalVariableDel(prefix + "CMD_ChangeBrickSize");
   }
   ```

2. **Event Broadcasting** (optional in main indicator)
   ```cpp
   // When brick completes
   EventChartCustom(0, EVENT_RENKO_BRICK_COMPLETED, 
                    total_bricks, is_bullish ? 1 : -1, 0);
   ```

## Requirements

- MetaTrader 5 build 3802 or higher
- Nortrading-Renko v1.0.0 or higher installed
- At least one active OVO_Renko_Generator instance

## Configuration

### Remote Control Settings
```cpp
// Scanning
Scan Interval Seconds: 2           // How often to scan for instances
Auto Refresh Dashboard: Yes        // Auto-update display

// Alerts
Enable Brick Alerts: No
Enable Reversal Alerts: Yes
Enable Multi-Brick Alerts: Yes
Alert Sound File: alert.wav

// Performance
Max Instances to Monitor: 20       // Prevent UI overload
Command Timeout Seconds: 5         // Wait for ACK

// UI
Panel Position: Top Right
Panel Width: 400
Show Detailed Stats: Yes
```

## Use Cases

### Multi-Symbol Trading Setup
Monitor and control Renko charts for:
- All forex majors with synchronized brick sizes
- Multiple indices with coordinated engine types
- Correlated pairs with simultaneous rebuilds

### Strategy Development
- Quickly test different brick sizes across symbols
- Compare Regular vs Mean Renko side-by-side
- Analyze brick patterns for entry/exit signals

### Performance Monitoring
- Track which instances are processing slowly
- Identify symbols with excessive rebuilds
- Monitor tick integrity across feeds

### Emergency Management
- Stop all generators during high-impact news
- Reset problematic instances remotely
- Coordinate chart maintenance across symbols

## Troubleshooting

### Remote Not Seeing Instances
- **Check**: Generator must be in LIVE or REBUILDING state
- **Check**: Global variables must be enabled
- **Solution**: Restart MT5 if global variables are corrupted

### Commands Not Processing
- **Check**: Command timestamp is recent (within 60 seconds)
- **Check**: ACK_Status for error codes
- **Solution**: Increase command timeout in settings

### Dashboard Not Updating
- **Check**: Scan interval not too long
- **Check**: Max instances limit not exceeded
- **Solution**: Manually click "Refresh" button

## Advanced Features

### Scripting Integration
Export instance data to CSV for analysis:
```
Symbol, Token, State, BrickSize, Type, TotalBricks, LastTime
US30, M61, LIVE, 600, Mean, 1847, 2024.01.15 14:23:45
EURAUD, M2, LIVE, 300, Regular, 923, 2024.01.15 14:23:40
```

### Custom Alert Logic
Create custom alert conditions:
```cpp
// Alert if brick frequency exceeds threshold
if(bricks_per_minute > 10)
   Alert("High volatility: ", symbol_name);

// Alert on synchronized reversals
if(IsReversalSynchronized(instances))
   Alert("Multi-symbol reversal detected!");
```

## Roadmap

- [ ] Historical playback mode (replay brick formation)
- [ ] Pattern recognition (e.g., double brick, triple brick sequences)
- [ ] Export to TradingView via webhook
- [ ] Mobile push notifications via Telegram bot
- [ ] Multi-terminal support (control generators across MT5 instances)

## License

Copyright 2024, Nortrading Renko Project

This project is open source and follows the same license as Nortrading-Renko.

## Dependencies

This project depends on:
- **Nortrading-Renko** (included as git submodule): https://github.com/vigilmvarghese/Nortrading-Renko

The main project provides the base type definitions (`RenkoTypes.mqh`) that are shared between the generator and remote control indicators.

## Repository Structure

This repository uses **git submodules** to reference the main Nortrading-Renko project. When cloning:

```bash
# Clone with submodules
git clone --recursive https://github.com/vigilmvarghese/Nortrading-Renko-Remote.git

# Or if already cloned without --recursive
git submodule update --init --recursive
```

## Support

- **Remote Control Issues**: https://github.com/vigilmvarghese/Nortrading-Renko-Remote/issues
- **Main Generator Issues**: https://github.com/vigilmvarghese/Nortrading-Renko/issues
- **Main Project**: https://github.com/vigilmvarghese/Nortrading-Renko

## Credits

Built as a companion tool for the Nortrading-Renko MT5 indicator system.

This remote control indicator extends the functionality of the main Renko generator by providing interactive control directly from the generated Renko charts.
