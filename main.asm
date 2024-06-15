%macro      buscarPosicion 4
    ; %1 = fil
    ; %2 = col
    ; %3 = longElemento
    ; %4 = cantCol
    mov         rax, [%1]
    dec         rax
    imul        qword[%4]
    add         rdx, rax

    mov         rcx, rdx

    mov         rax, [%2]
    dec         rax
    imul        qword[%3]
    add         rdx, rax
    
    add         rdx, rcx

    ; deja el desplazamiento en el rdx
%endmacro

%macro      mGets 0
    sub         rsp, 8
    call        gets
    add         rsp, 8
%endmacro

%macro      mPrintf 0
    sub         rsp, 8
    call        printf
    add         rsp, 8
%endmacro

%macro      mSystem 0
    sub     rsp, 8
    call    system
    add     rsp, 8
%endmacro

%macro      mPuts 0 
    sub     rsp, 8
    call    puts
    add     rsp, 8
%endmacro

%macro      _movsb      3
    ;   %1 ->    direccion del string origen
    ;   %2 ->    direccion del string destino
    ;   %3 ->    desplazamiento, en caso de querer cambiar algo en el tablero
    ;           0, en cualquier otro caso
    sub         rsi, rsi
    sub         rdi, rdi

    mov         rsi, %1
    mov         rdi, %2
    add         rdi, %3
    mov         rcx, 1
    rep     movsb

%endmacro

%macro      validarFicha    3
    ;   1 ->    direccion de la ficha ingresada por el usuario
    ;   2 ->    direccion del espacio en blanco (" ")
    ;   3 ->    direccion del vacio ("")
    
    ;La macro deja en el rbx:
    ;   - 0 si la ficha es válida
    ;   - 1 si la ficha es inválida

    mov         rdi, %1
    mov         rsi, %2
    mov         rcx, 1
    repe    cmpsb
    je          fichaInvalida

    mov         rdi, %1
    mov         rsi, %3
    mov         rcx, 1
    repe    cmpsb
    je          fichaInvalida

    ; la ficha es válida
    mov         rbx, 0
    jmp         finMacro

fichaInvalida:
    mov         rbx, 1
finMacro:
%endmacro
global          main

extern          printf,system,gets,puts
extern          mostrarMenu

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
    textConfiguracion           db      "Deseas configurar la partida (s/n): ",0
    textConfiguracionZorro      db      "Escriba el caracter con el que quiere representar al zorro: ",0
    textConfiguracionOcas       db      "Escriba el caracter con el que quiere representar las ocas: ",0
    textConfiguracionTablero    db      "Elija la orientacion en la que quiere ver el tablero: ",0
    respuestaAfirmativa         db      "s"
    respuestaNegativa           db      "n"

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
    eleccionConfiguracion           resb    50      
    configuracionZorro              resb    50
    configuracionOcas               resb    50
    configuracionTablero            resb    50       

section         .text
main:
    sub         rsp,8
    ;rutina externa que maneja la funcionalidad del menu
    ;devuelve el resultado de la opcion escogida en el rax (numero)
    call        mostrarMenu
    add         rsp,8

    sub         rsp, 8
    call        configuracion
    add         rsp, 8

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
    jle          ponerOcas

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

    jmp         avanzarInicializacion

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

    ret

;**********************************************************************
;**********************************************************************

configuracion:
    ; limpio la pantalla
    mov         rdi, cdm_clear
    mSystem

    ; Pregunto al usuario si quiere configurar el juego
    mov         rdi, textConfiguracion
    mPuts
    mov         rdi, eleccionConfiguracion
    mGets

    mov         rdi, eleccionConfiguracion
    mov         rsi, respuestaNegativa
    mov         rcx, 1
    repe cmpsb
    je          finConfiguracion

    mov         rdi, eleccionConfiguracion
    mov         rsi, respuestaAfirmativa
    mov         rcx, 1
    repe    cmpsb
    jne         configuracion

    ; El usuario quiere cambiar la configuracion
    ; CONFIGURACION DEL ZORRO
configurarZorro:
    ; limpio la pantalla
    mov         rdi, cdm_clear
    mSystem

    mov         rdi, textConfiguracionZorro
    mPuts
    mov         rdi, configuracionZorro
    mGets

    ;verifico que lo que puso el usuario no sea un espacio (" ")
    mov         rdi, configuracionZorro
    mov         rsi, espacio
    mov         rcx, 1
    repe    cmpsb
    je          configurarZorro

    ;verifico que lo que puso el usuario no sea un vacío ("")
    mov         rdi, configuracionZorro
    mov         rsi, vacio
    mov         rcx, 1
    repe    cmpsb
    je          configurarZorro


    ; cambio la ficha del zorro a la nueva
    mov         rsi, configuracionZorro
    mov         rdi, zorro
    mov         rcx, 1
    rep     movsb
    

    ;CONFIGURACION DE LAS OCAS
configurarOcas:
    mov         rdi, cdm_clear
    mSystem

    mov         rdi, textConfiguracionOcas
    mPuts
    mov         rdi, configuracionOcas
    mGets

    ;verifico que lo que puso el usuario no sea un espacio (" ")
    mov         rdi, configuracionOcas
    mov         rsi, espacio
    mov         rcx, 1
    repe    cmpsb
    je          configurarOcas

    ;verifico que lo que puso el usuario no sea un vacío ("")
    mov         rdi, configuracionOcas
    mov         rsi, vacio
    mov         rcx, 1
    repe    cmpsb
    je          configurarOcas

    ;verifico que lo ingresado por el usuario no es igual al Zorro
    mov         rdi, configuracionOcas
    mov         rsi, zorro
    mov         rcx, 1
    repe    cmpsb
    je          configurarOcas

    mov         rsi, configuracionOcas
    mov         rdi, ocas
    mov         rcx, 1
    rep     movsb

configurarTablero:

finConfiguracion:
    ret