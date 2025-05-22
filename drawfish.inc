;drawfish: 
;                lxi h, $d000 + FISH_Y
;                lxi d, fishb0
;                call drawspr
;                lxi h, $f000 + FISH_Y
;                lxi d, fishb1
;                call drawspr
;                ret

maybe_wipe_fish:
                mvi a, $ff
                sta fish_wraparound_flag
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
              
                ret

drawfish_a:
                mov a, m
                cpi $1e
                jp maybe_wipe_fish
                ;rp

                lxi d, fisha0
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
                lxi d, fisha1
                jmp drawspr

drawfish_b:
                mov a, m
                cpi $1e
                jp maybe_wipe_fish

                lxi d, fishb0
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
                lxi d, fishb1
                jmp drawspr
                
drawspr:
                mvi c, 2
drawspr_l1
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

                dcr c
                jnz drawspr_l1

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

                mvi a, FISH_Y
                mov l, a \ mov e, a \ mov c, a
                call oneshift

                lda fish_col
                adi (FISH_BP + $20)
                mov b, a \ inr a \ ani $1f \ adi (FISH_BP + $20) \ mov d, a
                           inr a \ ani $1f \ adi (FISH_BP + $20) \ mov h, a

                mvi a, FISH_Y
                mov l, a \ mov e, a \ mov c, a
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
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                ora a \ mov a, m \ ral \ mov m, a 
                           ldax d \ ral \ stax d
                           ldax b \ ral \ stax b \ dcr l \ dcr e \ dcr c
                
                ret

; vim: filetype=asm
