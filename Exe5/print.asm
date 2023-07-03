.model small

.data
    sentence db "The quick brown fox jumps over the lazy dog$"
    speed dw 0FFh

.stack 100h
.code
extern Change_IVT:near

; Prints the sentence, one character at a time, with a 1 second delay between each character, and background color changing every 4 characters
Print_Sentence proc uses ax bx cx dx di si
    ; Set up the cursor
    mov dh, 12
    mov dl, 20
    mov ah, 02h
    mov bh, 0
    int 10h

    mov si, offset sentence
    mov di, offset speed
    mov dh, 0 ; counter
    mov bl, 8h
    Loop1:
        ; Move cursor
        inc dl
        push dx
        mov dh, 12
        mov ah, 02h
        int 10h
        pop dx

        ; Print a character
        mov al, [si]
        cmp al, '$'
        je Print_Sentence_end

        mov ah, 09h
        mov cx, 1
        int 10h

        inc si
        inc dh

        ; Switch background color every 4 characters
        cmp dh, 4
        jne Wait_One_Second
        add bl, 10h
        and bl, 07Fh ; Make text not blink
        mov dh, 0

        Wait_One_Second:
            push dx
            mov dx, [di]

            Delay_Loop:
                dec dx
                mov cx, 1700h

                mov ah, 01h
                int 16h
                jz Delay_Inner

                mov ah, 00h
                int 16h

                cmp al, 'w'
                je Fast

                cmp al, 's'
                je Slow

                cmp al, 'p'
                je Stop

                Delay_Inner:
                    dec cx
                    jnz Delay_Inner
                cmp dx, 0
                jnz Delay_Loop
            
            pop dx
            jmp Loop1

            Fast:
                ; Make printing twice as fast
                mov ax, [di]

                ; Check if speed is maximum
                cmp ax, 1
                je Delay_Inner

                shr dx, 1
                shr ax, 1 
                mov [di], ax
                jmp Delay_Inner

            Slow:
                ; Make printing twice as slow
                mov ax, [di]

                ; Check if speed is minimum
                and ax, 8000h
                cmp ax, 8000h
                je Min_Speed

                mov ax, [di]
                shl ax, 1
                mov [di], ax
                shl dx, 1
                jmp Delay_Inner
                
                Min_Speed:
                    mov [di], 0FFFFh
                    mov dx, 0FFFFh
                    jmp Delay_Inner

            Stop:
                ; Wait for another 'p'
                Loop3:
                    mov ah, 01h
                    int 16h
                    jz Loop3

                    mov ah, 00h
                    int 16h

                    cmp al, 'p'
                    jne Loop3

                    jmp Delay_Inner
                


    Print_Sentence_end:
        ret
Print_Sentence endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    mov bx, offset Print
    jmp Change_IVT

    Print:
        call Print_Sentence
	
    .exit
end