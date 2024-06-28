%include "macros.asm"

global manejo_archivos

section .data
    mensaje_guardar         db 'Ingrese el nombre del archivo a guardar', 0
    mensaje_cargar          db 'Ingrese el nombre del archivo a cargar', 0
    mensaje_error           db 'Error al abrir el archivo. ¿Quizás fue la extensión?', 0
    modo_leer               db 'rb',0
    modo_escribir           db 'wb',0

section .bss
    direc_tablero                   resq    1
    id_archivo                      resq    1
    nombre_archivo                  resb    50

section .text
manejo_archivos:
    sub rsp,8
    mov [direc_tablero],rsi
    cmp rdi,1
    je  guardar

cargar:
    mPuts   mensaje_cargar
    mGets   nombre_archivo

    mFopen nombre_archivo,modo_leer
    cmp rax,0
    jle error

    mov qword[id_archivo],rax

leer:
    mFread [direc_tablero],150,1,[id_archivo]
    jmp cerrar_archivo

guardar:
    mPuts   mensaje_guardar
    mGets   nombre_archivo

    mFopen nombre_archivo,modo_escribir
    cmp rax,0
    jle error

    mov qword[id_archivo],rax

escribir:
    mFwrite [direc_tablero],150,1,[id_archivo]

cerrar_archivo:
    mFclose [id_archivo]
    jmp fin

error: 
    mPuts   mensaje_error
    mov rax,0
    
fin:
    add rsp,8
    ret
    