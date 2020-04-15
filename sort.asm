.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD
INCLUDE debug.h
INCLUDE io.h         ; header file for input/output
INCLUDE str_utils.h

CR      EQU     0dh     ; carriage return character
LF      EQU     0ah     ; line feed
MAX     EQU     100     ; the maximum number of strings in the array is 100
LEN     EQU     13      ; the maximum length of each string is 13 bytes (remember the 0 at the end)

.STACK  4096            ; reserve 4096-byte stack

.DATA                   ; reserve storage for data

; the strings must have extra space added for proper swapping
prompt   BYTE   "Enter a string: ", 0
strArray BYTE   MAX * LEN DUP (?) 
sz       WORD   ?                          ; the size of the array
temp     BYTE   LEN + 1 DUP (?)            ; string placed here while being read in

reportNum   BYTE   "The number of strings entered is ",0
arraySize   BYTE   6 DUP (?),0             ; ASCII for part of the report

text_        BYTE   50 DUP (?)
carriage_return    BYTE   CR, LF, 0


EXTRN 	        selectionSort:NEAR32
.CODE                                      ; start of main program code

                ; a macro to place a string in the array at the given index
                ; strings do not have to be added to the array in order
fillArray       MACRO   array, str1, index
				
				mov ax, index
				mov bx, LEN
				mul bx
				lea ecx, str1
				push ecx
				lea ecx, array
				movzx eax, ax
				add ecx, eax
				push ecx
				call strcopy_proc
				
                ENDM

				
				
                ; a macro to display the contents of the string array
printArray      MACRO   array

				mov ecx, 0
				mov cx, sz
                lea ebx, array
				
forloop:
				output [ebx]
				output carriage_return
				add ebx, LEN
				loop forloop
				
                ENDM
;Main PROC
_start:
				
                mov sz, 0                        ; initialize the size of the array to 0
                lea ebx, strarray                ; get the address of the first array element and place it in ebx
				
            
whileLoop:  
                  cmp       sz, MAX              ; test to see if size is larger than MAX (set the flags for the next jump)
                  jae       endWhile             ; exit the loop if the max number of integers has been added to the array (unsigned jump command)
                                           
                  output    prompt               ; prompt for the first grade (above bytes are displayed until 0 encountered)
                  input     temp, LEN + 1        ; read ASCII characters (stored in eax)

                  lea       ebx, temp
                  mov       cl, BYTE PTR [ebx]   ; test the first character for an "x"
                  cmp       cl, "x"
                  je        endWhile             ; exit the while loop if the sentinel is entered (the string entered starts with a "q")

                  fillarray strarray, temp, sz   ; put the text in the array at the current index
                  output temp
                  output carriage_return

                  inc       sz                   ; add 1 to size
                  jmp       whileLoop            ; get the next integer from the user (back to the top of the loop)
endWhile:

                output     carriage_return
                output     reportNum             ; report the number of strings placed into the array
                outputW    sz
                output     arraySize
                output     carriage_return
                cmp sz, 0
                je done
                ;printArray strArray

                ; prepare to sort (pass parameters to selection sort)
                lea        ecx, strArray
                push       ecx
                pushw      sz
                mov        ax, LEN
                push       ax
                ; sort!
                call       selectionSort

                output     carriage_return
                printArray strArray

                
done:
;ret
                INVOKE  ExitProcess, 0          ; exit with return code 0

PUBLIC _start                   ; make entry point public
 ;Main ENDP
END                             ; end of source code

