%include "macros.asm"

global Actividad_Tablero
extern validador_rango

section .data
    ; relacionado al tablero
    CANT_COL            dq      7
    LONG_ELEMEN         dq      1
    posCol              dq      1
    posFil              dq      1
    
    ;imprimir por pantalla
    espacio                         db      " ",0
    mostrarFicha                     db     " %c ", 0
    textFila                        db      "F",0
    textColumna                     db      "C",0
    mostrarIndicador                db      " %c%li",0
    separadorVertical               db      "|",0
    separadorHorizontal             db      "    ----------------------------",10,0
    separadorHorizontalCortado      db      "           -------------        ",10,0
    saltoLinea                      db      "",10,0

section .bss
    direc_tablero        resq 1
section .text

;rutina externa Actividad_Tablero la cual se encarga de iniciaizar el tablero
    ;y mostrar su estado
    ;parametros: rdi: 1 para inicializar tablero, 2 para mostrar tablero
    ;            rsi: direccion de la matriz que contiene al tablero
    ;            rdx:direccion del caracter del zorro
    ;            rcx: direccion del caracter de la oca
    
Actividad_Tablero:
    sub         rsp,8
    mov         [direc_tablero],rdi
    mov         qword[posFil], 0
    mov         qword[posCol], 0
    
mostrarTablero:    
    cmp         qword[posFil], 0
    je          identificarColumnas

    cmp         qword[posCol], 1
    jg          mostrarPosicion

    mov         rdi, mostrarIndicador
    mov         rsi, [textFila]
    mov         rdx, [posFil]
    mPrintf
    mov         rdi, separadorVertical
    mPrintf

mostrarPosicion:

    buscarPosicion  posFil, posCol, LONG_ELEMEN, CANT_COL
    mov             rdi, mostrarFicha
    mov             r10,[direc_tablero]
    mov             rsi, [r10 + rdx]
    mPrintf

    mov             rdi,[posFil]
    mov             rsi,[posCol]
    call            validador_rango
    
    cmp             rax, 1
    je              separadorColumnas

    cmp             qword[posCol], 2
    je              separadorColumnas

    mov             rdi, espacio
    mPrintf

    jmp             avanzarMostrarTablero

identificarColumnas:
    mov             rdi, mostrarIndicador
    mov             rsi, [textColumna]
    mov             rdx, [posCol]
    mPrintf

separadorColumnas:             
    mov             rdi, separadorVertical
    mPrintf

avanzarMostrarTablero:
    inc         qword[posCol]
    cmp         qword[posCol], 7
    jle         mostrarTablero

    mov         rdi, saltoLinea
    mPrintf

    cmp         qword[posFil], 2
    jl         separadorFilasCortado
    
    cmp         qword[posFil], 6
    jge         separadorFilasCortado

    mov         rdi, separadorHorizontal
    mPrintf

    jmp         avanzarFila

separadorFilasCortado:
    mov         rdi, separadorHorizontalCortado
    mPrintf

avanzarFila:
    mov         qword[posCol], 1
    inc         qword[posFil]

    cmp         qword[posFil], 7
    jle         mostrarTablero

fin:
    add         rsp,8
    ret