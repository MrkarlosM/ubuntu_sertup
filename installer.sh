#!/bin/bash
set -euo pipefail
# set -x  # Descomenta esta línea para modo depuración

# Verifica conexión a internet
ping -q -w 3 -c 1 google.com > /dev/null || { echo "❌ Sin conexión a Internet"; exit 1; }

# Funciones reutilizables
instalar_paquete() {
  sudo apt install "$@" -y || { echo "❌ Error al instalar: $*"; exit 1; }
}

descargar_archivo() {
  wget --timeout=10 -qO "$2" "$1" || { echo "❌ Error al descargar: $1"; exit 1; }
}

# Actualizar sistema
sudo apt update && sudo apt upgrade -y || { echo "❌ Error al actualizar el sistema"; exit 1; }

# Instalar entorno gráfico y gestor de sesión
instalar_paquete xorg xinit x11-xserver-utils lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

# i3 y utilidades
instalar_paquete i3 i3status i3lock feh unzip zip thunar gvfs gvfs-backends network-manager network-manager-gnome

# Herramientas
instalar_paquete flameshot rofi git curl polybar picom vlc playerctl fonts-jetbrains-mono fonts-firacode alacritty zsh fonts-powerline brightnessctl

# Brave Browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave.com/static-assets/archive.key || { echo "❌ Error clave Brave"; exit 1; }
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
sudo apt update && instalar_paquete brave-browser

# Configuración Rofi
mkdir -p ~/.config/rofi/themes
descargar_archivo https://raw.githubusercontent.com/dracula/rofi/master/theme.rasi ~/.config/rofi/themes/dracula.rasi
grep -q 'rofi.theme' ~/.Xresources || echo 'rofi.theme: ~/.config/rofi/themes/dracula.rasi' >> ~/.Xresources
xrdb -merge ~/.Xresources

# Configuración Alacritty
mkdir -p ~/.config/alacritty
cat <<EOF > ~/.config/alacritty/alacritty.yml
shell:
  program: /usr/bin/zsh

window:
  opacity: 0.90
  padding:
    x: 10
    y: 10

font:
  normal:
    family: "JetBrainsMono Nerd Font"
    style: Regular
  size: 10

import:
  - ~/.config/alacritty/dracula.yml
EOF
descargar_archivo https://raw.githubusercontent.com/dracula/alacritty/master/dracula.yml ~/.config/alacritty/dracula.yml

# Fondo de pantalla
mkdir -p ~/Pictures
descargar_archivo https://picsum.photos/1920/1080 ~/Pictures/fondo.jpg

# Picom
mkdir -p ~/.config/picom
cat <<EOF > ~/.config/picom/picom.conf
backend = "xrender";
vsync = true;
fading = true;
fade-delta = 4;
shadow = true;
shadow-radius = 8;
shadow-opacity = 0.7;
shadow-offset-x = -7;
shadow-offset-y = -7;
blur-background = false;
EOF

# Script música para Polybar
mkdir -p ~/.config/polybar/scripts
cat <<EOF > ~/.config/polybar/scripts/music.sh
#!/bin/bash
status=\$(playerctl --player=vlc,mpv,%any status 2>/dev/null)
if [ "\$status" = "Playing" ]; then
  echo "▶️ \$(playerctl --player=vlc,mpv,%any metadata artist 2>/dev/null) - \$(playerctl --player=vlc,mpv,%any metadata title 2>/dev/null)"
elif [ "\$status" = "Paused" ]; then
  echo "⏸️ \$(playerctl --player=vlc,mpv,%any metadata artist 2>/dev/null) - \$(playerctl --player=vlc,mpv,%any metadata title 2>/dev/null)"
else
  echo "🔇 No hay reproductor activo"
fi
EOF
chmod +x ~/.config/polybar/scripts/music.sh

# Polybar con soporte para red unificado
cat <<EOF > ~/.config/polybar/config.ini
[bar/example]
width = 100%
height = 28
background = #282a36
foreground = #f8f8f2
font-0 = "JetBrainsMono Nerd Font:size=10;2"

modules-left = i3
modules-center = date
modules-right = wireless-network wired-network volume battery music cpu

[module/i3]
type = internal/i3
label-foreground = #f8f8f2

[module/date]
type = internal/date
interval = 5
format = <label>
label = %date% %time%
date = %a %d %b
time = %H:%M
label-foreground = #f8f8f2

[module/wired-network]
type = internal/network
interface = wired
format-connected = <label-connected>
format-disconnected = <label-disconnected>
label-connected =  %essid% (%local_ip%)
label-disconnected = ❌ Sin red
label-foreground = #f8f8f2
format-disconnected =

[module/wireless-network]
type = internal/network
interface = wireless
format-connected = <label-connected>
format-disconnected = <label-disconnected>
label-connected =  %essid% (%local_ip%)
label-disconnected = ❌ Sin red
label-foreground = #f8f8f2
format-disconnected =

[module/volume]
type = internal/pulseaudio
format-volume = <label-volume>
format-muted = <label-muted>
label-volume = 🔊 %percentage%%
label-muted = 🔇 Muted
label-foreground = #f8f8f2

