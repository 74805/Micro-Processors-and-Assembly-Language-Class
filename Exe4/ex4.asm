.model small

.data
	rows db 25
	columns db 80

	last_location dw ?

.stack 1000h
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

Print_Symbol proc uses ax bx cx di
    ; Print red 'o' in the middle of the screen as the symbol
    mov bx, 80 ; Number of columns
    shr bx, 1 ; Divide by 2
    mov ax, 25 ; Number of rows
    shr ax, 1 ; Divide by 2 to get half of the rows
	mov cx, 160 ; Number of bytes per row
    mul cx 
	
    mov di, word ptr columns ; Add the offset for half of the columns (halp of the columns * 2 bytes per column)
	add di, ax ; Add the offset for half of the rows

    mov byte ptr es:[di], 'O'
    mov byte ptr es:[di + 1], 4h ; Attribute for red foreground color on black background

	mov last_location, di

    ret
Print_Symbol endp

Wait_For_Keypress proc uses ax bx dx di
	Loop1:
		in al, 64h
		test al, 01
		jz Loop1

	in al, 60h ; Get keyboard data

	cmp al, 1Eh ; a
	je Move_Left

	cmp al, 20h ; d
	je Move_Right

	cmp al, 11h ; w
	je Move_Up

	cmp al, 1Fh ; s
	je Move_Down

	cmp al, 71h ; q
	je Quit

	jmp Wait_For_Keypress

    Move_Left:
        ; Print the symbol to the left
		mov di, last_location
		
		; Check if the symbol is already at the leftmost column
		mov bl, columns
		add bl, bl
		mov ax, di
		div bl 
		cmp ah, 0 ; Check if the remainder is 0
		je Loop1

		; Move the symbol to the left
		sub di, 2

		jmp Move

    Move_Right:
        ; Print the symbol to the right
        mov di, last_location

        ; Check if the symbol is already at the rightmost column
        mov bl, columns
        add bl, bl
        mov ax, di
        div bl
		sub bl, 2
        cmp ah, bl
        je Loop1

        ; Move the symbol to the right
        add di, 2

        jmp Move

    Move_Up:
        ; Handle the logic for moving up
        jmp Loop1

    Move_Down:
        ; Handle the logic for moving down
        jmp Loop1

	Move:	
		mov byte ptr es:[di], 'O'
		mov byte ptr es:[di + 1], 4h ; Attribute for red foreground color on black background

		; Delete the symbol from the previous location
		mov ax, di
		mov di, last_location
		mov byte ptr es:[di], ' '

		; Update the last location
		mov last_location, ax

        jmp Loop1

    Quit:
        ret
Wait_For_Keypress endp


START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

	; Set extra segment to screen
	mov bx, 0B800h
	mov es, bx

    call Print_Screen_Black

    call Print_Symbol

	in al, 21h
	or al, 02h
	out 21h, al
	call Wait_For_Keypress

    .exit
end START