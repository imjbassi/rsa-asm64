; modexp.asm
section .text
global modexp
extern mod_mul

; uint64_t modexp(uint64_t base, uint64_t exp, uint64_t m)
; returns (base^exp) % m
modexp:
    push rbx
    push r12
    push r13            ; Add this to save exponent
    mov r12, rdx        ; r12 = m (preserved across calls)
    mov r13, rsi        ; r13 = exp (preserved across calls)
    mov rax, 1          ; result = 1
    mov rbx, rdi        ; rbx = base

    ; Handle special case: if exp == 0, return 1
    test r13, r13
    jz .done

.loop:
    test r13, 1         ; Check if exponent is odd
    jz .skip_mul
    
    ; result = (result * base) % m
    mov rdi, rax        ; a = result
    mov rsi, rbx        ; b = base  
    mov rdx, r12        ; m
    call mod_mul        ; This was corrupting rsi!

.skip_mul:
    shr r13, 1          ; exp = exp / 2 (use r13 instead of rsi)
    jz .done            ; If exp becomes 0, we're done
    
    ; base = (base * base) % m
    mov rdi, rbx        ; a = base
    mov rsi, rbx        ; b = base
    mov rdx, r12        ; m
    call mod_mul
    mov rbx, rax        ; Update base
    
    jmp .loop

.done:
    pop r13             ; Restore saved registers
    pop r12
    pop rbx
    ret
