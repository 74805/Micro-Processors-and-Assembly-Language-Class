.model small

.data
result dw ?
input_arr dw 30233, 1246, 42
inputLen EQU 3

.stack 100h
.code

arrGCD proc
	; save registers
		push ax
		push bx

		; if there is only one element in the array then return it
		cmp cx, 1 
		jne notOne
		mov bx, input_arr[0]
		mov result, bx

		jmp return

		; else return recGCD(input_arr[0], arrGCD(input_arr[1..inputLen]))
		notOne:
			push cx
			dec cx
			mov bx, cx ; bx = current index
			call arrGCD
			pop cx

			mov ax, 2
			push dx ; save dx (because mul uses dx)
			mul bx ; ax = 2 * current index (because each word is 2 bytes)
			pop dx
			mov bx, ax
			mov ax, input_arr[bx] ; ax = input_arr[current index]
			mov bx, result ; bx = arrGCD(0, ... , current index - 1)
			call recGCD

		return:
			; restore registers
			pop bx
			pop ax

			ret
	
arrGCD endp 

recGCD proc
	; save registers
	push ax
	push bx
	push dx

	; if bx == 0 return ax
	cmp bx, 0
	jne notZero
	mov result, ax

	jmp return2

	; else return recGCD(bx, ax % bx)
	notZero:
		mov dx, 0
		div bx
		mov ax, bx ; ax = bx
		mov bx, dx ; bx = ax % bx
		call recGCD

	return2:
		; restore registers
		pop bx
		pop ax
		pop dx

		mov dx, result
		ret

recGCD endp

START:
	mov ax, @data ; Set up the data segment
	mov ds, ax

	mov ax, 17325
	mov bx, 27456

	push cx
	mov cx, inputLen
	call arrGCD
	pop cx

	; return to OS
	mov ax, 4C00h
	int 21h

END START
