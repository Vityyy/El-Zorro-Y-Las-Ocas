%include "macros.asm"
global jugar_ocas
extern validador_formato

section .data
    CANT_COL              dq  7
    LONG_ELEMEN           dq  1

section .bss
    fila_aux                resq 1
    columna_aux             resq 1
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
    je  fin_turno
    mov [fila],rdi
    mov [columna],rsi
    
validar_posicion:
    buscarPosicion fila,columna,LONG_ELEMEN,CANT_COL
    mov rdi,[direc_tablero]
    mov rsi, [rdi + rdx]
    mCMPSB rsi,[direc_caracter_ocas],1
    jne seleccion

    mov r10,[fila]
    mov [fila_aux],r10

    mov r12,[columna]
    mov [columna_aux],r13
    dec qword [columna_aux]
    
ver_columnas:

    ver que no este fuera

    buscarPosicion fila_aux,columna_aux,LONG_ELEMEN,CANT_COL
    mov rdi,[direc_tablero]
    mov rsi,[rdi + rdx]
    mCMPSB rsi,espacio,1
    je posicion_validada

mover_columna:
    add qword [columna_aux], 2
    mov rdi,[columna_aux]
    sub rdi,r10
    cmp rdi,1
    jg  ver_columnas





    

validar_movimiento:
    




fin_turno:
    ret
