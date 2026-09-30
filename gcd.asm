; gcd.asm — extended Euclidean algorithm and modular inverse
section .text
global extended_gcd, modinv

; Extended Euclidean algorithm.
; Input:  rdi = a, rsi = b
; Output: rax = gcd(a, b), rdx = x with a*x + b*y == gcd(a, b)
;         (x is in two's complement; the y coefficient is not computed
;          because modinv doesn't need it)
; Clobbers rcx, r8-r11 only; rdi/rsi are left untouched.
extended_gcd:
    mov r8, rdi         ; r8  = old_r = a
    mov r9, rsi         ; r9  = r     = b
    mov r10, 1          ; r10 = old_s = 1
    xor r11d, r11d      ; r11 = s     = 0

.loop:
    test r9, r9         ; while r != 0
    jz .done

    mov rax, r8         ; quotient = old_r / r, remainder in rdx
    xor edx, edx
    div r9

    mov r8, r9          ; (old_r, r) = (r, old_r mod r)
    mov r9, rdx

    imul rax, r11       ; (old_s, s) = (s, old_s - quotient * s)
    mov rcx, r10
    sub rcx, rax
    mov r10, r11
    mov r11, rcx

    jmp .loop

.done:
    mov rax, r8         ; gcd = old_r
    mov rdx, r10        ; x   = old_s
    ret

; uint64_t modinv(uint64_t a, uint64_t m)
; Returns a^-1 mod m in [0, m), or 0 when gcd(a, m) != 1 (no inverse).
modinv:
    ; extended_gcd preserves rdi/rsi, so m stays in rsi across the call
    call extended_gcd
    cmp rax, 1          ; no inverse unless gcd(a, m) == 1
    jne .no_inv

    ; Normalize x into [0, m). At termination |x| <= m/2, so a single
    ; conditional add suffices, and the sign-bit test is valid even for
    ; m > 2^63 (a genuinely positive x is always < 2^63).
    mov rax, rdx
    test rax, rax
    jns .done
    add rax, rsi
.done:
    ret

.no_inv:
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
