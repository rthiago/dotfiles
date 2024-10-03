echo -n "₿ " ; result=$(curl -s "https://api.coindesk.com/v1/bpi/currentprice/usd.json" | jq -r '
  .bpi.USD.rate |
  gsub(","; "tmp") |
  gsub("\\." ; ",") |
  gsub("tmp"; ".")') || echo "failed" ; echo $result
