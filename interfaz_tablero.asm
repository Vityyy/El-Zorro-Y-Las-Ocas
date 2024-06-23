%include "macros.asm"
global Actividad_Tablero

section .data
    ; relacionado al tablero
    CANT_COL            dq      7
    LONG_ELEMEN         dq      1
    posCol              dq      1
    posFil              dq      1
    orientacionTablero  dq      2
    contadorAux         dq      0

    ;imprimir por pantalla
    espacio                         db      " ",0
    vacio                           db      "",0
    mostrarFicha                    db      " %c ", 0
    textFila                        db      "F",0
    textColumna                     db      "C",0
    mostrarIndicador                db      " %c%li",0
    separadorVertical               db      "|",0
    separadorHorizontal             db      "    ----------------------------",10,0
    separadorHorizontalCortado      db      "           -------------        ",10,0
    saltoLinea                      db      "",10,0

    ;posicion inicial del Zorro
    zorroPosColInicial        dq      4
    zorroPosFilInicial        dq      5

section .bss
    direc_tablero               resq 1
    direc_caracter_zorro        resq 1
    direc_caracter_ocas         resq 1

section .text
;rutina externa Actividad_Tablero la cual se encarga de iniciaizar el tablero
    ;y mostrar su estado
    ;parametros: rdi: 1 para inicializar tablero, 2 para mostrar tablero
    ;            rsi: direccion de la matriz que contiene al tablero
    ;            rdx:direccion del caracter del zorro
    ;            rcx: direccion del caracter de la oca
    
Actividad_Tablero:
    mov [direc_tablero],rsi
    mov [direc_caracter_zorro],rdx
    mov [direc_caracter_ocas],rcx

    cmp rdi,1
    je inicializarTablero

    mov         qword[posFil], 0
    mov         qword[posCol], 0
    jmp iniciar_mostrarTablero

inicializarTablero:
    ;subrutina que deja el tablero en su estdo inicial
    
ubicarOcas:
    ;UBICO LAS OCAS

    sub             rsp, 8
    call            validarPosicion
    add             rsp, 8
    
    ;si rbx = 1 significa que la posicion está fuera del rango del tablero
    cmp         rbx, 1
    je          espacioVacio

    cmp         qword[posFil], 3
    jle         ponerOcas

    cmp         qword[posFil], 5
    jle         ocasEnEsquinas

espacioVacio:
    buscarPosicion      posFil, posCol, LONG_ELEMEN, CANT_COL

    _movsb      espacio, [direc_tablero], rdx, 1   

    jmp         avanzarInicializacion

ocasEnEsquinas:
    cmp         qword[posCol],1
    je          ponerOcas

    cmp         qword[posCol], 7
    je          ponerOcas

    jmp         espacioVacio

ponerOcas:
    buscarPosicion      posFil, posCol, LONG_ELEMEN, CANT_COL

    _movsb      [direc_caracter_ocas], [direc_tablero], rdx, 1

avanzarInicializacion:
    inc         qword[posCol]
    cmp         qword[posCol], 7
    jle         ubicarOcas

    mov         qword[posCol], 1

    inc         qword[posFil]    
    cmp         qword[posFil], 7
    jle         ubicarOcas

    mov         qword[posFil], 1

    buscarPosicion     zorroPosFilInicial, zorroPosColInicial, LONG_ELEMEN, CANT_COL

    _movsb      [direc_caracter_zorro], [direc_tablero], rdx, 1
    
    ;return de inicializacion
    jmp         fin

;**********************************************************************
   
iniciar_mostrarTablero:     
    ; veo la posible orientacion de las filas
    cmp         qword[orientacionTablero], 2
    jle         orientacion_vertical

orientacion_horizontal:
    cmp         qword[orientacionTablero], 3
    je          mostrarTablero

    mov         qword[posFil], 8
    jmp         mostrarTablero

orientacion_vertical:
    cmp         qword[orientacionTablero], 1
    je          mostrarTablero

    mov         qword[posFil], 8

mostrarTablero:    
    cmp             qword[posFil], 0
    je              identificarColumnas

    cmp             qword[posFil], 8
    je              identificarColumnas

    cmp             qword[posCol], 1
    jg              mostrarPosicion

    mov         rdi, mostrarIndicador
    mov         rsi, [textFila]
    mov         rdx, [posFil]
    mPrintf
    mov         rdi, separadorVertical
    mPrintf

mostrarPosicion:

    buscarPosicion      posFil, posCol, LONG_ELEMEN, CANT_COL
    mov             rdi, mostrarFicha
    mov             r10,[direc_tablero]
    mov             rsi, [r10 + rdx]
    mPrintf

    sub             rsp, 8
    call            validarPosicion
    add             rsp, 8
    
    cmp             rbx, 0
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

    cmp         qword[contadorAux], 2
    jl         separadorFilasCortado
    
    cmp         qword[contadorAux], 6
    jge         separadorFilasCortado

    mov         rdi, separadorHorizontal
    mPrintf

    jmp         avanzarFila

separadorFilasCortado:
    mov         rdi, separadorHorizontalCortado
    mPrintf

avanzarFila:
    inc         qword[contadorAux]
    mov         qword[posCol], 1

    cmp         qword[orientacionTablero], 2
    je          decrementarFila

    inc         qword[posFil]
    cmp         qword[posFil], 7
    jle         mostrarTablero

    jmp         fin
decrementarFila:
    dec         qword[posFil]
    cmp         qword[posFil],1
    jge         mostrarTablero
    ; return de mostrarTablero
    jmp         fin

;***************************************************************************

validarPosicion:
    ; guarda en el rdx:
    ; -> 1 en caso de que la posicion no sea válida
    ; -> 0 en caso de que sea válida

    cmp         qword[posFil], 7
    jg          invalido

    cmp         qword[posCol], 7
    jg          invalido

    cmp         qword[posCol], 3
    jl          filaCortada

    cmp         qword[posCol], 5
    jg          filaCortada

    jmp         valido

filaCortada:
    cmp         qword[posFil], 3
    jl          invalido

    cmp         qword[posFil], 5
    jg          invalido

    jmp         valido
invalido:
    mov         rbx, 1
    jmp         finValidacion

valido:
    mov         rbx, 0
    jmp         finValidacion

finValidacion:
    ;return de validacion
    ret

fin:
    ret