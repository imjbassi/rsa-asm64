; main.asm
global main
global p, q, e, n, d, message, ciphertext
extern rsa_keygen, rsa_encrypt, rsa_decrypt, printf

section .data
p:            dq 7         ; Change to different primes
q:            dq 11        ; 
e:            dq 3         ; Different exponent
n:            dq 0
d:            dq 0
message:      dq 5         ; Different message
ciphertext:   dq 0

fmt_n:        db "n = %llu",   10, 0
fmt_d:        db "d = %llu",   10, 0
fmt_msg:      db "Original message: %llu", 10, 0
fmt_enc_hdr:  db "Encrypting with e=%llu, n=%llu", 10, 0
fmt_enc:      db "Ciphertext: %llu", 10, 0
fmt_dec:      db "Plaintext: %llu",  10, 0
fmt_debug:    db "Debug: %llu", 10, 0

section .text
main:
    ; Key generation
    call rsa_keygen

    ; Print n, d, and message
    xor rax, rax
    mov rdi, fmt_n
    mov rsi, [rel n]
    call printf

    xor rax, rax
    mov rdi, fmt_d
    mov rsi, [rel d]
    call printf

    xor rax, rax
    mov rdi, fmt_msg
    mov rsi, [rel message]
    call printf

    ; Header
    xor rax, rax
    mov rdi, fmt_enc_hdr
    mov rsi, [rel e]
    mov rdx, [rel n]
    call printf

    ; Encrypt
    mov rdi, [rel message]
    mov rsi, [rel e]
    mov rdx, [rel n]
    call rsa_encrypt
    mov [rel ciphertext], rax  ; Save ciphertext to variable

    ; Print ciphertext
    xor rax, rax
    mov rdi, fmt_enc
    mov rsi, [rel ciphertext]
    call printf

    ; Decrypt
    mov rdi, [rel ciphertext]
    mov rsi, [rel d]
    mov rdx, [rel n]
    
    ; Debug before decrypt
    push rdi
    push rsi
    push rdx
    xor rax, rax
    mov rdi, fmt_debug
    mov rsi, [rel d]
    call printf
    pop rdx
    pop rsi
    pop rdi
    
    call rsa_decrypt
    mov r12, rax        ; Save decrypted plaintext

    ; Print decrypted plaintext
    xor rax, rax
    mov rdi, fmt_dec
    mov rsi, r12        ; Print decrypted plaintext
    call printf
    ret

; Silence “executable stack” warning for this TU
section .note.GNU-stack noalloc noexec nowrite progbits
