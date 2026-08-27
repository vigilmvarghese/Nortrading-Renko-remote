# Flat Installation Guide - Nortrading-Renko-Remote

This guide covers **flat installation** where files are copied directly to MT5's standard `Include/` and `Indicators/` folders.

## Installation Method: Flat Structure

### Overview

Instead of keeping the project structure intact, you'll copy files to MT5's standard locations:

```
MQL5/
├── Include/
│   ├── RenkoRemote/          ← Remote control includes
│   │   ├── RemoteTypes.mqh
│   │   ├── ChartSymbolParser.mqh
│   │   └── GeneratorInterface.mqh
│   └── Renko/                ← Shared types from main project
│       └── RenkoTypes.mqh
└── Indicators/
    ├── Renko_Remote_Control.mq5       ← v1.0 Full featured
    └── Renko_Remote_Control_v2.mq5    ← v2.0 Compact
```

### Prerequisites

1. **Nortrading-Renko** main project must be installed
2. You need `RenkoTypes.mqh` from the main project

---

## Step-by-Step Installation

### Step 1: Locate MT5 Data Folder

1. Open MetaTrader 5
2. Go to **File → Open Data Folder**
3. Navigate to the `MQL5` subfolder

This is your installation root (e.g., `C:\Users\YourName\AppData\Roaming\MetaQuotes\Terminal\XXXX\MQL5\`)

### Step 2: Download or Clone the Project

**Option A: Git Clone**
```bash
cd ~/Downloads
git clone --recursive https://github.com/vigilmvarghese/Nortrading-Renko-remote.git
cd Nortrading-Renko-remote
```

**Option B: Download ZIP**
- Go to: https://github.com/vigilmvarghese/Nortrading-Renko-remote
- Click "Code" → "Download ZIP"
- Extract the ZIP file

### Step 3: Copy Include Files

Navigate to your downloaded project folder, then:

#### Copy RenkoRemote includes

**Windows:**
```cmd
xcopy /E /I "Include\RenkoRemote" "<MT5_DATA>\MQL5\Include\RenkoRemote"
```

**macOS/Linux:**
```bash
cp -r Include/RenkoRemote <MT5_DATA>/MQL5/Include/
```

**Manual:**
1. Create folder: `<MT5_DATA>/MQL5/Include/RenkoRemote/`
2. Copy these 3 files into it:
   - `RemoteTypes.mqh`
   - `ChartSymbolParser.mqh`
   - `GeneratorInterface.mqh`

#### Copy Renko shared types

If you already have Nortrading-Renko installed in a custom location, copy `RenkoTypes.mqh`:

**From:** `Nortrading-Renko/Include/Renko/RenkoTypes.mqh`  
**To:** `<MT5_DATA>/MQL5/Include/Renko/RenkoTypes.mqh`

**Manual:**
1. Create folder: `<MT5_DATA>/MQL5/Include/Renko/`
2. Copy file: `RenkoTypes.mqh` into it

**If Nortrading-Renko is already in standard location:**
- If main project is at `MQL5/Include/Renko/`, you're done - file already there!

### Step 4: Copy Indicator Files

**Windows:**
```cmd
copy "Indicators\Renko_Remote_Control.mq5" "<MT5_DATA>\MQL5\Indicators\"
copy "Indicators\Renko_Remote_Control_v2.mq5" "<MT5_DATA>\MQL5\Indicators\"
```

**macOS/Linux:**
```bash
cp Indicators/Renko_Remote_Control.mq5 <MT5_DATA>/MQL5/Indicators/
cp Indicators/Renko_Remote_Control_v2.mq5 <MT5_DATA>/MQL5/Indicators/
```

**Manual:**
1. Copy `Renko_Remote_Control.mq5` to `<MT5_DATA>/MQL5/Indicators/`
2. Copy `Renko_Remote_Control_v2.mq5` to `<MT5_DATA>/MQL5/Indicators/`

### Step 5: Verify File Structure

Your MT5 folder should now look like this:

```
MQL5/
├── Include/
│   ├── RenkoRemote/
│   │   ├── ChartSymbolParser.mqh      ✓
│   │   ├── GeneratorInterface.mqh     ✓
│   │   └── RemoteTypes.mqh            ✓
│   └── Renko/
│       └── RenkoTypes.mqh             ✓
└── Indicators/
    ├── Renko_Remote_Control.mq5       ✓
    └── Renko_Remote_Control_v2.mq5    ✓
```

### Step 6: Compile

1. Open **MetaEditor** (press F4 in MT5)
2. Navigate to `MQL5/Indicators/Renko_Remote_Control_v2.mq5`
3. Press **F7** to compile
4. Should see: `0 error(s), 0 warning(s)`
5. Repeat for `Renko_Remote_Control.mq5` if using v1.0

---

## Verification

### Check Compilation

In MetaEditor:
- Open `Renko_Remote_Control_v2.mq5`
- Check that includes resolve (no red underlines)
- Compile successfully (F7)

### Check Navigator

In MetaTrader 5:
1. Open **Navigator** (Ctrl+N)
2. Expand **Indicators → Custom**
3. You should see:
   - `Renko_Remote_Control` (v1.0)
   - `Renko_Remote_Control_v2` (v2.0)

### Test Attachment

1. Generate a Renko chart with OVO_Renko_Generator
2. Open the custom symbol chart (e.g., US30.M61)
3. Attach `Renko_Remote_Control_v2` from Navigator
4. Compact panel should appear

---

## Include Path Explanation

### Standard MT5 Include Syntax

When files are in `MQL5/Include/`, use angle brackets:

```cpp
#include <RenkoRemote/RemoteTypes.mqh>
```

This tells MT5 to look in: `MQL5/Include/RenkoRemote/RemoteTypes.mqh`

### Path Resolution

**From indicator:** `MQL5/Indicators/Renko_Remote_Control_v2.mq5`

```cpp
#include <RenkoRemote/RemoteTypes.mqh>
```

MT5 searches:
1. `MQL5/Include/RenkoRemote/RemoteTypes.mqh` ✓ Found

**From RemoteTypes.mqh:** `MQL5/Include/RenkoRemote/RemoteTypes.mqh`

```cpp
#include <Renko/RenkoTypes.mqh>
```

MT5 searches:
1. `MQL5/Include/Renko/RenkoTypes.mqh` ✓ Found

---

## Troubleshooting

### Error: "cannot open include file"

**Symptom:**
```
'RenkoRemote/RemoteTypes.mqh' cannot open include file
```

**Solution:**
- Verify folder exists: `MQL5/Include/RenkoRemote/`
- Check file is present: `RemoteTypes.mqh`
- Folder and file names are case-sensitive on some systems

### Error: "Renko/RenkoTypes.mqh not found"

**Symptom:**
```
'Renko/RenkoTypes.mqh' cannot open include file
```

**Solution:**
- Copy `RenkoTypes.mqh` from Nortrading-Renko project
- Place in: `MQL5/Include/Renko/RenkoTypes.mqh`
- Ensure main Nortrading-Renko project is installed

### Compilation Errors About Types

**Symptom:**
```
'ENUM_RENKO_TYPE' undeclared identifier
```

**Solution:**
- This means `RenkoTypes.mqh` isn't being included
- Check the include path is correct
- Verify `Renko/RenkoTypes.mqh` exists

### Indicator Not in Navigator

**Symptom:**
- Compiled successfully but don't see indicator

**Solution:**
- Restart MT5
- Check in Navigator under "Indicators → Custom"
- Compile errors may have been overlooked - check MetaEditor

---

## Updating

### Update Remote Control Files

1. Download latest version
2. Copy files again (overwrite existing):
   - `Include/RenkoRemote/*.mqh`
   - `Indicators/Renko_Remote_Control*.mq5`
3. Recompile in MetaEditor

### Update Main Project

If `RenkoTypes.mqh` changes in main project:

1. Get latest Nortrading-Renko
2. Copy updated `RenkoTypes.mqh` to `MQL5/Include/Renko/`
3. Recompile all indicators that use it

---

## Advantages of Flat Installation

✅ **Standard MT5 structure** - Files where MT5 expects them  
✅ **Easy to find** - Standard Include and Indicators folders  
✅ **Simple paths** - Uses `<>` angle bracket includes  
✅ **No submodule complexity** - Just copy files  
✅ **Works with any main project location** - Just need RenkoTypes.mqh  

---

## Alternative: Keep Submodule Structure

If you prefer keeping the project structure intact, see [INSTALLATION.md](INSTALLATION.md) for the git submodule approach.

---

## Quick Reference

### File Locations

| File | Source | Destination |
|------|--------|-------------|
| RemoteTypes.mqh | Include/RenkoRemote/ | MQL5/Include/RenkoRemote/ |
| ChartSymbolParser.mqh | Include/RenkoRemote/ | MQL5/Include/RenkoRemote/ |
| GeneratorInterface.mqh | Include/RenkoRemote/ | MQL5/Include/RenkoRemote/ |
| RenkoTypes.mqh | Nortrading-Renko/Include/Renko/ | MQL5/Include/Renko/ |
| Renko_Remote_Control.mq5 | Indicators/ | MQL5/Indicators/ |
| Renko_Remote_Control_v2.mq5 | Indicators/ | MQL5/Indicators/ |

### Include Paths Used

In indicators:
```cpp
#include <RenkoRemote/RemoteTypes.mqh>
#include <RenkoRemote/ChartSymbolParser.mqh>
#include <RenkoRemote/GeneratorInterface.mqh>
```

In RemoteTypes.mqh:
```cpp
#include <Renko/RenkoTypes.mqh>
```

---

## Support

- **Issues:** https://github.com/vigilmvarghese/Nortrading-Renko-remote/issues
- **Main Project:** https://github.com/vigilmvarghese/Nortrading-Renko
