start: 
  mov eax, 1
  mov ebx, 0
  mov ecx, 1

loop: add eax, ebx
  add ebx, eax

  prn eax
  prn ebx

  inc ecx
  cmp ecx, 15
  je end

  cmp eax, 0
  jl end

  cmp ebx, 0
  jg loop


end:
