# Changelog - Nortrading-Renko-Remote

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-08-27

### Added - Compact OVO-Style Panel
- **New indicator:** `Renko_Remote_Control_v2.mq5` with minimal footprint
- **Zero configuration:** No input parameters, all settings hardcoded
- **Compact design:** 24px height (92% smaller than v1.0)
- **Expandable chart type selector:** Click to expand, auto-collapse after selection
- **Radio button interface:** Visual selection with ● (filled) and ○ (empty) indicators
- **FEED button:** Quick navigation to source chart where generator is attached
- **Complete documentation:** `COMPACT_PANEL_DESIGN.md` with design philosophy

### Features
- Dynamic indicator window height (24px ↔ 72px)
- Click "Mean Renko" / "Regular Renko" label to expand options
- Select chart type with radio buttons
- Auto-collapse after selection
- Real-time brick count display
- Current brick size display
- Multi-brick burst alerts (3+ bricks)

### Technical
- Property `#property indicator_height 24` for compact subwindow
- Dynamic height control with `IndicatorSetInteger(INDICATOR_HEIGHT, ...)`
- Chart navigation using `ChartSetInteger(..., CHART_BRING_TO_TOP, ...)`
- Simulated radio buttons using OBJ_BUTTON with visual indicators
- Dark theme color scheme (C'40,40,40' background)

### Use Cases
- Minimal screen space requirement
- Quick chart type switching
- Clean workspace for multiple instances
- Efficient chart-to-chart navigation

---

## [1.0.0] - 2026-08-27

### Added - Initial Release
- **Full-featured panel:** `Renko_Remote_Control.mq5` with comprehensive controls
- **Chart-specific control:** Attaches to generated Renko custom symbol charts
- **Generator interface:** Communication via global variables
- **Interactive controls:**
  - Change brick size with editable field
  - Switch chart type with toggle button
  - Trigger manual rebuilds
- **Real-time monitoring:**
  - State display (LIVE, REBUILDING, etc.)
  - Total brick count
  - Last brick timestamp and direction
  - Build progress during reconstruction
- **Smart alerts:**
  - New brick completion (optional)
  - Trend reversals
  - Multi-brick burst detection
  - State change notifications
- **Statistics display:**
  - Bricks per hour rate
  - Session metrics

### Components
- `ChartSymbolParser.mqh` - Parse custom symbol names (US30.M61 → US30 + M61)
- `GeneratorInterface.mqh` - Read/write generator state via global variables
- `RemoteTypes.mqh` - Data structures and enums

### Configuration (v1.0 only)
- 13 input parameters for customization
- Panel positioning (X, Y)
- Alert configuration (types, thresholds)
- Display settings (colors, font size, statistics)
- Update interval (milliseconds)

### Documentation
- README.md - Complete feature overview
- INSTALLATION.md - Three installation methods
- QUICK_START.md - 5-minute getting started guide
- ARCHITECTURE.md - Technical design and patterns
- PROJECT_SUMMARY.md - Project statistics

### Integration
- Git submodule: Nortrading-Renko (main project)
- References shared `RenkoTypes.mqh`
- MIT License

---

## Version Comparison

| Feature | v1.0 (Full) | v2.0 (Compact) |
|---------|-------------|----------------|
| **Indicator File** | Renko_Remote_Control.mq5 | Renko_Remote_Control_v2.mq5 |
| **Input Parameters** | 13 configurable | 0 (hardcoded) |
| **Panel Height** | 180px fixed | 24px / 72px dynamic |
| **Screen Footprint** | Large | Minimal (92% smaller) |
| **Brick Size Edit** | ✅ Editable field | ❌ Not included |
| **Chart Type Switch** | ✅ Toggle button | ✅ Expandable radio buttons |
| **Rebuild Button** | ✅ Manual rebuild | ❌ Not included |
| **Statistics** | ✅ Brick rate display | ❌ Not included |
| **Feed Button** | ❌ Not included | ✅ Jump to source chart |
| **Auto-collapse** | N/A (fixed) | ✅ After selection |
| **Complexity** | High (feature-rich) | Low (focused) |
| **Use Case** | Power users, testing | Clean workspace, navigation |

### Which Version to Use?

**Choose v1.0 (Full) if you:**
- Need to frequently adjust brick size
- Want detailed statistics and metrics
- Prefer customizable appearance
- Need manual rebuild control
- Are testing different configurations

**Choose v2.0 (Compact) if you:**
- Have limited screen space
- Primarily switch chart types
- Run multiple instances
- Want minimal visual clutter
- Need quick chart navigation

**Both versions can coexist** - attach the one that fits your workflow!

---

## Future Roadmap

### v2.1 (Planned)
- [ ] Configurable panel position (left/right/center)
- [ ] Brick size quick selector (dropdown)
- [ ] Keyboard shortcuts (Ctrl+Click)
- [ ] Smooth expand/collapse animation
- [ ] Remember last panel state

### v3.0 (Consideration)
- [ ] Multi-chart dashboard view
- [ ] Drag-and-drop panel positioning
- [ ] Custom color themes
- [ ] Panel opacity control
- [ ] Floating detachable panel
- [ ] Pattern recognition alerts
- [ ] Historical brick analysis
- [ ] CSV export functionality

---

## Installation

### v2.0 (Latest)
```bash
cd <MT5_DATA_FOLDER>/MQL5/
git clone --recursive https://github.com/vigilmvarghese/Nortrading-Renko-remote.git
```

Compile: `Indicators/Renko_Remote_Control_v2.mq5`

### Update from v1.0
```bash
cd Nortrading-Renko-remote
git pull
git submodule update --remote
```

Both versions available in the same repository.

---

## Support

- **Repository:** https://github.com/vigilmvarghese/Nortrading-Renko-remote
- **Issues:** https://github.com/vigilmvarghese/Nortrading-Renko-remote/issues
- **Main Project:** https://github.com/vigilmvarghese/Nortrading-Renko

---

## License

MIT License - See [LICENSE](LICENSE) file for details.
