pragma Singleton
import QtQuick

QtObject {
    // ── Colours ────────────────────────────────────────────────────────────
    readonly property string colWhite:    "#ffffff"
    readonly property string colDimWhite: "#444444"
    readonly property string colBlue:     "#78b4f3"
    readonly property string colDimBlue:  "#3a5573"
    readonly property string colCyan:     "#ab9df2"
    readonly property string colDimCyan:  "#524a73"
    readonly property string colGreen:    "#a9dc76"
    readonly property string colYellow:   "#ffd866"
    readonly property string colRed:      "#ff6188"

    // ── Font ───────────────────────────────────────────────────────────────
    readonly property string fontNormal: "JetBrains Mono"

    // ── Font sizes ─────────────────────────────────────────────────────────
    readonly property int fontSizeSm: 14   // secondary / subscript
    readonly property int fontSizeMd: 18   // primary body text
    readonly property int fontSizeLg: 64   // clock time

    // ── Spacers ────────────────────────────────────────────────────────────
    readonly property int spacerSm: 4      // tight row/column spacing
    readonly property int spacerMd: 8      // section gaps

    // ── Label widths ───────────────────────────────────────────────────────
    readonly property int labelWidthSm: 60   // "INT", "EXT", connection type
    readonly property int labelWidthMd: 100  // proc names, mount paths

    // ── Layout ─────────────────────────────────────────────────────────────
    readonly property int margin: 24
}
