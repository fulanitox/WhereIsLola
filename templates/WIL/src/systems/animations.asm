include "include/hardware.inc"

SECTION "Animations Data", WRAM0
;;2 bytes to store the MEMORY ADRESS of the animation data
    anim_next:      DS 2
    LastAnim:       DS 2
    DEF FinalDeAnim = -1

SECTION "Animations Section", ROM0

sprite_animation:     

;ROB UP WALK
    DB $00
    DB $02
    DB $00
    DB $04
    DB FinalDeAnim 

;ROB DOWN WALK
    DB $06
    DB $08
    DB $06
    DB $0A
    DB FinalDeAnim

;ROB LEFT WALK
    DB $0C
    DB $0E
    DB $0C
    DB $20
    DB FinalDeAnim

;ROB RIGHT WALK
    DB $22
    DB $24
    DB $22
    DB $26
    DB FinalDeAnim
;ALIEN
    


anim_init:
    ld hl, sprite_animation ;;HL -> Adress of fisrt byte of sprite
    ld a, 0
    ld [LastAnim], a     ;;Guarda el estado de la animación
    ld a, l
    ld [anim_next + 0], a   ;;Store L in the fisrt byte of anim_next    
    ld a, h
    ld [anim_next + 1], a   ;;Store H in the second byte of anim_next
    ret

;INPUT -> A = INDEX FOR ENTITY TO MAN_ENTITY
anim_nextframe:
        
    push af         ;; Guardamos la dirección de memoria de la entidad, que mas tarde recogeremos antes de mandar al metodo que actualiza

    ld a, [anim_next + 0]   ;;Load L from anim_next
    ld l, a
    ld a, [anim_next + 1]   ;;Load H from anim_next
    ld h, a

    ;=======================================
    ; [2] Check if the animation has ended
    ld a, [hl]              ;;Load the first byte of the sprite
    cp FinalDeAnim                   ;;(OjO)  
    ld c, 0
    jr nz, .continue_anim
    ld hl, sprite_animation
    ld c, 1
    ;=======================================


    

    ; [3] Copy the data of this animation drame (tile number and atributtes) to the entity.
    .continue_anim
    call getAnimVelocity
    ld a, [hl+]
    ld d, a
    pop af
    push hl
    call man_actualize_TILE_ATTR
    pop hl

    ; [4] Store -the value of HL at anim_next_data that now contains the adress of the next frame of the animation, and return to caller.
    ld a, l
    ld [anim_next + 0], a
    ld a, h
    ld [anim_next + 1], a
    ret


animationGame_update:
    ;;==============CONTADOR================
    ld a, [$C008]    ;;/ =6
    dec a            ;;\ Decrementa BC
    ld [$C008], a    ;;/
    ret nz           ;;\ Repite el bucle hasta que BC llegue a cero el contador

    ld a, $0A        ;;/ RESET CONTADOR
    ld [$C008], a    ;;\
    ;;=====================================
    call vacaAnim

    ld a, 0         ;; A = Adress of the entity data of the sprite
    call anim_nextframe    
    ret
          

;;Obtiene la velocidad de la entidad
;;INPUT -> A = INDEX FOR ENTITY
;;OUTPUT -> DE = VELOCITY XY
;;DESTROY -> A, B, HL
getAnimVelocity:
    push hl
    ld hl, entity_array + 4
    ld a, [hl+]
    ld d, a
    ld a, [hl]
    ld e, a

    pop hl
    ld a, d
    cp 2
    jr z, .caseUP

    cp 1
    jr z, .caseDown

    ld a, e
    cp 2
    jr z, .caseLeft

    cp 1
    jr z, .caseRight
    .caseDown
        ld a, [LastAnim]
        sub 0
        or c
        jr z, .default

        ld a, 0
        ld [LastAnim], a
        jp .AddHL
    .caseUP
        ld a, [LastAnim]
        sub 5
        or c
        jr z, .default

        ld a, 5
        ld [LastAnim], a
        jp .AddHL
    .caseLeft
        ld a, [LastAnim]
        sub 10
        or c
        jr z, .default

        ld a, 10
        ld [LastAnim], a
        jp .AddHL
    .caseRight
        ld a, [LastAnim]
        sub 15
        or c
        jr z, .default

        ld a, 15
        ld [LastAnim], a
        jp .AddHL
    .AddHL
        ld e, a                 
        ld d, 0                 
        ld hl, sprite_animation
        add hl, de              
    .default
    ret

vacaAnim:
    call wait_VBLANK
    ld a, [VacaPos1]
    ld h, a
    ld a, [VacaPos2]
    ld l, a

    ld a, [VacaTime]
    cp 4
    jp c, .desaparece



    .noDesaparece
    ld a, [hl]
    cp $28
    jr z, .second_frame

    cp $2A
    jr z, .third_frame

    cp $2C
    jr z, .first_frame

    .desaparece
    ld a, [hl]
    cp $28
    jr z, .second_frame

    cp $2A
    jr z, .third_frame

    cp $2C
    jr z, .dead_frame

    cp $5F
    jr z, .first_frame



    .first_frame
    ld a, $28
    jp .paint

    .second_frame
    ld a, $2A
    jp .paint

    .third_frame
    ld a, $2C
    jp .paint

    .dead_frame
    call pintarBlanco
    jp .end

    .paint
    call pintarCuadradoVaca

    .end
    ret
;; INPUT -> A = Tile number
;; -------> HL = POSITION OF THE ENTITY

pintarCuadradoVaca:
    ld [hl+], a
    ld a, $29
    ld [hl], a

    ld bc, 32
    add hl, bc
    ld a, $39
    ld [hl], a

    dec hl
    ld a, $38
    ld [hl], a
    ret

pintarBlanco:
    ld a, $5f
    ld [hl+], a
    ld [hl], a

    ld bc, 32
    add hl, bc
    ld [hl], a

    dec hl
    ld [hl], a
    ret