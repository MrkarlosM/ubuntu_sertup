#!/bin/bash
set -euo pipefail
# set -x  # Modo depuración

# Verifica conexión a Internet
ping -q -w 3 -c 1 google.com > /dev/null || { echo "❌ Sin conexión a Internet"; exit 1; }

# Lista de paquetes fallidos
PAQUETES_FALLIDOS=()

# Función de instalación robusta
instalar_paquete() {
  local paquete
  for paquete in "$@"; do
    echo "📦 Instalando: $paquete"
    if ! sudo apt install -y "$paquete"; then
      echo "❌ Error al instalar: $paquete"
      PAQUETES_FALLIDOS+=("$paquete")
    fi
  done
}

# Paquetes por categoría
ENTORNO_GRAFICO=(xorg xinit x11-xserver-utils lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings)
I3_UTILIDADES=(i3 i3status i3lock feh unzip zip thunar gvfs gvfs-backends network-manager network-manager-gnome)
HERRAMIENTAS=(flameshot rofi git curl polybar picom vlc playerctl fonts-jetbrains-mono fonts-firacode alacritty zsh fonts-powerline brightnessctl neofetch)

# Mostrar lo que se va a instalar
echo "🔧 Los siguientes paquetes serán instalados:"
echo -e "\n🖥️ Entorno gráfico:"
printf '  - %s\n' "${ENTORNO_GRAFICO[@]}"

echo -e "\n🧩 i3 y utilidades:"
printf '  - %s\n' "${I3_UTILIDADES[@]}"

echo -e "\n🛠️ Herramientas generales:"
printf '  - %s\n' "${HERRAMIENTAS[@]}"

# Actualizar sistema
echo -e "\n🔄 Actualizando sistema..."
if ! sudo apt update && sudo apt upgrade -y; then
  echo "❌ Error al actualizar el sistema"
  exit 1
fi

# Instalar paquetes
echo -e "\n🖥️ Instalando entorno gráfico..."
instalar_paquete "${ENTORNO_GRAFICO[@]}"

echo -e "\n🧩 Instalando i3 y utilidades..."
instalar_paquete "${I3_UTILIDADES[@]}"

echo -e "\n🛠️ Instalando herramientas generales..."
instalar_paquete "${HERRAMIENTAS[@]}"

# Resultado final
echo -e "\n✅ Instalación de paquetes finalizada."

if [ "${#PAQUETES_FALLIDOS[@]}" -ne 0 ]; then
  echo -e "\n⚠️ Los siguientes paquetes NO se pudieron instalar:"
  for p in "${PAQUETES_FALLIDOS[@]}"; do
    echo "  - $p"
  done
  exit 1
else
  echo "🎉 Todos los paquetes fueron instalados correctamente."
fi

echo "Otorgando permisos a brave_install.sh..."
sudo chmod +x brave_install.sh

echo "Ejecutando brave_install.sh..."
bash brave_install.sh

echo "Otorgando permisos a ohmyzsh_setup.sh"
sudo chmod +x ohmyzsh_setup.sh
bash ohmyzsh_setup.sh

echo "Otorgando permisos a alacritty_setup.sh"
sudo chmod +x alacritty_setup.sh
bash alacritty_setup.sh

echo "Instalando wallpaper"
sudo chmod +x wallpaper.sh
bash wallpaper.sh

echo "Configurando Picom"
sudo chmod +x picom.sh
bash picom.sh

echo "Configurando zona horaria"
sudo chmod +x set_timezone.sh
bash sudo ./set_timezone.sh

echo "Finalizando... copiando los archivos de configuración"
sudo chmod +x copier.sh
bash copier.sh






