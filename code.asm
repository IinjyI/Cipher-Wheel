.MODEL SMALL
.STACK 100H


.DATA

    FNAME DB 'output.txt',00H
    FHANDLE DW ?
    BUFFER DB ?
    MSG1 DB 'ENTER KEY $'
    KEY DB ?
    
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
    
    ROT PROC NEAR
        CMP AL,65
        JL NOTCHAR
        CMP AL,122
        JG NOTCHAR
        CMP AL,90
        JG LOWERCASE
        JMP UPPERCASE
        UPPERCASE:
        SUB AL,KEY
        CMP AL,65
        JL ADDALPHA
        RET
        LOWERCASE:
        CMP AL,97
        JL NOTCHAR
        SUB AL,KEY
        CMP AL,97
        JL ADDALPHA
        RET
        ADDALPHA:
        ADD AL,26
        RET
        NOTCHAR:
        RET
        ROT ENDP
    
    SAVECHAR PROC NEAR
        CALL ROT
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
        CALL SAVECHAR
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
        SUB AL,30H
        MOV KEY,AL
        
        CALL MAKE_NEW_FILE
        CALL INPUT_TO_FILE
        

        
        .EXIT
    MAIN ENDP
END MAIN



        