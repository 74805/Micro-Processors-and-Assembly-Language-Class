.model small

.data
    sentence db "The quick brown fox jumps over the lazy dog$"

.stack 100h
.code

; Prints the sentence, one character at a time, with a 1 second delay between each character
Print_Sentence proc uses ax bx cx dx si
    ; Set up the cursor
    mov dh, 12
    mov dl, 30
    mov ah, 02h
    mov bh, 0
    int 10h

    mov si, offset sentence
    mov bl, 0Fh
    Loop1:
        ; Print a character
        mov al, [si]
        cmp al, '$'
        je Print_Sentence_end

        mov ah, 09h
        mov cx, 1
        int 10h

        inc si

        ; Move cursor
        inc dl
        mov ah, 02h
        int 10h

        ; Wait 1 second
        mov cx, 0FFFFh
        Loop2:
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            push [si]
            
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            pop [si]
            loop Loop2
            
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