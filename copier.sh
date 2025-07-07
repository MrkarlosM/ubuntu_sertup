#!/bin/bash

# Copiar configuración personalizada de i3
mkdir -p ~/.config/i3
cp ./configs/i3/config ~/.config/i3/config
mkdir -p ~/.config/polybar
cp ./configs/polybar/config.ini ~/.config/polybar/config.ini
cp ./configs/polybar/launch.sh ~/.config/polybar/launch.sh

sudo chmod +x ~/.config/polybar/launch.sh

# Recargar i3 si está corriendo
i3-msg reload
i3-msg restart
