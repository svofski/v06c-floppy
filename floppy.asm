        ; 💾 картинки нет печальнее на свете
        ;    чем демо о летающей дискете
        ;
        ; svofski & ivagor 2025
        ;
        ; Вектор-06ц БЛК+СБР!
        ;

;#define FADE_IN
#define FADE_OUT

; show all the text messages before the main screen appears
;#define MESSAGES_AT_ONCE

LOGOY           .equ $d8
FISH_Y          .equ $60
FISH_BP         .equ $80
;LOGOY           .equ $60

NBOUNDS         .equ 7
BUTTPLANE       .equ $c0
BUTTPLANE_A     .equ $c0
BUTTPLANE_B     .equ $e0
PixTabA         .equ 7800h
PixTabB         .equ 7C00h
DEG90           .equ 256/4

        .org $100
        di
        xra a
        out $10
        lxi sp, $100
        mvi a, $c9
        sta $38

        mvi a, $c3
        sta 0
        lxi h, $100
        shld 1
        
        lxi h, pal_0
        shld setpal_select
        ei

        ; clear zero initialized vars
        lxi h, zero_init_end
        mvi a, (zero_init_end - zero_init_start) / 32
        lxi b, 0
        call clear_array_backwards
        lxi h, ngon_start
        shld geometry_ptr

        ;; fish init
        ;mvi a, $1e      ; fish appears in this column
        ;sta fish_col
        ;mvi a, 1
        ;sta fish_col_frac

        lxi h, bounds_0
        shld bounds
        shld bounds1
        lxi h, bounds_1
        shld bounds_b
        shld bounds1_b

        lxi h, bounds_2
        shld bounds2
        lxi h, bounds_3
        shld bounds2_b
        
        lhld songe
        call player_init    ; starts playback immediately

        call clrscr
        di
        mvi a,0C3h
        sta 38h
        lxi h,ISR
        shld 39h
        ei

        lxi h, PixTabA
        mvi a, BUTTPLANE_A
        call MakePixTab
        lxi h, PixTabB
        mvi a, BUTTPLANE_B
        call MakePixTab
                
        mvi a, 1
        out $2

        call mathinit

        ; clear all bounds arrays
        lxi h, bounds_end
        mvi a, 4 * 256 * NBOUNDS / 32   
        lxi b, $ffff ; fill with ff
        call clear_array_backwards

        lxi h, pal_zero_end
        mvi a, 1
#ifdef FADE_IN        
        lxi b, 0
#else
        lxi b, $ffff
#endif
        call clear_array_backwards
        
        
        lxi h, $0860
        call gotoxy
        lxi h, msg_minus1
        call puts

        lxi h, pal_intro
        shld setpal_select

        mvi a, 240
black_loop:
        hlt
        dcr a
        jnz black_loop

        lxi h, pal_0
        shld setpal_select
        hlt
        call clrscr
        hlt


        ; main part

        ; нарисовать большую надпись
        mvi c, LOGOY
        mvi a, $80    ; плоскость $80
        sta varblit_plane
        lxi d, harzakc0
        call varblit

        mvi c, LOGOY-1
        mvi a, $a0    ; плоскость $a0
        sta varblit_plane
        lxi d, harzakc1
        call varblit

#ifdef MESSAGES_AT_ONCE
messages:
        lxi h, msg1
messages_lup:
        mov a, m
        cpi 255
        jz messages_done
        mov e, a
        inx h
        mov d, m
        inx h
        push h
          xchg
          call gotoxy
        pop h
        call puts
        lhld _puts_sptr
        inx h
        jmp messages_lup
messages_done:        
#else
        ; slow messages
        lxi h, msg1
        shld slow_msg_ptr
        lxi h, msg_restart
        shld slow_msg_loop
        mvi a, 1
        sta slowprint_enabled
        sta slow_msg_state
#endif


        ; MAIN PART BEGINS

        ; begin fade in -- make sure these pointers are initialised before oneframe()
        lxi h, pal_fade_a
        shld pal_a_ptr
        lxi h, pal_fade_b
        shld pal_b_ptr

        call oneframe

        mvi a, 8
        sta fade_in_flag    ; enable fade in for 8 frames (see ISR)

        ;mvi a, 1
        ;sta fish_enabled

forevs:
        call oneframe
        jmp forevs

                ; вывод спрайта в формате varblit:
                ; db first_column, jump offset = (16 - end) * 5, data
                ; db 255, 255 ; end of data
                ;
                ; di
                ; mvi c, $d0
                ; mvi a, $c0
                ; sta varblit_plane
                ; lxi d, varplane0
                ; call varblit
varblit:
                ;di
                lxi h, 0
                dad sp
                shld varblit_sp
                xchg
                mov a,c
                mov c,m
                inx h
                mov b,m
                inx h
                sphl
        
;                mov l, c
                mov l,a
                .db 0FEh        ; cpi .. , skip pop b
vb_L0:                
                pop b       ; c = first column, b = premultiplied jump offset = (16-end) * 5
                mov a, b    ; end = 255, 255
                ana c
                jm vb_exit
                
varblit_plane   .equ $+1
                mvi a, $c0 ; plane msb
                add c
                mov h, a        ; hl = screen addr

                mov a, b ; b = precalculated offset into vbline_16
                sta vb_M1+1
vb_M1:          jmp vbline_16

                .org $100 + $ & $ff00
vbline_16:      pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b \ inr h
                pop b \ mov m, c \ inr h \ mov m, b; \ inr h
                
vb_L2:          ; next line
                dcr l

                ;mvi a, -$73
                ;add l             ; перед строкой 73 очистить края вокруг будто маска
                ;jz troll_clearhook
                ;inr a
                ;jz troll_hook     ; после строки 73 нарисовать белый горизонт вокруг птероида

vb_L3:
                jmp vb_L0

vb_exit:                
varblit_sp      .equ $+1
                lxi sp, 0
                ret

vb_hl:          .dw 0



MakePixTab:        
;HiAdr - PixTab+0000h
                ;lxi h,PixTab
                ;mvi a,BUTTPLANE
                mvi b,32
MakePixTab2:
                mvi c,8
MakePixTab1:
                mov m,a
                inx h
                dcr c
                jnz MakePixTab1
                inr a
                dcr b
                jnz MakePixTab2

;LeftMask - PixTab+0100h
                mvi b,8
                mvi a,80h
                mov d,a
MakePixTab9:
                mvi c,7
                inx h
MakePixTab8:
                mov m,a
                rrc\ ora d
                inx h
                dcr c
                jnz MakePixTab8
                xra a\ ora d\ rar\ mov d,a
                dcr b
                jnz MakePixTab9
                mvi l,0
                inr h

;PixLeft - PixTab+0200h
                mvi b,32
MakePixTab7:
                mvi a,8
MakePixTab6:
                mov m,a
                inx h
                dcr a
                jnz MakePixTab6
                dcr b
                jnz MakePixTab7


;PixMaskLeft - PixTab+0300h
                mvi b,32
MakePixTab5:
                mvi a,255
                mvi c,8
MakePixTab4:
                mov m,a
                ora a\ rar
                inx h
                dcr c
                jnz MakePixTab4
                dcr b
                jnz MakePixTab5
        ret

clrscr:        
        lxi h, $8000
        mvi b, $0
clrscrl:        
        mov m, b \ inx h
        mov m, b \ inx h
        mov m, b \ inx h
        mov m, b \ inx h
        mov a, l
        ora h
        jnz clrscrl
        ret
      

songe_enabled: .db 1

; установить пиксель в плоскости $80
; вход:
; H - X
; L - Y
setpixel:
                ;mvi c, $c0
                mvi d, PixelMask >> 8

                mvi a, 7
                ana h
                mov e, a
                xra h
                rar \ rar \ rar
