TITLE Program 6 - Low Level fun with string conversions    (Proj6_sullbret.asm)

; Author: Brett Sullivan 
; Last Modified: 7-1-23
; OSU email address: Sullbret@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:     6            Due Date: 8-18-23
; Description: Implement and test two macros for string processing. 
;These macros should use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.
;user input will be tested for appropriate size, and error message will display if input is not within range, 
;or if there is no input. after ten numbers within range are collected from user, they will be displayed, 
;along with the sum of all numbers, and their truncated average. 

INCLUDE Irvine32.inc

.data


TitleDescription BYTE "PROGRAMMING CHALLENGE 6: Crafting Low-Level, "

BYTE "Input and Output Routines,             by Brett Sullivan", 0

constraints BYTE "Kindly provide ten signed decimal integers.", 13, 10

BYTE "Make sure each value fits comfortably within a "

BYTE "32-bit register.", 13, 10

BYTE "Upon completing the input of raw numbers, I "

BYTE "will exhibit a list", 13, 10

BYTE "showcasing the integers, their total, and their truncated "

BYTE "average.", 0

commaSeparator BYTE ", ", 0

userPrompt1 BYTE "Please enter a signed number: ", 0

userPrompt2 BYTE "Please try once more: ", 0

displayMessage BYTE "You have entered the following numbers:", 0


displaySumMessage BYTE "The cumulative total of these numbers is: ", 0

displayAvgMessage BYTE "The truncated average is: ", 0

errorMessage BYTE "ERROR: Your input is not valid. It must be a signed number or within the permissible range.", 0

goodbye BYTE "Thank you for your participation!", 0

array DWORD 10 DUP(?)

.code


main PROC

    push OFFSET TitleDescription 
    push OFFSET constraints 
    call programIntro 

    push OFFSET array 
    push LENGTHOF array 
    push OFFSET userPrompt1 
    push OFFSET userPrompt2 
    push OFFSET errorMessage 
    call getUserInput 

    push OFFSET array 
    push LENGTHOF array 
    push OFFSET displayMessage 
    push OFFSET commaSeparator 
    call displayList 

    push OFFSET array 
    push LENGTHOF array 
    push OFFSET displaySumMessage 
    push OFFSET displayAvgMessage 
    call printSumAverage 

    push OFFSET goodbye 
    call exitP

exit

main ENDP

; ---------------------------------------------------------------------------------
; Name: getString
;
; Gets a string input from the user.
;
; Preconditions: none
;
; Receives:
; pAddr  = address of the prompt message
; buff = buffer to store the input string
; lenOBuff = length of the buffer
;
; returns: nothing
; ---------------------------------------------------------------------------------
getString MACRO pAddr , buff, lenOBuff

push edx 

push ecx

mov edx, pAddr 

call WriteString

mov edx, buff

mov ecx, lenOBuff

call ReadString 

pop ecx 

pop edx

ENDM

; ---------------------------------------------------------------------------------
; Name: displayString
;
; Displays a string stored in memory.
;
; Preconditions: none
;
; Receives:
; stringAddress = address of the string to be displayed
;
; returns: nothing
; ---------------------------------------------------------------------------------
displayString MACRO stringAdd

push edx

mov edx, stringAdd ; print the string

call WriteString

pop edx

ENDM

; ---------------------------------------------------------------------------------
; Name: programIntro
;
; Displays the program introduction to the user.
;
; Preconditions: Uses edx
;
; Receives:
; titleAddr = address of the program title
; conditionsAddr = address of the program conditions message
;
; returns: nothing
; ---------------------------------------------------------------------------------
programIntro PROC USES edx

    push ebp
    mov ebp, esp

    ; Display the TitleIntro message
    mov edx, [ebp + 16]
    displayString edx
    call Crlf
    call Crlf

    ; Display the conditions message
    mov edx, [ebp + 12]
    displayString edx
    call Crlf
    call Crlf

    pop ebp

    ret 8

programIntro ENDP

; ---------------------------------------------------------------------------------
; Name: getUserInput
;
; Gets user input to fill an array.
;
; Preconditions: Uses esi, ecx, eax
;
; Receives:
; arrayAddr = address of the array to be filled
; arraySize = size of the array
; userPrompt1 = address of the first user prompt
; userPrompt2 = address of the second user prompt
; errorMsg = address of the error message
;
; returns: nothing
; ---------------------------------------------------------------------------------
getUserInput PROC USES esi ecx eax

    push ebp
    mov ebp, esp

    ; Load the address of the array into esi
    mov esi, [ebp + 36]

    ; Load the array length into ecx
    mov ecx, [ebp + 32]

readArr:

    mov eax, [ebp + 28]
    push eax
    push [ebp + 24]
    push [ebp + 20]

    
    call readVal

    ; Store the converted value in the array
    pop [esi]
    add esi, 4

    ; Loop back to read the next value
    loop readArr

    pop ebp

    ret 20

