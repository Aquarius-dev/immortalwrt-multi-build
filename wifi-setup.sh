#!/bin/sh

WIFI_SSID="NETGEAR_5G"
WIFI_KEY="13882020269"
WIFI_ENCRYPTION="psk2"
WIFI_CIPHER="ccmp"

echo "=== Checking required packages ==="
NEED_INSTALL=""
for pkg in wpad-openssl iw; do
  if ! opkg list-installed 2>/dev/null | grep -q "^$pkg "; then
    NEED_INSTALL="$NEED_INSTALL $pkg"
  fi
done

if [ -n "$NEED_INSTALL" ]; then
  echo "Missing packages:$NEED_INSTALL, installing..."
  opkg update
  for pkg in $NEED_INSTALL; do
    opkg install $pkg
  done
fi

echo ""
echo "=== Detecting 5GHz radio ==="

# Regenerate wireless config if missing
if ! uci show wireless >/dev/null 2>&1; then
  echo "No wireless config, running wifi detect..."
  wifi detect > /tmp/wireless.tmp 2>&1
  cat /tmp/wireless.tmp >> /etc/config/wireless 2>/dev/null
fi

echo "Available radios:"
uci show wireless | grep "wifi-device" | head -10

RADIO=""
for r in $(uci show wireless | grep "wifi-device" | cut -d= -f1 | cut -d. -f2 | sort -u); do
  _hwmode=$(uci get wireless.$r.hwmode 2>/dev/null)
  _band=$(uci get wireless.$r.band 2>/dev/null)
  echo "  $r: hwmode=$_hwmode band=$_band"
  if [ "$_hwmode" = "11a" ] || [ "$_band" = "5GHz" ]; then
    RADIO="$r"
  fi
done

if [ -z "$RADIO" ]; then
  echo "Error: could not detect 5GHz radio. Using radio1 as fallback."
  RADIO="radio1"
fi

echo ""
echo "=== Configuring $RADIO ==="
uci set wireless.$RADIO.disabled='0'

IFACE="default_$RADIO"
if ! uci get wireless.$IFACE >/dev/null 2>&1; then
  IFACE="cfg_$RADIO"
fi
if ! uci get wireless.$IFACE >/dev/null 2>&1; then
  IFACE="default_$RADIO"
  uci set wireless.$IFACE=wifi-iface
fi

uci set wireless.$IFACE.mode='ap'
uci set wireless.$IFACE.device="$RADIO"
uci set wireless.$IFACE.ssid="$WIFI_SSID"
uci set wireless.$IFACE.encryption="$WIFI_ENCRYPTION"
uci set wireless.$IFACE.key="$WIFI_KEY"
uci set wireless.$IFACE.cipher="$WIFI_CIPHER"
uci set wireless.$IFACE.disabled='0'
uci set wireless.$IFACE.network='lan'
uci set wireless.$IFACE.ieee80211k='1'
uci set wireless.$IFACE.ieee80211v='1'
uci set wireless.$IFACE.ieee80211r='1'

uci commit wireless
wifi reload

echo ""
echo "=== Done ==="
echo "SSID: $WIFI_SSID | Radio: $RADIO | Encryption: $WIFI_ENCRYPTION"