setpixel_bp     .equ $+1                
                adi BUTTPLANE
                mov h, a

                ldax d
                ora m
                mov m, a
                ret

                .org 400h
PixelMask:
                .db 10000000b
                .db 01000000b
                .db 00100000b
                .db 00010000b
                .db 00001000b
                .db 00000100b
                .db 00000010b
                .db 00000001b
        
RightOrMask:
                .db 00000000b
                .db 10000000b
                .db 11000000b
                .db 11100000b
                .db 11110000b
                .db 11111000b
                .db 11111100b
                .db 11111110b

RightAndMask:
                .db 11111111b
                .db 01111111b
                .db 00111111b
                .db 00011111b
                .db 00001111b
                .db 00000111b
                .db 00000011b
                .db 00000001b


y1x1:   .db 5, 70
y2x2:   .db 200, 5
;xinc:   .dw 0    
;ydir:   .db 0
;line_h: .db 0
;line_y: .db 0
        ; x1,y1 - x2,y2
        ; vert increment always +1, horz increment variable
line:
        lhld y1x1
        xchg
        lhld y2x2
        ; swap so that y2 - y1 is positive
        mov a, l
        sub e           ; a = y2 - y1
        rz      ; dy = 0, nothing to do
        jnc line_2
        shld y1x1
        xchg
        shld y2x2
        mov a, l
        sub e           ; a = y2 - y1
        
line_2:
        sta line_h      ; height = y2 - y1

                mov a,e
        sta line_y        ; line_y = y1

        mov a, h
        cmp d           ; x2 - x1
        jnc line_xplus
line_xminus:
        mvi a, $37 ; stc
        sta line_xsgn
        
        ; xinc = ((x1 - x2) << 7) / dy, negate after division
        mov a, d
        sub h   ; a = x1 - x2
        jmp line_shl7
line_xplus:
        ; positive xinc = ((x2 - x1) << 7) / dy
        mvi a, $b7 ; ora a
        sta line_xsgn
        
        mov a, h
        sub d   ; a = x2 - x1
line_shl7:        
        rar     ; a = a >> 1
        sta xinc+1
        mvi a, 0
        rar
        sta xinc

line_3:
        ; xinc = xinc / dy
        lhld xinc
line_h  .equ $+1
                mvi c,0
        xra a
        call udiv16248  ; hl = ahl/c
;        xchg            ; -> de
        
line_xsgn:        
        ora a ; ORA A = positive xinc | STC = negative xinc
        jnc line_ldx1
line_negxing:
        ; xinc = -xinc
                xra a\ sub l\ mov l,a
                sbb h\ sub l\ mov h,a
        
line_ldx1:
        shld xinc
                
        ; main loop
;        call setbounds_setup
;setbounds_setup:
line_y  .equ $+1
        lxi b,0
        mov h,b
        mov l,c
        dad b
        dad b
        dad h
        dad b
        xchg
        lhld bounds
        dad d           ; hl = &bounds[y][0]
;        shld setbounds_ptr
        xchg

        lda y1x1+1      ; x1
        ora a
        rar
        mov h, a
        mvi a, 0
        rar
        mov l, a        ; hl = x1 << 7
                
line_4:        
        ; d = y, hl = x << 7
line_putpixel:
        push h
        dad h \ mov a, h ; a = floor(x)
        
        ;push d \ push h \ push b \ push psw
        ;mov h, a
        ;call setpixel ; h=x, l=y
        ;pop psw \ pop b \ pop h \ pop d
              
;        call setbounds
        ; insert coordinate a to bounds[l][0], maintain ascending order
setbounds:
        lxi h, NBOUNDS
        dad d
;                                   ; 20+4+12+12+20=68
                                                                                ; hl = &bounds[y][7]
        xchg
        cmp m   ; bounds[i] - x, x < bounds[i] if no carry
        jnc sbins_k1     ; if x >= bounds[k] -> next k
        ;x<bounds[0]
        mov b,m
        mov m,a
        inr b
        jz after_setbounds                              ; if 255 == bounds[k] bounds[k] = x, return
        ; else insert
        dcr b
        inx h\ inx h\ inx h\ inx h              ; hl = &bounds[y][4]
        mvi a,255
        
        ; scan empty space before committing to memmove
        ;k = 4 
        cmp m \ jnz insx44 \ dcx h     ; --> 348088 ( -1260)
        cmp m \ jnz insx43 \ dcx h
        cmp m \ jnz insx42 \ dcx h
;       cmp m \ jnz insx41
;       mov m,b
        cmp m\ jz after_setbounds_
        jmp insx41
                
insx44: mov a,m \ inx h \ mov m,a \ dcx h \ dcx h ; k = 4, d[k+1] = d[k], k = 3
insx43: mov a,m \ inx h \ mov m,a \ dcx h \ dcx h ; k = 3, d[k+1] = d[k], k = 2
insx42: mov a,m \ inx h \ mov m,a \ dcx h \ dcx h ; k = 2, d[k+1] = d[k], k = 1
insx41: mov a,m \ mov m,b\ inx h \ mov m,a ; k = 1, d[k+1] = d[k], k = 0
        ; k = 0, d[k+1] = d[k], k = 1
        jmp after_setbounds
        
sbins_k1:
        inx h
        cmp m   ; bounds[i] - x, x < bounds[i] if no carry
        jnc sbins_k2     ; if x >= bounds[k] -> next k
        mov b,m
        mov m,a
        inr b
        jz after_setbounds                              ; if 255 == bounds[k] bounds[k] = x, return
        ; else insert
        dcr b
        inx h\ inx h\ inx h             ; hl = &bounds[y][4]
        mvi a,255
        
        ; scan empty space before committing to memmove
        ;k = 4 
        cmp m \ jnz insx34 \ dcx h     ; -> 347784 ( -304)
        cmp m \ jnz insx33 \ dcx h
;        cmp m \ jnz insx32
;               mov m,b
        cmp m\ jz after_setbounds_
        jmp insx32
        
insx34: mov a,m \ inx h \ mov m,a \ dcx h \ dcx h ; k = 4, d[k+1] = d[k], k = 3
insx33: mov a,m \ inx h \ mov m,a \ dcx h \ dcx h ; k = 3, d[k+1] = d[k], k = 2
insx32: mov a,m \ mov m,b\ inx h \ mov m,a ; k = 2, d[k+1] = d[k], k = 1
        jmp after_setbounds
        
sbins_k2:        
        inx h
        cmp m
        jnc sbins_k3     ; if x >= bounds[k] -> next k
        mov b,m
        mov m,a
        inr b
        jz after_setbounds                       ; if 255 == bounds[k] bounds[k] = x, return
        ; else insert
        dcr b
        ;k = 2
        inx h                 ; k = 2, d[k+1] = d[k], k = 3
        mov a,m \ mov m,b\ inx h                 ; k = 3, d[k+1] = d[k], k = 4
        mov b,m \ mov m,a\ inx h \ mov m,b                 ; k = 4, d[k+1] = d[k], k = 5
        jmp after_setbounds
        
sbins_k3:        
        inx h
        cmp m
        jnc sbins_k4     ; if x >= bounds[k] -> next k
        mov b,m
        mov m,a
        inr b
        jz after_setbounds                       ; if 255 == bounds[k] bounds[k] = x, return
        ; else insert
        dcr b
        ;k = 3
        inx h                 ; k = 3, d[k+1] = d[k], k = 4
        mov a,m \ mov m,b\ inx h \ mov m,a                 ; k = 4, d[k+1] = d[k], k = 5
        jmp after_setbounds
        

sbins_k4:
        inx h
        cmp m
        jnc sbins_k5     ; if x >= bounds[k] -> next k
        mov b,m
        mov m,a
        inr b
        jz after_setbounds                       ; if 255 == bounds[k] bounds[k] = x, return
        ; else insert
        dcr b
        ;k = 4 
        inx h \ mov m,b                 ; k = 4, d[k+1] = d[k], k = 5
        jmp after_setbounds

