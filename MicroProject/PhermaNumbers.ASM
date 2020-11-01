format PE console
entry start
include 'win32a.inc'

section '.idata' import data readable writeable
    library kernel32, 'kernel32.dll', \
        msvcrt, 'MSVCRT.DLL'

    import kernel32, \
        ExitProcess, 'ExitProcess'

    import msvcrt, \
        printf, 'printf',\
        getch, '_getch'

section '.data' data readable writeable
    szResult db 'Count of Ferma numbers %d',10,0
    cnt dd 0
    ferma dd 3
    max dd 10000h ;65536
    szCheckMax db 'MaxValue=%d',10,0
    szCheckSteps db 'Next Ferma number=%d' ,10,0

section '.text' code readable executable
    start:
        invoke printf, szCheckMax, [max]
        add esp, 8
        call countFerma
        invoke printf, szResult, dword[cnt]
    
    exit:
        call [getch]
        push 0
        call [ExitProcess]

    countFerma:
        invoke printf, szCheckSteps, [ferma]
        add esp, 8

        mov eax, [cnt]
        inc eax
        mov [cnt], eax

        mov eax, [ferma]
        sub eax, 1
        mul eax
        inc eax
        mov [ferma], eax
        cmp eax, [max]
        jl countFerma
        ret