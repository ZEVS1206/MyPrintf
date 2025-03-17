section .data
    format db "Hello, %d %s", 0Ah, 0
    string db "World!", 0
    len_of_str equ $ - string
    number dd 1234
    len_of_number equ $ - number
    buffer_for_text db 64 dup(0) 
    len_of_buffer equ $ - buffer_for_text
    buffer_index dq 0

jmp_table:
    dq print_char
    dq print_decimal_number
    dq print_string


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

    mov dword [buffer_index], 0 
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

    inc rsi
    add rbp, 8
    mov rdi, [rbp]
    add rbp, 8
    mov rdx, [rbp]

    ret

print_decimal_number:
    movsx r9, dword [rdi]
    mov rbx, 10
    xor rcx, rcx

    cmp r9, 0
    jns convert_number
    neg r9
    mov dl, '-'
    call buffer_write_char

    convert_number:
    mov rax, r9
    cqo
    xor rdx, rdx

    idiv rbx

    mov r9, rax
    add dl, '0'
    push rdx
    inc rcx
    cmp r9, 0
    jne convert_number

    add_to_buffer:
    pop rdx
    mov r10, rcx
    call buffer_write_char
    mov rcx, r10
    loop add_to_buffer

    inc rsi
    add rbp, 8
    mov rdi, [rbp]
    add rbp, 8
    mov rdx, [rbp]

    ret

print_char:
    mov dl, [rdi]
    call buffer_write_char
    inc rsi
    add rbp, 8
    mov rdi, [rbp]
    add rbp, 8
    mov rdx, [rbp] 
    
    ret

my_printf:
    push rbp     ;Save old value of stack frame                    
    mov rbp, rsp ;Get new value of stack frame in virtual space of function                

    jmp empty
    add_separator:
    inc rsi
    mov dl, [rsi]

    cmp dl, 0
    je end_of

    cmp dl, 'n'
    je add_newline
    jmp end_of

    cmp dl, 't'
    je add_tab
    jmp end_of

    add_newline:
    mov dl, 0Ah
    call buffer_write_char
    ;inc rsi
    jmp end_of

    add_tab:
    mov dl, 09h
    call buffer_write_char
    ;inc rsi
    jmp end_of

    empty:
    mov rsi, [rbp + 16];format         
    mov rdi, [rbp + 24];number         
    mov rdx, [rbp + 32];len_of_number
    add rbp, 32

    analyze_format:
    mov dl, [rsi]               
    cmp dl, 0                   
    je end_printf

    cmp dl, '%'                 
    je check_format

    cmp dl, '\'
    je add_separator
    
    call buffer_write_char
    end_of:
    inc rsi                    
    jmp analyze_format

    check_format:
    inc rsi                     
    mov dl, [rsi]

    cmp dl, 'c'
    je .char
    cmp dl, 'd'
    je .decimal
    cmp dl, 's'
    je .string
    jmp .default

    .char:
    mov rax, 0
    jmp .jump

    .decimal:
    mov rax, 1
    jmp .jump

    .string:
    mov rax, 2
    jmp .jump

    .default:
    call buffer_write_char
    inc rsi                     
    jmp analyze_format

    .jump:
    lea rbx, [jmp_table + rax*8]
    call [rbx]
    jmp analyze_format

    end_printf:
    call flush_buffer           
    pop rbp                     
    ret                         

;_start:
;    push len_of_str
;    push string
;    push len_of_number
;    push number
;    push format
;    call my_printf
;    add rsp, 5 * 8              
;    mov rax, 60                 
;    xor rdi, rdi                
;    syscall