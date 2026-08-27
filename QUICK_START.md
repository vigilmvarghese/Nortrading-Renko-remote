# Quick Start Guide - Nortrading Renko Remote

Get up and running with the Remote Control indicator in 5 minutes.

## Prerequisites

- ✅ MetaTrader 5 installed (build 3802+)
- ✅ Nortrading-Renko generator already installed and working
- ✅ At least one Renko chart generated (e.g., US30.M61)

## Installation (3 minutes)

### Option A: Git Clone (Recommended)

```bash
cd <MT5_DATA_FOLDER>/MQL5/
git clone --recursive https://github.com/vigilmvarghese/Nortrading-Renko-Remote.git
```

### Option B: Manual Download

1. Download ZIP from GitHub
2. Extract to `<MT5_DATA_FOLDER>/MQL5/Nortrading-Renko-Remote/`
3. Download main project and place in `Nortrading-Renko-Remote/Nortrading-Renko/`

## Compile (1 minute)

1. Open **MetaEditor** (F4 in MT5)
2. Open: `MQL5/Nortrading-Renko-Remote/Indicators/Renko_Remote_Control.mq5`
3. Press **F7** to compile
4. Should see: `0 error(s), 0 warning(s)`

## First Use (1 minute)

### Step 1: Generate a Renko Chart

If you don't have one yet:

1. Attach `OVO_Renko_Generator` to any symbol (e.g., US30)
2. Click the period button (M61) in the control panel
3. Wait for rebuild to complete
4. Custom symbol chart opens (US30.M61)

### Step 2: Attach Remote Control

1. Go to the **generated Renko chart** (US30.M61)
2. In Navigator → Indicators → Custom → Find `Renko_Remote_Control`
3. Drag to chart or double-click to attach
4. Control panel appears in the top-left corner

### Step 3: Test It

1. **Check Status:**
   - Panel shows: Symbol, State (LIVE), Type, Brick Size
   - Green "LIVE" indicator means generator is running

2. **Change Brick Size:**
   - Edit the brick size field: `600` → `1200`
   - Click "Apply Brick Size"
   - Chart rebuilds with new brick size

3. **Switch Engine Type:**
   - Click "Switch Type" button
   - Toggles between Regular and Mean Renko
   - Chart rebuilds automatically

## What You Should See

### Control Panel Layout

```
┌─────────────────────────────────────┐
│ Symbol: US30.M61                    │
│ State: LIVE                         │ ← Green = good
│ Type: Mean Renko                    │
│ Brick Size: 600 points              │
│ Total Bricks: 1847                  │
│ Last Brick: Bullish ▲ at 14:23:45   │
│ ┌──────┐  ┌──────────────┐          │
│ │ 1200 │  │Apply Brick Size│         │ ← Change size
│ └──────┘  └──────────────┘          │
│ ┌───────────┐  ┌─────────┐          │
│ │Switch Type│  │ Rebuild │          │ ← Controls
│ └───────────┘  └─────────┘          │
│ Rate: 42.3 bricks/hour              │ ← Statistics
└─────────────────────────────────────┘
```

## Common Use Cases

### 1. Quick Brick Size Adjustment

**Scenario:** You want to test different brick sizes quickly.

```
1. Edit brick size: 600 → 300
2. Click "Apply Brick Size"
3. Wait for rebuild (~10 seconds)
4. Evaluate chart
5. Repeat with different sizes
```

### 2. Compare Regular vs Mean Renko

**Scenario:** You want to see both engine types side-by-side.

```
1. On US30 source chart:
   - Generate M61 with Mean Renko
   - Generate M62 with Regular Renko (change token)

2. Open both charts: US30.M61 and US30.M62
3. Attach remote to each
4. Use "Switch Type" to toggle and compare
```

### 3. Force Rebuild

**Scenario:** Chart seems stuck or you want fresh data.

```
1. Click "Rebuild" button
2. Progress shows in State: "REBUILDING 47%"
3. Wait for completion
4. State returns to "LIVE"
```

## Input Parameters

When attaching the indicator, you can customize:

### Control Settings
- **Update Interval (ms):** How often to refresh state (default: 500)
- **Show Control Panel:** Enable/disable panel (default: Yes)
- **Panel X Position:** Horizontal position (default: 10)
- **Panel Y Position:** Vertical position (default: 30)

### Alert Settings
- **Alert on New Brick:** Alert every brick (default: No)
- **Alert on Reversal:** Alert on trend change (default: Yes)
- **Alert on Multi-Brick Burst:** Alert on volatility (default: Yes)
- **Multi-Brick Threshold:** How many bricks = burst (default: 3)

