# Architecture - Nortrading Renko Remote

This document describes the technical architecture and design patterns of the Renko Remote Control indicator.

## Overview

The Remote Control indicator is designed to attach to a generated Renko custom symbol chart (e.g., `US30.M61`) and provide interactive control over its associated generator instance running on the source chart (`US30`).

## Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MT5 Source Chart (US30)                      │
│  ┌────────────────────────────────────────────────────────┐    │
│  │         OVO_Renko_Generator Indicator                   │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │  • Processes live ticks                          │  │    │
│  │  │  • Generates Renko bricks                        │  │    │
│  │  │  • Publishes to custom symbol (US30.M61)         │  │    │
│  │  │  • Writes state to global variables              │  │    │
│  │  │  • Reads command global variables                │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                            ↕ (Global Variables)
┌─────────────────────────────────────────────────────────────────┐
│              MT5 Custom Symbol Chart (US30.M61)                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │       Renko_Remote_Control Indicator                    │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │  CChartSymbolParser                              │  │    │
│  │  │    • Parses chart symbol (US30.M61)              │  │    │
│  │  │    • Extracts source (US30) and token (M61)      │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │  CGeneratorInterface                             │  │    │
│  │  │    • Reads generator state from global vars      │  │    │
│  │  │    • Sends commands via global vars              │  │    │
│  │  │    • Monitors acknowledgments                    │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │  Control Panel UI                                │  │    │
│  │  │    • Displays status and metrics                 │  │    │
│  │  │    • Provides buttons for commands               │  │    │
│  │  │    • Shows alerts and notifications              │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Class Hierarchy

### CChartSymbolParser

**Purpose:** Parse custom symbol names to extract source symbol and period token.

**Responsibilities:**
- Validate chart symbol format (must be `SYMBOL.TOKEN`)
- Extract source symbol (e.g., `US30` from `US30.M61`)
- Extract period token (e.g., `M61` from `US30.M61`)
- Generate global variable prefix for communication

**Key Methods:**
```cpp
bool InitFromChart(long chart_id = 0)
bool Parse(const string symbol)
string GetSourceSymbol() const
string GetPeriodToken() const
string GetGlobalPrefix() const
bool IsValid() const
```

**Example Usage:**
```cpp
CChartSymbolParser parser;
if(parser.InitFromChart())
{
   Print("Source: ", parser.GetSourceSymbol());    // "US30"
   Print("Token: ", parser.GetPeriodToken());      // "M61"
   Print("Prefix: ", parser.GetGlobalPrefix());    // "OVORenko_US30_M61_"
}
```

### CGeneratorInterface

**Purpose:** Interface to communicate with the OVO_Renko_Generator via global variables.

**Responsibilities:**
- Read generator state (active, state, brick size, chart type, etc.)
- Send commands (change brick size, change type, rebuild, stop)
- Monitor command acknowledgments
- Cache state to minimize global variable reads
- Provide query methods for current generator state

**Key Methods:**
```cpp
bool Initialize()
bool ReadGeneratorState()
bool UpdateState()

bool SendChangeBrickSize(double new_brick_size)
bool SendChangeChartType(ENUM_RENKO_TYPE new_type)
bool SendRebuild()
bool SendStop()

bool CheckCommandAck(datetime command_timestamp)
ENUM_COMMAND_STATUS GetCommandStatus()

const AttachedInstanceInfo& GetInstanceInfo() const
bool IsGeneratorActive() const
string GetStateString() const
```

**State Caching:**
- Reads state at configurable intervals (default: 500ms)
- Prevents excessive global variable queries
- `UpdateState()` checks elapsed time before reading

**Example Usage:**
```cpp
CGeneratorInterface generator;
if(generator.Initialize())
{
   if(generator.IsGeneratorActive())
   {
      Print("State: ", generator.GetStateString());
      Print("Brick Size: ", generator.GetBrickSize());
      
      // Send command
      generator.SendChangeBrickSize(1200);
   }
}
```

## Communication Protocol

### Global Variable Naming Convention

All global variables follow this pattern:
```
OVORenko_<SOURCE_SYMBOL>_<PERIOD_TOKEN>_<VARIABLE_NAME>
```

Example: `OVORenko_US30_M61_Active`

### State Variables (Generator → Remote)

Written by generator, read by remote:

| Variable Name | Type | Description |
|---------------|------|-------------|
| `Active` | double (0/1) | Generator is active |
| `State` | double (enum) | Current state (ENUM_RENKO_STATE) |
| `ChartType` | double (enum) | Current chart type (ENUM_RENKO_TYPE) |
| `BrickSize` | double | Current brick size in points |
| `TotalBricks` | double | Total bricks generated |
| `LastBrickTime` | double | Timestamp of last brick |
| `LastBrickBullish` | double (0/1) | Last brick direction |
| `BuildProgress` | double | Build progress (0-100) |
| `ChartID` | double | Source chart ID |

