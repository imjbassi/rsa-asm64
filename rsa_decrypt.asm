; rsa_decrypt.asm
section .text
global rsa_decrypt
extern modexp

; uint64_t rsa_decrypt(uint64_t c, uint64_t d, uint64_t n)
rsa_decrypt:
    ; Parameters are already in the right registers:
    ; rdi = c (ciphertext), rsi = d (private key), rdx = n (modulus)
    call modexp
    ret
