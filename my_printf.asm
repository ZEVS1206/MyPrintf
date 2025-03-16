section .data
    format db "Hello, %s", 0Ah, 0
    number db "Test", 0
    len_of_number equ $ - number
    buffer_for_text db 64 dup(0) 
    len_of_buffer equ $ - buffer_for_text
    buffer_index dq 0            

section .text
    global _start





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
    cmp dl, 's'                 
    je print_string

    
    call buffer_write_char
    inc rsi                     
    jmp analyze_format

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
    jmp analyze_format

    end_printf:
    call flush_buffer           
    pop rbp                     
    ret                         

_start:
    
    push len_of_number
    push number
    push format
    call my_printf
    add rsp, 5 * 8              
    ;call flush_buffer
    mov rax, 60                 
    xor rdi, rdi                
    syscall