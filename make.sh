#!/bin/bash
set -e

TASM=./TASM.EXE
BIN2WAV=../bin2wav/bin2wav.js
ZX0=./tools/zx0.exe
PNG2DB=./tools/png2db-arzak.py

#ZX0_ORG=4000h
PLAYER_ORG=5000

MAIN=floppy
ROM=$MAIN-raw.rom
ROMZ=$MAIN.rom
WAV=$MAIN.wav
ROM_ZX0=$MAIN.zx0
DZX0_BIN=dzx0-fwd.$ZX0_ORG
RELOC=reloc-zx0
RELOC_BIN=$RELOC.0100
WITHPLAYER=$MAIN-withplayer.rom

rm -f $ROM_ZX0 $ROM

# graphlo
$PNG2DB graphics/blksbr.png -lineskip 1 -leftofs 8 -nplanes 2 -lut 0,2,3,1 -labels harzakc0,harzakc1 >blksbr.inc

#$TASM $PLAYER $MAIN.asm -o $ROM
./tasm.exe "-DPLAYER_BASE=$PLAYER_ORG"h -85 -b $MAIN.asm $ROM

ROM_SZ=`cat $ROM | wc -c`
echo "$ROM: $ROM_SZ octets"

# muzlo
cd muzlo/music
./vt2vi53Converter.exe music.vt2 3
cd ..
./sjasmplus.exe main.asm -DPLAYER_BASE="$PLAYER_ORG"h --lst=player.lst
cd ..


cat $ROM muzlo/player.bin >$WITHPLAYER
ls -l $WITHPLAYER