getUserInput ENDP

; ---------------------------------------------------------------------------------
; Name: readVal
;
; Reads an integer input from the user and validates it.
;
; Preconditions: Uses eax, ebx
;
; Receives:
; userPrompt = address of the user prompt
; userPromptRetry = address of the retry user prompt
; errorMsg = address of the error message
;
; returns: converted value in memory and isValid flag
; ---------------------------------------------------------------------------------
readVal PROC USES eax ebx

LOCAL inputNum[15]:BYTE, isValid:DWORD

push esi
push ecx

                                ;Load prompt1 address into eax

mov eax, [ebp + 16]

lea ebx, inputNum               ; Load inputNum address into ebx

rLoop:

getString eax, ebx, LENGTHOF inputNum       ;; Call the getString procedure to read user input

mov ebx, [ebp + 8]                          ; Load the address of isTooLarge flag into ebx
push ebx
lea eax, isValid
push eax

lea eax, inputNum                            ; Load the address of inputNum into eax
push eax
push LENGTHOF inputNum 

call validateInput 

pop edx
mov [ebp + 16], edx ; store converted value in [ebp + 16]
mov eax, isValid 

cmp eax, 1
mov eax, [ebp + 12]
lea ebx, inputNum

jne rLoop 

pop ecx
pop esi

ret 8

readVal ENDP

; ---------------------------------------------------------------------------------
; Name: validateInput
;
; Validates if the input string is a valid unsigned integer.
;
; Preconditions: Uses esi, ecx, eax, edx
;
; Receives:
; inputStringAddr = address of the input string
; isValidAddr = address to store the validation result
; errorMsg = address of the error message
;
; returns: nothing
; ---------------------------------------------------------------------------------
validateInput PROC USES esi ecx eax edx

    LOCAL tooBig:DWORD ; Flag to indicate if value is too large

    ; Set the source index and loop counter
    mov esi, [ebp + 12] 
    mov ecx, [ebp + 8]  

    cld ; Clear the direction flag for forward string processing

   
stringLoad:

    lodsb ; Load the next byte into al

    cmp al, 0   
    je covertStrToInt 

    cmp al, 48  
    jl invalid  

    cmp al, 57  
    ja invalid                                  ; Jump to invalid if al > '9'

    loop stringLoad                             ; Repeat for the entire string

                                               
invalid:

                                                ; Load the address of errorMsg into edx
    mov edx, [ebp + 20]

    displayString edx 
    call Crlf

    ; Set isValid to 0 (false)
    mov edx, [ebp + 16]
    mov eax, 0
    mov [edx], eax

    jmp finalValue 

; Convert string to integer if it passes digit verification
covertStrToInt:

    mov edx, [ebp + 8]                      ; Load the address of tooBig into edx

    cmp ecx, edx 

    je invalid 

    lea eax, tooBig 
    mov edx, 0 
    mov [eax], edx                          ; Store 0 in tooBig

    push [ebp + 12] 
    push [ebp + 8] 
    lea edx, tooBig
    push edx 

    call convertToNum 

    ; Check if the value is too large (tooBig == 1)
    mov edx, tooBig
    cmp edx, 1 
    je invalid 

    ; Set isValid to 1 (true)
    mov edx, [ebp + 16] 
    mov eax, 1 
    mov [edx], eax 

; Store the converted value in [ebp + 20]
finalValue:

    pop edx 
    mov [ebp + 20], edx 

    ret 12 

validateInput ENDP

; ---------------------------------------------------------------------------------
; Name: convertToNum
;
; Converts a string to an integer value.
;
; Preconditions: Uses esi, ecx, eax, ebx, edx
;
; Receives:
; inputStringAddr = address of the input string
; convertedValueAddr = address to store the converted value
; numTooBig = address to store the "too large" flag
;
; returns: nothing
; ---------------------------------------------------------------------------------
convertToNum PROC USES esi ecx eax ebx edx

    LOCAL value:DWORD                               ; Local variable to store the converted value

    ; Set up esi and ecx (loop counter)
    mov esi, [ebp + 16] 
    mov ecx, [ebp + 12] 

    lea eax, value 

    xor ebx, ebx 

    mov [eax], ebx                                  ; Clear value (initialize to 0)

    xor eax, eax 
    xor edx, eax 

    cld 

digInsert:

    lodsb 

    cmp eax, 0 
    je insertEnd 

    sub eax, 48 

    mov ebx, eax 

    mov eax, value 
    mov edx, 10                                     ; Set edx as the multiplier (10)
    mul edx 

    jc numTooBig                                    ; Jump to numTooBig if carry occurs

    add eax, ebx                                    ; Add the digit value to the converted value

    jc numTooBig                                     ; Jump to numTooBig if carry occurs

    mov value, eax                                  ; Store the updated value in the local variable

    mov eax, 0                                      ; Clear eax for the next iteration

    loop digInsert 