sbins_k5:
        inx h
        cmp m
        jnc after_setbounds      ; if x >= bounds[k] -> return
        mov b,m
        inr b
        jnz after_setbounds         ; if 255 == bounds[k] bounds[k] = x, return
        mov m, a

        .db 0FEh                                ;cpi ...
after_setbounds_:
        mov m,b
after_setbounds:
        lxi h,line_h
        dcr m
        pop h
xinc    .equ $+1
        lxi b,0
        dad b   ; x += xinc
line_nexty:
        jnz line_4
        ret
        
        ; double-buffa
        ; frame & 1 == 0:
        ;    bounds, bounds_b = bounds_1, bounds_2
        ; frame & 1 == 1:
        ;    bounds, bounds_b = bounds_3, bounds_4
next_bounds:
        ; swap a/b
        lhld bounds
        xchg
        lhld bounds_b
        shld bounds
        xchg
        shld bounds_b

        lda frame_no
        rar
        jc nb_bbb
        
        ;lxi h, pal_a
        lhld pal_a_ptr
        shld setpal_select

        lhld bounds
        shld bounds1
        lhld bounds_b
        shld bounds1_b
        lhld bounds2
        shld bounds
        lhld bounds2_b
        shld bounds_b
        
        mvi a, BUTTPLANE_A
        sta setpixel_bp
        mvi a, PixTabA >> 8
        sta hline_pixtab_plus_0
        sta hwipe_pixtab_plus_0
        adi 2
        sta hline_pixtab_plus_2
        sta hwipe_pixtab_plus_2
        inr a
        sta hline_pixtab_plus_3
        sta hline_pixtab_plus_3

        ret
        
nb_bbb:
        lhld bounds
        shld bounds2
        lhld bounds_b
        shld bounds2_b
        lhld bounds1
        shld bounds
        lhld bounds1_b
        shld bounds_b
        
        ;lxi h, pal_b
        lhld pal_b_ptr
        shld setpal_select

        mvi a, BUTTPLANE_B
        sta setpixel_bp
        mvi a, PixTabB >> 8
        sta hline_pixtab_plus_0
        sta hwipe_pixtab_plus_0
        adi 2
        sta hline_pixtab_plus_2
        sta hwipe_pixtab_plus_2
        inr a
        sta hline_pixtab_plus_3
        sta hline_pixtab_plus_3

        ret     ; bounds are cleared on read
        
        ; quick wipe array in hl backwards c * 32 bytes
clear_array_backwards:
        xchg
        
        lxi h, 0
        dad sp
        shld clrbounds_sp
;        di
        xchg
        sphl    ; sp = bounds_b + $600
        dcr a
        jz clrbounds_final
clrbounds_pushkin:        
        push b \ push b \ push b \ push b       ; 32 bytes
        push b \ push b \ push b \ push b
        push b \ push b \ push b \ push b
        push b \ push b \ push b \ push b
        dcr a
        jnz clrbounds_pushkin
clrbounds_final:
        push b \ push b \ push b \ push b       ; 30+2 bytes
        push b \ push b \ push b \ push b
        push b \ push b \ push b \ push b
        push b \ push b \ push b
        lxi h,-1
        dad sp
        mov m,b
        dcx h
        mov m,c
clrbounds_sp    .equ $+1
        lxi sp, 0
;        ei
        ret
        
oneframe:
        call next_bounds
        lda frametime
        xra a
        sta frametime
        
        call transform_geometry
        call draw_geometry
        call fill_bounds
        lxi h, frame_no
        inr m
        mov a, m
        sta anim_pos

        ;for benchmark
        rnz 

        ret
                
transform_geometry:
        ; in the future, the geometry will be transformed
        ; 12.05.2025 the future is now
        lda anim_pos; frame_no
        sta rotx
        mov b, a
        add a
        sta roty
        add b
        sta rotz
        call rotmatrix
        call calc_projection
        ; prepare data for draw_geometry: 
        ;   4, xy1 xy2 xy3 xy4 xy1 [5]
        ;   8, xy1...xy8 xy1 [9]
        ;   8, xy1...xy8 xy1 [9]
        ;   0
        lxi d, points_proj      ; raw array of x,y
        lxi h, ngon1            ; formatted ngon data for draw_geometry
        mvi m, 4 \ inx h
          ldax d \ mov c, a \ inx d \ mov m, a \ inx h
          ldax d \ mov b, a \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          mov m, c \ inx h \ mov m, b \ inx h
          
        mvi m, 8 \ inx h  
          ldax d \ mov c, a \ inx d \ mov m, a \ inx h
          ldax d \ mov b, a \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          mov m, c \ inx h \ mov m, b \ inx h

        mvi m, 8 \ inx h  
          ldax d \ mov c, a \ inx d \ mov m, a \ inx h
          ldax d \ mov b, a \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          ldax d \ inx d \ mov m, a \ inx h
          mov m, c \ inx h \ mov m, b \ inx h
        mvi m, 0
        ret
                
                
geometry_ptr:      .dw ngon_start

draw_geometry:
        ; contour 1
        lhld geometry_ptr
        
        ; check if geometry available and die
        mov a, m
        ora a
        jnz dg_next_ngon
        
        lxi h, ngon_start
        shld geometry_ptr

dg_next_ngon:
        mov a, m        ; line count
        ora a
        inx h
        jnz dg_line
        shld geometry_ptr
        ret
        
        
dg_line:        
        mov d, m \ inx h \ mov e, m \ inx h
        xchg
        shld y1x1
        xchg
        mov d, m \ inx h \ mov e, m \ inx h
        xchg
        shld y2x2
        xchg
        
        push psw
        push h
        call line
        pop h
        pop psw
        
        dcr a
        jz dg_next_ngon
        dcx h \ dcx h
        jmp dg_line
        ;;

;         ; loop continue without push/pop
; fb_bounds_loop_cont:
;         lxi b, NBOUNDS
;         dad b
;         xchg
;         dad b
;         xchg
;         jmp fb_bounds_loop_nexty


fill_bounds:
        lhld bounds_b
        xchg
        lhld bounds     ; hl = &bounds[0]       -- draw
                        ; de = &bounds_b[0]     -- wipe (normalized and sorted on previous step)
        
        mvi a, 255      ; current line, y
        sta fb_y
fb_lines_loop:
        ; if [hl] == 255 && [de] == 255 continue to the next line
        ldax d
        ana m
        inr a
        jz fb_bounds_loop_cont

        push h
        push d

        xra a
        sta fb_state
        sta fb_next
        jmp fb_bounds_loop

        ; when the state is advanced without draw or wipe
fb_nextstate:
;        lda fb_state - лишняя команда
        sta fb_prev
;        lda fb_next
fb_next .equ $+1
                mvi a,0
        sta fb_state    ; 16+8+16=40

        ;; inner loop that iterates max 6 + 6 bounds
fb_bounds_loop:   
        ; x1 = x2
        mov b, c
        
        ldax d          ; a = xb[ib]
;        cpi 255
;        jz fb_if_else   ; if xbib == 255...
       
        ; if actr == 0 || x2 < xa[ia]
        cmp m           ; xb - xa
        jnc fb_if_else
        mov c, a
;fb_sel_xb:

        lda fb_next
        xri $40         ; next_b = !state_b
        sta fb_next
        
        ;# expermimental wipe on read
        mvi a, 255
        stax d
        ;#
        
        inx d           ; ++ib          
                
;               cmp c
;        jnz fb_if_done
;               jmp fb_bounds_loop_break        ;здесь никогда не срабатывает, т.к. в эту ветку не можем попасть при xb[ib]=255

                jmp fb_if_done

fb_if_else:
        mov c, m
