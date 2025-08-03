; rsa_encrypt.asm - make sure parameters are passed correctly
section .text
global rsa_encrypt
extern modexp

; uint64_t rsa_encrypt(uint64_t msg, uint64_t e, uint64_t n)
rsa_encrypt:
    ; Parameters are already in the right registers:
    ; rdi = msg, rsi = e, rdx = n
    call modexp
    ret
