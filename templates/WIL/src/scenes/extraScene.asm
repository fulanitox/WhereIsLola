    include "include/hardware.inc"
    include "include/gbt_player.inc"
    EXPORT lolaLV_data

SECTION "EXTRA SCENE", ROM0

extraScene_init:
    call ScreenOff
    call CleanOAM
    call cleanScreen
    call Copiar_en_VRAM_Extra_Numero
    call Copiar_en_VRAM_Extra_MaxScore
    call Copiar_en_VRAM_Text
    call pintarSpritesExtra
    call renderExtra_init
    ld a, 0
    ld [lastBTN_ANTERIOR], a
    ld [lastBTN], a
    call gbt_stop
    call ScreenOn
    ret
extraScene_update:
    call extraSceneControls 
    ;call  gbt_update
ret

Copiar_en_VRAM_Extra_Numero:
    ld hl, $8800
    ld bc, GAMEOVER_NUMEROS_SP
    ld de, GAMEOVER_NUMEROS_SP_END - GAMEOVER_NUMEROS_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_Extra_MaxScore:
    ld hl, $8B00
    ld bc, MAX_SCORE_SP
    ld de, MAX_SCORE_SP_END - MAX_SCORE_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_Text:
    ld hl, $8D00
    ld bc, EXTRA_SP
    ld de, EXTRA_SP_END - EXTRA_SP
    call CopiarEnVRAM_recto
    ret

extraSceneControls:
    ld a, [lastBTN_ANTERIOR]
    ld b,a
    ld a, [lastBTN] ;A = [D|U|L|R|St|Se|B|A]
    cp b
    jr z, .return
    
    cp %00000010
    jr nz, .return
    ld a, 0
    call changeScene

    .return
    ret

pintarSpritesExtra:
    call pintarMAIN
    call pintarTitulo
    call pintarMaxScoreExtra
    call pintarText
    ret
pintarMaxScoreExtra:
    ld hl, $9964
    ld bc, MAX_SCORE_MAP
    ld de, MAX_SCORE_MAP_END - MAX_SCORE_MAP
    .loop
        ld a, 12
        .loop2
            push af
            ld a, [bc]
            ld [hl], a
            pop af

            inc hl
            inc bc
            dec de          ; Decrementa DE
            dec a
        jr nz, .loop2
        push bc
        ld bc, 20
        add hl, bc
        pop bc
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
    jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret

pintarText:
    ld hl, $9A06
    ld a, $D0
    .loop2
        ld [hl], a
        
        inc hl
        inc a         
        cp $D8
    jr nz, .loop2
         
    ret