;fb_if_done:
        ; if x2 == 255 break
        mvi a,255
        cmp c
        jz fb_bounds_loop_break
        inx h
        lda fb_next
        xri $80         ; next_a = !state_a
        sta fb_next
        
        ; if (state_a ^ state_b == 0)
        
fb_if_done:
;        lda fb_state
fb_state .equ $+1
        mvi a,0
        ora a           ; $00 -> Z=1                    -> continue
                        ; $80 -> Z=0, S=1, P=0          -> A (fill)
                        ; $C0 -> Z=0, S=1, P=1          -> continue
                        ; $40 -> Z=0, S=0, P=0          -> B (wipe)
;        jz fb_nextstate ; !state_a & !state_b
        jpe fb_nextstate
;        jm fb_fillline
;        jmp fb_wipeline
        jp fb_wipeline
        
fb_fillline:        
        ; this.hfill(x1, x2, y, INK);
        ; a = y
        ; b = x1, c = x2
        push d
        push h
        lda fb_y

;        call hline_xy
        ;; fast fill horizontal segment
        ;; a = y
        ;; b = x1, c = x2
;hline_xy:           
        mov e, a
        mov l,b
        ; c - b = count
        mov a, c
        sub b
        inr a
        mov b, a
hline_pixtab_plus_2 .equ $+1            
        mvi h,(PixTabA>>8)+2
        sub m
hline_pixtab_plus_0 .equ $+1            
        mvi h,(PixTabA>>8)
        mov d,m                         ;HiAdr
;       jnc hline_xy_LeftBlock
        jc hline_xy_LeftBlock
                
        mov b,a
hline_pixtab_plus_3 .equ $+1            
        mvi h,(PixTabA>>8)+3
        mov a,m
        xchg
        ora m
        mov m,a
        xra a
        ora b
        jz hline_xy_end
hline_xy_L3:
        inr h           ; next column
        sui 8
        jnc hline_xy_L4
        adi (RightOrMask&255)+8
        mov e,a
        mvi d,RightOrMask>>8
        ldax d
        ora m
        mov m,a
        jmp hline_xy_end

hline_xy_L4:
        ; fill in chunks
        mvi m, 255
        jnz hline_xy_L3
        jmp hline_xy_end

hline_xy_LeftBlock:
        mvi a,7
        ana l
        rlc\ rlc\ rlc
        ora b
        mov l,a
        inr h                           ;to LeftMask
        ldax d
        ora m
        stax d

hline_xy_end:
        ; [prev, state] = [state, next]
;        lhld fb_state   
;        shld fb_prev    ; 20+20 = 40 (+28 = 68, but!)
        lda fb_state
        sta fb_prev
        lda fb_next
        sta fb_state

        pop h
        pop d
        jmp fb_bounds_loop
fb_wipeline:  
        ; ; if (prev_a == 1) ++x1
;        lda fb_prev
;        ora a
fb_prev .equ $+1
        ori 0           ;сюда приходим с A7=0, остальные биты не выжны
        jm fb_3
        ; else if (next_a == 1) --x2
        lda fb_next
        ora a
        jp fb_5_
        mvi a,-1
        add c
        jmp fb_5
fb_3:
        inr b
fb_5_:
        mov a,c
fb_5:
        ; c - b = count
        sub b
        jc fb_4

        push h
        push d
        mov e,b
        inr a
        mov b, a

        lhld fb_y
        xchg

;        call hwipe_xy
        ;; fast wipe horizontal segment
        ;; e = y
                ;; l= x1
        ;; b = x2-x1+1
;hwipe_xy:           
hwipe_pixtab_plus_2 .equ $+1
        mvi h,(PixTabA>>8)+2
        sub m
hwipe_pixtab_plus_0 .equ $+1            
        mvi h,(PixTabA>>8)
        mov d,m                         ;HiAdr
        jc hwipe_xy_LeftBlock
                
        mov b,a
hwipe_pixtab_plus_3 .equ $+1            
        mvi h,(PixTabA>>8)+3
        mov a,m
        xchg
        cma
        ana m
        mov m,a
        xra a
        ora b
        jz hwipe_xy_end
hwipe_xy_L3:
        inr h           ; next column
        sui 8
        jnc hwipe_xy_L4
        adi (RightAndMask&255)+8
        mov e,a
        mvi d,RightAndMask>>8
        ldax d
        ana m
        mov m,a
        jmp hwipe_xy_end

hwipe_xy_L4:
        ; do in chunks
        mvi m, 0
        jnz hwipe_xy_L3
        jmp hwipe_xy_end

hwipe_xy_LeftBlock:             
        mvi a,7
        ana l
        rlc\ rlc\ rlc
        ora b
        mov l,a
        inr h                           ;to LeftMask
        ldax d
        ora m
        xra m
        stax d

hwipe_xy_end:
        pop d
        pop h
fb_4:        
        ; [prev, state] = [state, next]
;        lhld fb_state   
;        shld fb_prev    ; 20+20 = 40 (+28 = 68, but!)
        lda fb_state
        sta fb_prev
        lda fb_next
        sta fb_state
        
        jmp fb_bounds_loop

fb_bounds_loop_break:        
        ; next line..
        ; ...
        ; bounds += 6, bounds_b += 6
        pop d
        pop h
        ; loop continue without push/pop
fb_bounds_loop_cont:
        lxi b, NBOUNDS
        dad b
        xchg
        dad b
        xchg
fb_bounds_loop_nexty:        
;        lda fb_y
fb_y    .equ $+1
        mvi a,0
        dcr a

        ; lfsr for line shuffling, but we need to update bounds/bounds_b by the same law, too much effort
        ;         ral
        ;         jnc lfsr_nofeedback
        ;         xri $1d
        ; lfsr_nofeedback:        
        ;         cpi 1
        
        sta fb_y
        jnz fb_lines_loop
        ret
;         ; loop continue without push/pop
; fb_bounds_loop_cont:
;         lxi b, NBOUNDS
;         dad b
;         xchg
;         dad b
;         xchg
;         jmp fb_bounds_loop_nexty


;Максимальное допустимое делимое AHL=FEFFFF
;HL=AHL/C
;A=AHL%C
;16=24/8
udiv16248:
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l

        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l

        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l

        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+7\ cmp c\ jc $+5 \ sub c\ inr l
        dad h\ adc a\ jc $+5\ cmp c\ rc\ sub c\ inr l
        ret
      
    ; Программирование палитры
set_palette_pp:
        mvi a, $88
        out 0
        mvi a, 255
        out 3
        lxi b, 0
setpal_select .equ $+1          
        lxi d, pal_b
_setpal_pp_1:
        mov a, c
        out 2
        ldax d
        out $c
        xthl
        out $c
        xthl
        inx d
        inr c
        nop \ nop
        out $c
setpal_top .equ $+1             ; set to 3 to only program first 3 colors
        mvi a,$10
        cmp c
        jnz _setpal_pp_1
        ret

; light floppy theme

;CLRA    .equ 243q
;CLRB    .equ 243q
;BLKC    .equ 121q
;WHTC    .equ 377q    
;
;pal_a: ; $e0  
;    ;    0    1    2    3    4    5    6    7    8    9    a    b    c    d    e    f
;    .db  BLKC,CLRA,BLKC,CLRA,WHTC,WHTC,WHTC,WHTC,000q,000q,000q,000q,000q,000q,000q,BLKC
;pal_b: ; $c0    
;    .db  BLKC,BLKC,CLRB,CLRB,WHTC,WHTC,WHTC,WHTC,000q,000q,000q,000q,000q,000q,000q,BLKC

; goth floppy theme

CLRA    .equ 000q
CLRB    .equ 000q

BLKC    .equ 232q
WHTC    .equ 377q    
XXXC    .equ 110q

