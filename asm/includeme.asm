start_include:
	mov [1], 1
	prn [1]
	ret

end_include:
	jmp end_include
