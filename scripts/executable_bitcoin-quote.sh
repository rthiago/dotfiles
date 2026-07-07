price=$(
    curl -fs --max-time 5 "https://api.coinbase.com/v2/prices/BTC-USD/spot" | jq -er '
        def format_price:
            (.*100 | round) as $cents
            | (($cents / 100) | floor | tostring) as $whole
            | (($cents % 100) | tostring | if length == 1 then "0" + . else . end) as $fraction
            | ($whole | explode | reverse | [range(0; length; 3) as $i | .[$i:$i+3] | reverse | implode] | reverse | join(".")) + "," + $fraction;
        .data.amount | tonumber | format_price
    '
)
# Nerd Font bitcoin glyph (U+F15A): the Unicode sign ₿ (U+20BF) is missing
# from Hack, the bar font.
if [ -n "$price" ]; then
    echo " $price"
else
    echo " failed"
fi
