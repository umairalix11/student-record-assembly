[org 0x0100]
jmp near main_program

; 1. DATA SECTION (STRINGS & MENUS)
menu_title db 10,13,'   ====================================================',10,13
           db '            STUDENT INFORMATION CENTRAL SYSTEM         ',10,13
           db '   ====================================================',10,13
           db '    1. Add Student (Basic Info)',10,13
           db '    2. View All Students Registry',10,13
           db '    3. Admission Management (Status Update)',10,13
           db '    4. Fee Management (Payment Records)',10,13
           db '    5. Attendance Management (Logs)',10,13
           db '    6. Health & Disability Records',10,13
           db '    7. Performance Management (Evaluation)',10,13
           db '    8. Search Student Record',10,13
           db '    9. Delete Student Record (Remove)',10,13
           db '    10. Exit System',10,13,10,13
           db '    Choose an option [1-10]: $'

msg_roll   db 10,13,'   Enter Roll Number (Numeric ID): $'
msg_name   db 10,13,'   Enter Student Full Name: $'
msg_status db 10,13,'   Enter Admission Status (Admit/Pend): $'
msg_fee    db 10,13,'   Enter Fee Status (Paid/Unpaid): $'
msg_attn   db 10,13,'   Enter Attendance out of 100 (0-100): $'
msg_health db 10,13,'   Enter Health Info (Fit/Unfit): $'
msg_perf   db 10,13,'   Enter Performance (Poor/Good/Excel): $'

table_header db 10,13,'   ========================================================================',10,13
             db '   ROLL | STUDENT NAME         | STATUS  | FEES    | ATTN    | HEALTH  | PERF',10,13
             db '   ========================================================================$'

str_success  db 10,13,10,13,'   [SUCCESS]: Database Updated Successfully!$'
str_pause    db 10,13,'   Press Enter to continue...$'
str_error    db 10,13,'   [ERROR]: Student Roll Number not found!$'
str_invalid  db 10,13,'   [INVALID]: Choice out of range. Try again.$'
str_goodbye  db 10,13,10,13,'   Exiting system safely. Goodbye!$',10,13

; 2. DATA STORAGE (DATABASE ARRAYS)

student_rolls       times 10 dw 0       
student_names       times 200 db ' '  
student_status      times 70 db ' '    
student_fees        times 70 db ' '     
student_attendance  times 70 db ' '   
student_health      times 70 db ' '    
student_perf        times 70 db ' '    
record_count        dw 0               

; Temporary Buffer for DOS Inputs

input_buffer        db 21, 0
                    times 22 db 0
temp_storage        dw 0
delete_index        dw 0                 ; Temporary storage for deletion index

; 3. MAIN ROUTING ENGINE

main_program:
    call clear_screen
    mov dx, menu_title
    call print_string

    mov dx, input_buffer
    call get_input_string

    mov al, [input_buffer+1]
    cmp al, 2
    je near handle_two_digits

    mov al, [input_buffer+2]
    cmp al, '1'
    je near route_add
    cmp al, '2'
    je near route_view
    cmp al, '3'
    je near route_admission
    cmp al, '4'
    je near route_fee
    cmp al, '5'
    je near route_attendance
    cmp al, '6'
    je near route_health
    cmp al, '7'
    je near route_performance
    cmp al, '8'
    je near route_search
    cmp al, '9'
    je near route_delete
    jmp near invalid_choice

route_add:         jmp near mod_add_student
route_view:        jmp near mod_view_all
route_admission:   jmp near mod_admission
route_fee:         jmp near mod_fee
route_attendance:  jmp near mod_attendance
route_health:      jmp near mod_health
route_performance: jmp near mod_performance
route_search:      jmp near mod_search
route_delete:      jmp near mod_delete

handle_two_digits:
    mov al, [input_buffer+2]
    mov ah, [input_buffer+3]
    cmp al, '1'
    jne near invalid_choice
    cmp ah, '0'
    je near route_exit
    jmp near invalid_choice
route_exit:        jmp near mod_exit

invalid_choice:
    mov dx, str_invalid
    call print_string
    mov dx, str_pause
    call print_string
    call press_any_key
    jmp near main_program

; 4. CORE FUNCTIONAL MODULES



