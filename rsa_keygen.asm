; rsa_keygen.asm
section .data
fmt_debug:    db "Debug phi: %llu", 10, 0

section .text
global rsa_keygen
extern modinv
extern p, q, e, n, d
extern printf

; void rsa_keygen()
rsa_keygen:
    ; n = p * q
    mov rax, [rel p]
    mov rbx, [rel q]
    mul rbx
    mov [rel n], rax

    ; phi = (p-1)*(q-1)
    mov rax, [rel p]
    sub rax, 1
    mov rbx, [rel q]
    sub rbx, 1
    mul rbx
    mov rcx, rax      ; rcx = phi

    ; Print phi
    push rcx          ; Save phi
    mov rdi, fmt_debug
    mov rsi, rcx      ; phi value
    xor rax, rax
    call printf
    pop rcx           ; Restore phi

    ; d = modinv(e, phi)
    mov rdi, [rel e]
    mov rsi, rcx
    call modinv
    mov [rel d], rax

    ret
