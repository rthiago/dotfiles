#!/bin/bash

TITLE=`cat ~/.config/Google\ Play\ Music\ Desktop\ Player/json_store/playback.json | jq '.song.title' | sed 's/\"//g'`
ARTIST=`cat ~/.config/Google\ Play\ Music\ Desktop\ Player/json_store/playback.json | jq '.song.artist' | sed 's/\"//g'`
CURRENT=`cat ~/.config/Google\ Play\ Music\ Desktop\ Player/json_store/playback.json | jq '.time.current'`
TOTAL=`cat ~/.config/Google\ Play\ Music\ Desktop\ Player/json_store/playback.json | jq '.time.total'`
PLAYING=`cat ~/.config/Google\ Play\ Music\ Desktop\ Player/json_store/playback.json | jq '.playing'`

PERCENT=`bc <<< "scale=5; $CURRENT/$TOTAL*100"`
PERCENT=`bc <<< "scale=0; $PERCENT/1"`

if [[ $PLAYING == 'true' ]]; then
	PAUSED=""
else
	PAUSED="(PAUSED) "
fi

echo $PAUSED$ARTIST' - '$TITLE' | '$PERCENT'%'
