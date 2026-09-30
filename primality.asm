; primality.asm — deterministic Miller-Rabin primality test for 64-bit integers
section .rodata
; Testing against these 12 witnesses is a proven deterministic primality
; test for every n < 3,317,044,064,679,887,385,961,981 — which covers all
; of uint64_t (Sorenson & Webster, 2015).
witnesses:  dq 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37
NUM_WITNESSES equ 12

section .text
global is_prime
extern modexp, mod_mul

; uint64_t is_prime(uint64_t n)
; Returns 1 if n is prime, 0 otherwise.
is_prime:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16         ; [rsp] = inner squaring counter; keeps rsp 16-aligned

    mov rbx, rdi        ; rbx = n

    ; Small cases: 0 and 1 are not prime; 2 and 3 are; other evens are not.
    cmp rbx, 2
    jb .composite
    je .prime
    cmp rbx, 3
    je .prime
    test rbx, 1
    jz .composite

    mov r12, rbx
    dec r12             ; r12 = n - 1

    ; Write n - 1 = odd_part * 2^s
    mov r13, r12        ; r13 = odd_part
    xor r14d, r14d      ; r14 = s
.factor_out_twos:
    test r13, 1
    jnz .witnesses_start
    shr r13, 1
    inc r14
    jmp .factor_out_twos

.witnesses_start:
    xor r15d, r15d      ; r15 = witness index

.witness_loop:
    cmp r15, NUM_WITNESSES
    jae .prime          ; survived every witness -> prime

    lea rax, [rel witnesses]
    mov rdi, [rax + r15*8]
    cmp rdi, rbx        ; witness >= n can only happen for tiny n, where the
    jae .next_witness   ;   smaller witnesses already decide -> just skip it

    ; x = witness^odd_part mod n
    mov rsi, r13
    mov rdx, rbx
    call modexp

    cmp rax, 1          ; x == 1 -> this witness passes
    je .next_witness
    cmp rax, r12        ; x == n-1 -> this witness passes
    je .next_witness

    ; Square x up to s-1 times looking for n-1
    mov rcx, r14
    dec rcx
    jz .composite       ; s == 1 and x wasn't ±1 -> composite
    mov [rsp], rcx
.square_loop:
    mov rdi, rax        ; x = mod_mul(x, x, n)
    mov rsi, rax
    mov rdx, rbx
    call mod_mul
    cmp rax, r12        ; hit n-1 -> this witness passes
    je .next_witness
    cmp rax, 1          ; hit 1 without passing n-1 -> nontrivial sqrt of 1
    je .composite
    dec qword [rsp]
    jnz .square_loop
    jmp .composite      ; never reached n-1 -> composite

.next_witness:
    inc r15
    jmp .witness_loop

.prime:
    mov eax, 1
    jmp .epilogue
.composite:
    xor eax, eax
.epilogue:
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
