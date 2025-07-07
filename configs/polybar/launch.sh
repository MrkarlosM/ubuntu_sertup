#!/bin/bash

# Matar instancias anteriores
killall -q polybar

# Esperar a que se cierren
while pgrep -x polybar >/dev/null; do sleep 0.5; done

# Lanzar polybar en cada monitor
if type "xrandr" >/dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload example &
  done
else
  polybar --reload example &
fi

echo "✅ Polybar lanzado"

