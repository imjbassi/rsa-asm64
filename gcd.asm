; gcd.asm
section .text
global extended_gcd, modinv

; Extended Euclidean Algorithm
; Input: rdi = a, rsi = b
; Output: rax = gcd(a,b), rbx = x, rcx = y such that ax + by = gcd(a,b)
extended_gcd:
    push r8
    push r9
    push r10
    push r11
    
    ; Initialize: we want gcd(a,b) and coefficients x,y such that ax + by = gcd
    mov r8, rdi         ; r8 = a (old_r)
    mov r9, rsi         ; r9 = b (r)
    mov r10, 1          ; r10 = old_s = 1
    mov r11, 0          ; r11 = s = 0
    
.loop:
    test r9, r9         ; while r != 0
    jz .done
    
    ; quotient = old_r / r
    mov rax, r8         ; rax = old_r
    xor rdx, rdx        ; clear rdx
    div r9              ; rax = quotient, rdx = remainder
    
    ; temp = r
    push r9
    
    ; r = old_r - quotient * r = remainder
    mov r9, rdx
    
    ; old_r = temp
    pop r8
    
    ; temp = s
    push r11
    
    ; s = old_s - quotient * s
    imul rax, r11       ; rax = quotient * s
    mov r11, r10        ; s = old_s
    sub r11, rax        ; s = old_s - quotient * s
    
    ; old_s = temp
    pop r10
    
    jmp .loop
    
.done:
    mov rax, r8         ; gcd = old_r
    mov rbx, r10        ; x = old_s
    mov rcx, 0          ; y = 0 (we don't need y for modular inverse)
    
    pop r11
    pop r10
    pop r9
    pop r8
    ret

; uint64_t modinv(uint64_t a, uint64_t m)
modinv:
    push rbx
    push r12
    push r13
    
    mov r12, rdi        ; save a
    mov r13, rsi        ; save m
    
    call extended_gcd   ; rax = gcd, rbx = x
    
    cmp rax, 1          ; if gcd != 1, no inverse
    jne .no_inv
    
    mov rax, rbx        ; x is the inverse
    
    ; Normalize to [0, m-1]
    test rax, rax
    jns .positive
    
.negative:
    add rax, r13
    test rax, rax
    js .negative
    
.positive:
    cmp rax, r13
    jl .done
    sub rax, r13
    jmp .positive
    
.done:
    pop r13
    pop r12
    pop rbx
    ret
    
.no_inv:
    xor rax, rax
    jmp .done
