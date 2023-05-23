.model small

.data
result dw ?

.stack 100h
.code

recGCD proc
	; save registers
	push ax
	push bx

	; if bx == 0 return ax
	cmp bx, 0
	jne notZero
	mov result, ax

	jmp return

	; else return recGCD(bx, ax % bx)
	notZero:
		mov dx, 0
		div bx
		mov ax, bx ; ax = bx
		mov bx, dx ; bx = ax % bx
		call recGCD

	return:
		; restore registers
		pop bx
		pop ax

		ret

recGCD endp

START:
	mov ax, @data ; Set up the data segment
	mov ds, ax

	mov ax, 17325
	mov bx, 27456

	call recGCD

	; print result
	; set extra segment to screen
	mov bx, 0B800h
	mov es, bx

	; return to OS
	mov ax, 4C00h
	int 21h

END START
