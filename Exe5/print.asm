.model small

.data
    sentence db "The quick brown fox jumps over the lazy dog$"
    speed dw 0F000h

.stack 100h
.code

; Prints the sentence, one character at a time, with a 1 second delay between each character, and background color changing every 4 characters
Print_Sentence proc uses ax bx cx dx di si
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
            mov di, offset speed
            mov dx, [di]

            Delay_Loop:
                dec dx
                mov cx, 20d

                mov ah, 01h
                int 16h
                jz Delay_Inner

                mov ah, 00h
                int 16h

                cmp al, 'w'
                ;je Poll_Keyboard_end

                cmp al, 's'
                ;je Poll_Keyboard_end

                cmp al, 'p'
                ;je Stop

                Delay_Inner:
                    dec cx
                    jnz Delay_Inner
                cmp dx, 0
                jnz Delay_Loop
            pop dx

                
        jmp Loop1

    Print_Sentence_end:
        ret
Print_Sentence endp

; Poll_Keyboard proc uses ax si
;     mov si, offset speed
;     mov cx, [si]
;     Loop3:
;         dec cx

;         mov ah, 01h
;         int 16h
;         jz Check_cx

;         mov ah, 00h
;         int 16h

;         cmp al, 'w'
;         je Poll_Keyboard_end

;         cmp al, 's'
;         je Poll_Keyboard_end

;         cmp al, 'p'
;         je Stop
        
;         Check_cx:
;             cmp cx, 0
;             jne Loop3
;             ret

;     Fast:


;     Slow:


;     Stop:
;         ; Wait for another 'p'
;         Loop4:
;             mov ah, 01h
;             int 16h
;             jz Loop4

;             mov ah, 00h
;             int 16h

;             cmp al, 'p'
;             jne Loop4

;     Poll_Keyboard_end:
;         ret
; Poll_Keyboard endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    call Print_Sentence

	
    .exit
end START