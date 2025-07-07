#!/bin/bash

# === Verificar si es root ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script debe ejecutarse como root. Use: sudo $0"
  exit 1
fi

# === Establecer zona horaria de Colombia ===
echo "🌎 Estableciendo zona horaria a 'America/Bogota'..."
timedatectl set-timezone America/Bogota

# === Habilitar sincronización de hora por red ===
echo "🕒 Habilitando sincronización horaria con la red..."
timedatectl set-ntp true

# === Mostrar estado ===
echo "🔍 Estado actual del reloj:"
timedatectl status

echo "✅ Zona horaria y sincronización configuradas correctamente."
