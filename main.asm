%include "macros.asm"

global          main
extern          mostrarMenu,configuracion_tablero,Actividad_Tablero

section         .data
    ; system
    cdm_clear           db      "clear",0             

    ; relacionado al tablero
    CANT_COL            dq      7
    LONG_ELEMEN         dq      1
    posCol              dq      1
    posFil              dq      1

    ; relacionado al juego
    zorro               db      "X",0
    ocas                db      "O",0

section         .bss
    tablero         times 49        resb    1

    ;configuracion del Juego
section         .text
main:
    mov         rdi, cdm_clear
    mSystem  

    sub         rsp,8
    ;rutina externa que maneja la funcionalidad del menu
    ;devuelve el resultado de la opcion escogida en el rax (numero)
    call        mostrarMenu
    add         rsp,8

    cmp         rax,2
    je          llamar_configuracion

    mov         rdi, cdm_clear
    mSystem

    ;rutina externa Actividad_Tablero la cual se encarga de iniciaizar el tablero
    ;y mostrar su estado
    ;parametros: rdi: 1 para inicializar tablero, 2 para mostrar tablero
    ;            rsi: direccion de la matriz que contiene al tablero
    ;            rdx:direccion del caracter del zorro
    ;            rcx: direccion del caracter de la oca
    mov         rdi,1
    mov         rsi,tablero
    lea         rdx,[zorro]
    lea         rcx,[ocas]
    sub         rsp, 8
    call        Actividad_Tablero
    add         rsp, 8

    mov         rdi,2
    mov         rsi,tablero
    lea         rdx,[zorro]
    lea         rcx,[ocas]
    sub         rsp, 8
    call        Actividad_Tablero
    add         rsp, 8

    ; return del main
    ret

;**********************************************************************

llamar_configuracion:
    sub     rsp,8
    ;Rutina externa que deja los nuevo caracteres en el rax y rbx
    ;Si el R8 es -1, no se realizaron cambios
    call    configuracion_tablero
    add     rsp,8

    cmp     r8,-1
    je      main

    mov     rdi,zorro
    mov     rsi,rax
    mov     rcx,1
    rep     movsb

    mov     rdi,ocas
    mov     rsi,rbx
    mov     rcx,1
    rep     movsb

    jmp     main