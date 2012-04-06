# Simplistic prime-finding algorithm

start:    mov eax, 2  # EAX is prime candidate

checkPrime: mov ebx, 2  # EBX is factor candidate

checkFactor:  cmp eax, ebx
    je primeFound
  
    mod eax, ebx
    rem ecx
    cmp ecx, 0
    je nextPrime
  
    inc ebx
    jmp checkFactor  # test comment

primeFound: prn eax

nextPrime:  inc eax
    cmp eax, 100
    jl checkPrime