;;;; semi-transparent
;WHTCt    .equ 377q-011q
;
;pal_a: ; $e0  
;    ;    0    1    2    3    4    5    6    7    8    9    a    b    c    d    e    f
;    .db  BLKC,CLRA,BLKC,CLRA,WHTC,WHTCt,WHTC,WHTCt,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,BLKC
;pal_b: ; $c0    
;    .db  BLKC,BLKC,CLRB,CLRB,WHTC,WHTC,WHTCt,WHTCt,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,BLKC
;;;;

pal_a: ; $e0  
    ;    0    1    2    3    4    5    6    7    8    9    a    b    c    d    e    f
    .db  BLKC,CLRA,BLKC,CLRA,WHTC,WHTC,WHTC,WHTC,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,BLKC
pal_b: ; $c0    
    .db  BLKC,BLKC,CLRB,CLRB,WHTC,WHTC,WHTC,WHTC,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,XXXC,BLKC
pal_intro: 
    ;    0    1    2    3    4    5    6    7    8    9    a    b    c    d    e    f
    .db  0,0,0,0,WHTC,WHTC,WHTC,WHTC,0,0,0,0,0,0,0,0

do_fade_in:
        lda fade_in_flag
        dcr a
        sta fade_in_flag
        lxi d, pal_a        ; goal
        lxi h, pal_fade_a   ; work
#ifdef FADE_IN
        call fade_in
#else
        call fade_out
#endif
        lxi d, pal_b        ; goal
        lxi h, pal_fade_b   ; work
#ifdef FADE_IN
        call fade_in
#else
        call fade_out
#endif
        ret

#ifdef FADE_IN
        ; de=goal, hl=work (start with zeroes)
        ; work < goal (start with 000q)
fade_in:
        mvi c, 16
fade_in_loop:
        ldax d          ; goal
        push d

        sub m           ; goal - work (work < goal)
        mov d, a
        mvi e, 0
        ani 007q
        jz $+5
        mvi e, 001q
        mov a, d
        ani 070q
        jz $+7
        mvi a, 010q
        ora e
        mov e, a
        mov a, d
        ani 300q
        jz $+7
        mvi a, 100q
        ora e
        mov e, a
        
        mov a, m
        add e
        mov m, a
        pop d
        inx h
        inx d
        dcr c
        jnz fade_in_loop
        ret
#endif
#ifdef FADE_OUT
        ; de=goal, hl=work (start with 377q)
        ; work > goal (start with 377q)
fade_out:
        mvi c, 16
        xchg            ; hl=goal, de=work
fade_out_loop:
        ldax d          ; work
        push d
        sub m           ; work - goal
        mov d, a
        mvi b, 0
        ani 007q
        jz $+5
        mvi b, 001q
        mov a, d
        ani 070q
        jz $+7
        mvi a, 010q
        ora b
        mov b, a
        mov a, d
        ani 300q
        jz $+7
        mvi a, 100q
        ora b
        mov b, a
        pop d

        ldax d
        sub b
        stax d
        inx h
        inx d
        dcr c
        jnz fade_out_loop
        ret
#endif

slowprint:
        lhld slow_msg_ptr
        lda slow_msg_state
        ora a                 ; state == 0 :-> print
        jz slop_nextbyte
        dcr a
        sta slow_msg_state
        ;xra a
        ;sta slow_msg_state
        ora a                 ; state was 1 now 0 :-> new line
        rnz                   ; otherwise just delay
        ; y, x
        mov e, m \ inx h
        mov d, m \ inx h
        push h
        xchg
        call gotoxy
        pop h
slop_nextbyte:
        mov a, m
        shld _puts_sptr
        inx h
        shld slow_msg_ptr
        cpi 253
        jz delay_line
        cpi 254
        jz launch_fish
        cpi 255
        jz slop_wraparound
        ora a
        jnz slop_char
        ; 0, next line in group
        inr a
        sta slow_msg_state
        ret ; next time get the coords
slop_char:
        jmp _putchar
slop_wraparound:
        lhld slow_msg_loop
        shld slow_msg_ptr
        mvi a, 1
        sta slow_msg_state
        ret
launch_fish:
        mvi a, 1
        sta slow_msg_state
        mvi a, $1e      ; fish appears in this column
        sta fish_col
        mvi a, 1
        sta fish_col_frac
        sta fish_enabled
        ret
delay_line:
        mvi a, 33
        sta slow_msg_state
        ret



ISRstack:
        .ds 32
ISRstackEnd:
ISR:
        shld ISRsetHL+1
        pop h
        shld ISRsetRet+1
        push psw
        lxi h,2
        dad sp
        shld ISRsetSP+1
        mov l,c
        mov h,b
        xthl
        lxi sp,ISRstackEnd
        push h                          ;push psw
        push b
        push d

        call set_palette_pp

        lda fade_in_flag
        ora a
        cnz do_fade_in

        lda fish_enabled
        ora a
        cnz dumbshift


        lhld intcount
        inx h
        shld intcount
        
        lda songe_enabled
        ora a
        cnz player_tick               ; play songe from the interrupt

        lda slowprint_enabled
        ora a
        cnz slowprint

        pop d
        pop b
        pop psw
ISRsetSP:
        lxi sp,0
ISRsetHL:
        lxi h,0
        ei
ISRsetRet:
        jmp 0
        
        ; active bounds
bounds:         .dw bounds_0
bounds_b:       .dw bounds_1

        ; bounds even
bounds1:        .dw bounds_0
bounds1_b:      .dw bounds_1
        ; bounds odd
bounds2:        .dw bounds_2
bounds2_b:      .dw bounds_3

                .ds 2

        ; polygon bounds array
        .org 0100h + $ & 0ff00h  ; ALIGN 256
bounds_0:
        .db 1
        .org bounds_0 + (NBOUNDS * 256)
bounds_1:
        .db 1
        .org bounds_1 + (NBOUNDS * 256)
bounds_2:
        .db 1
        .org bounds_2 + (NBOUNDS * 256)
bounds_3:
        .db 1
        .org bounds_3 + (NBOUNDS * 256)
        
        
bounds_end:
        .db 0

ngon_start:

ngon1:
        .ds 48
        .db 0, 0, 0

;; .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .
;; -    -      -      -    -     -     -     -- -
;; -  -    -     -             -  -       -   - -
;; -------------- - -- maths -- ---- ------------
;; ---------------- --- --- --- -----------------
;; ==============================================
;; ==============================================
;; ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
calc_projection:
        lxi h, points_xy
        lxi d, points_proj

rot_loop:
        push h
        push d
          mov b, m \ inx h        ; b = x
          mov c, m                ; c = y
          
          ; just use (0,0) as end marker because floppies have holes in the middle
          mov a, b
          ora c
          jz rot_loop_end
          
          lda mat_axx
          mov e, a
          mov d,b
          call muls8s8shr7    ; d = a = d * e >> 7
          sta rot_px
          lda mat_axy
          mov d, a
          mov e,c
          call muls8s8shr7      ; d = a = d * e >> 7
          lda rot_px
          add d
          sta rot_px            ; rot_px = Axx * px + Axy * py        =c5, 
                                ; but here -60 ($c4) * 126 ($7e) =-59 (c4*7e=$c5)
                                ; expected -57, got -56.. meh
          lda mat_ayx
          mov e, a
          mov d,b
          call muls8s8shr7          ; -3
          sta rot_py
          lda mat_ayy
          mov d, a
          mov e,c
          call muls8s8shr7
          lda rot_py
          add d
          sta rot_py          ; rot_py = Ayx * px + Ayy * py
          
          lda mat_azx
          mov e, a
          mov d,b
          call muls8s8shr7    ; =1
          sta rot_pz
          lda mat_azy
          mov d, a
          mov e,c
          call muls8s8shr7
          lda rot_pz
          add d
          sta rot_pz            ; rot_pz = Azx * px + Azy * py

          adi 85        ; make sure z > 0
          ora a \ rar \ ora a \ rar     ; (z + 85) >> 2  =$15
          mov d, a ; d = z_tmp
          
          lda anim_pos; frame_no
          add a
          call sincosa ; c = cos(2 * frame_no)
          ; calc cos / 4 (signed)
          xra a
          ora c
          jp locm1
          cma \ inr a
          rar \ ora a \ rar
          cma \ inr a
          jmp locm2
                  
