.model small

.data
saveAx dw ?
saveBx dw ?

.stack 100h
.code

START:
    .startup

    mov ax, @data ; Set up the data segment
	mov ds, ax


    .exit
end START