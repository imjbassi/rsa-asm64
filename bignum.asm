; bignum.asm — modular multiplication
section .text
global mod_mul

; uint64_t mod_mul(uint64_t a, uint64_t b, uint64_t m)
; Returns (a * b) % m.
; Requires a < m and b < m so the 128-bit product's quotient fits in 64 bits
; (otherwise DIV would fault). Requires m != 0.
mod_mul:
    push rbx
    mov rbx, rdx    ; rbx = m (save before MUL clobbers rdx)
    mov rax, rdi    ; rax = a
    mul rsi         ; rdx:rax = a * b (full 128-bit product)
    div rbx         ; rax = quotient, rdx = remainder
    mov rax, rdx    ; return the remainder
    pop rbx
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
