.model small

.data
	rows db 25
	columns db 80

	last_key db 0 ; last key pressed

	last_location dw ?
    last_point_location dw ?

    normal_factor db ? ; normal factor for the random number generator

	score db 0 ; 1-2 digit number
	score_a_msg db 'Score is A: ', ?, '$'
	score_b_msg db 'Score is B: ', ?, '$'
	score_c_msg db 'Score is C: ', ?, ?, '$'

	counter db 0

.stack 100h
.code

; Print_Screen_Black clears the screen and sets the background color to black
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

; Print_Symbol prints the symbol (red 'O') in the middle of the screen
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

; Wait_For_Keypress waits for a key to be pressed and then changes the last_key variable
; Whenever counter variable is 0, it calls Move_Symbol to move in the direction of the last key pressed
Wait_For_Keypress proc uses ax bx dx di
	Loop1:
		in al, 64h
		test al, 01h
		jz No_Key_Pressed

	in al, 60h ; Get keyboard data
	mov last_key, al
	jmp Get_Button

	No_Key_Pressed:
		mov al, last_key

	Get_Button:
		; if the counter is not 0, then the symbol should not move
		mov ah, counter
		cmp ah, 0
		jne Loop1

		; Update the counter so that the symbol does not move too fast
		mov counter, 1

		; Check if the key pressed is one of the arrow keys or q
		cmp al, 9Eh ; a
		je Move_Left

		cmp al, 0A0h ; d
		je Move_Right

		cmp al, 91h ; w
		je Move_Up

		cmp al, 9Fh ; s
		je Move_Down

		cmp al, 90h ; q
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
		; Clear the screen
		call Print_Screen_Black

		call Print_Score

		call Restore_IVT

		; Return to DOS
		in al, 21h
		and al, 0FDh
		out 21h, al
		
		mov ax, 4c00h
		int 21h
		
Wait_For_Keypress endp

; Move_Symbol moves the symbol in the direction of the last key pressed
Move_Symbol proc
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

Move_Symbol endp

; Generate_X generates a new point (red 'X') in a random location on the screen at the 
; beginning of the game or after the previous point was captured 
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

; Print_Score prints the score when quitting the game
Print_Score proc uses ax bx dx si
	; Set the cursor to the top left corner
	mov ah, 02h
	mov bh, 0h
	mov dx, 0h
	int 10h

	mov ah, 0h 
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
		mov ah, 09h
		int 21h

	ret
Print_Score endp

; New_ISR resets the counter every third time the timer interrupt is called
New_ISR proc uses ax
	inc counter

	mov al, 3h
	cmp al, counter
	jne Exit

	; Reset the counter
	mov counter, 0

	Exit:
		iret
New_ISR endp

; Change_IVT updates the timer interrupt vector
Change_IVT proc uses ax es
	mov ax, 0h
	mov es, ax 

	cli ; Disable interrupts

	; Save the old ISR in an unused IVT entry
	mov ax, es:[1Ch*4] ; IP
	mov es:[80h*4], ax
	mov ax, es:[1Ch*4 + 2] ; CS
	mov es:[80h*4 + 2], ax

	; Set the new ISR
	mov ax, offset New_ISR
	mov es:[1Ch*4], ax ; IP
	mov ax, cs
	mov es:[1Ch*4 + 2], ax ; CS

	sti ; Enable interrupts
	ret
Change_IVT endp

; Restore_IVT restores the timer interrupt vector
Restore_IVT proc uses ax es
	mov ax, 0h
	mov es, ax 

	cli ; Disable interrupts

	; Save the old ISR in an unused IVT entry
	mov ax, es:[80h*4] ; IP
	mov es:[1Ch*4], ax
	mov ax, es:[80h*4 + 2] ; CS
	mov es:[1Ch*4 + 2], ax

	sti ; Enable interrupts
	ret
Restore_IVT endp

START:
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

	call Change_IVT

	in al, 21h
	or al, 02h
	out 21h, al
	call Wait_For_Keypress

end START