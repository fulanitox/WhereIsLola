include "include/hardware.inc"
SECTION "POSOAM Section", WRAM0
   posOAM: DS 1
   posY: DS 1
   posX: DS 1
   tile: DS 1
   velY: DS 1
   velX: DS 1
   attr: DS 1
   anim: DS 1
SECTION "Physics Section", ROM0

DEF velMov = 1
physics_update:
   ld de, physics_movement
   call man_entity_for_each
   ; ld hl, $C000
   ; call physics_movement
ret

physics_movement:
   ld d, h           ; Guardamos la dirección de memoria de la entidad
   ld e, l

   inc hl
   ld a, [hl]        ; Nos movemos hasta el idOAM de la entidad
   ld [posOAM], a    ; Guardamos el ID de la OAM

   inc hl            ; Nos movemos hasta la posicion Y de la entidad
   ld a, [hl]
   ld [posY], a      ; Guardamos la posición Y de la entidad

   inc hl            ; Nos movemos hasta la posicion X de la entidad
   ld a, [hl]
   ld [posX], a      ; Guardamos la posición X de la entidad

   inc hl            ; Nos movemos hasta la velocidad en Y de la entidad
   ld a, [hl]
   ld [velY], a      ; Guardamos la velocidad en Y de la entidad

   inc hl            ; Nos movemos hasta la velocidad en X de la entidad
   ld a, [hl]
   ld [velX], a      ; Guardamos la velocidad en X de la entidad

   ; Procesar la velocidad en X
    ld a, [velX]
    cp 0
    jr z, .check_velY      ; Si la velocidad es 0, saltamos a comprobar velY

    cp 1
    jr z, .add_posX        ; Si la velocidad es 1, sumamos 1 a la posición X

    cp 2
    jr z, .sub_posX        ; Si la velocidad es 2, restamos 1 a la posición X

   ; Procesar la velocidad en Y
   .check_velY
   ld a, [velY]
   cp 0
   jr z, .end              ; Si la velocidad en Y es 0, terminamos

   cp 1
   jr z, .add_posY        ; Si la velocidad es 1, sumamos 1 a la posición Y

   cp 2
   jr z, .sub_posY        ; Si la velocidad es 2, restamos 1 a la posición Y

   jr .end

   ; Sumar a la posición X
   .add_posX:
   ld a, [posX]
   cp $50
   jr nz, .no_move_scroll_X_positive
   ld hl, $FF43
   ld a, [hl]
   cp 72
   jr z, .no_move_scroll_X_positive

   inc a
   ld [hl], a
   jr .check_velY

   .no_move_scroll_X_positive
   ld a, [posX]
   add velMov             ; Aumentamos la posición X en 1
   ld [posX], a

   jr .check_velY         ; Saltamos a procesar la velocidad en Y

   ; Restar de la posición X
   .sub_posX:
   ld a, [posX]
   cp $50
   jr nz, .no_move_scroll_X_negative
   ld hl, $FF43
   ld a, [hl]
   cp 0
   jr z, .no_move_scroll_X_negative
   dec a
   ld [hl], a
   jr .check_velY

   .no_move_scroll_X_negative
   ld a, [posX]
   sub velMov              ; Disminuimos la posición X en 1
   ld [posX], a

   jr .check_velY          ; Saltamos a procesar la velocidad en Y

   ; Sumar a la posición Y
   .add_posY:
   ld a, [posY]
   cp $48
   jr nz, .no_move_scroll_Y_positive
   ld hl, $FF42
   ld a, [hl]
   cp 112
   jr z, .no_move_scroll_Y_positive
   inc a
   ld [hl], a
   jr .end

   .no_move_scroll_Y_positive
   ld a, [posY]
   add velMov              ; Aumentamos la posición Y en 1
   ld [posY], a
   jr .end                 ; Finalizamos

   ; Restar de la posición Y
   .sub_posY:
   ld a, [posY]
   cp $48
   jr nz, .no_move_scroll_Y_negative
   ld hl, $FF42
   ld a, [hl]
   cp 0
   jr z, .no_move_scroll_Y_negative
   dec a
   ld [hl], a
   jr .end

   .no_move_scroll_Y_negative
   ld a, [posY]
   sub velMov              ; Disminuimos la posición Y en 1
   ld [posY], a
   jr .end                 ; Finalizamos

   .end  
   ld h, d                 ; Recuperamos la dirección de memoria de la entidad
   ld l, e
   
   inc hl
   inc hl
   ld a, [posY]
   ld [hl], a              ; Actualizamos la posición Y de la entidad
   inc hl
   ld a, [posX]
   ld [hl], a              ; Actualizamos la posición X de la entidad
   ret











