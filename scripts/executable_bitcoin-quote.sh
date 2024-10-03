echo -n "₿ " ; result=$(curl -s "https://api.coindesk.com/v1/bpi/currentprice/usd.json" | jq -r '.bpi.USD.rate_float *100|round/100') || echo "failed" ; echo $result
