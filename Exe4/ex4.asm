.model small

.data
	rows db 25
	columns db 80

	last_location dw ?
    last_point_location dw ?

    normal_factor db ?

	score db 0 ; 1-2 digit number
	score_a_msg db 'Score is A: ', ?, '$'
	score_b_msg db 'Score is B: ', ?, '$'
	score_c_msg db 'Score is C: ', ?, ?, '$'

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

Print_Symbol proc uses ax bx cx di
    ; Print red 'o' in the middle of the screen as the symbol
    mov bl, columns ; Number of columns
	mov bh, 0
	mov cx, bx
    shr bx, 1 ; Divide by 2

    mov al, rows ; Number of rows
	mov ah, 0
    shr ax, 1 ; Divide by 2 to get half of the rows

	add cx, cx ; Number of bytes per row
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
		test al, 01h
		jz Loop1

	in al, 60h ; Get keyboard data

	cmp al, 1Eh;9Eh ; a
	je Move_Left

	cmp al, 20h ;0A0h ; d
	je Move_Right

	cmp al, 11h;91h ; w
	je Move_Up

	cmp al, 1Fh;9Fh ; s
	je Move_Down

	cmp al, 10h;90h ; q
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
        ; Print the symbol one row up
        mov di, last_location

        ; Check if the symbol is already at the topmost row
        mov bl, columns
		add bl, bl
        mov ax, di
        div bl
        cmp al, 0 
        je Loop1

        ; Move the symbol one row up
        mov bl, columns
		mov bh, 0
        add bl, bl
        sub di, bx

        jmp Move

    Move_Down:
        ; Print the symbol one row down
        mov di, last_location

        ; Check if the symbol is already at the bottommost row
        mov bl, columns
		add bl, bl
        mov ax, di
        div bl
		mov bl, rows
		dec bl
        cmp al, bl
        je Loop1

        ; Move the symbol one row down
        mov bl, columns
		mov bh, 0
        add bl, bl
        add di, bx

        jmp Move

	Move:	
		mov byte ptr es:[di], 'O'
		mov byte ptr es:[di + 1], 4h ; Attribute for red foreground color on black background

		; Delete the symbol from the previous location
		mov ax, di
		mov di, last_location
		mov byte ptr es:[di], ' '

		; Update the last location
		mov last_location, ax

        ; Check if the point was captured
		mov bx, last_point_location
        cmp ax, bx
        jne Loop1

		; Update the score
		inc score
		call Generate_X

		jmp Loop1

    Quit:
		call Print_Score
        ret
Wait_For_Keypress endp

Generate_X proc uses ax bx dx di
    ; Get random number using the system clock
	Loop2:
		; Read seconds
		mov al, 0h
		out 70h, al
		in al, 71h

		mov bh, al ; Save seconds in bh

		; Read minutes
		mov al, 02h
		out 70h, al
		in al, 71h

		mov bl, al ; Save minutes in bl

		; Devide by the normal factor to get a better distribution
		mov ax, bx
		mov bl, normal_factor
		mov bh, 0
		mov dx, 0
		div bx
		mov bx, ax
		add bx, bx

		cmp bx, last_location
		je Loop2

		; Calculate the screen size
		mov al, rows
		mov ah, 0
		mov dl, columns
		add dl, dl ; Multiply by 2 to get the number of bytes per row
		mul dl

		; Check if the point exceeds the screen
		cmp bx, ax
		jge Loop2

	; Print X at the random location
	mov di, bx
	mov byte ptr es:[di], 'X'
	mov byte ptr es:[di + 1], 4h ; Attribute for red foreground color on black background

    ; Update the last location
    mov last_point_location, di

    ret
Generate_X endp

Print_Score proc uses ax bx dx si
	; Set the cursor to the top left corner
	mov ah, 02h
	mov bh, 0
	mov dx, 0
	int 10h

	mov ah, 0 
    mov al, score

	cmp al, 10d
	jge Print_C

	cmp al, 5d
	jge Print_B

	Print_A:
		add al, 30h ; ASCII

		; Move the score into the message
		mov si, offset score_a_msg + 12
		mov [si], al

		mov dx, offset score_a_msg
		jmp Print_Score_Message

	Print_B:
		add al, 30h ; ASCII

		; Move the score into the message
		mov si, offset score_b_msg + 12
		mov [si], al

		mov dx, offset score_b_msg
		jmp Print_Score_Message

	Print_C:
		mov bl, 10d
		div bl ; First digit in al and second in ah
		add ax, 3030h ; ASCII

		; Move the score into the message
		mov si, offset score_c_msg + 12
		mov [si], al
		mov [si + 1], ah

		mov dx, offset score_c_msg
		jmp Print_Score_Message

	Print_Score_Message:
		; Print the score message
		mov ah, 09h
		int 21h

	ret
Print_Score endp


START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

	; Set extra segment to screen
	mov bx, 0B800h
	mov es, bx

    call Print_Screen_Black

    call Print_Symbol

    ; Calculate the normal factor
    ; Screen size:
    mov al, rows
    mov ah, 0
    mov cl, columns
    mul cl
    mov bx, ax

    ; seconds:minutes range:
    mov ax, 5959h

    ; normal factor = screen size / seconds:minutes range
	mov dx, 0
    div bx
    mov normal_factor, al

	call Generate_X

	in al, 21h
	or al, 02h
	out 21h, al
	call Wait_For_Keypress

	in al, 21h
	and al, 0FDh
	out 21h, al

    .exit
end START