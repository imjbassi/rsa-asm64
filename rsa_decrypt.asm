; rsa_decrypt.asm — decryption wrapper
section .text
global rsa_decrypt
extern modexp

; uint64_t rsa_decrypt(uint64_t c, uint64_t d, uint64_t n)
; m = c^d mod n. Arguments are already in the registers modexp
; expects, so this is a pure tail call.
rsa_decrypt:
    jmp modexp

section .note.GNU-stack noalloc noexec nowrite progbits
