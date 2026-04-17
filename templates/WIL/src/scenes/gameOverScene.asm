    include "include/hardware.inc"
    include "include/gbt_player.inc"
    EXPORT gameOver_data
SECTION "Game Over Vars", WRAM0
    tiempo: DS 1
    compScroll: DS 1
SECTION "GAME OVER SCENE", ROM0

gameOver_init:
    call ScreenOff
    call CleanOAM
    call cleanScreen
    call Copiar_en_VRAM_GameOver_Dibujo
    call Copiar_en_VRAM_GameOver_Titulo
    call Copiar_en_VRAM_GameOver_Score
    call Copiar_en_VRAM_GameOver_Numero
    call Copiar_en_VRAM_MaxScore
    call Copiar_en_VRAM_robert_triste
    call pintarSpritesGAMEOVER
    call cambiarMaxScore
    call renderGameOver_init
    call initScrollMAIN
    call gbt_stop
    ; call timer_init
    ld a, 0
    ld [compScroll], a
    ld [EstadoFlecha], a
    ld [LastEstadoFlecha], a
    ld [lastBTN_ANTERIOR], a
    ld [lastBTN], a
    ld a, 28
    ld [tiempoANT], a
    ld a, 10
    ld [tiempo], a
    ld a, [$FF40]       ; Cargar el valor actual de LCDC
                        ; Desactiva el bit 5 (window enable) y el bit 6 (window map en $9C00)
    res 6, a
    res 5, a
    ld [$FF40], a
    call ScreenOn
    call musicOver
    ret

gameOverScene_update:
    call wait_VBLANK
    call wait_VBLANK
    call gbt_update
    ; call TIMER_CONTROL
    call moverSCROLL
    call repintar
    call comprobarFinal
    
    ret
borrarGameOver:
    ld hl, $9800
    ld de, $9853 - $9800
    .loop
        ld a, $7F
        ld [hl+], a
        dec de          ; Decrementa DE
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
        jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret
    ret
repintar:
    ld a, [$FF42]
    cp 30
    jr nz, .next1
    call wait_VBLANK
    call borrarGameOver
    .next1
    ret
moverSCROLL:
    ld a, [$FF42]
    cp 95
    jr c, .next

    ret
    .next
    ld a, [compScroll]
    cp 0
    jr nz, .end2
    ld a, 1
    ld [compScroll], a

    ld b, 7
    ld a, [tiempo]
    cp b
    jr nc, .end
    ld a, [$FF42]
    add 1
    ld [$FF42], a

    jr .end
    .end2
    ld a, 0
    ld [compScroll], a
    .end
    ret

cambiarMaxScore:
    ld a, [score]
    ld b, a
    ld a, [maxscore]
    cp b
    jr nc, .end
    ld a, b
    ld [maxscore], a
    .end
    ret

comprobarFinal:
    ld a, [tiempoANT]     ; Cargar el tiempo anterior en A
    ld b, a               ; Guardar el tiempo anterior en B
    ld a, [SECONDS]       ; Cargar el valor actual de SECONDS
    cp b                  ; Comparar con el tiempo anterior
    jr z, .end          ; Si no hay cambio, saltar
    
    ld [tiempoANT], a     ; Guardar el tiempo actual como tiempo anterior

    ld a, [tiempo]
    sub 1                 ; Decrementar el tiempo en 1
    cp 0
    jr nz, .next
    ld a, 0
    call changeScene
    jr .end
    .next
    ld [tiempo], a         ; Guardar el nuevo tiempo
    
    .end
    ret

Copiar_en_VRAM_GameOver_Dibujo:
    ld hl, $8000
    ld bc, GAMEOVER_OVNIVACA_SP
    ld de, GAMEOVER_OVNIVACA_SP_END - GAMEOVER_OVNIVACA_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_GameOver_Titulo:
    ld hl, $8400
    ld bc, GAMEOVER_TITULO_SP
    ld de, GAMEOVER_TITULO_SP_END - GAMEOVER_TITULO_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_GameOver_Score:
    ld hl, $8560
    ld bc, GAMEOVER_SCORE_SP
    ld de, GAMEOVER_SCORE_SP_END - GAMEOVER_SCORE_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_GameOver_Numero:
    ld hl, $8800
    ld bc, GAMEOVER_NUMEROS_SP
    ld de, GAMEOVER_NUMEROS_SP_END - GAMEOVER_NUMEROS_SP
    call CopiarEnVRAM_recto
    ret
Copiar_en_VRAM_MaxScore:
    ld hl, $8B00
    ld bc, MAX_SCORE_SP
    ld de, MAX_SCORE_SP_END - MAX_SCORE_SP
    call CopiarEnVRAM_recto
    ret

Copiar_en_VRAM_robert_triste:
    ld hl, $8D00
    ld bc, ROBERT_TRISTE_SP
    ld de, ROBERT_TRISTE_SP_END - ROBERT_TRISTE_SP
    call CopiarEnVRAM_recto
    ret

pintarSpritesGAMEOVER:
    call pintarGAMEOVER
    call pintarTituloGAMEOVER
    call pintarScore
    call pintarMaxScore
    call pintarRobertTriste
    ; call pintarFlecha
    ret
pintarRobertTriste:
    ld hl, $9B08
    ld bc, ROBERT_TRISTE_MAP
    ld de, ROBERT_TRISTE_MAP_END - ROBERT_TRISTE_MAP
    .loop
        ld a, 4
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
        ld bc, 28
        add hl, bc
        pop bc
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
    jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret
pintarGAMEOVER:
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

pintarTituloGAMEOVER:
    ld hl, $9825
    ld bc, GAMEOVER_TITULO_MAP
    ld de, GAMEOVER_TITULO_MAP_END - GAMEOVER_TITULO_MAP
    .loop
        ld a, 11
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
        ld bc, 21
        add hl, bc
        pop bc
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
    jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret
pintarScore:
    ld hl, $9984
    ld bc, GAMEOVER_SCORE_MAP
    ld de, GAMEOVER_SCORE_MAP_END - GAMEOVER_SCORE_MAP
    .loop
        ld a, 13
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
        ld bc, 19
        add hl, bc
        pop bc
        ld a, e         ; Carga el byte menos significativo de DE
        or d            ; Comprueba si DE es cero
    jr nz, .loop    ; Si 'e' no es cero, repite el bucle    
    ret

pintarMaxScore:
    ld hl, $9A44
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


musicOver:
    ld      de, gameOver_data
    ld      bc, BANK(gameOver_data)
    ld      a, $07
    call    gbt_play    ; Reproducir canción
ret
