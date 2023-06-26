.model small

.data
    sentence db "The quick brown fox jumps over the lazy dog$"

.stack 100h
.code

; Prints the sentence, one character at a time, with a 1 second delay between each character, and background color changing every 4 characters
Print_Sentence proc uses ax bx cx dx si
    ; Set up the cursor
    mov dh, 12
    mov dl, 20
    mov ah, 02h
    mov bh, 0
    int 10h

    mov si, offset sentence
    mov dh, 0 ; counter
    mov bl, 8h
    Loop1:
        ; Print a character
        mov al, [si]
        cmp al, '$'
        je Print_Sentence_end

        mov ah, 09h
        mov cx, 1
        int 10h

        inc si
        inc dh
        add di, 2

        ; Move cursor
        inc dl
        push dx
        mov dh, 12
        mov ah, 02h
        int 10h
        pop dx

        ; Switch background color every 4 characters
        cmp dh, 4
        jne Wait_One_Second
        add bl, 10h
        and bl, 07Fh ; Make text not blink
        mov dh, 0

        Wait_One_Second:
            push dx
            mov dx, 1500
            Delay_Loop:
                mov cx, 1000
                Delay_Inner:
                    dec cx
                    jnz Delay_Inner
                dec dx
                jnz Delay_Loop
            pop dx
                
        jmp Loop1

    Print_Sentence_end:
        ret
Print_Sentence endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    call Print_Sentence

	
    .exit
end START