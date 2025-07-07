#!/bin/bash

# === Variables ===
PICOM_CONF_DIR="$HOME/.config/picom"
PICOM_CONF="$PICOM_CONF_DIR/picom.conf"
I3_CONFIG="$HOME/.config/i3/config"

# === Crear carpetas necesarias ===
mkdir -p "$PICOM_CONF_DIR"

# === Configuración de picom.conf ===
cat <<EOF > "$PICOM_CONF"
backend = "glx";
vsync = true;
shadow = false;
fading = true;
inactive-opacity = 0.9;
active-opacity = 1.0;
frame-opacity = 0.8;
corner-radius = 6;
blur-method = "dual_kawase";

opacity-rule = [
  "90:class_g = 'Alacritty'"
];
EOF
echo "✅ Archivo de configuración de picom creado."
