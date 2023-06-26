.model small

.data
    time db  0, 0, 0
    time_string db '00:00:00$'
.stack 100h
.code

; New_ISR resets the counter every third time the timer interrupt is called
New_ISR proc uses si ax
	mov si, offset time + 2 ; Point to the miliseconds
    mov al, [si]
    mov ah, 0 

    add ax, 55
    cmp ax, 100 ; If the miliseconds are greater than 100
    jl Exit ; Add a second

    Add_Second:
        sub ax, 100 ; Subtract 100 miliseconds
        mov [si], al ; Save the miliseconds

        mov si, offset time + 1 ; Point to the seconds
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
        call Print_Time
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

; Print_Time prints the time to the screen
Print_Time proc uses si ax bx di dx
    ; Update the time string
    mov si, offset time_string
    mov di, offset time
    mov bl, 10

    mov al, [di]
    mov ah, 0
    div bl
    add ax, 3030h
    mov [si], ax

    mov al, [di + 1]
    mov ah, 0
    div bl
    add ax, 3030h
    mov [si + 3], ax

    mov al, [di + 2]
    mov ah, 0
    div bl
    add ax, 3030h
    mov [si + 6], ax

    Set the cursor position
    mov dh, 12
    mov dl, 20
    mov ah, 02h
    mov bh, 0
    int 10h

    ; Print the time to the screen
    mov dx, offset time_string
    mov ah, 09h
    int 21h

    ret
Print_Time endp

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax

    call Change_IVT ; Update the timer interrupt vector

    mov ax, 0b800h
    mov es, ax
    ;call Print_Time
	
    Loop1:
        jmp Loop1
    .exit
end START