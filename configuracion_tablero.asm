%include "macros.asm"

global configuracion_tablero

section .data
    LONG_ELEMEN                 dq      1
    CANT_COL                    dq      7
    cdm_clear                   db      "clear",0
    textConfiguracion           db      "Deseas configurar la partida (s/n): ",0
    textConfiguracionZorro      db      "Escriba el caracter con el que quiere representar al zorro: ",0
    textConfiguracionOcas       db      "Escriba el caracter con el que quiere representar las ocas: ",0
    respuestaAfirmativa         db      "s",0
    respuestaNegativa           db      "n",0
    espacio                     db      " ",0
    vacio                       db      "",0
    fila                        dq      1
    columna                     dq      1

section .bss
    eleccionConfiguracion           resb    50      
    configuracion                   resb    50
    zorro                           resb    1
    ocas                            resb    1
    direc_caracter_ocas             resq    1
    direc_caracter_zorro            resq    1
    direc_tablero                   resq    1

section .text
configuracion_tablero:
    sub rsp,8
    mov [direc_tablero],rdi
    mov [direc_caracter_zorro],rsi
    mov [direc_caracter_ocas],rdx

inicio:
    ; limpio la pantalla
    mSystem cdm_clear

    ; Pregunto al usuario si quiere configurar el juego
    mPuts   textConfiguracion
    mGets   eleccionConfiguracion

    mCMPSB respuestaNegativa,eleccionConfiguracion,0,2
    je          sin_cambios

    mCMPSB eleccionConfiguracion,respuestaAfirmativa,0,2
    jne         inicio

    ; El usuario quiere cambiar la configuracion
    ; CONFIGURACION DEL ZORRO
configurarZorro:
    ; limpio la pantalla
    mSystem cdm_clear

    mPuts   textConfiguracionZorro
    mGets   configuracion

    ; sub     rsp,8
    call validar_input
    ; add     rsp,8

    cmp     rax,-1
    je      configurarZorro

    _movsb  configuracion,zorro,0,1

;CONFIGURACION DE LAS OCAS
configurarOcas:
    mSystem cdm_clear

    mPuts   textConfiguracionOcas
    mGets   configuracion

    ; sub     rsp,8
    call validar_input
    ; add     rsp,8

    cmp     rax,-1
    je      configurarOcas

    ;caso particular para que los simbolos de ambos no sean iguales
    mCMPSB configuracion, zorro, 0, 1
    je          configurarOcas

    _movsb configuracion, ocas, 0, 1

modificar_tablero:
    buscarPosicion fila,columna,LONG_ELEMEN,CANT_COL
    mCMPSB [direc_caracter_zorro],[direc_tablero],rdx,1
    je modificar_caracter_zorro

    mCMPSB [direc_caracter_ocas],[direc_tablero],rdx,1
    je modificar_caracter_ocas

    jmp mover_columna

modificar_caracter_zorro:
    _movsb zorro,[direc_tablero],rdx,1
    _movsb zorro,[direc_caracter_zorro],0,1
    jmp mover_columna

modificar_caracter_ocas:
    _movsb ocas,[direc_tablero],rdx,1

mover_columna:
    inc qword[columna]   
    cmp qword[columna],8
    jl  modificar_tablero
    mov qword[columna],1

mover_fila:
    inc qword[fila]
    cmp qword[fila],8
    jl  modificar_tablero

    _movsb ocas,[direc_caracter_ocas],0,1
    jmp finConfiguracion

sin_cambios:
    mov     r10,-1

finConfiguracion:
    add rsp,8
    ret
;**********************************************************************

validar_input:
    mov     rax,-1

    mov     bl,byte[configuracion+1]
    cmp     bl,0
    jne     fin_validacion

    ;verifico que lo que puso el usuario no sea un espacio (" ")
    mCMPSB espacio, configuracion, 0, 1
    je          fin_validacion

    ;verifico que lo que puso el usuario no sea un vacío ("")
    mCMPSB vacio, configuracion, 0, 1
    je          fin_validacion

input_valido:
    mov     rax,1

fin_validacion:
    ret