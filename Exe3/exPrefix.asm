.model small

.data

.stack 100h
.code

proc numPrefix

numPrefix endp

proc Print

Print endp

START:
	mov ax, @data ; Set up the data segment
	mov ds, ax

	push 3257

	call numPrefix

	; return to OS
	mov ax, 4C00h
	int 21h

END START
