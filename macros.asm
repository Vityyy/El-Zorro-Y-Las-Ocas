%macro mPuts 1
    mov rdi,%1
    sub rsp,8
    call puts
    add rsp,8
%endmacro

%macro mGets 1
    mov rdi,%1
    sub rsp,8
    call gets
    add rsp,8
%endmacro

%macro mPrintf 0
    sub  rsp, 8
    call printf
    add  rsp, 8
%endmacro

%macro mSscanf 3
    mov rdi,%1
    mov rsi,%2
    mov rdx,%3

    sub rsp,8
    call sscanf
    add rsp,8
%endmacro

%macro mSystem 1
    mov rdi,%1
    sub rsp,8
    call system
    add rsp,8
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
%macro mCMPSB 3
    ;   %1 ->    direccion del string origen
    ;   %2 ->    direccion del string destino
    ;   %3 ->    bytes a comparar
    xor         rsi, rsi
    xor         rdi, rdi

    mov         rsi, %1
    mov         rdi, %2
    mov         rcx, %3
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


extern puts,gets,system,sscanf,printf