### Command Variables (Remote → Generator)

Written by remote, read by generator:

| Variable Name | Type | Description |
|---------------|------|-------------|
| `CMD_ChangeBrickSize` | double | New brick size to apply |
| `CMD_ChangeChartType` | double | New chart type (0=Regular, 1=Mean) |
| `CMD_Rebuild` | double (0/1) | Trigger rebuild flag |
| `CMD_Stop` | double (0/1) | Stop generator flag |
| `CMD_Timestamp` | double | Command timestamp (for dedup) |

### Acknowledgment Variables (Generator → Remote)

Written by generator after processing command:

| Variable Name | Type | Description |
|---------------|------|-------------|
| `ACK_Timestamp` | double | Timestamp of last processed command |
| `ACK_Status` | double | Status code (0=success, >0=error) |

### Command Flow

```
1. Remote sends command:
   - Set CMD_ChangeBrickSize = 1200
   - Set CMD_Timestamp = current time

2. Generator detects command:
   - Check if CMD_Timestamp > last processed timestamp
   - Process command
   - Set ACK_Timestamp = CMD_Timestamp
   - Set ACK_Status = 0 (success)

3. Remote checks acknowledgment:
   - Poll ACK_Timestamp
   - If ACK_Timestamp >= CMD_Timestamp, command was received
   - Check ACK_Status for success/error
```

## Chart Event Protocol (Optional)

For real-time notifications, the generator can send custom chart events:

### Event IDs

```cpp
#define EVENT_RENKO_BRICK_COMPLETED     10001
#define EVENT_RENKO_STATE_CHANGED       10002
#define EVENT_RENKO_REVERSAL            10003
#define EVENT_RENKO_MULTI_BRICK         10004
#define EVENT_RENKO_PERFORMANCE_WARNING 10005
#define EVENT_RENKO_ERROR               10006
```

### Event Parameters

```cpp
// Brick completed
EventChartCustom(0, EVENT_RENKO_BRICK_COMPLETED, 
                 total_bricks,      // lparam: brick count
                 is_bullish ? 1 : -1, // dparam: direction
                 0);                // sparam: unused

// Reversal detected
EventChartCustom(0, EVENT_RENKO_REVERSAL,
                 total_bricks,      // lparam: brick count
                 new_direction ? 1 : -1, // dparam: new direction
                 0);

// Multi-brick burst
EventChartCustom(0, EVENT_RENKO_MULTI_BRICK,
                 brick_count,       // lparam: number of bricks
                 0, 0);
```

## UI Architecture

### Panel Layout

```
┌─────────────────────────────────────────────┐
│  Symbol: US30.M61                           │
│  State: LIVE                     [●]         │
│  Type: Mean Renko                           │
│  Brick Size: 600 points                     │
│  Total Bricks: 1847                         │
│  Last Brick: Bullish ▲ at 14:23:45          │
│  ┌──────┐  ┌────────────────┐               │
│  │ 1200 │  │ Apply Brick Size│              │
│  └──────┘  └────────────────┘               │
│  ┌─────────────┐  ┌────────────┐            │
│  │ Switch Type │  │  Rebuild   │            │
│  └─────────────┘  └────────────┘            │
│  Rate: 42.3 bricks/hour                     │
└─────────────────────────────────────────────┘
```

### UI Update Strategy

**Timer-Based Updates:**
- `OnTimer()` called every 1 second
- Calls `g_generator.UpdateState()` to refresh state
- Updates panel labels with new data
- Checks for brick changes and triggers alerts

**Event-Based Updates:**
- Button clicks handled in `OnChartEvent()`
- Custom events from generator processed immediately

**Color Coding:**
- Green: LIVE state
- Yellow: REBUILDING state
- Red: Inactive generator
- White: Other states

## Data Structures

### AttachedInstanceInfo

Cached information about the attached generator instance:

```cpp
struct AttachedInstanceInfo
{
   string            custom_symbol_name;     // US30.M61
   string            source_symbol;          // US30
   string            period_token;           // M61
   
   bool              is_valid;
   bool              generator_active;
   ENUM_RENKO_STATE  current_state;
   ENUM_RENKO_TYPE   chart_type;
   double            brick_size;
   
   int               total_bricks;
   datetime          last_brick_time;
   bool              last_brick_bullish;
   
   int               build_progress;
   long              source_chart_id;
   
   datetime          last_update_time;
   bool              is_responsive;
};
```

### RemoteCommand

Command structure for sending commands:

```cpp
struct RemoteCommand
{
   ENUM_REMOTE_COMMAND  command_type;
   string               target_symbol;
   string               target_token;
   
   double               param_double;
   int                  param_int;
   string               param_string;
   
   datetime             timestamp;
   ENUM_COMMAND_STATUS  status;
   string               error_message;
};
```

## Performance Considerations

### Optimization Strategies

