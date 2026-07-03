#!/bin/bash
set -e

# Default user and password if not set
RDP_USER=${RDP_USER:-aiuser}
RDP_PASSWORD=${RDP_PASSWORD:-aipassword}

# Create user if it doesn't exist
if ! id -u $RDP_USER > /dev/null 2>&1; then
    useradd -m -s /bin/bash -G sudo $RDP_USER
    echo "$RDP_USER:$RDP_PASSWORD" | chpasswd
    # Give all permissions (passwordless sudo) to the user (Hermes Agent requirement)
    echo "$RDP_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$RDP_USER
    chmod 0440 /etc/sudoers.d/$RDP_USER
fi

# Set password for existing user if changed
echo "$RDP_USER:$RDP_PASSWORD" | chpasswd

# Setup dbus directory
mkdir -p /var/run/dbus
rm -f /var/run/dbus/pid

# Setup xrdp directories
mkdir -p /var/run/xrdp
rm -f /var/run/xrdp/xrdp.pid /var/run/xrdp/xrdp-sesman.pid

# Start dbus
dbus-daemon --system

# Start Xrdp Session Manager
xrdp-sesman

# Start tools if they are available (they run in background)
# This fulfills the Omniroute -> Hermes Agent -> Aion UI workflow conceptually
echo "Starting Omniroute..."
if command -v omniroute >/dev/null; then
    omniroute start &
fi

echo "Starting Hermes Agent..."
if command -v hermes-agent >/dev/null; then
    hermes-agent start &
fi

echo "Starting Aion UI..."
if command -v aion-ui >/dev/null; then
    aion-ui start &
fi

echo "Starting Hermes Workspace..."
if command -v hermes-workspace >/dev/null; then
    hermes-workspace start &
fi

echo "Starting XRDP..."
# Ensure RSA keys are generated
if [ ! -f /etc/xrdp/rsakeys.ini ]; then
    xrdp-keygen xrdp auto
fi

# Start XRDP in foreground to keep container running
exec xrdp -n
