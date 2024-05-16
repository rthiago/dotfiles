echo -n "⌨  "; python /home/thiago/projects/zmk-configs/sofle-nicenano/battery-level.py 2>/dev/null | awk '/Main:/{main=$2} /Peripheral 0:/{print main "%", $3 "%"}'