### Display Settings
- **Show Statistics:** Show brick rate (default: Yes)
- **Panel Background Color:** Customize panel color
- **Text Color:** Customize text color
- **Font Size:** Adjust text size (default: 9)

## Keyboard Shortcuts

There are no built-in shortcuts, but you can use MT5's:

- **F1:** Help (context-sensitive)
- **Ctrl+I:** Indicators list (to modify settings)
- **Ctrl+B:** Objects list (to see panel objects)
- **Ctrl+E:** Expert Advisors panel (see logs)

## Troubleshooting

### Panel Not Showing

**Check:**
1. Is `Show Control Panel` set to `Yes` in inputs?
2. Did indicator initialize? Check Experts log for errors
3. Try repositioning: Change `Panel X/Y Position` in inputs

**Fix:**
```
1. Remove indicator
2. Reattach with defaults
3. Check Experts tab for error messages
```

### "Generator is not active" Alert

**Cause:** Main generator not running or not responsive.

**Check:**
1. Is OVO_Renko_Generator attached to source chart (US30)?
2. Is generator in LIVE state?
3. Are global variables enabled? Tools → Options → Expert Advisors → Allow global variables

**Fix:**
```
1. Go to source chart (US30)
2. Check generator panel shows "LIVE"
3. If not, reattach OVO_Renko_Generator
4. Re-generate chart by clicking period button
```

### Commands Not Working

**Symptom:** Click buttons but nothing happens.

**Check:**
1. Is AutoTrading enabled? (Toolbar button)
2. Check Experts tab for error messages
3. Verify generator is responsive (State shows "LIVE")

**Fix:**
```
1. Enable AutoTrading (Alt+E or toolbar button)
2. Check if generator acknowledges commands:
   - Tools → Global Variables
   - Look for: OVORenko_US30_M61_ACK_Timestamp
3. If no ACK variables, generator may not be processing commands
```

### Wrong Chart

**Symptom:** Attached to wrong symbol.

**Cause:** Must attach to **generated custom symbol** (US30.M61), not source symbol (US30).

**Fix:**
```
1. Remove indicator from current chart
2. Open the generated Renko chart (US30.M61)
3. Attach indicator to the Renko chart
```

## Tips & Tricks

### 1. Optimal Brick Size Testing

Start wide, narrow down:
```
600 → 300 → 150 → 75
```

Each rebuild takes ~10 seconds on 7 days of data.

### 2. Multi-Symbol Setup

Organize your workspace:
```
Top Row:    US30.M61  EURAUD.M61  GBPUSD.M61
Bottom Row: US30.M62  EURAUD.M62  GBPUSD.M62
```

Attach remote to each. Quick comparison across symbols and settings.

### 3. Performance Monitoring

Enable statistics display:
```
Rate: 42.3 bricks/hour
```

- **High rate (>50/hr):** High volatility, consider larger brick size
- **Low rate (<10/hr):** Low volatility, consider smaller brick size
- **Reversal ratio:** Bullish vs bearish bricks

### 4. Alert Configuration

For active trading:
```
✓ Alert on Reversal: Yes
✓ Alert on Multi-Brick Burst: Yes (threshold: 3)
✗ Alert on New Brick: No (too noisy)
```

For monitoring:
```
✗ Alert on Reversal: No
✓ Alert on Multi-Brick Burst: Yes (threshold: 5)
✗ Alert on New Brick: No
```

## Next Steps

Once comfortable with basics:

1. **Read Full Documentation:**
   - [README.md](README.md): Complete feature overview
   - [ARCHITECTURE.md](Docs/ARCHITECTURE.md): Technical details
   - [INSTALLATION.md](INSTALLATION.md): Advanced installation

2. **Explore Advanced Features:**
   - Custom panel positioning
   - Alert customization
   - Statistics analysis

3. **Integrate with Trading:**
   - Use with EAs
   - Coordinate with other indicators
   - Develop strategies based on Renko patterns

## Support

- **Issues:** https://github.com/vigilmvarghese/Nortrading-Renko-Remote/issues
- **Main Project:** https://github.com/vigilmvarghese/Nortrading-Renko
- **Discussions:** https://github.com/vigilmvarghese/Nortrading-Renko/discussions

## Summary

You should now be able to:
- ✅ Install and compile the remote indicator
- ✅ Attach to a generated Renko chart
- ✅ See the control panel
- ✅ Change brick size
- ✅ Switch engine types
- ✅ Trigger rebuilds
- ✅ Monitor status and statistics

**Time to get productive:** < 5 minutes from install to first command! 🚀
