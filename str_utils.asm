.386
.MODEL FLAT

PUBLIC	strlen_proc, strcopy_proc, compare_proc, substring_proc, append_proc, replace_proc, tolower_proc, indexof_proc, equals_proc

.CODE

; Parameters are passed on the stack:

; address of source
source       EQU [ebp + 12]
; address of destination
dest         	EQU [ebp + 8]

strlen_proc      PROC    NEAR32
; find length of string whose address is passed on stack
; length returned in AX
; the length does not include the null byte that terminates the string

            push    ebp               
            mov     ebp, esp
            push    ebx        
            pushf                     

            mov     ax, 0              ; length := 0
            mov     ebx, dest          ; address of string

while_loop:  
           
            cmp     BYTE PTR [ebx], 0  ; null byte?
            je      	end_while_loop
            inc     	ax                 ; increment length
            inc     	ebx                ; point at next character
            jmp     	while_loop         ; repeat

end_while_loop:

            popf 
            pop     	ebx  
            pop     	ebp
            ret     	4                 

strlen_proc      ENDP

strcopy_proc     PROC NEAR32

; Procedure to copy string until null byte in source is copied.
; It is assumed that destination location is long enough for copy.

; Parameters are passed on the stack:
;    (1)  address of destination
;    (2)  address of source

            push   	ebp             
            mov    	ebp, esp        

            push   	edi
            push   	esi
            push   	eax
            push   	ecx
            pushf

            mov   	ecx, 0
            mov    	esi, source       ; initial source address
            mov    	edi, dest         ; destination 
            cld

            push 	DWORD PTR source
            call 		strlen_proc
            mov 	cx, ax
            rep 		movsb

            mov    	BYTE PTR [edi], 0 ; terminate destination string

            popf             
            pop    	ecx
            pop    	eax      
            pop   	esi
            pop   	edi

            mov    	esp, ebp

            pop    	ebp
            ret    	8                

strcopy_proc     ENDP

; if the two strings are equal, ax will be 0
; if the first string is "smaller"  (earlier alphabetically) than the second string, ax will be -1
; if the first string is "larger" (later alphabetically) than the second string, ax will be +1

compare_proc     PROC Near32

            push   	ebp            
            mov    	ebp, esp        
            push   	edi               
            push   	esi
            push   	ecx
            pushf

            mov    	esi, source      
            mov    	edi, dest

            mov    	eax, 0
            mov    	ecx, 0
            push   	DWORD PTR source
            call   	strlen_proc ; get the length of the source string

            cld
            mov    	cx, ax
            repe   	cmpsb              ; repeat while ECX > 0 AND ZF = 1 (repeat as long as there is a match)
            jnz    	no_match          ; did the last character match?

            ; if the last character matched, and the next dest character is a null, the strings are equal
            cmp    	BYTE PTR [edi], 0  ; the strings must be the same length

            ; if we make it here, either the two are an exact match, or source is smaller (shorter length, but otherwise the same as dest)
            jne    	smaller

match:
            mov 	ax, 0
            jmp 		finish

no_match:
            ; the flags are still set from the last cmpsb instruction
            ; was the source character larger or smaller than the dest character (there was no match)
            ja  		larger   

smaller:
            mov 	ax, -1   
            jmp 		finish

larger:
            mov 	ax, 1

finish:          
        
            popf                    
            pop    	ecx
            pop    	esi
            pop    	edi
            mov    	esp, ebp
            pop    	ebp
            ret    	8                 

compare_proc     ENDP

substring_proc      PROC    NEAR32
; find and return the substring specified by the two integer parameters
; the characters moved to the dest are inclusive of the starting and ending indices
; 1) the memory address of the string (16)
; 2) the memory address of the substring (12)
; 3) the starting index of the substr (10) (0 for the first character)
; 4) the ending index of the substr (8) (strlen - 1 for the last character)
; 0 to strlen - 1 valid indices

strAddr         	EQU [ebp + 16]
subStrAddr   	EQU [ebp + 12]
starting        	EQU [ebp + 10]
ending          	EQU [ebp + 8]

setup:

     	push		ebp
		mov		ebp, esp	                                      
        push    	eax
		push    	ebx		
        push    	ecx
        push    	edi
        push    	esi
		pushf 			

        mov 		eax, 0
        mov 		ebx, 0
        mov 		ecx, 0

        ; check indices for valid values
        mov     	ax, starting    ; make sure that the starting index is nonnegative
        cmp     	ax, 0
        jl      	finish

        mov     	bx,  ending
        cmp     	bx, ax          ; make sure that the ending index is greater than or equal to the starting index
        jl      	finish
             
        push    	DWORD PTR strAddr  	; make sure that the ending index is less than or equal to strlen - 1
        call    	strlen_proc      				; length of the string is in ax
        dec     	ax              					; the last valid index is one less than the length
        cmp     	ax, bx          					
        jl      	finish

        mov     	esi, strAddr    			; the starting address of the source
        mov     	edi, subStrAddr 			; the starting address of the destination

        mov     	ax, starting    			; the starting index to move esi to the correct starting address
        add     	esi, eax        			; update esi to point to the correct string location

        ; the number of characters to copy is ending - starting + 1
        mov     	cx, ending      			; reset cx (was used as a counter above)
        sub     	cx, ax          				; the number of copies from source to dest to perform
        inc     	cx              				; copy at least one character
        cld
        rep     	movsb           			; repeat while ECX > 0

        mov     BYTE PTR [edi], 0 		; terminate destination string with a null

