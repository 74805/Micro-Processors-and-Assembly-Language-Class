.model small

.data
    time db  0, ':', 0, ':', 0, '$'
.stack 100h
.code

; New_ISR resets the counter every third time the timer interrupt is called
New_ISR proc uses si ax
	mov si, offset time + 4 ; Point to the miliseconds
    mov al, [si]
    mov ah, 0 

    add ax, 55
    cmp ax, 100 ; If the miliseconds are greater than 100
    jl Exit ; Add a second

    Add_Second:
        sub ax, 100 ; Subtract 100 miliseconds
        mov [si], al ; Save the miliseconds

        mov si, offset time + 2 ; Point to the seconds
        mov al, [si]
        
        add al, 1
        cmp al, 60 ; If the seconds are greater than 60
        jge Add_Minute ; Add a minute

        Add_Minute:
            mov [si], 0 ; Save the seconds

            mov si, offset time ; Point to the minutes
            mov al, [si]

            add al, 1

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

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    call Change_IVT ; Update the timer interrupt vector
	
    .exit
end START