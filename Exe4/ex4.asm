.model small

.data
	rows db 25
	columns db 80

	last_location db 0

.stack 100h
.code

Print_Screen_Black proc uses ax bx cx dx
    mov ah, 06h ; Function to clear the screen and set attribute
    xor al, al
    mov cx, 0 ; Starting row, column (0,0)

	; Set the ending row and column (24, 79)
	mov dh, rows
	mov dl, columns
	dec dh
	dec dl
    mov bh, 0 ; Attribute for black background

    int 10h ; Call BIOS video service

    ret
Print_Screen_Black endp

Print_Symbol proc uses ax bx cx dx di
    ; Print red 'o' in the middle of the screen as the symbol
    mov bx, 80 ; Number of columns
    shr bx, 1 ; Divide by 2
    mov ax, 25 ; Number of rows
    shr ax, 1 ; Divide by 2 to get half of the rows
	mov cx, 160 ; Number of bytes per row
    mul cx 
	
    xor di, di
	add di, ax ; Add the offset for half of the rows
	add di, 80 ; Add the offset for half of the columns

    ; Print 'O' with red foreground color on black background
    mov byte ptr es:[di], 'O'
    mov byte ptr es:[di + 1], 4h ; Attribute for red foreground color on black background

	mov last_location, di

    ret
Print_Symbol endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

	; Set extra segment to screen
	mov bx, 0B800h
	mov es, bx

    call Print_Screen_Black

    call Print_Symbol

    .exit
end START