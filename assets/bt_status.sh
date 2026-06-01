#!/bin/bash
state=$(bluetoothctl show 2>/dev/null)
if echo "$state" | grep -q "Powered: yes"; then
  echo "<span font_family='Material Symbols Outlined' fallback='false' size='large' rise='-3840' color='#81a2be'>&#xe1a7;</span>"
else
  echo "<span font_family='Material Symbols Outlined' fallback='false' size='large' rise='-3840' color='#c75d68'>&#xe1a9;</span>"
fi
