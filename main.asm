; main.asm — driver: parse arguments, generate keys, round-trip a message
global main
global p, q, e, n, d, phi, message, ciphertext
extern rsa_keygen, rsa_encrypt, rsa_decrypt
extern printf, fprintf, strtoull, stderr

section .data
; Defaults: the classic textbook example (n = 3233, d = 2753, c = 2790).
; Override on the command line: ./rsa <p> <q> <e> <message>
p:            dq 61
q:            dq 53
e:            dq 17
n:            dq 0
d:            dq 0
phi:          dq 0
message:      dq 65
ciphertext:   dq 0

section .rodata
fmt_pq:       db "p = %llu, q = %llu", 10, 0
fmt_n:        db "n   = %llu", 10, 0
fmt_phi:      db "phi = %llu", 10, 0
fmt_e:        db "e   = %llu", 10, 0
fmt_d:        db "d   = %llu", 10, 0
fmt_msg:      db "message    = %llu", 10, 0
fmt_ct:       db "ciphertext = %llu", 10, 0
fmt_rec:      db "recovered  = %llu", 10, 0
str_ok:       db "round-trip OK", 10, 0

fmt_usage:    db "usage: %s [p q e message]", 10, 0
err_p:        db "error: p (%llu) is not prime", 10, 0
err_q:        db "error: q (%llu) is not prime", 10, 0
err_pq:       db "error: p and q must be distinct primes", 10, 0
err_ovf:      db "error: p * q overflows 64 bits", 10, 0
err_e:        db "error: e (%llu) is not coprime with phi (%llu)", 10, 0
err_range:    db "error: message (%llu) must be smaller than n (%llu)", 10, 0
err_rt:       db "error: round-trip FAILED (got %llu, expected %llu)", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp
    push r12
    push r13            ; rsp is now 16-aligned at every call site below

    mov r12d, edi       ; argc
    mov r13, rsi        ; argv

    ; ./rsa            -> use the built-in defaults
    ; ./rsa p q e msg  -> take all four from the command line
    cmp r12, 1
    je .args_done
    cmp r12, 5
    jne .usage

    mov rdi, [r13 + 8]
    call parse_u64
    mov [rel p], rax

    mov rdi, [r13 + 16]
    call parse_u64
    mov [rel q], rax

    mov rdi, [r13 + 24]
    call parse_u64
    mov [rel e], rax

    mov rdi, [r13 + 32]
    call parse_u64
    mov [rel message], rax

.args_done:
    call rsa_keygen
    test rax, rax
    jnz .keygen_error

    ; textbook RSA can only carry messages in [0, n)
    mov rax, [rel message]
    cmp rax, [rel n]
    jae .range_error

    ; ---- print parameters ----
    lea rdi, [rel fmt_pq]
    mov rsi, [rel p]
    mov rdx, [rel q]
    xor eax, eax
    call printf

    lea rdi, [rel fmt_n]
    mov rsi, [rel n]
    xor eax, eax
    call printf

    lea rdi, [rel fmt_phi]
    mov rsi, [rel phi]
    xor eax, eax
    call printf

    lea rdi, [rel fmt_e]
    mov rsi, [rel e]
    xor eax, eax
    call printf

    lea rdi, [rel fmt_d]
    mov rsi, [rel d]
    xor eax, eax
    call printf

    lea rdi, [rel fmt_msg]
    mov rsi, [rel message]
    xor eax, eax
    call printf

    ; ---- encrypt ----
    mov rdi, [rel message]
    mov rsi, [rel e]
    mov rdx, [rel n]
    call rsa_encrypt
    mov [rel ciphertext], rax

    lea rdi, [rel fmt_ct]
    mov rsi, [rel ciphertext]
    xor eax, eax
    call printf

    ; ---- decrypt ----
    mov rdi, [rel ciphertext]
    mov rsi, [rel d]
    mov rdx, [rel n]
    call rsa_decrypt
    mov r12, rax        ; r12 = recovered plaintext (callee-saved)

    lea rdi, [rel fmt_rec]
    mov rsi, r12
    xor eax, eax
    call printf

    ; ---- verify ----
    cmp r12, [rel message]
    jne .roundtrip_error

    lea rdi, [rel str_ok]
    xor eax, eax
    call printf

    xor eax, eax
.exit:
    pop r13
    pop r12
    pop rbp
    ret

; ---- error paths (messages to stderr, nonzero exit) ----

.usage:
    mov rdi, [rel stderr]
    lea rsi, [rel fmt_usage]
    mov rdx, [r13]      ; argv[0]
    xor eax, eax
    call fprintf
    mov eax, 2
    jmp .exit

.keygen_error:
    cmp eax, 1
    je .kg_p
    cmp eax, 2
    je .kg_q
    cmp eax, 3
    je .kg_pq
    cmp eax, 4
    je .kg_ovf
    ; code 5: e not coprime with phi
    mov rdi, [rel stderr]
    lea rsi, [rel err_e]
    mov rdx, [rel e]
    mov rcx, [rel phi]
    xor eax, eax
    call fprintf
    jmp .fail
.kg_p:
    mov rdi, [rel stderr]
    lea rsi, [rel err_p]
    mov rdx, [rel p]
    xor eax, eax
    call fprintf
    jmp .fail
.kg_q:
    mov rdi, [rel stderr]
    lea rsi, [rel err_q]
    mov rdx, [rel q]
    xor eax, eax
    call fprintf
    jmp .fail
.kg_pq:
    mov rdi, [rel stderr]
    lea rsi, [rel err_pq]
    xor eax, eax
    call fprintf
    jmp .fail
.kg_ovf:
    mov rdi, [rel stderr]
    lea rsi, [rel err_ovf]
    xor eax, eax
    call fprintf
    jmp .fail

.range_error:
    mov rdi, [rel stderr]
    lea rsi, [rel err_range]
    mov rdx, [rel message]
    mov rcx, [rel n]
    xor eax, eax
    call fprintf
    jmp .fail

.roundtrip_error:
    mov rdi, [rel stderr]
    lea rsi, [rel err_rt]
    mov rdx, r12
    mov rcx, [rel message]
    xor eax, eax
    call fprintf

.fail:
    mov eax, 1
    jmp .exit

; uint64_t parse_u64(const char *s) — strtoull(s, NULL, 10) as a tail call
parse_u64:
    xor esi, esi
    mov edx, 10
    jmp strtoull

section .note.GNU-stack noalloc noexec nowrite progbits
