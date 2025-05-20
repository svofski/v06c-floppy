	DEVICE ZXSPECTRUM48

;	org 2000h
        org PLAYER_BASE
begin:
	jp vktInit
	jp vktPlay
	dw module
	include "player.a80"
module:
	incbin "music\music.vtk"     
	savebin "player.bin",begin,$-begin

                                                                                                        

