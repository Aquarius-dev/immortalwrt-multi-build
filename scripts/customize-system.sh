#!/bin/bash
# customize-system.sh - Customize system configuration
set -e

DEVICE_NAME="${1:-}"
TARGET="${2:-}"
SUBTARGET="${3:-}"
LAN_IP="${4:-192.168.1.1}"

if [ -z "$DEVICE_NAME" ]; then
    echo "❌ Usage: $0 <device_name> <target> <subtarget> <lan_ip>"
    exit 1
fi

echo "🎨 Customizing system configuration..."

# Create UCI defaults
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom-config << EOF
#!/bin/sh
uci set network.lan.ipaddr='$LAN_IP'
uci set luci.main.mediaurlbase='/luci-static/material'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit
exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-config

# Create banner
mkdir -p files/etc
cat > files/etc/banner << EOF
.---------------------------.
| ImmortalWrt Custom Build |
| Device   : $DEVICE_NAME
| Target   : $TARGET/$SUBTARGET
| LAN IP   : $LAN_IP
.---------------------------.
EOF

echo "✅ System customization complete"
