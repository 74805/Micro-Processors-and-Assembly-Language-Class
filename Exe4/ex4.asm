.model small

.data

.stack 100h
.code

Print_Screen_Black proc uses ax bx cx dx
    mov ah, 06h   ; Function to clear the screen and set attribute
    xor al, al
    mov cx, 0     ; Starting row, column (0,0)
    mov dx, 184Fh ; Ending row, column (79, 24)
    mov bh, 0   ; Attribute for black background

    int 10h       ; Call BIOS video service

    ret
Print_Screen_Black endp

Print_Symbol proc
    ; Print red 'o' in the middle of the screen as the symbol

Print_Symbol endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    call Print_Screen_Black

    call Print_Symbol

    .exit
end START