[module/battery]
type = internal/battery
enable-upower = true
full-at = 98
poll-interval = 5
format-charging = <label-charging>
format-discharging = <label-discharging>
format-full = <label-full>
format-not-present = <label-not-present>
label-charging = ⚡ %percentage%%
label-discharging = 🔋 %percentage%%
label-full = 🔌 %percentage%%
label-not-present = 🔋 N/A
label-foreground = #f8f8f2

[module/music]
type = custom/script
exec = ~/.config/polybar/scripts/music.sh
interval = 3
format = <label>
label = 🎵 %output%
label-foreground = #f8f8f2

[module/cpu]
type = internal/cpu
interval = 2
format = <label>
label = 🧠 %percentage%%
label-foreground = #f8f8f2
EOF

# Script de lanzamiento Polybar
cat <<EOF > ~/.config/polybar/launch.sh
#!/bin/bash
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done
polybar example &
EOF
chmod +x ~/.config/polybar/launch.sh

# Configuración i3
mkdir -p ~/.config/i3
cat <<EOF > ~/.config/i3/config
set \$mod Mod4

font pango:JetBrainsMono Nerd Font 10

exec_always --no-startup-id nm-applet
exec_always --no-startup-id feh --bg-scale $HOME/Pictures/fondo.jpg
exec_always --no-startup-id picom --config ~/.config/picom/picom.conf
exec_always --no-startup-id ~/.config/polybar/launch.sh
exec_always --no-startup-id flameshot

bindsym \$mod+Return exec alacritty
bindsym \$mod+d exec rofi -show drun
bindsym \$mod+f exec thunar
bindsym \$mod+b exec brave-browser
bindsym \$mod+Shift+d exec rofi -show window
bindsym Print exec flameshot gui
bindsym \$mod+Shift+e exec "i3-nagbar -t warning -m '¿Salir de i3?' -b 'Sí' 'i3-msg exit'"
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous

client.focused          #6272a4 #6272a4 #f8f8f2 #6272a4
client.focused_inactive #44475a #44475a #f8f8f2 #44475a
client.unfocused        #282a36 #282a36 #f8f8f2 #282a36
client.urgent           #ff5555 #ff5555 #f8f8f2 #ff5555
EOF

# Zsh y temas
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || { echo "❌ Error al instalar Oh My Zsh"; exit 1; }
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k || { echo "❌ Error al clonar Powerlevel10k"; exit 1; }
git clone --depth=1 https://github.com/dracula/powerlevel10k.git ~/dracula-powerlevel10k || { echo "❌ Error al clonar Dracula para Powerlevel10k"; exit 1; }
cp ~/dracula-powerlevel10k/files/.p10k.zsh ~/.p10k.zsh || { echo "❌ Error al copiar .p10k.zsh"; exit 1; }
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
grep -q "source ~/.p10k.zsh" ~/.zshrc || echo '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' >> ~/.zshrc

# Plugins zsh
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions || { echo "❌ Error al clonar zsh-autosuggestions"; exit 1; }
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting || { echo "❌ Error al clonar zsh-syntax-highlighting"; exit 1; }
grep -q "plugins=" ~/.zshrc || echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc

# Alias
echo "alias ll='ls -lah --color=auto'" >> ~/.zshrc
echo "alias gs='git status'" >> ~/.zshrc
echo "alias update='sudo apt update && sudo apt upgrade -y'" >> ~/.zshrc

# Nerd font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
descargar_archivo https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip JetBrainsMono.zip
unzip -o JetBrainsMono.zip || { echo "❌ Error al descomprimir JetBrainsMono"; exit 1; }
fc-cache -fv || { echo "❌ Error al actualizar caché de fuentes"; exit 1; }
cd ~
rm -f JetBrainsMono.zip

# Tema Dracula para LightDM
mkdir -p ~/.themes
descargar_archivo https://github.com/dracula/gtk/archive/master.zip dracula-gtk.zip
unzip dracula-gtk.zip -d ~/.themes || { echo "❌ Error al descomprimir Dracula GTK"; exit 1; }
mv ~/.themes/gtk-master ~/.themes/Dracula
sudo bash -c "cat <<EOF > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
theme-name = Dracula
icon-theme-name = Dracula
background = $HOME/Pictures/fondo.jpg
font-name = JetBrains Mono 10
EOF"
mkdir -p ~/.icons
descargar_archivo https://github.com/dracula/gtk/files/5214870/Dracula.zip dracula-icons.zip
unzip dracula-icons.zip -d ~/.icons || { echo "❌ Error al descomprimir iconos Dracula"; exit 1; }
rm -f dracula-gtk.zip dracula-icons.zip

# Cambiar shell
chsh -s "$(which zsh)" || { echo "❌ Error al cambiar shell a zsh"; exit 1; }

# Mensaje final
echo -e "\n✅ Instalación finalizada correctamente con tema Dracula."
echo "ℹ️  Inicia sesión en LightDM seleccionando i3."
echo "🔁 Puedes reiniciar más tarde ejecutando: sudo reboot"