undo_movement:

   ld a, [entity_array + 5]
   cp 2
   jr z, .comprobarIzquierda


   ld a, [entity_array + 5]
   cp 1
   jr z, .comprobarDerecha

   ld a, [entity_array + 4]
   cp 1
   jr z, .comprobarAbajo

   cp 2
   jr z, .comprobarArriba

   ret
;--------------------------------------------------------------------------------
;--------------------------------Izquierda----------------------------------------
;--------------------------------------------------------------------------------
   .comprobarIzquierda  
   ld hl, $FF43
   ld a, [hl]
   cp 0
   jr z, .max
   cp 72
   jr z, .max
   inc [hl]
   jr .exit

   .max
   ld hl , $c003
   inc [hl]

   jr .exit

;--------------------------------------------------------------------------------
;---------------------------DERECHA----------------------------------------------
;--------------------------------------------------------------------------------

   .comprobarDerecha
   ld hl, $FF43
   ld a, [hl]
   cp 72
   jr z, .maxDerecha
   cp 0
   jr z, .maxDerecha
   dec [hl]
   jr .exit

   .maxDerecha
   ld hl , $c003
   dec [hl]
   jr .exit
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;---------------------------ABAJO----------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
   .comprobarAbajo
   ld hl, $FF42
   ld a, [hl]
   cp 112
   jr z, .maxAbajo
   cp 0
   jr z, .maxAbajo
   dec [hl]
   jr .exit

   .maxAbajo
   ld hl , $c002
   dec [hl]
   jr .exit







   .comprobarArriba
   ld hl, $FF42
   ld a,[hl]
   cp 0
   jr z, .maxArriba
   cp 112
   jr z, .maxArriba
   inc [hl]
   jr .exit

   .maxArriba
   ld hl , $c002
   inc [hl]
   jr .exit



   .exit
   ld hl, entity_array + 4
   ld [hl], 0
   inc hl
   ld [hl], 0

   ld hl, lastBTN
   ld [hl],0
ret


undo_movement_deseado:

   ld a, [velXdes]
   cp 2
   jr z, .comprobarIzquierda


   ld a, [velXdes]
   cp 1
   jr z, .comprobarDerecha

   ld a, [velYdes]
   cp 1
   jr z, .comprobarAbajo

   cp 2
   jr z, .comprobarArriba

   ret
;--------------------------------------------------------------------------------
;--------------------------------Izquierda----------------------------------------
;--------------------------------------------------------------------------------
   .comprobarIzquierda  
   ld hl, $FF43
   ld a, [hl]
   cp 0
   jr z, .max
   cp 72
   jr z, .max
   inc [hl]
   jr .exit

   .max
   ld hl , $c003
   inc [hl]

   jr .exit

;--------------------------------------------------------------------------------
;---------------------------DERECHA----------------------------------------------
;--------------------------------------------------------------------------------

   .comprobarDerecha
   ld hl, $FF43
   ld a, [hl]
   cp 72
   jr z, .maxDerecha
   cp 0
   jr z, .maxDerecha
   dec [hl]
   jr .exit

   .maxDerecha
   ld hl , $c003
   dec [hl]
   jr .exit
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;---------------------------ABAJO----------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
   .comprobarAbajo
   ld hl, $FF42
   ld a, [hl]
   cp 112
   jr z, .maxAbajo
   cp 0
   jr z, .maxAbajo
   dec [hl]
   jr .exit

   .maxAbajo
   ld hl , $c002
   dec [hl]
   jr .exit







   .comprobarArriba
   ld hl, $FF42
   ld a,[hl]
   cp 0
   jr z, .maxArriba
   cp 112
   jr z, .maxArriba
   inc [hl]
   jr .exit

   .maxArriba
   ld hl , $c002
   inc [hl]
   jr .exit



   .exit
  
ret