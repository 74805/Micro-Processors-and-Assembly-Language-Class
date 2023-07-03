.model tiny

.code
org 100h

jmp START

public Change_IVT
time db '00:00:000$'

START:
    mov ax, cs
    mov ds, ax
    push ax

    mov bx, offset Finish
    jmp Change_IVT

    ; Print_Time prints the time to the screen
    Print_Time proc uses ax bx dx
        ; Set the cursor position
        mov dh, 11
        mov dl, 27
        mov ah, 02h
        mov bh, 0
        int 10h

        ; Print the time to the screen
        mov dx, offset time
        mov ah, 09h
        int 21h

        ret
    Print_Time endp

    ; New_ISR updates the time
    New_ISR proc uses si ax bx dx
        mov si, offset time

        ; Update the miliseconds
        mov dx, word ptr [si + 7]
        sub dx, 3030h ; Convert from ASCII
        mov ax, 10d

        ; Calculate two first digits of miliseconds
        mul dl
        mov dl, dh
        mov dh, 0
        add ax, dx
        mov bx, ax

        ; Calculate last digit of miliseconds
        mov dl, [si + 6]
        sub dl, 30h ; Convert from ASCII
        mov ax, 100d
        mul dl
        add ax, bx
        mov bl, 10d
        
        add ax, 55d ; Add 55 miliseconds
        cmp ax, 1000d
        jge Miliseconds_Carry

        ; Convert back to ASCII
        div bl
        add ah, 30h
        mov [si + 8], ah

        mov ah, 0
        div bl
        add ax, 3030h
        mov word ptr [si + 6], ax
        jmp Exit

        Miliseconds_Carry:
            mov [si + 6], 30h ; Reset third digit of miliseconds

            sub ax, 1000d
            div bl
            add ax, 3030h
            mov word ptr [si + 7], ax 

        ; Update the seconds
        mov ax, word ptr [si + 3]

        sub ax, 3030h ; Convert from ASCII
        mov dl, ah
        mov dh, 0
        mul bl
        add ax, dx
        cmp ax, 59d
        je Seconds_Carry

        inc ax
        div bl
        add ax, 3030h ; Convert back to ASCII
        mov word ptr [si + 3], ax
        jmp Exit

        Seconds_Carry:
            mov word ptr [si + 3], 3030h ; Reset seconds

            ; Update the minutes
            mov ax, word ptr [si]
            cmp ah, '9'
            je Minutes_Carry

            inc ah
            mov word ptr [si], ax
            jmp Exit

            Minutes_Carry:
                mov ah, 30h
                inc al
                mov word ptr [si], ax

        Exit:
            call Print_Time
            
            ; Old ISR
            int 80h
            iret
    New_ISR endp


    ; Update the timer interrupt vector
    Change_IVT:
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
        jmp bx
	
    Finish:
        pop ax
        mov cs, ax
        mov dx, offset Finish
        int 27h
end START