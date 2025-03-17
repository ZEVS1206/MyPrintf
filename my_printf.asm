section .data
    buffer_for_text db 64 dup(0) 
    len_of_buffer equ $ - buffer_for_text
    buffer_index dq 0

; Таблица переходов
jmp_table:
    dq print_binary_number; %b
    dq print_char         ; %c
    dq print_decimal_number ; %d
    dq print_string       ; %s

section .text
    global my_printf 

buffer_write_char:
    mov rcx, [buffer_index]      
    cmp rcx, len_of_buffer       
    jge flush_buffer             

    mov [buffer_for_text + rcx], dl 
    inc rcx                      
    mov [buffer_index], rcx      
    ret

flush_buffer:
    mov rax, 1                  
    mov rdi, 1                  
    lea rsi, [buffer_for_text]  
    mov rdx, [buffer_index]
    syscall

    mov byte [buffer_for_text], 0
    mov qword [buffer_index], 0
    ret

print_string:
    mov r9, rdi              

    add_string_to_buffer:
    mov dl, [r9]            
    cmp dl, 0               
    je end_add_string
    call buffer_write_char  
    inc r9                 
    jmp add_string_to_buffer
    end_add_string:
    ret

print_binary_number:
    movsx r9, edi
    mov r11, 2
    xor rcx, rcx

    .convert_number:
    mov rax, r9
    xor rdx, rdx
    div r11

    mov r9, rax
    add dl, '0'
    push rdx
    inc rcx
    cmp r9, 0
    jne .convert_number

    .add_to_buffer:
    pop rdx
    mov r10, rcx
    call buffer_write_char
    mov rcx, r10
    loop .add_to_buffer

    ret



print_decimal_number:
    movsx r9, edi
    mov r11, 10
    xor rcx, rcx
;Process negative number
;--------------------------
    cmp r9, 0
    jns .convert_number
    neg r9
    mov dl, '-'
    call buffer_write_char
    xor rcx, rcx
;--------------------------

    .convert_number:
    mov rax, r9
    xor rdx, rdx
    div r11

    mov r9, rax
    add dl, '0'
    push rdx
    inc rcx
    cmp r9, 0
    jne .convert_number

    .add_to_buffer:
    pop rdx
    mov r10, rcx
    call buffer_write_char
    mov rcx, r10
    loop .add_to_buffer

    ret

print_char:
    mov dl, dil
    call buffer_write_char
    ret

my_printf:
    push rbp     ;Save old stack frame
    mov rbp, rsp ;Create new stack frame for virtual space

    push r9 
    push r8
    push rcx
    push rdx
    push rsi
    push rdi

    call my_printf_cdecl

    add rsp, 48  

    pop rbp ;Return old stack frame
    ret

my_printf_cdecl:
    push rbp
    mov rbp, rsp

    mov rsi, [rbp + 16]  ; format
    lea rbx, [rbp + 24]  ; first argument

    analyze_format:
    mov dl, [rsi]               
    cmp dl, 0                   
    je end_printf

    cmp dl, '%'                 
    je check_format

    call buffer_write_char
    inc rsi                    
    jmp analyze_format

    check_format:
    inc rsi                     
    mov dl, [rsi]

    cmp dl, 'b'
    je .binary

    cmp dl, 'c'
    je .char

    cmp dl, 'd'
    je .decimal

    cmp dl, 's'
    je .string

    jmp .default

    .binary:
    mov rax, 0
    jmp .jump

    .char:
    mov rax, 1
    jmp .jump

    .decimal:
    mov rax, 2
    jmp .jump

    .string:
    mov rax, 3 
    jmp .jump

    .default:
    call buffer_write_char
    inc rsi                     
    jmp analyze_format

    .jump:
    mov rdi, [rbx]
    add rbx, 8

    lea r10, [jmp_table + rax * 8]; Calculate address in jump table
    call [r10]; Call function for processing
    inc rsi ;Skip symbol of specificator
    jmp analyze_format

    end_printf:
    call flush_buffer           
    pop rbp                     
    ret