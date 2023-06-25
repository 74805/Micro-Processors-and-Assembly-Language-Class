.model small

.data
    sentence db "The quick brown fox jumps over the lazy dog$"

.stack 100h
.code

Print_Sentence proc uses ax dx
    mov dx, offset sentence
    mov ah, 09h
    int 21h
    ret
Print_Sentence endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    call Print_Sentence

	
    .exit
end START