finish:

		popf			   
        pop     	esi
        pop     	edi
        pop     	ecx
		pop		ebx
        pop     	eax
        mov     	esp, ebp	     
		pop		ebp
		ret		12		     

substring_proc   ENDP

; replacement character
old_char   	EQU [ebp + 14]
; overwritten character
new_char  	EQU [ebp + 12]
; address of destination
dest       	EQU [ebp + 8]

replace_proc     PROC Near32

            push   ebp             
            mov    ebp, esp         
            push   edi              
            push   esi
            push   eax
            push   ecx
            pushf

            mov    edi, dest     	; destination
            cld

            mov    eax, 0
            mov    ecx, 0

            mov    ax, old_char  	; al contains old character
            mov    cx, new_char

            mov    ah, cl             ; ah contains the new character

            ; put the length of the destination string in ecx
            push   ax
               push		edi
               call   		strlen_proc
               mov 		cx, ax
            pop    ax

            ; don't process a zero length string
            cmp    cx, 0   
            je     finish

while_loop:

            ; next statement won't do anything if ecx is 0 (unlike a loop instruction)
            repne  scasb  	; scan for the character to be replaced
									; will stop if the end of the string reached or the character was found
            jnz    finish     	; there were no additional matches 
									; (zero flag set if last comparison was equal, so if the zero 
									; flag is not set, there were no additional matches 
									; and the loop completed through to the end of the string)

            ; there was a match so back up and replace the character
            xchg   	al, ah
            dec    	edi
            stosb                     	; automatically increments edi after replacement
            xchg   	al, ah       	; return the character order to test for the next character to be replaced

            jmp while_loop 

finish:          
        
            popf                   
            pop    	ecx
            pop    	eax
            pop    	esi
            pop    	edi
            mov 	esp, ebp
            pop    	ebp
            ret    	8           

replace_proc     ENDP

tolower_proc PROC Near32

            push   ebp                
            mov    ebp, esp         
            push   edi              
            push   esi
            push   eax
            push   ecx
            pushf

            mov    edi, dest          ; destination (all lower case)
            mov    esi, source        ; source (upper and lower case)

whileLoop:

            cmp BYTE PTR [esi], 0
            je endLoop

            ; upper and lower case letters differ by 30h in ASCII value
            ; lower case letters have a larger ASCII value than upper case letters
            lodsb                     
            or     al, 00100000b      ; change from upper case to lower case
            stosb

            jmp whileLoop

endLoop:

            mov BYTE PTR [edi], 0
        
finish:          
        
            popf                     
            pop    ecx
            pop    eax
            pop    esi
            pop    edi
            mov    esp, ebp
            pop    ebp
            ret    8                

tolower_proc ENDP

src         EQU [ebp + 10]
char        EQU [ebp + 8]

indexof_proc     PROC Near32

            push   ebp              
            mov    ebp, esp          
            push   edi                
            push   ebx
            push   ecx
            pushf

            mov    	ebx, 0
            mov    	edi, src           ; obtain the length of the source string
            push   	edi
            call   	strlen_proc
 
            cmp    	ax, 0
            je     	not_found          ; a string of length zero (automatically not found)

            mov    	ecx, 0
            mov    	cx, ax
            mov    	bx, cx             ; store the original length of the source string

            mov    	ax, char

            repne scasb               ; search string for the character in al
            jnz not_found

            mov ax, bx                ; compute the index where the first match was found
            sub ax, cx				  ; strlen - count - 1 (count was decremented one extra time)
            dec ax
            jmp finish

not_found:
            mov ax, -1
        
finish:          
        
            popf                    
            pop    ecx 
            pop    ebx
            pop    edi
            mov    esp, ebp
            pop    ebp
            ret    6                

indexof_proc     ENDP

append_proc	    PROC    NEAR32

