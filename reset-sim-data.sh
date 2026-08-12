#!/bin/bash
# ============================================================
# reset-sim-data.sh — Reset data C4-MySkin di iOS Simulator
# ------------------------------------------------------------
# Menghapus SEMUA data app (journeys, foto, UserDefaults) dan
# meng-install ulang build terakhir dari DerivedData, lalu launch.
#
# Cara pakai (dari folder project):
#   bash reset-sim-data.sh
#
# Hasil: app fresh -> main page EMPTY state ("No active product yet")
# ============================================================
set -e

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

# 1. Cari simulator iPhone 17 Pro (ambil entri terakhir, yang biasa booted)
UDID=$(xcrun simctl list devices | grep -E "iPhone 17 Pro \(" | grep -oE "[0-9A-F-]{36}" | tail -1)
if [ -z "$UDID" ]; then
    echo "ERROR: Simulator 'iPhone 17 Pro' tidak ditemukan."
    echo "Cek dengan: xcrun simctl list devices | grep iPhone"
    exit 1
fi
echo "Target simulator : $UDID"

# 2. Cari app bundle hasil build terakhir (Debug-iphonesimulator)
APP=$(ls -d ~/Library/Developer/Xcode/DerivedData/C4-MySkin-*/Build/Products/Debug-iphonesimulator/C4-MySkin.app 2>/dev/null | head -1)
if [ -z "$APP" ]; then
    echo "ERROR: App bundle tidak ditemukan di DerivedData."
    echo "Build dulu: xcodebuild -project C4-MySkin.xcodeproj -scheme C4-MySkin -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build"
    exit 1
fi
echo "App bundle       : $APP"

# 3. Hapus app (data ikut terhapus) lalu install ulang
xcrun simctl terminate "$UDID" test.C4-MySkin 2>/dev/null || true
xcrun simctl uninstall "$UDID" test.C4-MySkin 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"

# 4. Launch fresh
xcrun simctl launch "$UDID" test.C4-MySkin

echo ""
echo "OK — data bersih total. App fresh, mulai dari awal."
echo ""
echo "DEBUG hook yang tersedia (launch manual):"
echo "  xcrun simctl launch $UDID test.C4-MySkin --main-active      # main page ACTIVE (journey sample)"
echo "  xcrun simctl launch $UDID test.C4-MySkin --show-timelapse   # journey sample + halaman timelapse"
echo "  xcrun simctl launch $UDID test.C4-MySkin --journey-m1       # JourneyMainView Milestone 1 state"
echo "  xcrun simctl launch $UDID test.C4-MySkin --journey-m2       # JourneyMainView Milestone 2 state"
echo "  xcrun simctl launch $UDID test.C4-MySkin --self-assessment  # langsung ke kuesioner"
echo "  xcrun simctl launch $UDID test.C4-MySkin --camera-guide     # langsung ke halaman kamera"
