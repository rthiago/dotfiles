echo -n "₿ " ; result=$(curl -s "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD" | jq -r '.USD *100|round/100') || echo "failed" ; echo $result
