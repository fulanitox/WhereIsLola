    include "include/hardware.inc"
    include "include/gbt_player.inc"
    EXPORT dearlolacow_data

SECTION "MAIN MENU VARS", WRAM0
    EstadoFlecha: DS 1 ; 0 = Start, 1 = Credits
    LastEstadoFlecha: DS 1 ; 0 = Start, 1 = Credits
    lastBTN_ANTERIOR: DS 1
SECTION "MAIN MENU SCENE", ROM0

main_menu_scene_init:
    call ScreenOff
    call CleanOAM
    call cleanScreen
    call Copiar_en_VRAM_Main
    call Copiar_en_VRAM_Letras
    call Copiar_en_VRAM_MaxScoreMAIN
    call pintarSprites
    call initScrollMAIN
    ld a, 0
    ld [EstadoFlecha], a
    ld a, 1
    ld [LastEstadoFlecha], a
    ld a, 0
    ld [lastBTN_ANTERIOR], a
    ld [lastBTN], a
    ld a, [$FF40]       ; Cargar el valor actual de LCDC
                        ; Desactiva el bit 5 (window enable) y el bit 6 (window map en $9C00)
    res 6, a
    res 5, a
    ld [$FF40], a
    call ScreenOn
    call musicMenu
ret

initScrollMAIN:
    ld hl, $FF42
    ld a, 0
    ld [hl], a
    ld hl, $FF43
    ld a, 0
    ld [hl], a
    ret
main_menu_scene_update:
    call renderMain_update
    call main_menu_scene_controls
    call gbt_update 
ret

main_menu_scene_controls:
    ld a, [lastBTN_ANTERIOR]
    ld b,a
    ld a, [lastBTN] ;A = [D|U|L|R|St|Se|B|A]
    cp b
    jr z, .return
    
    cp %10000000
    jr nz, .arriba
    call changeFlecha
    ret

    .arriba
    cp %01000000
    jr nz, .A
    ld a, [EstadoFlecha]
    cp 0
    jr z, .A
    call changeFlecha
    ret

    .A
    cp %00000001
    call z, gestBOTON

    .return
    ret
gestBOTON:
    ld a, [EstadoFlecha]
    cp 0
    jr nz, .cambio1
    ld a, 1
    call changeScene
    ret
    .cambio1
    ld a, 3
    call changeScene
    ret
changeFlecha:
    ld a, [lastBTN]
    ld [lastBTN_ANTERIOR], a

    ld a, [EstadoFlecha]
    cp 0
    jr z, .cambio1
    ld a, 0
    ld [EstadoFlecha], a
    ret
    .cambio1
    ld a, 1
    ld [EstadoFlecha], a
    ret

Copiar_en_VRAM_Main:
    ld hl, $8000
    ld bc, MAIN_SP
    ld de, MAIN_SP_END - MAIN_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_Letras:
    ld hl, $8400
    ld bc, LETRAS_SP
    ld de, LETRAS_SP_END - LETRAS_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_MaxScoreMAIN:
    ld hl, $8B00
    ld bc, MAX_SCORE_MAIN_SP
    ld de, MAX_SCORE_MAIN_SP_END - MAX_SCORE_MAIN_SP
    call CopiarEnVRAM_recto
    ret

pintarSprites:
    call pintarMAIN
    call pintarTitulo
    call pintarStart
    call pintarFlecha
    call pintarMAXMAIN
    ret

pintarMAXMAIN:
    ld hl, $99C5
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
pintarMAIN:
    ld hl, $9866
    ld bc, MAIN_MAP_SP
    ld de, MAIN_MAP_SP_END - MAIN_MAP_SP
    .loop
        ld a, 8
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
        ld bc, 24
        add hl, bc
        pop bc
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
    jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret

pintarTitulo:
    ld hl, $9822
    ld bc, TITULO_SP
    ld de, TITULO_SP_END - TITULO_SP
    .loop
        ld a, 17
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
        ld bc, 15
        add hl, bc
        pop bc
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
    jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret

pintarStart:
    ld hl, $9985
    ld bc, START_SP
    ld de, START_SP_END - START_SP 
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

pintarFlecha:
    ld hl, $9984
    ld a, $92
    ld [hl], a

    ld hl, $99A4
    ld a, $93
    ld [hl], a
    ret
    


musicMenu:
    ld      de, dearlolacow_data
    ld      bc, BANK(dearlolacow_data)
    ld      a, $07
    call    gbt_play    ; Reproducir canción
ret