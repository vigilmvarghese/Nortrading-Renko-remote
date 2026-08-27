# Quick Installation Guide - Flat Structure

## Installation in 3 Steps

### Step 1: Copy Include Files

Copy to `<MT5_DATA>/MQL5/Include/`:

```
Include/RenkoRemote/  →  MQL5/Include/RenkoRemote/
   ├── RemoteTypes.mqh
   ├── ChartSymbolParser.mqh
   └── GeneratorInterface.mqh

Also copy (from Nortrading-Renko):
Nortrading-Renko/Include/Renko/RenkoTypes.mqh  →  MQL5/Include/Renko/RenkoTypes.mqh
```

### Step 2: Copy Indicators

Copy to `<MT5_DATA>/MQL5/Indicators/`:

```
Indicators/Renko_Remote_Control_v2.mq5  →  MQL5/Indicators/
```

### Step 3: Compile

1. Open MetaEditor (F4)
2. Open `Renko_Remote_Control_v2.mq5`
3. Press F7 to compile
4. Done! ✓

## Final Structure

```
MQL5/
├── Include/
│   ├── RenkoRemote/
│   │   ├── RemoteTypes.mqh
│   │   ├── ChartSymbolParser.mqh
│   │   └── GeneratorInterface.mqh
│   └── Renko/
│       └── RenkoTypes.mqh
└── Indicators/
    └── Renko_Remote_Control_v2.mq5
```

## Usage

1. Generate Renko chart: Attach OVO_Renko_Generator to US30, click M61
2. Open custom chart: US30.M61
3. Attach indicator: Renko_Remote_Control_v2
4. Compact panel appears! ✓

---

For detailed instructions, see [INSTALLATION_FLAT.md](INSTALLATION_FLAT.md)