locm1:
          rar \ ora a \ rar
;          inr c
;          dcr c         ;test sign
;          jp $+5
;          cma \ inr a   ; a = cos(2 * frame) / 4
locm2:
          adi 58-30        ; a += 58 - ZINV_MIN       ; =$59
          add d         ; a = full z
          
          call bzinva    ; b = zinv[z - ZINV_MIN] ; =$26
          ;mov a, b \ ora a \ rar \ mov b, a
          
          ; clamp b at 127
          ;mov a, b
          ;ora a
          ;jp $+5
          ;mvi b, $7f
          ;mvi b, $b0
          
          
;         push b
          lda rot_px
          mov e, a
          mov d,b
          call muls8u8shr7
          adi $80     ; +128
          sta rot_px  ; rot_px = x * zinv[z - ZINV_MIN] >> 7
;         pop b
          lda rot_py
          mov e, a
          mov d,b
          call muls8u8shr7
          adi $80     ; +128
          sta rot_py    ; rot_py = y * zinv[z - ZINV_MIN] >> 7
          ; kek
          
        pop d
        lda rot_px \ stax d \ inx d
        lda rot_py \ stax d \ inx d
        pop h
        inx h \ inx h
        jmp rot_loop

rot_loop_end:
        pop psw
        pop psw
        ret
        
rot_px:         .db 0
rot_py:         .db 0
rot_pz:         .db 0
        
points_xy:  .db $c4,$c4, $3c,$c4, $3c,$3c, $c4,$3c, $12,$00,$0d,$0d,$00,$12,$f3,$0d,$ee,$00,$f3,$f3,$00,$ee,$0d,$f3,$06,$35,$03,$3a,$fd,$3a,$fa,$35
            .db $fa,$1d,$fd,$18,$03,$18,$06,$1d,
            .db 0, 0
            
points_proj: .ds 21*2

rotmatrix:
        lda rotz
        call sincosa
        mov h, b
        mov l, c
        shld cos_a
        lda rotx
        call sincosa
        mov h, b
        mov l, c
        shld cos_b
        lda roty
        call sincosa
        mov h, b
        mov l, c
        shld cos_c
        
        ; axx = mul(cosa, cosb) >> 7
        lda cos_a
        mov d, a
        lda cos_b
        mov e, a
        call muls8s8shr7
        sta mat_axx
        ;        t2   t1                                         t4 t3
        ; axy = (emul(emul(cosa, sinb) >> SHITF, sinc) >> SHITF) - (emul(sina, cosc) >> SHITF);
        lda cos_a
        mov d, a
        lda sin_b
        mov e, a
        call muls8s8shr7        ; a = emul(cosa, sinb) >> SHITF
        sta cosa_x_sinb         ; =2
        mov d, a
        lda sin_c
        mov e, a
        call muls8s8shr7        ; a = emul(t1, sinc) >> SHITF  =0
        sta mat_axy             ; temporary t2
        lda sin_a
        mov d, a
        lda cos_c
        mov e, a
        call muls8s8shr7
        cma
        inr a
        mov b, a
        lda mat_axy
        add b
        sta mat_axy             ; =f8
        
        ; Axz is not used
        ; ;        t1                                                t2
        ; ; axz = (emul(emul(cosa, sinb) >> SHITF, cosc) >> SHITF) - (emul(sina, sinc) >> SHITF);
        ; lda cosa_x_sinb
        ; mov b, a
        ; lda cos_c
        ; mov c, a
        ; call muls8s8shr7
        ; sta mat_axz ; temporary
        
        ; lda sin_a
        ; mov b, a
        ; lda sin_c
        ; mov c, a
        ; call muls8s8shr7
        ; cma
        ; inr a
        ; mov b, a
        ; lda mat_axz
        ; add b
        ; sta mat_axz             ; =01
        
        ; ayx = emul(sina, cosb) >> SHITF;
        lda sin_a
        mov d, a
        lda cos_b
        mov e, a
        call muls8s8shr7
        sta mat_ayx             ; =08
        
        ; ayy = (emul(emul(sina, sinb) >> SHITF, sinc) >> SHITF) + (emul(cosa, cosc) >> SHITF);
        lda sin_a
        mov d, a
        lda sin_b
        mov e, a
        call muls8s8shr7
        sta sina_x_sinb
        mov d, a
        lda sin_c
        mov e, a
        call muls8s8shr7
        sta mat_ayy ; tmp
        lda cos_a
        mov d, a
        lda cos_c
        mov e, a
        call muls8s8shr7
        mov b, a
        lda mat_ayy
        add b
        sta mat_ayy             ; =7e
        
        ; Ayz is not used
        ; ; ayz = (emul(emul(sina, sinb) >> SHITF, cosc) >> SHITF) - (emul(cosa, sinc) >> SHITF);
        ; lda sina_x_sinb
        ; mov b, a
        ; lda cos_c
        ; mov c, a
        ; call muls8s8shr7
        ; sta mat_ayz     ; tmp
        
        ; lda cos_a
        ; mov b, a
        ; lda sin_c
        ; mov c, a
        ; call muls8s8shr7
        ; cma
        ; inr a
        ; mov b, a
        ; lda mat_ayz
        ; add b
        ; sta mat_ayz             ; =fb
        
        ; Azx = -sinb;
        lda sin_b
        cma
        inr a
        sta mat_azx             ; =fd
        
        ; Azy = emul(cosb, sinc) >> SHITF;
        lda cos_b
        mov d, a
        lda sin_c
        mov e, a
        call muls8s8shr7
        sta mat_azy             ; =05

        ; Azz is not used        
        ; ; Azz = emul(cosb, cosc) >> SHITF;
        ; lda cos_b
        ; mov b, a
        ; lda cos_c
        ; mov c, a
        ; call muls8s8shr7
        ; sta mat_azz             ; =


        ret

        ; a = d = ((signed) e * (unsigned) d) >> 7
muls8u8shr7:
                xra a
                sub e
        jm muls8u8shr7pos
;muls8u8shr7neg
        mov e, a
        call mul8
        ; a = de >> 7
;       xchg
;       dad h
        xra a
        sub d
        ret

muls8u8shr7pos:
        call mul8
        ; a = de >> 7
;       xchg
;       dad h
;       mov a, d
        ret


;         ; a = l = ((signed) c * (unsigned) b) >> 7
; muls8u8shr7:
;         mvi d, 0
;         mov e, b
;         mov b, d
;         mov a, c
;         ora a
;         jp $+7
;         cma \ inr a \ dcr b
;         mov c, a
        
;         call MulAHL_A_DE
;         ; a = hl >> 7
;         mov a, l
;         ral
;         mov a, h
;         ral
;         mov l, a
        
;         mov a, b
;         ora a
;         mov a, l
;         rz
;         cma
;         inr a
;         mov l, a
;         ret
        
