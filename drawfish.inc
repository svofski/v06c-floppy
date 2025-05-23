;drawfish: 
;                lxi h, $d000 + FISH_Y
;                lxi d, fishb0
;                call drawspr
;                lxi h, $f000 + FISH_Y
;                lxi d, fishb1
;                call drawspr
;                ret

maybe_wipe_fish:
                ;mvi a, $ff
                ;sta fish_wraparound_flag
                ;lda msgseq_end_flag
                ;ora a
                ;rz
                xra a
                sta fish_enabled
                ; time to let go of the fish
                lxi d, fishz0
                mvi h, FISH_BP;$c0
                mvi l, FISH_Y

                lxi b, $0208
mwf_l2:
                xra a
mwf_l1:
                mov m, a \ inr h \ mov m, a \ dcr l
                mov m, a \ dcr h \ mov m, a \ dcr l
                dcr c
                jnz mwf_l1
                mvi a, $20
                add h
                mov h, a
                mvi l, FISH_Y
                dcr b
                jnz mwf_l2

                jmp fade_to_blue 
              
                ;ret

drawfish_a:
                mov a, m
                cpi $1e
                jp maybe_wipe_fish
                ;rp

                lxi d, fisha0
                lxi b, fisha1
                jmp drawfish_b2

drawfish_b:
                mov a, m
                cpi $1e
                jp maybe_wipe_fish

                lxi d, fishb0
                lxi b, fishb1
drawfish_b2:
                mvi a, FISH_BP
                add m
                inr a
                mov h, a
                mvi l, FISH_Y
                push h
                call drawspr
                pop h
                mvi a, $20
                add h
                mov h, a
				mov e,c
				mov d,b
                
drawspr:
				call $+3
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ldax d \ mov m, a \ inx d \ inr h
                ldax d \ mov m, a \ inx d \ dcr h \ dcr l
                ret
                
                ; fish swimming
dumbshift:
                lda fish_col
                adi FISH_BP;$c0
                mov b, a
                inr a
                ani $1f
                adi FISH_BP;$c0
                mov d, a

                inr a 
                ani $1f
                adi FISH_BP;$c0
                mov h, a

                call oneshift

				mvi a,20h\ add h\ mov h,a
				mvi a,20h\ add d\ mov d,a
				mvi a,20h\ add b\ mov b,a

                call oneshift

                lxi h, fish_col_frac
                mov a, m
                rlc
                mov m, a
                rnc

                inx h       ; hl = &fish_col
                mov a, m
                dcr a       ; previous column
                ani $1f
                mov m, a

                ; switch sprite
                rar ; lsb
                jc  drawfish_a
                jmp drawfish_b
                ;ret

oneshift:
                mvi l, FISH_Y \ mov e, l \ mov c, l

                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                mov a, m \ add a \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b ; \ dcr l \ dcr e \ dcr c
                
                ret

; vim: filetype=asm
