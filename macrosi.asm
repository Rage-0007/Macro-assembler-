include settings.inc
include io2023.inc
.stack 4096

.data
RegErr db 'ERROR! Input register.', 0
ConstErr db 'ERROR! Input constant.', 0 
DifErr db 'ERROR! Different types.', 0
TypeErr db 'ERROR! Type != byte/word/dword.', 0
Over db 'Overflow: ', 0

b1 db 255
b2 db 2
b3 db 10
w1 dw 1
w2 dw 2
w3 dw 3
d1 dd 4
d2 dd 5
d3 dd 6
q1 dq 7
q2 dq 8
q3 dq 9


.code
start:
    print macro i                   ;вывод значения
        push EAX
        mov EAX, 0
        if (type i) EQ byte
            mov AL, i
            outu EAX
        elseif (type i) EQ word
            mov AX, i
            outu EAX
        elseif (type i) EQ dword
            mov EAX, i
            outu EAX
        endif
        pop EAX
        newline
    endm


    AddThree macro a, b, c
        local ext, nOver

        for i, <a, b, c>
            ife ((opattr i) and 8)              ;если память
                if ((opattr i) and 16)         ;если регистр
                    outstr offset RegErr 
                else                            ;если константа
                    outstr offset ConstErr
                endif
                newline
                jmp ext
            endif
        endm

        for i, <a, b, c>                         
            if ((type i) NE byte) and ((type i) NE word) and ((type i) NE dword)   ; i==(byte/word/dword)  
                outstr offset TypeErr
                newline
                jmp ext
            endif
        endm

        if (type a EQ type b) and (type a EQ type c)                                ;(type a) == (type b) == (type c)
            push EAX  
            push EBX
            mov EAX, 0
            mov EBX, 0
            
            if type a EQ byte   
                mov AL, a
                add AL, b
                adc BL, 0                   ;BL + 1 если было переполнение
                add AL, c
                adc BL, 0
                mov a, AL
            elseif type a EQ word           
                mov AX, a
                add AX, b
                adc BL, 0
                add AX, c
                adc BL, 0
                mov a, AX
            elseif type a EQ dword          
                mov EAX, a
                add EAX, b
                adc BL, 0
                add EAX, c
                adc BL, 0
                mov a, EAX
            endif

            mov EAX, 0    
            cmp EBX, EAX                ;если BL == 0 значит переполнения не было
            je nOver
            outstr offset Over

            nOver:
            pop EBX
            pop EAX
        else
            outstr offset DifErr
            newline
            jmp ext
        endif
    ext:
        exitm
    endm

    ;Тесты:
    AddThree b1,b2,b3
    print b1 

    AddThree b2,b3,b1
    print b2

    AddThree w1,w2,w3 
    print w1

    AddThree w3,w2,w1 
    print w3

    AddThree d1,d2,d3
    print d1

    AddThree w1,b1,w3 

    AddThree d2,w2,b2 

    AddThree b3,b1,w2 

    AddThree b1,b2,7 

    AddThree w1,5,20 

    AddThree 5,b1,4 

    AddThree d2,5,6 

    AddThree 5,2,w3 

    AddThree ax,bx,dx 

    AddThree ax,w1,w2 

    AddThree w1,w2,si 

    AddThree al,b2,cl 

    AddThree ax,w2,dl 

    AddThree cx,b3,bl

    AddThree q1,q2,q3

    exit
end start