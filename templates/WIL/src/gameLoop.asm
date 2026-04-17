include "include/hardware.inc"
SECTION "Game Engine Vars", WRAM0
    currentScene: DS 1
    mainScene: DS 1
    gameScene: DS 1
SECTION "Game Engine Section", ROM0

;------------------------------------------------------------------------------
; ---------------------------------CHECKBOTONES--------------------------------
; Funcion que comprueba el input del jugador y lo guarda en la variable lastBTN
; Entradas: Ninguna
; Salidas: Ninguna
; Destruye: A, B, HL
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

checkBotones:
   ld a, $20
   ldh [$FF00], a 
   ldh a, [$FF00] 
   ldh a, [$FF00] 
   ldh a, [$FF00] 
   cpl
   
   and $0F
   swap a
   ld b, a
   
   ld a, $10
   ldh [$FF00], a
   ldh a, [$FF00]
   ldh a, [$FF00]
   ldh a, [$FF00]
   cpl
   and $0F
   or b

   cp 0
   ret z
   
   ld hl, lastBTN
   ld [hl], a
    ret


gameLoop:
    ld a, 0
    ld [currentScene], a
    ld [mainScene], a
    ld a, 1
    ld [gameScene], a
    ld a, 0
    ld [maxscore], a
    call main_menu_scene_init
    .loop
    call checkBotones
    call TIMER_CONTROL
        ld a, [currentScene]

        cp 0
        jr nz, .gameScene
        call main_menu_scene_update
        jr .loop

        .gameScene
        ld a, [currentScene]
        cp 1
        jr nz, .gameOverScene
        call gameEscene_update
        jr .loop

        .gameOverScene
        ld a, [currentScene]
        cp 2
        jr nz, .extraScene
        call gameOverScene_update
        jr .loop

        .extraScene
        ld a, [currentScene]
        cp 3
        jr nz, .end
        call extraScene_update
        jr .loop

        .end
    ret

changeScene:
    push af
    ld a, 0
    ld [lastBTN], a
    pop af

    cp 0
    jr nz, .gameScene
    ld [currentScene], a
    call main_menu_scene_init
    jr .end

    .gameScene
    cp 1
    jr nz, .gameOverScene
    ld [currentScene], a
    call gameScene_init
    jr .end

    .gameOverScene
    cp 2
    jr nz, .extraScene
    ld [currentScene], a
    call gameOver_init
    jr .end

    .extraScene
    cp 3
    jr nz, .end
    ld [currentScene], a
    call extraScene_init
    jr .end

    .end
    call random_init
    ret