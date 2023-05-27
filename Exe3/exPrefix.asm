.model small

.data

.stack 100h
.code

proc numPrefix

numPrefix endp

printDecimal proc 
    push ax
    push bx
    push cx
    push dx

    ; Check if the number is zero
    mov cx, 0 ; Digit counter
    mov bx, 10
    cmp ax, 0
    jne convertLoop
    
    mov dl, 30h
    mov byte ptr es:[si], dl ; store in memory for printing
    jmp printDecimalEnd

    convertLoop:
        xor dx, dx
        div bx          ; Divide by 10
        add dl, 30h     ; Convert remainder to ASCII
        push dx         
        inc cx          

        cmp ax, 0
    jnz convertLoop

    printLoop:
        pop dx          ; Pop digit from stack

        mov byte ptr es:[si], dl ; store in memory for printing
        add si, 2
    loop printLoop

    printDecimalEnd:
        pop dx
        pop cx
        pop bx
        pop ax
        ret

printDecimal endp

START:
	mov ax, @data ; Set up the data segment
	mov ds, ax

	push 3257

    pop ax
    ; set extra segment to screen
	mov bx, 0B800h
	mov es, bx
	
	mov si, 0
	call printDecimal

	; return to OS
	mov ax, 4C00h
	int 21h

END START
