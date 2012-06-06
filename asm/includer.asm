%include 'asm/includeme.asm'

start:
	call start_include
	mov [1], 0
	prn [1]
eof:
	jmp eof
