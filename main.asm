%include "macros.asm"

global          main
extern          mostrarMenu,configuracion_tablero,Actividad_Tablero,jugar_zorro,validador_formato,jugar_ocas,condicion_de_fin,validador_rango, manejo_archivos

section         .data
    ; system
    cdm_clear           db      "clear",0             

    ; relacionado al tablero
    tablero_default             db      "  OOO    OOO  OOOOOOOO     OO  X  O              " 
    tablero            times 49 db " "
    zorro                       db      "X"
    ocas                        db      "O"
    posCol_zorro                dq       4
    posFil_zorro                dq       5
    kills                       dq       0
    movimientos        times 16 db       0      
    turno                       db       0

    CANT_COL            dq      7
    LONG_ELEMEN         dq      1

    ; relacionado al juego
    formato               db      "%li",0
   
    mensaje_gana_zorro    db      "¡El zorro gana! ¿Quieres volver a jugar? [-1 = salir]",0
    mensaje_ganan_ocas    db      "¡Las ocas ganan! ¿Quieres volver a jugar? [-1 = salir]",0
    mensaje_Final         db      "Saliendo del programa. Gracias por jugar.",0

section         .bss
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

    cmp         rax,3
    je          cargar

    cmp         rax,2
    je          llamar_configuracion

    _movsb tablero_default,tablero,0,49
    mov qword[posFil_zorro],5
    mov qword[posCol_zorro],4

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

    cmp rax,-2
    je guardar

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

    cmp rax,-2
    je guardar

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

cargar:
    mov rdi,0
    mov rsi,tablero_default
    sub rsp,8
    call manejo_archivos
    add rsp,8
    jmp gameplay

guardar:
    mov rdi,1
    mov rsi,tablero_default
    sub rsp,8
    call manejo_archivos
    add rsp,8
    jmp end_game

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