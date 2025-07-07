#!/bin/bash

# Verifica si Zsh está instalado
if ! command -v zsh >/dev/null 2>&1; then
  echo "Zsh no está instalado. Por favor, instale Zsh primero."
  exit 1
fi

# Verifica si Oh My Zsh ya está instalado
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh ya está instalado."
else
  echo "Instalando Oh My Zsh..."

  # Evita que se inicie Zsh automáticamente tras la instalación
  export RUNZSH=no

  # Instala Oh My Zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # Verifica si se instaló correctamente
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh instalado correctamente."
  else
    echo "Hubo un problema instalando Oh My Zsh."
    exit 1
  fi
fi

# Obtener la ruta de Zsh
ZSH_PATH=$(which zsh)

# Verifica si ya es el shell por defecto
if [ "$SHELL" = "$ZSH_PATH" ]; then
  echo "Zsh ya es el shell predeterminado."
else
  echo "Estableciendo Zsh como el shell por defecto para el usuario $(whoami)..."
  chsh -s "$ZSH_PATH"
  echo "Shell predeterminado actualizado. Cierre sesión y vuelva a entrar para aplicar los cambios."
fi


#Instalar temas
echo "Instalando el tema powerlevel10k"

# Ruta de instalación del tema
THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh}/themes/powerlevel10k"

# Clonar tema si no existe
if [ ! -d "$THEME_DIR" ]; then
  echo "Clonando Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"
else
  echo "Powerlevel10k ya está instalado."
fi

# Ruta del archivo .zshrc
ZSHRC="$HOME/.zshrc"

if grep -q '^ZSH_THEME=' "$ZSHRC"; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
fi

echo "Tema Powerlevel10k configurado correctamente en .zshrc."
echo "Reinicie su terminal o ejecute 'source ~/.zshrc' para aplicar los cambios."

#Tema

#!/bin/bash

# Ruta del repositorio y archivos
REPO_URL="https://github.com/dracula/powerlevel10k.git"
CLONE_DIR="$HOME/.config/dracula_p10k"

# Clonar el repositorio de Dracula Powerlevel10k
if [ ! -d "$CLONE_DIR" ]; then
  echo "Clonando tema Dracula Powerlevel10k..."
  git clone "$REPO_URL" "$CLONE_DIR"
else
  echo "Ya existe el repositorio en $CLONE_DIR. Actualizando..."
  git -C "$CLONE_DIR" pull
fi

# Verificar si existen los archivos necesarios
if [ ! -f "$CLONE_DIR/files/.zshrc" ] || [ ! -f "$CLONE_DIR/files/.p10k.zsh" ]; then
  echo "❌ No se encontraron los archivos .zshrc o .p10k.zsh en $CLONE_DIR/files"
  exit 1
fi

# Backup de archivos previos si existen
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.backup_$TIMESTAMP"
[ -f "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup_$TIMESTAMP"

# Copiar archivos de configuración
echo "Copiando archivos de configuración..."
cp "$CLONE_DIR/files/.zshrc" "$HOME/.zshrc"
cp "$CLONE_DIR/files/.p10k.zsh" "$HOME/.p10k.zsh"

# Corregir ruta de instalación de Oh My Zsh
sed -i 's|^export ZSH=.*|export ZSH="$HOME/.oh-my-zsh"|' "$HOME/.zshrc"

# Corregir línea de source del tema para que apunte a la ubicación válida
sed -i 's|source ~/powerlevel10k/powerlevel10k.zsh-theme|source ~/.oh-my-zsh/themes/powerlevel10k/powerlevel10k.zsh-theme|' "$HOME/.zshrc"

#Corregir la linea ruta del archivo .zshrc
ZSHRC="$HOME/.zshrc"

if grep -q '^ZSH_THEME=' "$ZSHRC"; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
fi

echo "✅ Configuración del tema Dracula aplicada correctamente."

# Reiniciar Zsh para aplicar los cambios
echo "Reiniciando Zsh..."
exec zsh -l
