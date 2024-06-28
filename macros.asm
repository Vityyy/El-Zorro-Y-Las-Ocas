%macro mPuts 1
    mov rdi,%1
    call puts
%endmacro

%macro mGets 1
    mov rdi,%1
    call gets
%endmacro

%macro mPrintf 0
    call printf
%endmacro

%macro mSscanf 3
    mov rdi,%1
    mov rsi,%2
    mov rdx,%3
    call sscanf
%endmacro

%macro mSystem 1
    mov rdi,%1
    call system
%endmacro

%macro mFopen 2
    mov rdi,%1
    mov rsi,%2
    call fopen
%endmacro

%macro mFclose 1
    mov rdi,%1
    call fclose
%endmacro

%macro mFread 4
    mov rdi,%1
    mov rsi,%2
    mov rdx,%3
    mov rcx,%4
    call fread
%endmacro

%macro mFwrite 4
    mov rdi,%1
    mov rsi,%2
    mov rdx,%3
    mov rcx,%4
    call fwrite
    
%endmacro

%macro      _movsb      4
    ;   %1 ->    direccion del string origen
    ;   %2 ->    direccion del string destino
    ;   %3 ->    desplazamiento, en caso de querer cambiar algo en el tablero 0, en cualquier otro caso
    ;   %4 ->    bytes a copiar
    
    xor         rsi, rsi
    xor         rdi, rdi
    
    mov         rsi, %1
    mov         rdi, %2
    add         rdi, %3
    mov         rcx, %4
    rep     movsb

%endmacro
;
%macro mCMPSB 4
    ;   %1 ->    direccion del string origen
    ;   %2 ->    direccion del string destino
    ;   %3 ->    desplazamiento,en caso de querer comparar a partir de un byte en particular
    ;   %4 ->    bytes a comparar
    xor         rsi, rsi
    xor         rdi, rdi

    mov         rsi, %1
    mov         rdi, %2
    add         rdi, %3
    mov         rcx, %4
    repe        cmpsb

%endmacro

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

%macro contar_direccion 4
    ; %1 = fil
    ; %2 = col
    ; %3 = longElemento
    ; %4 = cantCol
    mov         rax, %1
    add         rax,2
    mov         r8,%4
    imul        r8
    add         rdx, rax

    mov         rcx, rdx

    mov         rax, %2
    add         rax,2
    mov         r8,%3
    imul        r8
    add         rdx, rax
    
    add         rdx, rcx
%endmacro



extern puts,gets,system,sscanf,printf, fopen, fclose, fread, fwrite