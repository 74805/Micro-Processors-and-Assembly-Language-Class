.model small

.data
saveAx dw ?
saveBx dw ?

.stack 100h
.code

numPrefix proc 
    mov saveBx, bx

    pop bx ; the instruction pointer of the caller

    mov saveAx, ax

    pop ax
    push bx
    call printDecimal

    push dx
    push si
    add si, 160 ; Move to next line

    mov bx, 10
    xor dx, dx
    div bx ; Remove the last digit
    cmp ax, 0
    je numPrefixEnd ; Done if the number is zero

    mov bx, saveAx

    push ax ; Push the remaining number back
    call numPrefix

    mov saveAx, bx
    
    numPrefixEnd:
        pop si
        pop dx
        mov bx, saveBx
        mov ax, saveAx
        ret

numPrefix endp

printDecimal proc 
    push ax
    push bx
    push cx
    push dx
    push si

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
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret

printDecimal endp

START:
	mov ax, @data ; Set up the data segment
	mov ds, ax

     ; set extra segment to screen
	mov bx, 0B800h
	mov es, bx


    mov ax, 3257h
	push ax

    mov si, 3000
    call numPrefix
    
    ; return to OS
    mov ax, 4C00h
    int 21h

END START
