#!/bin/bash
set -e

TASM=./TASM.EXE
BIN2WAV=../bin2wav/bin2wav.js
#ZX0=./tools/zx0.exe
ZX0="./tools/salvador.exe -classic"
PNG2DB=./tools/png2db-arzak.py

ZX0_ORG=6000
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

if ! test -e fish.inc ; then
    $PNG2DB graphics/outline1.png -mode bits8 -lineskip 1 -leftofs 0 -nplanes 2 \
        -lut 0,2,3,1 \
        -labels fisha0,fisha1 > fish.inc

    $PNG2DB graphics/outline2.png -mode bits8 -lineskip 1 -leftofs 0 -nplanes 2 \
        -lut 0,2,3,1 \
        -labels fishb0,fishb1 >> fish.inc
fi
 


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

$ZX0 -c $WITHPLAYER $ROM_ZX0
ROM_ZX0_SZ=`cat $ROM_ZX0 | wc -c`
echo "$ROM_ZX0: $ROM_ZX0_SZ octets"

$TASM -85 -b -Ddzx0_org=${ZX0_ORG}h dzx0-fwd.asm $DZX0_BIN
DZX0_SZ=`cat $DZX0_BIN | wc -c`
echo "$DZX0_BIN: $DZX0_SZ octets"

set -x
$TASM -85 -b -Ddst=${ZX0_ORG}h -Ddzx_sz=$DZX0_SZ -Ddata_sz=$ROM_ZX0_SZ $RELOC.asm $RELOC_BIN
RELOC_SZ=`cat $RELOC_BIN | wc -c`
echo "$RELOC_BIN: $RELOC_SZ octets"

cat $RELOC_BIN $DZX0_BIN $ROM_ZX0 > $ROMZ

../bin2wav/bin2wav.js floppy.rom floppy.wav


mkdir -p release
cp blksbr.nfo release/
cp floppy.rom release/blksbr.rom
cp floppy.wav release/blksbr.wav
