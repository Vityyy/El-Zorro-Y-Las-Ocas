%include "macros.asm"

global configuracion_tablero

section .data
    cdm_clear                   db      "clear",0
    textConfiguracion           db      "Deseas configurar la partida (s/n): ",0
    textConfiguracionZorro      db      "Escriba el caracter con el que quiere representar al zorro: ",0
    textConfiguracionOcas       db      "Escriba el caracter con el que quiere representar las ocas: ",0
    respuestaAfirmativa         db      "s"
    respuestaNegativa           db      "n"
    espacio                     db      " ",0
    vacio                       db      "",0

section .bss
    eleccionConfiguracion           resb    50      
    configuracion                   resb    50
    zorro                           resb    1
    ocas                            resb    1

section .text
configuracion_tablero:
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
    repe        cmpsb
    je          Sin_cambios

    mov         rdi, eleccionConfiguracion
    mov         rsi, respuestaAfirmativa
    mov         rcx, 1
    repe        cmpsb
    jne         configuracion_tablero

    ; El usuario quiere cambiar la configuracion
    ; CONFIGURACION DEL ZORRO
configurarZorro:
    ; limpio la pantalla
    mov         rdi, cdm_clear
    mSystem

    mov         rdi, textConfiguracionZorro
    mPuts
    mov         rdi, configuracion
    mGets

    sub     rsp,8
    call validar_input
    add     rsp,8

    cmp     rax,-1
    je      configurarZorro

    mov         rsi, configuracion
    mov         rdi, zorro
    mov         rcx, 1
    rep         movsb

;CONFIGURACION DE LAS OCAS
configurarOcas:
    mov         rdi, cdm_clear
    mSystem

    mov         rdi, textConfiguracionOcas
    mPuts
    mov         rdi, configuracion
    mGets

    sub     rsp,8
    call validar_input
    add     rsp,8

    cmp     rax,-1
    je      configurarOcas

    ;caso particular para que los simbolos de ambos no sean iguales
    mov         rdi, configuracion
    mov         rsi, zorro
    mov         rcx, 1
    repe        cmpsb
    je          configurarOcas

    mov         rsi, configuracion
    mov         rdi, ocas
    mov         rcx, 1
    rep         movsb
    jmp         finConfiguracion

validar_input:
    mov     rax,-1
    mov     bl,byte[configuracion+1]
    cmp     bl,0
    jne     fin_validacion

    ;verifico que lo que puso el usuario no sea un espacio (" ")
    mov         rdi, configuracion
    mov         rsi, espacio
    mov         rcx, 1
    repe        cmpsb
    je          fin_validacion

    ;verifico que lo que puso el usuario no sea un vacío ("")
    mov         rdi, configuracion
    mov         rsi, vacio
    mov         rcx, 1
    repe        cmpsb
    je          fin_validacion

input_valido:
    mov     rax,1

fin_validacion:
    ret

Sin_cambios:
    mov     r8,-1

finConfiguracion:
    lea     rax,[zorro]
    lea     rbx,[ocas]
    ret