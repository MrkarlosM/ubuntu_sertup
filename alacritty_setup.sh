#!/bin/bash

# Configuración
ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
ALACRITTY_TOML="$ALACRITTY_CONFIG_DIR/alacritty.toml"
DRACULA_ZIP_URL="https://github.com/dracula/alacritty/archive/master.zip"
TEMP_DIR="/tmp/dracula_alacritty"
DRACULA_TOML_TARGET="$ALACRITTY_CONFIG_DIR/dracula.toml"

# Crear carpeta si no existe
mkdir -p "$ALACRITTY_CONFIG_DIR"
mkdir -p "$TEMP_DIR"

# Descargar y extraer tema Dracula
echo "🔽 Descargando tema Dracula..."
curl -Ls "$DRACULA_ZIP_URL" -o "$TEMP_DIR/master.zip"
unzip -q "$TEMP_DIR/master.zip" -d "$TEMP_DIR"

# Verificar que exista el archivo dracula.toml
DRACULA_TOML_SOURCE="$TEMP_DIR/alacritty-master/dracula.toml"
if [ -f "$DRACULA_TOML_SOURCE" ]; then
  cp "$DRACULA_TOML_SOURCE" "$DRACULA_TOML_TARGET"
  echo "🎨 Tema Dracula copiado a $DRACULA_TOML_TARGET"
else
  echo "❌ No se encontró dracula.toml en el zip"
  exit 1
fi

# Crear alacritty.toml con el contenido deseado
cat <<EOF > "$ALACRITTY_TOML"
import = ["$DRACULA_TOML_TARGET"]
env = { TERM = "xterm-256color" }

[colors]
draw_bold_text_with_bright_colors = true

[window]
opacity = 0.5

[shell]
program = "/usr/bin/zsh"
args = ["--login"]
EOF

echo "✅ alacritty.toml escrito con configuración completa."

# Limpiar temporales
rm -rf "$TEMP_DIR"



# Obtener ruta absoluta del directorio donde se encuentra el script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directorio fuente relativo al script
SOURCE_DIR="$SCRIPT_DIR/alacritty_fonts"

# Directorio destino
TARGET_DIR="$HOME/.local/share/fonts"

# Crear destino si no existe
mkdir -p "$TARGET_DIR"

# Verificar si hay archivos .ttf
if compgen -G "$SOURCE_DIR"/*.ttf > /dev/null; then
  echo "📁 Copiando fuentes desde $SOURCE_DIR a $TARGET_DIR..."
  cp "$SOURCE_DIR"/*.ttf "$TARGET_DIR/"
else
  echo "❌ No se encontraron archivos .ttf en $SOURCE_DIR"
  exit 1
fi

# Actualizar caché de fuentes
echo "🔄 Actualizando caché de fuentes..."
fc-cache -fv > /dev/null

echo "✅ Fuentes MesloLGS NF instaladas desde $SOURCE_DIR."
