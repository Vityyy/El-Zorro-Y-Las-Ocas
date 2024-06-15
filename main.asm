%include "macros.asm"

global          main
extern          mostrarMenu,configuracion_tablero

section         .data
    ; system
    cdm_clear           db      "clear",0             

    ; relacionado al tablero
    CANT_COL            dq      7
    LONG_ELEMEN         dq      1
    posCol              dq      1
    posFil              dq      1

    ; relacionado al juego
    ;zorro
    zorro               db      "X"
    zorroPosCol         dq      4
    zorroPosFil         dq      5
    
    ;ocas
    ocas                db      "O"

    ;Textos de configuracion
    
    textConfiguracionTablero    db      "Elija la orientacion en la que quiere ver el tablero: ",0
    

    ; imprimir por pantalla
    espacio                         db      " ",0
    vacio                           db      "",0
    ficha                           db      " %c ", 0
    separadorVertical               db      "|",0
    separadorHorizontal             db      "----------------------------",10,0
    separadorHorizontalCortado      db      "       -------------        ",10,0
    saltoLinea                      db      "",10,0

section         .bss
    tablero         times 49        resb    1

    ;configuracion del Juego
section         .text
main:
    sub         rsp,8
    ;rutina externa que maneja la funcionalidad del menu
    ;devuelve el resultado de la opcion escogida en el rax (numero)
    call        mostrarMenu
    add         rsp,8

    cmp     rax,2
    je      llamar_configuracion

    mov         rdi, cdm_clear
    mSystem

    sub         rsp, 8
    call        inicializarTablero
    add         rsp, 8

    mov         qword[posFil], 0
    mov         qword[posCol], 1

    sub         rsp, 8
    call        mostrarTablero
    add         rsp, 8
    
    ; return del main
    ret
;**************************************************************************************************
inicializarTablero:
    ;subrutina que deja el tablero en su estdo inicial
    
ubicarOcas:
    ;UBICO LAS OCAS

    sub         rsp, 8
    call        validarPosicion
    add         rsp, 8

    ;si rbx = 1 significa que la posicion está fuera del rango del tablero
    cmp         rbx, 1
    je          espacioVacio

    cmp         qword[posFil],3
    jle         ponerOcas

    cmp         qword[posFil], 5
    jle         ocasEnEsquinas

espacioVacio:
    buscarPosicion      posFil, posCol, LONG_ELEMEN, CANT_COL

    _movsb      espacio, tablero, rdx    

    jmp         avanzarInicializacion

ocasEnEsquinas:
    cmp         qword[posCol],1
    je          ponerOcas

    cmp         qword[posCol], 7
    je          ponerOcas

    jmp         espacioVacio

ponerOcas:
    buscarPosicion      posFil, posCol, LONG_ELEMEN, CANT_COL

    _movsb      ocas, tablero, rdx

avanzarInicializacion:
    inc         qword[posCol]
    cmp         qword[posCol], 7
    jle         ubicarOcas

    mov         qword[posCol], 1

    inc         qword[posFil]    
    cmp         qword[posFil], 7
    jle         ubicarOcas

    mov         qword[posFil], 1

    buscarPosicion      zorroPosFil, zorroPosCol, LONG_ELEMEN, CANT_COL

    _movsb      zorro, tablero, rdx 
    
    ;return de inicializacion
    ret


;********************************************************
;********************************************************  

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

;**********************************************************************
;**********************************************************************

mostrarTablero:
    cmp             qword[posFil], 0
    je              separadorFilasCortado

    buscarPosicion      posFil, posCol, LONG_ELEMEN, CANT_COL
    mov             rdi, ficha
    mov             rsi, [tablero + rdx]
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

separadorColumnas:             
    mov             rdi, separadorVertical
    mPrintf

avanzarMostrarTablero:
    inc         qword[posCol]
    cmp         qword[posCol], 7
    jle          mostrarTablero

    mov         rdi, saltoLinea
    mPrintf

    cmp         qword[posFil], 1
    jle         separadorFilasCortado
    
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
    ; return de mostrarTablero
    ret

;**********************************************************************

llamar_configuracion:
    sub     rsp,8
    ;Rutina externa que deja los nuevo caracteres en el rax y rbx
    ;Si el R8 es -1, no se realizaron cambios
    call    configuracion_tablero
    add     rsp,8

    cmp     r8,-1
    je     main

    mov     rdi,zorro
    mov     rsi,rax
    mov     rcx,1
    rep     movsb

    mov     rdi,ocas
    mov     rsi,rbx
    mov     rcx,1
    rep     movsb

    jmp     main

    