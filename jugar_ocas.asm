%include "macros.asm"
global jugar_ocas
extern validador_formato

section .data
    CANT_COL              dq  7
    LONG_ELEMEN           dq  1
    espacio               db " ",0
    mensaje_invalido      db "Movimiento ingresado invalido, intente nuevamente",0

section .bss
    fila_origen             resq 1
    columna_origen          resq 1
    fila_destino            resq 1
    columna_destino         resq 1
    direc_caracter_ocas     resq 1
    direc_tablero           resq 1
    
section .text

jugar_ocas:

    mov [direc_tablero],rdi
    mov [direc_caracter_ocas],rsi

seleccion:
    mov rdi,1
    sub rsp,8
    call validador_formato
    add rsp,8

    cmp rax,-1
    jle  fin_turno

    mov [fila_destino],rdi
    mov [columna_destino],rsi
    mov [fila_origen],rdx
    mov [columna_origen],rcx
    
validar_existencia_oca:
    buscarPosicion fila_origen,columna_origen,LONG_ELEMEN,CANT_COL
    mCMPSB [direc_caracter_ocas],[direc_tablero],rdx,1
    jne input_invalido

    ; reviso si el destino es un espacio vacío
    buscarPosicion fila_destino,columna_destino,LONG_ELEMEN,CANT_COL
    mCMPSB espacio,[direc_tablero],rdx,1
    jne input_invalido

validar_movimiento_permitido:
    mov r8,[fila_destino]
    sub r8,[fila_origen]
    cmp r8,1
    je  validar_mov_vertical
    cmp r8,0
    je  validar_mov_horizontal

    jmp input_invalido

validar_mov_vertical:
    mov r9,[columna_destino]
    sub r9,[columna_origen]
    cmp r9,0
    je  mover_oca

    jmp input_invalido
    
validar_mov_horizontal:
    mov r9,[columna_destino]
    sub r9,[columna_origen]
    cmp r9,1
    je  mover_oca
    cmp r9,-1
    je  mover_oca

    jmp input_invalido

input_invalido:
    mPuts mensaje_invalido
    jmp seleccion

mover_oca:
    buscarPosicion fila_destino,columna_destino,LONG_ELEMEN,CANT_COL
    _movsb [direc_caracter_ocas], [direc_tablero], rdx, 1

borrar_posicion_anterior:
    buscarPosicion fila_origen,columna_origen,LONG_ELEMEN,CANT_COL
    _movsb espacio,[direc_tablero],rdx,1
    
fin_turno:
    ret
