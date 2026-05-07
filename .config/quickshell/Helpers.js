.pragma library

// Left-filled 8-char block bar  e.g. ████░░░░
function barStr(pct) {
    const filled = Math.round(pct / 100 * 8)
    return "█".repeat(filled) + "░".repeat(8 - filled)
}

// Right-filled 8-char block bar  e.g. ░░░░████
function barStrR(pct) {
    const filled = Math.round(pct / 100 * 8)
    return "░".repeat(8 - filled) + "█".repeat(filled)
}

// 6-char TX bar scaled relative to the running EMA ceiling
function txBarStr(txRate, txEma) {
    const pct    = txEma > 0 ? Math.min(1, txRate / (txEma * 3.0)) : 0
    const filled = Math.round(pct * 6)
    return "█".repeat(filled) + "░".repeat(6 - filled)
}

// 6-char RX bar scaled relative to the running EMA ceiling
function rxBarStr(rxRate, rxEma) {
    const pct    = rxEma > 0 ? Math.min(1, rxRate / (rxEma * 3.0)) : 0
    const filled = Math.round(pct * 6)
    return "░".repeat(6 - filled) + "█".repeat(filled)
}

// Bytes-per-second → human-readable string
function netRateStr(bps) {
    if (bps >= 1048576) return (bps / 1048576).toFixed(1) + " MB/s"
    if (bps >= 1024)    return Math.round(bps / 1024)     + " KB/s"
    return Math.round(bps) + " B/s"
}

// Colour for CPU temperature (pass Theme singleton)
function tempColor(temp, theme) {
    if (temp >= 80) return theme.colRed
    if (temp >= 60) return theme.colBlue
    return theme.colGreen
}

// Colour for disk usage percentage (pass Theme singleton)
function diskColor(pct, theme) {
    if (pct >= 85) return theme.colRed
    if (pct >= 70) return theme.colBlue
    return theme.colGreen
}

// Colour for CPU usage percentage (pass Theme singleton)
function cpuColor(pct, theme) {
    if (pct >= 80) return theme.colRed
    if (pct >= 50) return theme.colYellow
    return theme.colGreen
}

// Colour for battery (pass Theme singleton)
function batColor(pct, charging, theme) {
    if (charging)  return theme.colBlue
    if (pct <= 15) return theme.colRed
    return theme.colGreen
}
