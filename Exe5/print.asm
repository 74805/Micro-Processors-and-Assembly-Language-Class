.model small

.data
    sentence db "The quick brown fox jumps over the lazy dog$"

.stack 100h
.code

Print_Sentence proc uses ax si cx
    ; Every second print one character
    mov si, offset sentence
    Loop1:
        ; Print a character
        

        ; Delay for 1 second
        ; cmp - 3 cycles
        ; loop - 17 cycles
        ; (20 cycles * 800ns per cycle * 0F424h) = 1 second
        mov cx, 0F424h
        Loop2:
            cmp cx, 0
            loop Loop2

    ret
Print_Sentence endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    call Print_Sentence

	
    .exit
end START