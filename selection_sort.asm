.386
.MODEL FLAT

INCLUDE str_utils.h
INCLUDE debug.h
PUBLIC selectionSort

.DATA
debug   	BYTE   "TEST",0
debugOutB	BYTE   "OuterS",0
debugInnerB	BYTE   "InnerB",0
debugInnerE	BYTE   "InnerE",0
.CODE
; the address of the temporary storage DWORD 
tempAddr      EQU    [ebp + 16]
; the address of the array is the second parameter DWORD address
arrayAddr     EQU    [ebp + 12]

; the size of the array is the third parameter WORD 
sz	EQU     [ebp + 10]
; the maximum length of each string in the array (LEN) WORD
ln	EQU     [ebp + 8]

indexx        EQU    [ebp - 4]   ; DWORD
scan          EQU    [ebp - 6]   ; WORD
;tempWord	  EQU	 [ebp - 8]

; a possible idea for the swap procedure is to use lodsb and stosb (i.e. using al for temporary storage)
swapproc      PROC    NEAR32
; swap two strings

; address of first string
_str1        EQU [ebp + 12]
; address of second string
_str2        EQU [ebp + 8]

; length of first string
_len1        EQU [ebp - 2]
; length of second string
_len2        EQU [ebp - 4]

setup:
        ; entry code
		push 	ebp
		mov     ebp, esp
		pushW	0
		pushW	0
		push	eax
		push 	ecx
		push 	esi
		push 	edi
		pushf
		
		push _str1
		call strlen_proc
        inc  ax            ; size is in ax--  include the NULL terminator in the length
        mov  _len1, ax     ; get and store the lengths of the source and destination strings

        push _str2
        call strlen_proc
        inc  ax            ; include the NULL terminator in the length
        mov  _len2, ax

        std                ; stack increases downward, so a needed correction
		movzx ecx, word ptr _len1
		mov esi, _str1
		mov edi, _str2

swapThem:

		
        ; copy source string to temp
		mov		AL, 0
		XCHG    AL,[esi]
		XCHG    AL,[edi]
		XCHG    [esi],AL
		inc 	esi
		inc 	edi
		loop swapThem
        ; copy destination to source
        ; copy temp to destination
finish:
       
        cld

        ; exit code
		popf	                 
        pop     edi
        pop     esi
        pop     ecx
        pop     eax
        mov     esp, ebp	
		pop		ebp
		ret		8		

swapproc    ENDP

selectionSort 	PROC 	Near32

		push 	ebp
		mov 	ebp, esp
		pushd	0
        push 	edx
		push 	ecx
		push 	ebx
		push 	eax
		mov 	cl, 1
        mov 	eax, arrayAddr    

outerLoop:

		;indexx is smallest word ecx is loop
		mov 	ch, cl
		mov 	indexx, eax
		mov 	ebx, eax
		movzx	edx, word ptr ln
		add 	ebx, edx
        cmp 	cl, sz
		je 		done
		
innerLoop:

		cmp 	ch, sz
		je		endInner
		mov		eax, indexx
		push 	eax
		push	ebx
		call	compare_proc
		
        cmp 	al, 0
		jle 	minUnchanged
		
		;tempWord gets updated if it doesnt jump
		mov 	indexx, ebx
		
minUnchanged:

		mov		edx, 0
		mov		dx, ln
		add 	ebx, edx
		inc 	ch
		jmp 	innerLoop
        
endInner:

		; swap elements (use index and min)
		mov		edx, indexx
		push	edx
		mov		eax, 0
		mov		al, cl
		dec		al
		mov		edx, 0
		mov		dx, ln
		mul		edx
		add		eax, arrayAddr
		push	eax
		mov		edx, indexx
		call 	swapproc
		inc		cl
		movzx	edx, word ptr ln
		add		eax, edx
		jmp     outerLoop

done:

        pop     eax
        pop     ebx
        pop     ecx
        pop     edx
        mov     esp, ebp           ; discard local variables
        pop     ebp
        ret     12                 ; discard the four parameters

selectionSort	ENDP




END