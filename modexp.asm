; modexp.asm — fast modular exponentiation (square-and-multiply)
section .text
global modexp
extern mod_mul

; uint64_t modexp(uint64_t base, uint64_t exp, uint64_t m)
; Returns (base ^ exp) % m. Requires m != 0.
; The base is reduced mod m up front, so callers may pass base >= m.
modexp:
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdx        ; r12 = m      (callee-saved, survives mod_mul calls)
    mov r13, rsi        ; r13 = exp
    mov r14, 1          ; r14 = result (must be callee-saved: mod_mul returns
                        ;               in rax, so rax can't hold it across the
                        ;               squaring call)

    ; base %= m, so every mod_mul sees operands < m
    mov rax, rdi
    xor edx, edx
    div r12
    mov rbx, rdx        ; rbx = base mod m

    test r13, r13
    jz .done            ; exp == 0 -> 1

.loop:
    test r13, 1         ; low bit set -> multiply result by base
    jz .skip_mul

    mov rdi, r14        ; result = mod_mul(result, base, m)
    mov rsi, rbx
    mov rdx, r12
    call mod_mul
    mov r14, rax

.skip_mul:
    shr r13, 1          ; exp >>= 1
    jz .done            ; no bits left -> done

    mov rdi, rbx        ; base = mod_mul(base, base, m)
    mov rsi, rbx
    mov rdx, r12
    call mod_mul
    mov rbx, rax

    jmp .loop

.done:
    mov rax, r14
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
