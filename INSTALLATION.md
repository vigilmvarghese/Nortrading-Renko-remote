# Installation Guide - Nortrading Renko Remote

This guide covers different installation methods for the Nortrading-Renko-Remote indicator.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Method 1: Git Clone with Submodules (Recommended)](#method-1-git-clone-with-submodules-recommended)
3. [Method 2: Manual Installation](#method-2-manual-installation)
4. [Method 3: Side-by-Side Installation](#method-3-side-by-side-installation)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **MetaTrader 5** (build 3802 or higher)
- **MetaEditor** (included with MT5)

### Required Projects
- **Nortrading-Renko** (main generator): https://github.com/vigilmvarghese/Nortrading-Renko
- **Nortrading-Renko-Remote** (this project): https://github.com/vigilmvarghese/Nortrading-Renko-Remote

### Optional
- **Git** (for cloning with submodules)

---

## Method 1: Git Clone with Submodules (Recommended)

This method automatically includes the required Nortrading-Renko dependency.

### Step 1: Locate MT5 Data Folder

1. Open MetaTrader 5
2. Go to **File → Open Data Folder**
3. This opens your MT5 data folder (e.g., `C:\Users\YourName\AppData\Roaming\MetaQuotes\Terminal\XXXX\MQL5\`)

### Step 2: Clone Repository

Open command prompt or terminal in the `MQL5` folder and run:

```bash
git clone --recursive https://github.com/vigilmvarghese/Nortrading-Renko-Remote.git
```

The `--recursive` flag automatically clones the Nortrading-Renko submodule.

### Step 3: Verify Structure

Your folder structure should now be:

```
MQL5/
└── Nortrading-Renko-Remote/
    ├── Indicators/
    │   └── Renko_Remote_Control.mq5
    ├── Include/
    │   └── RenkoRemote/
    │       ├── RemoteTypes.mqh
    │       ├── ChartSymbolParser.mqh
    │       └── GeneratorInterface.mqh
    └── Nortrading-Renko/                    # Git submodule
        ├── Indicators/
        │   └── OVO_Renko_Generator.mq5
        └── Include/
            └── Renko/
                └── RenkoTypes.mqh           # Referenced by remote
```

### Step 4: Compile

1. Open **MetaEditor** (press F4 in MT5)
2. Navigate to: `MQL5/Nortrading-Renko-Remote/Indicators/Renko_Remote_Control.mq5`
3. Press **F7** to compile
4. If successful, you'll see: "0 error(s), 0 warning(s)"

### Step 5: Compile Main Generator (if not already done)

1. Navigate to: `MQL5/Nortrading-Renko-Remote/Nortrading-Renko/Indicators/OVO_Renko_Generator.mq5`
2. Press **F7** to compile

---

## Method 2: Manual Installation

If you don't have git or prefer manual installation:

### Step 1: Download Projects

1. **Download Nortrading-Renko**:
   - Go to: https://github.com/vigilmvarghese/Nortrading-Renko
   - Click "Code" → "Download ZIP"
   - Extract the ZIP file

2. **Download Nortrading-Renko-Remote**:
   - Go to: https://github.com/vigilmvarghese/Nortrading-Renko-Remote
   - Click "Code" → "Download ZIP"
   - Extract the ZIP file

### Step 2: Locate MT5 Data Folder

1. Open MetaTrader 5
2. Go to **File → Open Data Folder**
3. Navigate to the `MQL5` subfolder

### Step 3: Copy Files

Copy the folders to create this structure:

```
MQL5/
└── Nortrading-Renko-Remote/
    ├── Indicators/
    ├── Include/
    └── Nortrading-Renko/        # Manually copied here
        ├── Indicators/
        └── Include/
```

**Steps:**
1. Copy the extracted `Nortrading-Renko-Remote` folder to `MQL5/`
2. Copy the extracted `Nortrading-Renko` folder **inside** `MQL5/Nortrading-Renko-Remote/`

### Step 4: Compile

Same as Method 1, Step 4 and 5.

---

## Method 3: Side-by-Side Installation

Install both projects as separate top-level folders in MQL5.

### Step 1: Install Main Generator

1. Download/Clone **Nortrading-Renko**
2. Copy to: `<MT5_DATA_FOLDER>/MQL5/Nortrading-Renko/`

### Step 2: Install Remote Control

1. Download/Clone **Nortrading-Renko-Remote**
2. Copy to: `<MT5_DATA_FOLDER>/MQL5/Nortrading-Renko-Remote/`

### Step 3: Update Include Path

Since the main project is NOT a submodule, you need to adjust the include path:

1. Open: `MQL5/Nortrading-Renko-Remote/Include/RenkoRemote/RemoteTypes.mqh`

2. **Change line 12:**
   ```cpp
   // OLD:
   #include "../../Nortrading-Renko/Include/Renko/RenkoTypes.mqh"
   
   // NEW:
   #include "../../../Nortrading-Renko/Include/Renko/RenkoTypes.mqh"
   ```

   This goes up 3 levels (`../../..`) from:
   ```
   MQL5/Nortrading-Renko-Remote/Include/RenkoRemote/RemoteTypes.mqh
   ```
   To reach:
   ```
   MQL5/Nortrading-Renko/Include/Renko/RenkoTypes.mqh
   ```

### Step 4: Compile

Compile both indicators as usual.

**Final Structure:**
```
MQL5/
├── Nortrading-Renko/
│   ├── Indicators/
│   │   └── OVO_Renko_Generator.mq5
│   └── Include/
│       └── Renko/
│           └── RenkoTypes.mqh
└── Nortrading-Renko-Remote/
    ├── Indicators/
    │   └── Renko_Remote_Control.mq5
    └── Include/
        └── RenkoRemote/
            └── ...
```

---

## Verification

### 1. Check Compilation

In MetaEditor, after compiling:
- **Errors tab** should show: `0 error(s), 0 warning(s)`
- If there are errors, check the [Troubleshooting](#troubleshooting) section

### 2. Check Navigator

In MetaTrader 5:
1. Open **Navigator** (Ctrl+N)
2. Expand **Indicators → Custom**
3. You should see:
   - `OVO_Renko_Generator` (from main project)
   - `Renko_Remote_Control` (from remote project)

### 3. Test Basic Functionality

1. **Generate a Renko Chart:**
   - Attach `OVO_Renko_Generator` to any symbol (e.g., US30)
   - Click the period button (M61) in the panel
   - Wait for chart generation (US30.M61 chart opens)

2. **Attach Remote Control:**
   - Go to the generated Renko chart (US30.M61)
   - Attach `Renko_Remote_Control` indicator
   - Remote control panel should appear
   - Panel should show: Symbol, State (LIVE), Type, Brick Size, etc.

---

## Troubleshooting

### Error: "Cannot open include file"

**Symptom:**
```
'../../Nortrading-Renko/Include/Renko/RenkoTypes.mqh' cannot open
```

**Solution:**
- Check that Nortrading-Renko is in the correct location
- If using side-by-side installation (Method 3), update the include path as described
- Verify folder names match exactly (case-sensitive on some systems)

### Error: "Undeclared identifier"

**Symptom:**
```
'ENUM_RENKO_TYPE' - undeclared identifier
```

**Solution:**
- This means `RenkoTypes.mqh` is not being included properly
- Double-check the include path in `RemoteTypes.mqh`
- Make sure the main project is fully installed

### Remote Panel Not Showing

**Symptom:**
- Indicator attached but no panel visible

**Solution:**
- Check that you attached to a Renko custom symbol (e.g., US30.M61), not the source symbol
- Check input parameters: `InpShowControlPanel = true`
- Check MetaEditor Experts tab for errors during initialization

### "Generator is not active" Alert

**Symptom:**
- Panel shows but all buttons show "Generator is not active" alert

**Solution:**
- Ensure the main `OVO_Renko_Generator` is attached to the source symbol
- Verify the generator is in LIVE or PANEL_ONLY state
- Check that global variables are enabled in MT5: Tools → Options → Expert Advisors → "Allow EA to use global variables"

### Commands Not Being Received

**Symptom:**
- Click buttons but nothing happens

**Solution:**
- Check that AutoTrading is enabled (button in toolbar)
- Verify global variables are working: Tools → Options → Charts → "Show global variables"
- Check MetaEditor Experts tab for error messages
- Ensure command timeout is not too short (default: 5 seconds)

### Compilation Error: "Old style definition"

**Symptom:**
```
old style definition - use 'strict' property
```

**Solution:**
- This is usually just a warning, not an error
- Make sure `#property strict` is at the top of each .mqh file
- Update to latest MT5 build if possible

---

## Updating the Remote Control

### If Using Git Submodules (Method 1)

```bash
cd MQL5/Nortrading-Renko-Remote
git pull
git submodule update --remote --merge
```

This updates both the remote control and the submodule reference to the latest main project.

### If Using Manual Installation (Method 2 or 3)

1. Download the latest version from GitHub
2. Backup your existing installation
3. Replace files with new versions
4. Recompile

---

## Getting Help

- **Remote Control Issues**: https://github.com/vigilmvarghese/Nortrading-Renko-Remote/issues
- **Main Generator Issues**: https://github.com/vigilmvarghese/Nortrading-Renko/issues
- **Discussions**: https://github.com/vigilmvarghese/Nortrading-Renko/discussions

When reporting issues, please include:
- MT5 build number
- Installation method used
- Full error message from MetaEditor
- Folder structure screenshot