; append one string to the end of the other
; the source string is pushed first (12)
; the destination string is passed second (appended to) (8)
; the entire contents of source are copied to the end of dest (including the null at the end of source)

            push    ebp
            mov     ebp, esp     
            push    esi           
            push    edi
            push    eax
            push    ecx
            pushf

            mov     eax, 0
            mov     esi, source     ; move source address to esi
            mov     edi, dest       ; move destination address to edi
                                    
            push    edi             ; passing a parameter to strlen
            call    strlen_proc      ; need to know the length of the destination string
                                    ; the length of the desination is in eax
            add     edi, eax        ; move edi to the end of the destination string (null excluded)
            ; the original null at the end of the destination string will be overwritten

            push    esi             ; passing a parameter to strlen
            call    strlen_proc      ; the length of the source string is now is eax
            inc     eax             ; need to copy the null at the end of source, so add 1 to eax
            mov     ecx, eax        ; move the length of the source string to ecx as a counter
            cld
            rep     movsb           ; ecx is the counter for the rep instruction

            popf
            pop     ecx
            pop     eax
            pop     edi
            pop     esi
            mov     esp, ebp      
            pop     ebp
            ret     8           

append_proc      ENDP

; if the two strings are equal, ax will be 0
; if the two strings are not equal, ax will be -1

equals_proc      PROC Near32

            push   ebp               
            mov    ebp, esp       
            push   edi           
            push   esi
            push   ecx
            pushf

            mov    esi, source        ; initial source address
            mov    edi, dest          ; destination 

            mov    ecx, 0
            push   source
            call   strlen_proc
            cmp    ax, 0
            je     nomatch            ; a zero length string is not equal to anything

            mov    cx, ax
            repe   cmpsb              ; repeat while ECX > 0 AND ZF = 1 (repeat as long as there is a match)

            jnz    nomatch            ; did the last character match?

            cmp    BYTE PTR [edi], 0  ; the strings must be the same length
            jne    noMatch

match:
            mov ax, 0
            jmp finish

noMatch:
            mov ax, -1

finish:          
        
            popf                     
            pop    ecx
            pop    esi
            pop    edi
            mov    esp, ebp
            pop    ebp
            ret    8              

equals_proc      ENDP

; if the two strings are equal (ignoring case), ax will be 0
; if the two strings are not equal, ax will be -1
; assume the two strings are not zero length (no need to check for a zero length string)

equals_ignore_case_proc      PROC Near32

            push   ebp               
            mov    ebp, esp       
            push   edi           
            push   esi
            push   ecx
            pushf

            mov    esi, source        ; initial source address
            mov    edi, dest          ; destination 

            mov    ecx, 0
            push   source
            call   strlen_proc
			
			mov    cx, ax
			cld
			
for_loop:

			lodsb  ; load a source string character into al
			scasb	; determine whether the destination string has that character at the same location
			jz continue
			
adjust_for_possible_caps:

			;or al, 00100000b		; convert the source string character to lower case
			xor al, 00100000b	; change the source string character to the opposite case
			
			dec edi
			scasb
			jnz no_match
			
			;and al, 11011111b		; convert the source string character to upper case
			
			;dec edi
			;scasb
			;jnz no_match
			
continue:			
			loop for_loop
			
			cmp    BYTE PTR [edi], 0  ; the strings must be the same length
            jne    no_match
			
match:
            mov ax, 0
            jmp finish

no_match:
            mov ax, -1

finish:          
        
            popf                     
            pop    ecx
            pop    esi
            pop    edi
            mov    esp, ebp
            pop    ebp
            ret    8              

equals_ignore_case_proc      ENDP

swap      PROC    NEAR32
; swap two strings

; address of first string
str1        EQU [ebp + 16]
; address of second string
str2        EQU [ebp + 12]
; address of temporary string
temp        EQU [ebp + 8]

; length of first string
len1        EQU [ebp - 2]
; length of second string
len2        EQU [ebp - 4]

setup:

     	push	ebp
	mov	ebp, esp     
        sub     esp, 4     
        push    eax
	push    ebx		
        push    ecx
        push    edx
        push    esi
        push    edi
	pushf 	            

        push    str1
        call    strlen_proc
        inc     ax            ; size is in ax--  include the NULL in the length
        mov     len1, ax      ; get and store the lengths of the source and destination strings

        push    str2
        call    strlen_proc
        inc     ax            ; include the NULL in the length
        mov     len2, ax

swapThem:

        mov ecx, 0

        ; copy source string to temp
        mov     cx, len1      ; the length of the source string
        mov     esi, str1     ; the first string is copied to the temporary string's memory address
        mov     edi, temp     ; the dest is the temporary space
        rep     movsb 

        ; copy destination to source
        mov     cx, len2      ; the second string is copied to the first string's memory address
        mov     esi, str2     ; source is the second string
        mov     edi, str1     ; dest is the first string
        rep     movsb  

        ; copy temp to destination
        mov     cx, len1      ; the temporary string is copied to the second string's memory address
                              ; temporary's length is the length of the first string
        mov     esi, temp     ; source is the temporary space (contains the original source string)
        mov     edi, str2     ; dest is the second string
        rep     movsb 

finish:

	popf	                   
        pop     edi
        pop     esi
        pop	edx
        pop     ecx
	pop	ebx
        pop     eax
        mov     esp, ebp	
	pop	ebp
	ret	12		

swap    ENDP

END