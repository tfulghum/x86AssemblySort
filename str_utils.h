.NOLIST
.386

EXTRN strcopy_proc :   Near32
EXTRN append_proc :    Near32
EXTRN strlen_proc :    Near32
EXTRN substring_proc : Near32
EXTRN equals_proc :    Near32
EXTRN compare_proc :   Near32
EXTRN replace_proc :   Near32
EXTRN tolower_proc :   Near32
EXTRN indexof_proc :   Near32
EXTRN equals_ignore_case_proc :    Near32



strcopy		MACRO source, dest, xtra

                   IFB <source>
                      .ERR <missing "source" operand in strcopy>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in strcopy>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in strcopy>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         lea ebx, dest
                         push ebx
                         call strcopy_proc

                      pop ebx

                   ENDIF

		ENDM

strlen		MACRO source, xtra

                   IFB <source>
                      .ERR <missing "source" operand in strlen>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in strlen>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         call strlen_proc

                      pop ebx

                   ENDIF

		ENDM

append		MACRO source, dest, xtra

                   IFB <source>
                      .ERR <missing "source" operand in append>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in append>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in append>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         lea ebx, dest
                         push ebx
                         call append_proc

                      pop ebx

                   ENDIF

		ENDM

; indexing is zero-based
substring		MACRO source, dest, start, end, xtra

                   IFB <source>
                      .ERR <missing "source" operand in substring>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in substring>
                   ELSEIFB <start>
                      .ERR <missing "starting index" operand in substring>
                   ELSEIFB <end>
                      .ERR <missing "ending index" operand in substring>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in substring>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         lea ebx, dest
                         push ebx
						 mov bx, start
                         push bx
						 mov bx, end
                         push bx
                         call substring_proc

                      pop ebx

                   ENDIF

		ENDM
		
		equals_ignore_case		MACRO source, dest, xtra

                   IFB <source>
                      .ERR <missing "source" operand in equals>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in equals>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in equals>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         lea ebx, dest
                         push ebx
                         call equals_ignore_case_proc

                      pop ebx

                   ENDIF

		ENDM

equals		MACRO source, dest, xtra

                   IFB <source>
                      .ERR <missing "source" operand in equals>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in equals>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in equals>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         lea ebx, dest
                         push ebx
                         call equals_proc

                      pop ebx

                   ENDIF

		ENDM

compare		MACRO source, dest, xtra

                   IFB <source>
                      .ERR <missing "source" operand in compare>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in compare>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in compare>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         lea ebx, dest
                         push ebx
                         call compare_proc

                      pop ebx

                   ENDIF

		ENDM

replace		MACRO old_char, new_char, dest, xtra

                   IFB <oldChar>
                      .ERR <missing "old character" operand in replace>
                   ELSEIFB <dest>
                      .ERR <missing "new character" operand in replace>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in replace>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in replace>
                   ELSE

                      push ebx

                         pushw old_char
                         pushw new_char
                         lea ebx, dest
                         push ebx
                         call replace_proc

                      pop ebx

                   ENDIF

		ENDM

to_lower		MACRO source, dest, xtra

                   IFB <source>
                      .ERR <missing "source" operand in toLower>
                   ELSEIFB <dest>
                      .ERR <missing "dest" operand in toLower>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in toLower>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
                         lea ebx, dest
                         push ebx
                         call tolower_proc

                      pop ebx

                   ENDIF

		ENDM

; char is an ASCII character (a byte)
index_of		MACRO source, char, xtra

                   IFB <source>
                      .ERR <missing "source" operand in indexOf>
                   ELSEIFB <char>
                      .ERR <missing "char" operand in indexOf>
                   ELSEIFNB <xtra>
                      .ERR <extra operand(s) in indexOf>
                   ELSE

                      push ebx

                         lea ebx, source
                         push ebx
						 mov bx, char
                         push bx
                         call indexof_proc

                      pop ebx

                   ENDIF

		ENDM


.NOLISTMACRO
.LIST
