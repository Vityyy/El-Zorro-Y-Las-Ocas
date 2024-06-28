%include "macros.asm"

global          main
extern          mostrarMenu,configuracion_tablero,Actividad_Tablero,jugar_zorro,validador_formato,jugar_ocas,condicion_de_fin,validador_rango, manejo_archivos

section         .data
    cdm_clear           db      "clear",0             

    ; relacionado al tablero
    ; contador_mov_default        db 0,-1,0,-1,0,-1,0,0,0,-1,0,0,-1,0,0,-1,0,0,0,-1,0,-1,0,-1,0
    tablero_default             db      "  OOO    OOO  OOOOOOOO     OO  X  O              " 
    tablero            times 49 db " "
    zorro                       db      "X"
    ocas                        db      "O"
    posCol_zorro                dq       4
    posFil_zorro                dq       5
    kills                       dq       0
    movimientos        times 25 db       0      
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
    sub         rsp,8
inicio:
    mSystem  cdm_clear

    call        mostrarMenu

    cmp         rax,3
    je          cargar

    cmp         rax,2
    je          llamar_configuracion

    ; _movsb contador_mov_default,movimientos,0,25
    _movsb tablero_default,tablero,0,49
    mov qword[kills],0
    mov qword[posFil_zorro],5
    mov qword[posCol_zorro],4

gameplay:
    cmp byte[turno],0
    jne turno_ocas

turno_zorro:
    mSystem cdm_clear

    mov         rdi,tablero
    call        Actividad_Tablero

    mov         rdi,tablero
    mov         rsi,zorro
    mov         rdx,posFil_zorro
    mov         rcx,posCol_zorro
    call        jugar_zorro

    cmp rax,-1
    je end_game

    cmp rax,-2
    je guardar

    cmp rbx,1
    je aumentar_score
    
    mov byte[turno],1

turno_ocas:
    mSystem cdm_clear
    
    mov         rdi,tablero
    call        Actividad_Tablero

    mov         rdi,tablero
    mov         rsi,ocas
    call        jugar_ocas

    cmp rax,-1
    je end_game

    cmp rax,-2
    je guardar

    mov byte[turno],0
    jmp corroborar_acorralamiento

aumentar_score:
    inc qword[kills]
    cmp qword[kills],12
    je  gana_zorro
    jmp turno_zorro

corroborar_acorralamiento:
    mov rdi,tablero
    mov rsi,[posFil_zorro]
    mov rdx,[posCol_zorro]
    call condicion_de_fin

    cmp rax,1
    je  turno_zorro
    
    jmp ganan_ocas

llamar_configuracion:
    mov     rdi,tablero_default
    mov     rsi,zorro
    mov     rdx,ocas
    call    configuracion_tablero
    jmp     inicio

cargar:
    mov rdi,0
    mov rsi,tablero_default
    call manejo_archivos
    jmp gameplay

guardar:
    mov rdi,1
    mov rsi,tablero_default
    call manejo_archivos
    jmp gameplay

gana_zorro:
    mPuts mensaje_gana_zorro
    jmp jugar_de_nuevo?

ganan_ocas:
    mPuts mensaje_ganan_ocas

jugar_de_nuevo?:
    mGets volver_a_jugar
    mSscanf volver_a_jugar,formato,eleccion
    cmp rax,1
    jl  inicio
    cmp qword[eleccion],-1
    jne inicio

end_game:
    mSystem cdm_clear
    mPuts mensaje_Final
    ;fin de programa
    add rsp,8
    ret