; --- MODULE 1: ADD STUDENT ---
mod_add_student:
    mov dx, msg_roll
    call print_string
    call input_numeric
    mov [temp_storage], ax

    mov ax, [record_count]
    mov cx, 20
    mul cx
    mov di, student_names
    add di, ax
    mov cx, 20
    mov al, ' '
    rep stosb

    mov ax, [record_count]
    mov cx, 20
    mul cx
    mov di, student_names
    add di, ax
    mov dx, msg_name
    call print_string
    mov cx, 0
.name_loop:
    call read_char
    cmp al, 13
    je near .name_done
    mov [di], al
    inc di
    inc cx
    cmp cx, 20
    jb near .name_loop
.name_done:

    ; Auto-Fill empty placeholders ('-')
    mov ax, [record_count]
    mov cx, 7
    mul cx
    mov bx, ax

    mov di, student_status
    add di, bx
    mov byte [di], '-'

    mov di, student_fees
    add di, bx
    mov byte [di], '-'

    mov di, student_attendance
    add di, bx
    mov byte [di], '-'

    mov di, student_health
    add di, bx
    mov byte [di], '-'

    mov di, student_perf
    add di, bx
    mov byte [di], '-'

    ; Save Roll Number
    mov bx, [record_count]
    shl bx, 1
    mov ax, [temp_storage]
    mov [student_rolls + bx], ax

    inc word [record_count]
    jmp near operation_complete

; --- MODULE 2: VIEW ALL STUDENTS ---
mod_view_all:
    call clear_screen
    mov dx, table_header
    call print_string

    mov cx, [record_count]
    cmp cx, 0
    je near .view_empty

    mov si, 0
.display_loop:
    push cx
    call display_row
    inc si
    pop cx
    loop .display_loop

.view_empty:
    mov dx, str_pause
    call print_string
    call press_any_key
    jmp near main_program

; --- MODULE 3: ADMISSION MANAGEMENT ---
mod_admission:
    mov dx, msg_roll
    call print_string
    call input_numeric
    call search_engine
    jc near record_error

    mov ax, bx
    mov cx, 7
    mul cx
    mov di, student_status
    add di, ax
    push di
    mov cx, 7
    mov al, ' '
    rep stosb
    pop di

    mov dx, msg_status
    call print_string
    mov cx, 0
.input_loop:
    call read_char
    cmp al, 13
    je near .input_done
    mov [di], al
    inc di
    inc cx
    cmp cx, 7
    jb near .input_loop
.input_done:
    jmp near operation_complete

; --- MODULE 4: FEE MANAGEMENT ---
mod_fee:
    mov dx, msg_roll
    call print_string
    call input_numeric
    call search_engine
    jc near record_error

    mov ax, bx
    mov cx, 7
    mul cx
    mov di, student_fees
    add di, ax
    push di
    mov cx, 7
    mov al, ' '
    rep stosb
    pop di

    mov dx, msg_fee
    call print_string
    mov cx, 0
.input_loop:
    call read_char
    cmp al, 13
    je near .input_done
    mov [di], al
    inc di
    inc cx
    cmp cx, 7
    jb near .input_loop
.input_done:
    jmp near operation_complete

; --- MODULE 5: ATTENDANCE MANAGEMENT (NUMERIC 0-100) ---
mod_attendance:
    mov dx, msg_roll
    call print_string
    call input_numeric
    call search_engine
    jc near record_error

    mov ax, bx
    mov cx, 7
    mul cx
    mov di, student_attendance
    add di, ax

    ; Clear the 7-byte field with spaces first
    push di
    mov cx, 7
    mov al, ' '
    rep stosb
    pop di                      ; di now points to start of attendance field

    ; Read numeric attendance value (0-100) into ax
    mov dx, msg_attn
    call print_string
    call input_numeric          ; ax = entered number (0-100)

    ; Store numeric value as text characters into the field
    call store_numeric_field

    jmp near operation_complete

; --- MODULE 6: HEALTH AND DISABILITY ---
mod_health:
    mov dx, msg_roll
    call print_string
    call input_numeric
    call search_engine
    jc near record_error

    mov ax, bx
    mov cx, 7
    mul cx
    mov di, student_health
    add di, ax
    push di
    mov cx, 7
    mov al, ' '
    rep stosb
    pop di

    mov dx, msg_health
    call print_string
    mov cx, 0
.input_loop:
    call read_char
    cmp al, 13
    je near .input_done
    mov [di], al
    inc di
    inc cx
    cmp cx, 7
    jb near .input_loop
