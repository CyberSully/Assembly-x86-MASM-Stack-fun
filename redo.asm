TITLE Program Template     (template.asm)

; Author: Brett Sullivan 
; Last Modified: 7-1-23
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data
TitleDescription BYTE "PROGRAMMING CHALLENGE 6: Crafting Low-Level, ", 0
constraints BYTE "Kindly provide ten non-negative decimal integers.", 13, 10, "Make sure each value fits comfortably within a ", 13, 10, "32-bit register.", 0
commaSeparator BYTE ", ", 0
userPrompt1 BYTE "Please enter a signed number: ", 0
userPrompt2 BYTE "Please try once more: ", 0
displayMessage BYTE "You have entered the following numbers:", 0
displaySumMessage BYTE "The cumulative total of these numbers is: ", 0
displayAvgMessage BYTE "The truncated average is: ", 0
errorMessage BYTE "ERROR: Your input is not valid. It must be a signed number or within the permissible range.", 0
exitMessage BYTE "Thank you for your participation!", 0

.code
main PROC
    LOCAL array[10]:SDWORD
    LOCAL sum:SDWORD
    LOCAL avg:SDWORD
    LOCAL count:DWORD
    LOCAL temp:SDWORD

    push OFFSET TitleDescription
    push OFFSET constraints
    call programIntro

    lea eax, array
    lea ecx, count

inputLoop:
    push ecx
    push OFFSET userPrompt1
    push OFFSET userPrompt2
    push OFFSET errorMessage
    call getUserInput

    mov eax, count
    cmp eax, 10
    jge inputDone
    inc dword ptr [ecx]

    jmp inputLoop

inputDone:
    mov ecx, count
    mov esi, 0            ; Initialize the sum

sumLoop:
    mov eax, [array + esi * 4]
    add sum, eax
    inc esi
    loop sumLoop

    mov ecx, count
    cdq
    idiv ecx               ; Calculate average

    push OFFSET array
    push count
    push OFFSET displayMessage
    push OFFSET commaSeparator
    call displayList

    push sum
    call writeVal
    push OFFSET displaySumMessage
    call displayString

    push eax
    call writeVal
    push OFFSET displayAvgMessage
    call displayString

    push OFFSET exitMessage
    call exitP

    ret
main ENDP

; Implement getString, displayString, programIntro, getUserInput, and other procedures accordingly
; ...

END main