insertEnd:

    mov eax, value 
    mov [ebp + 16], eax 

    jmp finish 

; Handle case where value doesn't fit in 32-bit register
numTooBig:

    mov ebx, [ebp + 8]                      ; Load the address of numTooBig into ebx
    mov eax, 1 
    mov [ebx], eax 

    mov eax, 0 
    mov [ebp + 16], eax 

finish:

    ret 8 

convertToNum ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Displays an array of numbers.
;
; Preconditions: Uses esi, ebx, ecx, edx
;
; Receives:
; titleAddr = address of the array title
; arrayAddr = address of the array
; arraySize = size of the array
; commaSpaceAddr = address of the comma and space string
;
; returns: nothing
; ---------------------------------------------------------------------------------
displayList PROC USES esi ebx ecx edx

    push ebp           
    mov ebp, esp        

    call Crlf         

    mov edx, [ebp + 28] 
    displayString edx   
    call Crlf           

    mov esi, [ebp + 36] ; Load the address of the array
    mov ecx, [ebp + 32] ; Load the length of the array

    mov ebx, 1         

valueP:

    push [esi]           
    call writeVal        

    add esi, 4          
    cmp ebx, [ebp + 32]  ; Compare the counter with the array length
    jge endList          ; If the counter is greater or equal, jump to endList

    mov edx, [ebp + 24]  
    displayString edx    

    inc ebx              
    loop valueP      ; Repeat the loop for remaining values

endList:

    call Crlf          
    pop ebp             
    ret 16               

displayList ENDP

; ---------------------------------------------------------------------------------
; Name: writeVal
;
; Converts and displays an integer value as a string.
;
; Preconditions: Uses eax
;
; Receives:
; value = integer value to be converted and displayed
;
; returns: nothing
; ---------------------------------------------------------------------------------
writeVal PROC USES eax

    LOCAL stringResult[11]:BYTE

    lea eax, stringResult
    push eax
    push [ebp + 8]                                   ; Push the integer value onto the stack
    call covertIntToStr
    lea eax, stringResult
    displayString eax                                ; Display the converted value as a string
    ret 4
writeVal ENDP

; ---------------------------------------------------------------------------------
; Name: covertIntToStr
;
; Converts an integer to a string.
;
; Preconditions: Uses eax, ebx, ecx
;
; Receives:
; intValue = integer value to be converted
; strBufferAddr = address of the string buffer
;
; returns: nothing
; ---------------------------------------------------------------------------------
covertIntToStr PROC USES eax ebx ecx
    LOCAL charTemp:DWORD

    ; Perform division of integer by 10
    mov eax, [ebp + 8]
    mov ebx, 10
    mov ecx, 0
    cld

    ; Count the value of digits and push them in reverse order
ConLoop:
    cdq
    div ebx
    push edx
    inc ecx  
    cmp eax, 0
    jne ConLoop

    mov edi, [ebp + 12]                                     ; Move into destination char array

    ; Store the character in the array
S_Char:
    pop charTemp
    mov al, BYTE PTR charTemp
    add al, 48
    stosb
    loop S_Char

    mov al, 0
    stosb
    ret 8
covertIntToStr ENDP

; ---------------------------------------------------------------------------------
; Name: printSumAverage
;
; Prints the sum and average of an array of integers.
;
; Preconditions: Uses esi, edx, ecx, eax, ebx
;
; Receives:
; sumMessageAddr = address of the sum message
; avgMessageAddr = address of the average message
; arrayAddr = address of the array
; arraySize = size of the array
;
; returns: nothing
; ---------------------------------------------------------------------------------
printSumAverage PROC USES esi edx ecx eax ebx

    push ebp
    mov ebp, esp

    mov edx, [ebp + 32]                              ; Load the message for displaying the sum
    displayString edx

    mov esi, [ebp + 40]                            
    mov ecx, [ebp + 36]                           

    xor eax, eax                                    ; Clear overflow and carry flags

    ; Calculate the sum
SumLoop:
    add eax, [esi]
    add esi, 4
    loop SumLoop

    ; Display the sum
    push eax
    call writeVal
    call Crlf

    ; Calculate and display the average
    mov edx, [ebp + 28]  
    displayString edx

    cdq

    mov ebx, [ebp + 36]                             ; Load the LENGTHOF array present at [ebp + 36]
    div ebx 

    push eax
    call writeVal 
    call Crlf

    pop ebp
    ret 16

printSumAverage ENDP

;---------------------------------------------------------------------------------
; Name: exitP
;
; Displays the program exit message.
;
; Preconditions: Uses edx
;
; Receives:
; exitMessageAddr = address of the exit message
;
; returns: nothing
; ---------------------------------------------------------------------------------
exitP PROC USES edx

    push ebp
    mov ebp, esp
    call Crlf

    mov edx, [ebp + 12]  ; Load the exit message
    displayString edx

    call Crlf

    pop ebp
    ret 4

exitP ENDP

END main