.input_done:
    jmp near operation_complete

; --- MODULE 7: PERFORMANCE EVALUATION ---
mod_performance:
    mov dx, msg_roll
    call print_string
    call input_numeric
    call search_engine
    jc near record_error

    mov ax, bx
    mov cx, 7
    mul cx
    mov di, student_perf
    add di, ax
    push di
    mov cx, 7
    mov al, ' '
    rep stosb
    pop di

    mov dx, msg_perf
    call print_string
    mov cx, 0
.input_loop:
    call read_char
    cmp al, 13
    je near .input_done
    mov [di], al
    inc di
    inc cx
    cmp cx, 7
    jb near .input_loop
.input_done:
    jmp near operation_complete

; --- MODULE 8: SEARCH STUDENT ---
mod_search:
    mov dx, msg_roll
    call print_string
    call input_numeric
    call search_engine
    jc near record_error

    mov si, bx
    call clear_screen
    mov dx, table_header
    call print_string
    call display_row

    mov dx, str_pause
    call print_string
    call press_any_key
    jmp near main_program

; --- MODULE 9: DELETE STUDENT RECORD ---
mod_delete:
    mov dx, msg_roll
    call print_string
    call input_numeric
    call search_engine
    jc near record_error

    mov [delete_index], bx

    mov cx, [record_count]
    sub cx, bx
    dec cx
    cmp cx, 0
    je near .update_count

.shift_loop:
    push cx

    ; 1. Shift Roll Numbers (2 Bytes each)
    mov bx, [delete_index]
    mov si, bx
    inc si
    shl si, 1
    shl bx, 1
    mov ax, [student_rolls + si]
    mov [student_rolls + bx], ax

    ; 2. Shift Names (20 Bytes each)
    mov bx, [delete_index]
    mov ax, bx
    inc ax
    mov cx, 20
    mul cx
    mov si, ax

    mov ax, [delete_index]
    mov cx, 20
    mul cx
    mov di, ax

    push ds
    pop es
    mov cx, 20
    rep movsb

    ; 3. Shift Status (7 Bytes each)
    mov bx, [delete_index]
    mov ax, bx
    inc ax
    mov cx, 7
    mul cx
    mov si, ax

    mov ax, [delete_index]
    mov cx, 7
    mul cx
    mov di, ax
    mov cx, 7
    rep movsb

    ; 4. Shift Fees (7 Bytes each)
    mov bx, [delete_index]
    mov ax, bx
    inc ax
    mov cx, 7
    mul cx
    mov si, ax

    mov ax, [delete_index]
    mov cx, 7
    mul cx
    mov di, ax
    mov cx, 7
    rep movsb

    ; 5. Shift Attendance (7 Bytes each)
    mov bx, [delete_index]
    mov ax, bx
    inc ax
    mov cx, 7
    mul cx
    mov si, ax

    mov ax, [delete_index]
    mov cx, 7
    mul cx
    mov di, ax
    mov cx, 7
    rep movsb

    ; 6. Shift Health Logs (7 Bytes each)
    mov bx, [delete_index]
    mov ax, bx
    inc ax
    mov cx, 7
    mul cx
    mov si, ax

    mov ax, [delete_index]
    mov cx, 7
    mul cx
    mov di, ax
    mov cx, 7
    rep movsb

    ; 7. Shift Performance Entry (7 Bytes each)
    mov bx, [delete_index]
    mov ax, bx
    inc ax
    mov cx, 7
    mul cx
    mov si, ax

    mov ax, [delete_index]
    mov cx, 7
    mul cx
    mov di, ax
    mov cx, 7
    rep movsb

    inc word [delete_index]
    pop cx
    dec cx
    cmp cx, 0
    jne near .shift_loop

.update_count:
    dec word [record_count]
    jmp near operation_complete

record_error:
    mov dx, str_error
    call print_string
    mov dx, str_pause
    call print_string
    call press_any_key
    jmp near main_program

; 5. SYSTEM SUBSYSTEMS & ALGORITHMS

search_engine:
    push cx
    push si
    mov cx, [record_count]
    xor si, si
.loop:
    cmp cx, 0
    je .not_found
    mov bx, si
    shl bx, 1
    mov dx, [student_rolls + bx]
    shr bx, 1
    cmp dx, ax
    je .found
    inc si
    dec cx
    jmp .loop
