; bignum.asm
section .text
global mod_mul

; uint64_t mod_mul(uint64_t a, uint64_t b, uint64_t m)
; returns (a*b) % m
mod_mul:
    push rbx
    mov rbx, rdx    ; rbx = m (modulus) - save BEFORE any operations
    mov rax, rdi    ; rax = a
    mul rsi         ; rdx:rax = a*b (128-bit result)
    
    ; Now divide rdx:rax by rbx
    div rbx         ; rax = quotient, rdx = remainder
    
    mov rax, rdx    ; return remainder
    pop rbx
    ret
