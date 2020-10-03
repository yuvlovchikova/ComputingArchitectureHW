; вариант 14: Массив B с заменой всех отрицательных элементов значением максимального

format PE console
entry start

include 'INCLUDE/win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize     db 'size of vector: ', 0
        strIncorSize   db 'Incorrect size of vector = %d', 10, 0
        strVecElemI    db '[%d]? ', 0
        strScanInt     db '%d', 0
        strMaxValue    db 'Max = %d', 10, 0
        strBVec        db '---B---', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        max          dd 0
        i            dd ?
        i_b            dd ?
        tmp          dd ?
        tmp_b          dd ?
        tmpStack     dd ?
        vec          rd 100
        vecB          rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 2) get vector max
        call VectorMax ; подготовка к проходу по массиву
        call VectorMaxLoop ; ищем максимум в цикле
; 3) replacing zeros
        call VectorMax ; подготовка к проходу по массиву
        call zeroVecLoop ; заменить отрицательные максимальным
; 4)
; 4) out of max
        push [max]
        push strMaxValue
        call [printf]
; 5) out of B Vector
        push strBVec
        call [printf]

; 6) test vector out
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; fail size
        push vec_size
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        mov ebx, vec
        xor ecx, ecx
        ret
;--------------------------------------------------------------------------
VectorMax:
        xor ecx, ecx
        mov ebx, vec                 ; ebx = &vec
        ret
VectorMaxLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endZeroVector
        mov [i], ecx ; to end of loop

        mov eax, 0
        cmp [ebx], eax

        jg firstMax
        jl firstMax
endOfProgram:

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4

        jmp VectorMaxLoop

firstMax:
        cmp [max], 0
        je newMax
        jmp checkForMax
checkForMax:
        mov edi, [ebx] ; [ebx] в регистр edi, чтобы видеть флаг
        cmp edi, [max]
        jg newMax
        jmp endOfProgram
newMax:
        mov ecx, [ebx]
        mov [max], ecx
        jmp endOfProgram
zeroVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endZeroVector
        mov [i], ecx

        mov edx, [ebx]
        cmp edx, 0
        jl makeZeroMax
afterMk:
        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp zeroVecLoop

makeZeroMax:
        mov edx, [max]
        mov [ebx], edx
        jmp afterMk

endZeroVector:
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'INCLUDE/api\user32.inc'
include 'INCLUDE/api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'INCLUDE/api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'