;Умножение AHL=A*DE
;MulAHL_A_DE:
;       mvi c,0
;       mov h,d\ mov l,e
;       add a\ jc xxMUL1
;       add a\ jc xxMUL2+2
;       add a\ jc xxMUL3+2
;       add a\ jc xxMUL4+2
;       add a\ jc xxMUL5+2
;       add a\ jc xxMUL6+2
;       add a\ jc xxMUL7+2
;       add a\ rc
;       lxi h,0
;       ret
;
;xxMUL1: dad h\ adc a\ jnc xxMUL2+2
;xxMUL2: dad d\ adc c\ dad h\ adc a\ jnc xxMUL3+2
;xxMUL3: dad d\ adc c\ dad h\ adc a\ jnc xxMUL4+2
;xxMUL4: dad d\ adc c\ dad h\ adc a\ jnc xxMUL5+2
;xxMUL5: dad d\ adc c\ dad h\ adc a\ jnc xxMUL6+2
;xxMUL6: dad d\ adc c\ dad h\ adc a\ jnc xxMUL7+2
;xxMUL7: dad d\ adc c\ dad h\ adc a\ rnc
;xxMUL8: dad d\ adc c
;       ret        

        ; a=d = (d * e) >> 7 signed
muls8s8shr7:
                mov a,d
                xra e
                jm muls8s8shr7neg
;muls8s8shr7pos
                xra e
                jp muls8s8shr7pos2
                xra a
                sub e
                mov e,a
                xra a
                sub d
                mov d,a
muls8s8shr7pos2:
                call mul8
;               xchg
;               dad h
;               mov a,d
                ret
                
muls8s8shr7neg:
                xra e
                jp muls8s8shr7neg1
                xra a
                sub d
                mov d,a
muls8s8shr7neg1:
                xra a
                sub e
                jm muls8s8shr7neg2
                mov e,a
muls8s8shr7neg2:
                call mul8
;               xchg
;               dad h
                xra a
;               sub h
;               mov h,a
                sub d
                mov d,a
                ret

rotx:           .db 0
roty:           .db 0
rotz:           .db 0

cos_a:          .db 0
sin_a:          .db 0
cos_b:          .db 0
sin_b:          .db 0
cos_c:          .db 0
sin_c:          .db 0

mat_axx:        .db      0
mat_axy:        .db      0
mat_axz:        .db      0
mat_ayx:        .db      0
mat_ayy:        .db      0
mat_ayz:        .db      0
mat_azx:        .db      0
mat_azy:        .db      0
mat_azz:        .db      0

cosa_x_sinb:    .db 0
sina_x_sinb:    .db 0

mathinit:
        lxi b,-1
        xra a
        mov d, a
        mov e, a
        lxi h, MULTAB
        call GenSQRtab
        inr h
        inr h
        call GenSQRtab
        ret

        ; b = sin(a), c = cos(a)
sincosa:
        mvi h, costbl >> 8
        mov l, a
        mov c, m        ; c = cos
        sui DEG90
        mov l, a
        mov b, m        ; b = sin
        ret
     
        ; from raytracing8080_vXsource/mul8bit.asm
        ; de = (d * e)<<1
        ; clobbers: everything
mul8:
        mov a, d
        sub e                   ;A=D-E
        mvi h, 1+(MULTAB>>8)
        jnc m8_GetDif2
        cma
        inr a                   ;A=E-D
;m8_GetDif:
        mov l, a
        add d
        add d                   ;A=E+D
        mov d, m
        dcr h
        mov e, m
        jnc m8_GetSum
        mvi h, 2+(MULTAB>>8)
m8_GetSum:
        mov l, a
        mov a, m
        sub e
        mov e, a
        inr h
        mov a, m
        sbb d
        mov d, a
        ret

m8_GetDif2:
        mov l, a
        mov d, m
        dcr h
        add e
        add e                   ;A=D+E
        mov e, m
        jnc m8_GetSum2
        mvi h, 2+(MULTAB>>8)
m8_GetSum2:
        mov l, a
        mov a, m
        sub e
        mov e, a
        inr h
        mov a, m
        sbb d
        mov d, a
        ret


GenSQRtab:
        push d
        push psw
        rar
        push psw
        mov a, d
        rar
        mov d, a
        mov a, e
        rar
        mov e, a
        pop psw
;       rar
        mov a, d
;       rar
        inr h
        mov m,a
        dcr h
        mov a, e
;       rar
        mov m, a
        pop psw
        pop d
        inx b
        inx b
        xchg
        dad b
        xchg
        aci 0
        inr l
        jnz GenSQRtab
        ret

        .org 0100h + $ & 0ff00h  ; ALIGN 256
zinvtbl:
                .db $ff,$ff,$f8,$f1,$ea,$e3,$dd,$d7,$d2,$cd,$c8,$c3,$be,$ba,$b6,$b2,$ae,$aa,$a7,$a4,$a0,$9d,$9a,$97,$95,$92,$8f,$8d,$8b,$88,$86,$84,
        .db $82,$80,$7e,$7c,$7a,$78,$76,$75,$73,$72,$70,$6e,$6d,$6c,$6a,$69,$67,$66,$65,$64,$62,$61,$60,$5f,$5e,$5d,$5c,$5b,$5a,$59,$58,$57,
        .db $56,$55,$54,$53,$52,$52,$51,$50,$4f,$4f,$4e,$4d,$4c,$4c,$4b,$4a,$4a,$49,$48,$48,$47,$46,$46,$45,$45

        ; b = 8192/(31+a)
bzinva:
        mvi h, zinvtbl >> 8
        mov l, a
        mov b, m
        ret

        .org 0100h + $ & 0ff00h  ; ALIGN 256
costbl:
        .db $7f,$7f,$7f,$7f,$7e,$7e,$7e,$7d,$7d,$7c,$7b,$7a,$7a,$79,$78,$76,$75,$74,$73,$71,$70,$6f,$6d,$6b,$6a,$68,$66,$64,$62,$60,$5e,$5c
        .db $5a,$58,$55,$53,$51,$4e,$4c,$49,$47,$44,$41,$3f,$3c,$39,$36,$33,$31,$2e,$2b,$28,$25,$22,$1f,$1c,$19,$16,$13,$10,$0c,$09,$06,$03
        .db $00,$fd,$fa,$f7,$f4,$f0,$ed,$ea,$e7,$e4,$e1,$de,$db,$d8,$d5,$d2,$cf,$cd,$ca,$c7,$c4,$c1,$bf,$bc,$b9,$b7,$b4,$b2,$af,$ad,$ab,$a8
        .db $a6,$a4,$a2,$a0,$9e,$9c,$9a,$98,$96,$95,$93,$91,$90,$8f,$8d,$8c,$8b,$8a,$88,$87,$86,$86,$85,$84,$83,$83,$82,$82,$82,$81,$81,$81
        .db $81,$81,$81,$81,$82,$82,$82,$83,$83,$84,$85,$86,$86,$87,$88,$8a,$8b,$8c,$8d,$8f,$90,$91,$93,$95,$96,$98,$9a,$9c,$9e,$a0,$a2,$a4
        .db $a6,$a8,$ab,$ad,$af,$b2,$b4,$b7,$b9,$bc,$bf,$c1,$c4,$c7,$ca,$cd,$cf,$d2,$d5,$d8,$db,$de,$e1,$e4,$e7,$ea,$ed,$f0,$f4,$f7,$fa,$fd
        .db $00,$03,$06,$09,$0c,$10,$13,$16,$19,$1c,$1f,$22,$25,$28,$2b,$2e,$31,$33,$36,$39,$3c,$3f,$41,$44,$47,$49,$4c,$4e,$51,$53,$55,$58
        .db $5a,$5c,$5e,$60,$62,$64,$66,$68,$6a,$6b,$6d,$6f,$70,$71,$73,$74,$75,$76,$78,$79,$7a,$7a,$7b,$7c,$7d,$7d,$7e,$7e,$7e,$7f,$7f,$7f

MULTAB: .ds 1024

TOPLINE .equ $a0
LINEH   .equ 14
msg1:   
        .db TOPLINE - 30, 4, "HTTPS://CAGLRC.CC/SCALAR", 0
        .db 10, 14, "2025", 0
