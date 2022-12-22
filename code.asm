.MODEL SMALL


.DATA

    FNAME DB 'output.txt',00H
    FHANDLE DW ?
    BUFFER DB ?
    MSG1 DB 'TYPE E FOR ENCRYPTING AND D FOR DECRYPTING $'
    MSG2 DB 'ENTER KEY (1-25) $'
    KEY DB ?
    OP DB ?
    
.CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MAKE_NEW_FILE PROC NEAR
        MOV AH,3CH
        LEA DX,FNAME
        MOV CX,00H
        INT 21H
        MOV FHANDLE,AX
        RET
    MAKE_NEW_FILE ENDP
                
    OPEN_FILE PROC NEAR
        MOV AH,3DH
        LEA DX,FNAME
        MOV AL,2
        INT 21H
        MOV FHANDLE,AX
        RET
    OPEN_FILE ENDP
        
    CLOSE_FILE PROC NEAR
        MOV AH,3EH
        MOV BX,FHANDLE
        INT 21H
        RET
    CLOSE_FILE ENDP
    
    GET_KEY PROC NEAR
        mov dl, 10  
        mov bl, 0
        GETNUM:
        MOV AH,01H
        INT 21H
        CMP AL, 13   ; Check if user pressed ENTER KEY
        JE GOTKEY 
        MOV AH,0H  
        SUB AL,30H   ; ASCII to DECIMAL
        MOV CL,AL
        MOV AL,BL   ; Store the previous value in AL
        MUL DL       ; multiply the previous value with 10
        ADD AL,CL   ; previous value + new value ( after previous value is multiplyed with 10 )
        mov BL, AL
        jmp GETNUM    
        GOTKEY:
        MOV KEY,BL
        RET
    GET_KEY ENDP
    
    DROT PROC NEAR
        CMP AL,65
        JL NOTCHARACTER
        CMP AL,122
        JG NOTCHARACTER
        CMP AL,90
        JG LOWER
        JMP UPPER
        UPPER:
        SUB AL,KEY
        CMP AL,65
        JL ADDALPHA
        RET
        LOWER:
        CMP AL,97
        JL NOTCHARACTER
        SUB AL,KEY
        CMP AL,97
        JL ADDALPHA
        RET
        ADDALPHA:
        ADD AL,26
        RET
        NOTCHARACTER:
        RET
    DROT ENDP
    
    EROT PROC NEAR
        CMP AL,65
        JL NOTCHAR
        CMP AL,122
        JG NOTCHAR
        CMP AL,90
        JG LOWERCASE
        JMP UPPERCASE
        UPPERCASE:
        ADD AL,KEY
        CMP AL,90
        JG SUBALPHA
        RET
        LOWERCASE:
        CMP AL,97
        JL NOTCHAR
        ADD AL,KEY
        CMP AL,122
        JG SUBALPHA
        RET
        SUBALPHA:
        SUB AL,26
        RET
        NOTCHAR:
        RET
    EROT ENDP
    
    ENCRYPT_OR_DECRYPT PROC NEAR
        CMP OP,'D'
        JE DECRYPT
        CMP OP,'d'
        JE DECRYPT
        JMP ENCRYPT
        DECRYPT:
        CALL DROT
        CALL SAVECHAR
        RET
        ENCRYPT:
        CALL EROT
        CALL SAVECHAR
        RET
    ENCRYPT_OR_DECRYPT ENDP
    
    SAVECHAR PROC NEAR
        MOV BUFFER,AL
        MOV AH,40H
        MOV BX,FHANDLE
        LEA DX,BUFFER
        INT 21H
        RET
    SAVECHAR ENDP
        
    INPUT_TO_FILE PROC NEAR
        MOV CX,1H
        AGAIN:
        MOV AH,01H
        INT 21H
        CMP AL,'@'
        JE EXIT
        CALL ENCRYPT_OR_DECRYPT
        JMP AGAIN
        EXIT:
        CALL CLOSE_FILE
        RET
    INPUT_TO_FILE ENDP
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MAIN PROC FAR
        .STARTUP
        
        MOV AH,09H
        LEA DX,MSG1
        INT 21H
        
        MOV AH,01H
        INT 21H
        MOV OP,AL
        
        MOV AH,02H
        MOV DL,0AH
        INT 21H
        
        MOV AH,09H
        LEA DX,MSG2
        INT 21H
        
        CALL GET_KEY 
        CALL MAKE_NEW_FILE
        CALL INPUT_TO_FILE
        
        
        .EXIT
    MAIN ENDP
END MAIN