1. **State Caching**
   - Read global variables at intervals (default: 500ms)
   - Avoid reading on every tick/timer event
   - Cache frequently accessed values

2. **Minimal UI Updates**
   - Only update changed labels
   - Use `ChartRedraw()` sparingly
   - Batch multiple label updates

3. **Efficient Global Variable Access**
   - Check existence before reading: `GlobalVariableCheck()`
   - Use double type (native MT5 global variable type)
   - Delete command variables after processing

4. **Event Processing**
   - Process custom events asynchronously
   - Don't block timer for event handling
   - Queue alerts if many events arrive

### Memory Footprint

- Minimal memory usage (<1 MB)
- No heavy arrays or buffers
- Small UI objects (10-15 objects)
- Cached state structure (~200 bytes)

## Error Handling

### Initialization Errors

```cpp
int OnInit()
{
   if(!g_generator.Initialize())
   {
      // Chart symbol is not valid Renko custom symbol
      Print("ERROR: Must attach to Renko custom symbol");
      return INIT_FAILED;
   }
   
   if(!g_generator.IsGeneratorActive())
   {
      // Generator not running, but this is not fatal
      Print("WARNING: Generator is not active");
      // Continue initialization, might activate later
   }
   
   return INIT_SUCCEEDED;
}
```

### Command Errors

```cpp
void OnApplyBrickSizeClicked()
{
   if(!g_generator.IsGeneratorActive())
   {
      Alert("Generator is not active");
      return;
   }
   
   double new_size = GetBrickSizeFromEditBox();
   if(new_size <= 0)
   {
      Alert("Invalid brick size");
      return;
   }
   
   if(!g_generator.SendChangeBrickSize(new_size))
   {
      Alert("Failed to send command");
   }
}
```

### Runtime Errors

- Global variable access failures: non-fatal, retry on next update
- Parser validation failures: fatal at init, indicator cannot function
- UI creation failures: non-fatal, continue without UI

## Extension Points

### Adding New Commands

1. Add enum to `ENUM_REMOTE_COMMAND` in `RemoteTypes.mqh`
2. Add send method to `CGeneratorInterface`
3. Add button handler in main indicator
4. Document in README

### Adding Custom Events

1. Define event ID constant (10001-19999 range)
2. Add event handler in `OnChartEvent()`
3. Trigger from generator when event occurs
4. Update documentation

### Custom UI Elements

1. Create object in `CreateControlPanel()`
2. Update in `UpdateControlPanel()`
3. Clean up in `DestroyControlPanel()`
4. Handle events in `OnChartEvent()`

## Testing Strategy

### Manual Testing

1. **Parser Testing:**
   - Attach to valid custom symbols: US30.M61, EURAUD.M2
   - Attach to invalid symbols: US30 (no token), Invalid.ABC (bad token)
   - Verify correct parsing in Experts log

2. **Interface Testing:**
   - Generate Renko chart with OVO_Renko_Generator
   - Attach remote control
   - Verify state reading
   - Send each command type
   - Monitor global variables in terminal

3. **UI Testing:**
   - Verify panel rendering
   - Test all buttons
   - Check edit box input validation
   - Verify color coding
   - Test panel repositioning

4. **Alert Testing:**
   - Enable various alert types
   - Generate bricks (fast market or brick size change)
   - Verify alerts fire correctly
   - Test reversal detection

### Integration Testing

1. **Multi-Instance:**
   - Run multiple generators: US30.M61, EURAUD.M2
   - Attach remote to each
   - Verify no cross-interference
   - Check global variable isolation

2. **State Transitions:**
   - Test during rebuild (progress updates)
   - Test generator stop/restart
   - Test MT5 restart (auto-resume)

3. **Performance:**
   - Monitor CPU usage
   - Check for memory leaks (long running)
   - Verify UI responsiveness
   - Test with many bricks (>10,000)

## Future Enhancements

### Planned Features

1. **Multi-Instance Dashboard:**
   - Attach to any chart
   - Monitor all active generators
   - Control multiple instances

2. **Advanced Analytics:**
   - Brick formation patterns
   - Volatility metrics
   - Session statistics

3. **Pattern Recognition:**
   - Detect common Renko patterns
   - Alert on specific formations
   - Visual pattern highlighting

4. **Export/Import:**
   - Export settings to file
   - Share configurations
   - Backup/restore state

### Integration Ideas

1. **Telegram Bot:**
   - Send alerts via Telegram
   - Remote control via chat commands

2. **TradingView Integration:**
   - Export Renko data to TV
   - Webhook notifications

3. **Custom EA Integration:**
   - Provide API for EAs
   - Read Renko state from EA
   - Coordinate trading with Renko signals

## Conclusion

The Remote Control indicator provides a clean, extensible architecture for interacting with Renko generators. The modular design allows easy enhancement and maintenance while keeping the codebase simple and performant.
