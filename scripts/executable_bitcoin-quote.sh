echo -n "₿ " ; result=$(curl -s --fail rate.sx/1BTC) || echo "failed" ; echo $result | cut -d . -f 1 | rev | fold -w3 | paste -sd'.' - | rev
