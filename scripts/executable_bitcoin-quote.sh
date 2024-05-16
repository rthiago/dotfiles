echo -n "₿ " ; curl -s rate.sx/1BTC | cut -d . -f 1 | rev | fold -w3 | paste -sd'.' - | rev
