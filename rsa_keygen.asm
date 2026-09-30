; rsa_keygen.asm — RSA key generation with input validation
section .text
global rsa_keygen
extern modinv, is_prime
extern p, q, e, n, d, phi

; uint64_t rsa_keygen(void)
; Reads the globals p, q, e; on success writes n, phi, d and returns 0.
; Error codes:
;   1  p is not prime
;   2  q is not prime
;   3  p == q
;   4  p * q overflows 64 bits
;   5  e is not coprime with phi (no modular inverse exists)
rsa_keygen:
    push rbp
    mov rbp, rsp
    push r12
    push r13            ; two pushes + rbp keep rsp 16-aligned at call sites

    mov r12, [rel p]
    mov r13, [rel q]

    ; validate: p prime, q prime, p != q
    mov rdi, r12
    call is_prime
    test rax, rax
    jz .err_p_not_prime

    mov rdi, r13
    call is_prime
    test rax, rax
    jz .err_q_not_prime

    cmp r12, r13
    je .err_p_eq_q

    ; n = p * q (must fit in 64 bits)
    mov rax, r12
    mul r13
    test rdx, rdx
    jnz .err_overflow
    mov [rel n], rax

    ; phi = (p-1) * (q-1)  (fits: it's <= n, which fit)
    lea rax, [r12 - 1]
    lea rcx, [r13 - 1]
    mul rcx
    mov [rel phi], rax

    ; d = modinv(e, phi); 0 means gcd(e, phi) != 1
    mov rdi, [rel e]
    mov rsi, rax
    call modinv
    test rax, rax
    jz .err_e_not_coprime
    mov [rel d], rax

    xor eax, eax
    jmp .done

.err_p_not_prime:
    mov eax, 1
    jmp .done
.err_q_not_prime:
    mov eax, 2
    jmp .done
.err_p_eq_q:
    mov eax, 3
    jmp .done
.err_overflow:
    mov eax, 4
    jmp .done
.err_e_not_coprime:
    mov eax, 5

.done:
    pop r13
    pop r12
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
