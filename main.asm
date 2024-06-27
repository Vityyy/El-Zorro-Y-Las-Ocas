%include "macros.asm"

global          main
extern          mostrarMenu,configuracion_tablero,Actividad_Tablero,jugar_zorro,validador_formato,jugar_ocas,condicion_de_fin,validador_rango

section         .data
    ; system
    cdm_clear           db      "clear",0             

    ; relacionado al tablero
    tablero_default             db      "  OOO    OOO  OOOOOOOO     OO  X  O              ",0 
    CANT_COL            dq      7
    LONG_ELEMEN         dq      1
    posCol_zorro        dq      4
    posFil_zorro        dq      5
    fila_aux            dq      1
    columna_aux            dq      1


    ; relacionado al juego
    zorro               db      "X",0
    ocas                db      "O",0
    formato             db      "%li",0
    kills               dq       0
    mensaje_gana_zorro  db      "¡El zorro gana! ¿Quieres volver a jugar? [-1 = salir]",0
    mensaje_ganan_ocas  db      "Las ocas ganan! ¿Quieres volver a jugar? [-1 = salir]",0
    mensaje_Final       db      "Saliendo del programa. Gracias por jugar.",0

section         .bss
    tablero         times 50        resb    1
    volver_a_jugar                  resb    1
    eleccion                        resq    1

    ;configuracion del Juego
section         .text
main:
    mSystem  cdm_clear

    sub         rsp,8
    ;rutina externa que maneja la funcionalidad del menu
    ;devuelve el resultado de la opcion escogida en el rax (numero)
    call        mostrarMenu
    add         rsp,8

    cmp         rax,2
    je          llamar_configuracion

    _movsb tablero_default,tablero,0,50

gameplay:
    mSystem cdm_clear

    mov         rdi,tablero
    sub         rsp, 8
    call        Actividad_Tablero
    add         rsp, 8

    mov         rdi,tablero
    mov         rsi,zorro
    mov         rdx,posFil_zorro
    mov         rcx,posCol_zorro
    sub         rsp,8
    call        jugar_zorro
    add         rsp,8

    cmp rax,-1
    je end_game


    cmp rbx,1
    je aumentar_score
    
    mSystem cdm_clear
    
    mov         rdi,tablero
    sub         rsp, 8
    call        Actividad_Tablero
    add         rsp, 8

    mov         rdi,tablero
    mov         rsi,ocas
    sub         rsp,8
    call        jugar_ocas
    add         rsp,8

    cmp rax,-1
    je end_game

    jmp corroborar_acorralamiento

aumentar_score:
    inc qword[kills]
    cmp qword[kills],12
    je  gana_zorro
    jmp gameplay

corroborar_acorralamiento:
    mov rdi,tablero
    mov rsi,[posFil_zorro]
    mov rdx,[posCol_zorro]
    sub rsp,8
    call condicion_de_fin
    add rsp,8

    cmp rax,1
    je  gameplay
    
    jmp ganan_ocas

llamar_configuracion:
    mov     rdi,tablero_default
    mov     rsi,zorro
    mov     rdx,ocas

    sub     rsp,8
    call    configuracion_tablero
    add     rsp,8

    jmp     main

gana_zorro:
    mPuts mensaje_gana_zorro
    jmp jugar_de_nuevo?

ganan_ocas:
    mPuts mensaje_ganan_ocas

jugar_de_nuevo?:
    mGets volver_a_jugar
    mSscanf volver_a_jugar,formato,eleccion
    cmp rax,1
    jl  main
    cmp qword[eleccion],-1
    jne main

end_game:
    mSystem cdm_clear
    mPuts mensaje_Final
    ;fin de programa
    ret