.found:
    mov bx, si
    pop si
    pop cx
    clc
    ret
.not_found:
    pop si
    pop cx
    stc
    ret


store_numeric_field:
    push ax
    push bx
    push cx
    push dx

    xor cx, cx              ; digit counter
    mov bx, 10
.snf_div:
    xor dx, dx
    div bx                  ; ax = quotient, dx = remainder digit
    push dx                 ; push digit onto stack
    inc cx
    cmp ax, 0
    jne .snf_div

.snf_store:
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    loop .snf_store

    pop dx
    pop cx
    pop bx
    pop ax
    ret

display_row:
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov bx, si
    call print_newline
    mov dl, ' '
    call print_character

    ; 1. Draw Roll Number Cell
    mov bx, si
    shl bx, 1
    mov ax, [student_rolls + bx]
    call print_number

    cmp ax, 10
    jae .p1
    mov dl, ' '
    call print_character
.p1:
    cmp ax, 100
    jae .p2
    mov dl, ' '
    call print_character
.p2:
    mov dl, ' '
    call print_character
    call print_table_bar

    ; 2. Draw Name Cell (20 Chars)
    mov ax, si
    mov cx, 20
    mul cx
    mov di, student_names
    add di, ax
    mov cx, 20
.c1:
    mov dl, [di]
    call print_character
    inc di
    loop .c1
    call print_table_bar

    ; 3. Draw Status Cell (7 Chars)
    mov ax, si
    mov cx, 7
    mul cx
    mov di, student_status
    add di, ax
    mov cx, 7
.c2:
    mov dl, [di]
    call print_character
    inc di
    loop .c2
    call print_table_bar

    ; 4. Draw Fees Cell (7 Chars)
    mov ax, si
    mov cx, 7
    mul cx
    mov di, student_fees
    add di, ax
    mov cx, 7
.c3:
    mov dl, [di]
    call print_character
    inc di
    loop .c3
    call print_table_bar

    ; 5. Draw Attendance Cell (7 Chars) - displays stored numeric text
    mov ax, si
    mov cx, 7
    mul cx
    mov di, student_attendance
    add di, ax
    mov cx, 7
.c4:
    mov dl, [di]
    call print_character
    inc di
    loop .c4
    call print_table_bar

    ; 6. Draw Health Cell (7 Chars)
    mov ax, si
    mov cx, 7
    mul cx
    mov di, student_health
    add di, ax
    mov cx, 7
.c5:
    mov dl, [di]
    call print_character
    inc di
    loop .c5
    call print_table_bar

    ; 7. Draw Performance Text Cell (7 Chars)
    mov ax, si
    mov cx, 7
    mul cx
    mov di, student_perf
    add di, ax
    mov cx, 7
.c6:
    mov dl, [di]
    call print_character
    inc di
    loop .c6

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; 6. BIOS / DOS INTERRUPT WRAPPERS

operation_complete:
    mov dx, str_success
    call print_string
    mov dx, str_pause
    call print_string
    call press_any_key
    jmp near main_program

print_string:
    mov ah, 9
    int 21h
    ret

print_character:
    mov ah, 2
    int 21h
    ret

read_char:
    mov ah, 1
    int 21h
    ret

get_input_string:
    mov ah, 0Ah
    int 21h
    ret

press_any_key:
    mov ah, 01h
    int 21h
    cmp al, 13
    jne press_any_key
    ret

input_numeric:
    mov dx, input_buffer
    call get_input_string
    xor ax, ax
    mov si, input_buffer+2
    xor cx, cx
    mov cl, [input_buffer+1]
.loop:
    cmp cx, 0
    je .done
    mov bl, [si]
    cmp bl, 13
    je .done
    sub bl, '0'
    mov dx, 10
    mul dx
    xor bh, bh
    add ax, bx
    inc si
    dec cx
    jmp .loop
.done:
    ret

print_number:
    push ax
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
.div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .div_loop
.print_loop:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop .print_loop
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_newline:
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    ret

print_table_bar:
    mov dl, ' '
    call print_character
    mov dl, '|'
    call print_character
    mov dl, ' '
    call print_character
    ret

clear_screen:
    mov ax, 0003h
    int 10h
    ret

; --- MODULE 10: SYSTEM TERMINATION ---
mod_exit:
    call clear_screen
    mov dx, str_goodbye
    call print_string
    mov ax, 4C00h
    int 21h