;                                         "                                "
msg_restart:
        .db TOPLINE -  0, 4, "KARTOTEKA FOR VECTOR-06C", 0
        .db TOPLINE - 10, 4, "------------------------", 0
        .db TOPLINE - 80, 0,              " VISIT FOR GIGAZ OF V-06C WAREZ ", 0
        .db TOPLINE - 80 - LINEH, 0,      "     GAMEZ, DEMOS  AND DOCS     ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  "       RECENT & HISTORICAL      ", 0

        ;.db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0
        .db 1, 1, 253
        .db 1, 1, 253
        
        .db TOPLINE - 80, 0,              "      COME AND LEARN ABOUT      ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "         -- -- -- -- --         ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "            -- -- --            ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  "           VECTOR-06C           ", 0

        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        .db 1, 1, 253
        .db 1, 1, 253

        .db TOPLINE - 80 - (LINEH*1), 0,  "                                ", 0   ; wipe previous
        .db TOPLINE - 80 - (LINEH*2), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0

        .db TOPLINE - 80, 0,              "  CODE NEW DEMOS AND GAMES FOR  ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "           BEKTOP-06",20,"           ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  "   FOR ITS POWERFUL 8080A CPU   ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "      (BEAUTIFUL MNEMONICS)     ", 0
        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        .db 1, 1, 253
        .db 1, 1, 253

        .db TOPLINE - 80, 0,              "                                ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "                                ", 0   ; wipe previous
        .db TOPLINE - 80 - (LINEH*2), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0

        .db TOPLINE - 80 + (LINEH*1), 0,  "     XCHG                       ", 0
        .db TOPLINE - 80 + (LINEH*1), 0,  "                      DAD SP    ", 0
        .db TOPLINE - 80 + (LINEH*1), 0,  "            XTHL                ", 0
        .db TOPLINE - 80 + (LINEH*1), 0,  "        SPHL                    ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0     ; wipe "beautiful mnemonics"
        .db TOPLINE - 80 + (LINEH*1), 0,  "                                ", 0
        .db TOPLINE - 80 + (LINEH*1), 0,  "                FHTAGN          ", 0
        .db TOPLINE - 80 + (LINEH*1), 0,  "                                ", 0


        .db TOPLINE -  0, 4, "  KAPTOTEKA BEKTOPA-06",20,"  ", 0

        .db TOPLINE - 80, 0,              "    WRITE MASSIVE TUNES  FOR    ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "          THE AMAZING           ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "         THE INCREDIBLE         ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "       THE SECOND TO NONE       ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  "           8253 (VI53)          ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "         SOUND GENERATOR        ", 0

        ;.db 1, 1, 254 ; launch fish

        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        .db 1, 1, 253 ; delay
        .db 1, 1, 253 ; delay

        .db TOPLINE - 80 - (LINEH*1), 0,  "                                ", 0   ; wipe previous
        .db TOPLINE - 80 - (LINEH*2), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0

        .db TOPLINE - 80, 0,              "    WIN OLDSKOOL COMPOS WITH    ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "         -- -- -- -- --         ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "            -- -- --            ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  "        BEKTOP-06",20," PRODS        ", 0

        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        .db 1, 1, 253
        .db 1, 1, 253

        .db TOPLINE - 80 - (LINEH*1), 0,  "                                ", 0   ; wipe previous
        .db TOPLINE - 80 - (LINEH*2), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0

        ;.db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0
        .db 1, 1, 253
        .db TOPLINE - 80,             0,  "             CREDITS            ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  " CODE, GFX, MUSIC ..... SVOFSKI ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  " MAD CODE & BASS ....... IVAGOR ", 0

        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        .db 1, 1, 253

        .db TOPLINE - 80 - (LINEH*1), 0,  "                                ", 0   ; wipe previous
        .db TOPLINE - 80 - (LINEH*2), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0
        
        .db TOPLINE - 80 - (LINEH*1), 0,  " ECHOING.MOD VARIATION FOR VI53 ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  " BY SVOFSKI FEAT IVAGOR ON BEHS ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "     - OG AUTHOR UNKNOWN -      ", 0

        ;.db TOPLINE - 80 - (LINEH*4), 0,  "                                ", 0
        .db 1, 1, 253

        .db TOPLINE -  0, 4, "  KPOTOTEKA", 0

        .db TOPLINE - 80 - (LINEH*0), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*1), 0,  "                                ", 0   ; wipe previous
        .db TOPLINE - 80 - (LINEH*2), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0

        .db TOPLINE - 80 - (LINEH*2), 0,  "      GREETINGS OUTLINE \\o/     ", 0
        .db 1, 1, 253
        .db 1, 1, 254 ; launch fish
        .db 1, 1, 253
        .db 1, 1, 253
        .db 1, 1, 253
        .db 1, 1, 253
        .db 1, 1, 253
        .db 1, 1, 253
        
        ;.db TOPLINE - 80 - (LINEH*0), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*0), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*0), 0,  "                                ", 0
        ;.db TOPLINE - 80 - (LINEH*1), 0,  "                                ", 0   ; wipe previous
        ;.db TOPLINE - 80 - (LINEH*3), 0,  "                                ", 0
        .db TOPLINE - 80 - (LINEH*2), 0,  "                                ", 0

        .db 1, 1, 255

        .ds 32  ; there's a bug with alignment somewhere!

msg_minus1: .db "SVOFSKI & IVAGOR", 0


        .org 020h + ($ & 0ffe0h)  ; ALIGN 32
zero_init_start:

intcount:   .dw 0
frametime:  .db 0 ; interrupts between oneframe
frame_no:   .db 0
anim_pos:   .db 0

pal_0:
            .db 0, 0, 0, 0
            .db 0, 0, 0, 0
            .db 0, 0, 0, 0
            .db 0, 0, 0, 0
pal_a_ptr:  .dw 0
pal_b_ptr:  .dw 0
pal_fade_a: .ds 16
pal_fade_b: .ds 16
pal_zero_end:

fade_in_flag:       .db 0
slowprint_enabled:  .db 0
slow_msg_state:     .db 0
slow_msg_ptr:       .dw 0
slow_msg_loop:      .dw 0

; fish vars
fish_wraparound_flag:   .db 0
;msgseq_end_flag:        .db 0
                ; ORDER IMPORTANT
fish_col_frac:    .db 0
fish_col:         .db 0
fish_enabled:     .db 0


        .org 020h + ($ & 0ffe0h)  ; ALIGN 32
zero_init_end:

        ; big logo
        .include "blksbr.inc"

        ; big time textuality
        .include "font8x8.inc"

        .include "fish.inc"
fishz0: .ds 32   ; empty sprite for wiping
        .include "drawfish.inc"

        .org PLAYER_BASE-1
        .db 0

player_init .equ PLAYER_BASE+0
player_tick .equ PLAYER_BASE+3
songe       .equ PLAYER_BASE+6

        .end
        
        
; code snippets cemetery

        ; xor-swap, register-saving but too slow
        ; xra m           ; X = Y xor X  (X = *hl)
        ; mov m, a
        ; dcx h
        ; xra m
        ; mov m, a        ; Y = X xor Y 
        ; inx h
        ; xra m
        ; mov m, a        ; = 64/swap
        
        

        ; ora a           ; $00 -> Z=1                    -> continue
        ;                 ; $80 -> Z=0, S=1, P=0          -> A (fill)
        ;                 ; $C0 -> Z=0, S=1, P=1          -> continue
        ;                 ; $40 -> Z=0, S=0, P=0          -> B (wipe)

        ; add a           ; CY = state_a, S = state_b
        ;                 ; $80 -> C=1, Z=1, P=1, S=0
        ;                 ; $00 -> C=0, Z=1, P=1, S=0     ~ !state_a & !state_b
        ;                 ; $40 -> C=0, Z=0, P=0, S=1
        ;                 ; $C0 -> C=1, Z=0, P=0, S=1     ~ state_a & state_b
        
