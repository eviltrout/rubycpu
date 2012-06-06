; included file

start_include:
	mov [1], 1
	prn [1]

end_include:
	jmp end_include
