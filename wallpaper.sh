#!/bin/bash

# Crear el directorio si no existe
mkdir -p "$HOME/Pictures"

# Ruta al fondo
WALLPAPER="$HOME/Pictures/wallpaper.jpg"

# Descargar imagen aleatoria
echo "📥 Descargando imagen desde picsum.photos..."
curl -sL "https://picsum.photos/1920/1080" -o "$WALLPAPER"

# Aplicar el fondo con feh
feh --bg-fill "$WALLPAPER"
