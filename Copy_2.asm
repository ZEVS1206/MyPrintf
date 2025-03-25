section .data
    buffer_for_text db 500 dup(0)
    len_of_buffer equ $ - buffer_for_text
    buffer_index dq 0
    hex_digits db "0123456789abcdef"

jmp_table:
    dq print_binary_number    ; %b
    dq print_char            ; %c
    dq print_decimal_number  ; %d
    dq print_hex_number      ; %h
    dq print_octal_number    ; %o
    dq print_string          ; %s

section .text
    global my_printf

buffer_write_char:
    push rcx
    push rdx
    mov rcx, [buffer_index]
    cmp rcx, len_of_buffer
    jae .flush
;add_to_buffer
.store:
    mov [buffer_for_text + rcx], dl
    inc rcx
    mov [buffer_index], rcx
    pop rdx
    pop rcx
    ret
;clean buffer
.flush:
    call flush_buffer
    mov rcx, 0
    jmp .store

flush_buffer:
    mov rax, 1
    mov rdi, 1
    lea rsi, [buffer_for_text]
    mov rdx, [buffer_index]
    syscall
    mov qword [buffer_index], 0
    ret

print_string:
    push rbp
    mov rbp, rsp
    push rbx
    
    mov rbx, rdi
.loop:
    mov dl, [rbx]
    test dl, dl
    jz .done
    call buffer_write_char
    inc rbx
    jmp .loop
.done:

    pop rbx
    pop rbp
    ret

print_binary_number:
    push rbp
    mov rbp, rsp
    push rbx

    mov rax, rdi
    mov rcx, 64
    mov rbx, 1
    shl rbx, 63
    
.find_msb:
    test rax, rbx
    jnz .convert
    shr rbx, 1
    dec rcx
    jnz .find_msb
    
    ; If zero
    mov dl, '0'
    call buffer_write_char
    jmp .done
    
.convert:
    mov r12, rax
.print_loop:
    mov dl, '0'
    test r12, rbx
    jz .store_char
    mov dl, '1'
.store_char:
    call buffer_write_char
    shr rbx, 1
    loop .print_loop
    
.done:

    pop rbx
    pop rbp
    ret

print_octal_number:
    push rbp
    mov rbp, rsp
    push rbx
    
    mov rax, rdi
    mov r12, 8
    xor rcx, rcx
    
    test rax, rax
    jnz .convert
    mov dl, '0'
    call buffer_write_char
    jmp .done
    
.convert:
    xor rdx, rdx
    div r12
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .convert
    
.print:
    pop rdx
    call buffer_write_char
    loop .print
    
.done:
    pop rbx
    pop rbp
    ret

print_hex_number:
    push rbp
    mov rbp, rsp
    push rbx
    
    mov rax, rdi
    mov r12, 16
    xor rcx, rcx
    
    test rax, rax
    jnz .convert
    mov dl, '0'
    call buffer_write_char
    jmp .done
    
.convert:
    xor rdx, rdx
    div r12
    mov dl, [hex_digits + rdx]
    push rdx
    inc rcx
    test rax, rax
    jnz .convert
    
.print:
    pop rdx
    call buffer_write_char
    loop .print
    
.done:
    pop rbx
    pop rbp
    ret

print_decimal_number:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    mov rax, rdi
    mov r12, 10
    xor rcx, rcx
    
    test rax, rax
    jnz .check_negative
    mov dl, '0'
    call buffer_write_char
    jmp .done
    
.check_negative:
    bt rax, 63
    jnc .convert
    neg rax
    mov dl, '-'
    call buffer_write_char
    
.convert:
    xor rdx, rdx
    div r12
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .convert
    
.print:
    pop rdx
    call buffer_write_char
    loop .print
    
.done:
    pop r12
    pop rbx
    pop rbp
    ret

print_char:
    mov dl, dil
    call buffer_write_char
    ret

my_printf:
    push rbp
    mov rbp, rsp
    push rbx

    ; Save all arguments
    mov r14, rdi        ; Save format string
    mov r15, rsi        ; Save first argument
    mov rbx, rdx        ; Save second argument
    mov r12, rcx        ; Save third argument
    mov r11, r8         ; Save fourth argument
    mov r10, r9         ; Save fifth argument
    
    ; Stack arguments start at rbp+16
    lea r13, [rbp + 16]
    xor r9, r9          ; Argument counter

    mov rsi, r14        ; format string pointer

.process:
    mov dl, [rsi]
    test dl, dl
    jz .done

    cmp dl, '%'
    je .specifiyer

    ; Not a specifiyer
    call buffer_write_char
    inc rsi
    jmp .process

.specifiyer:
    inc rsi
    mov dl, [rsi]
    test dl, dl
    jz .done

    ;Choose specifiyer
    xor rax, rax
    cmp dl, 'b'
    je .prepare
    inc rax
    cmp dl, 'c'
    je .prepare
    inc rax
    cmp dl, 'd'
    je .prepare
    inc rax
    cmp dl, 'h'
    je .prepare
    inc rax
    cmp dl, 'o'
    je .prepare
    inc rax
    cmp dl, 's'
    je .prepare

    ; Unknown specifiyer
    mov dl, '%'
    call buffer_write_char
    jmp .process

.prepare:
    inc r9
    cmp r9, 1
    je .arg1
    cmp r9, 2
    je .arg2
    cmp r9, 3
    je .arg3
    cmp r9, 4
    je .arg4
    cmp r9, 5
    je .arg5
    cmp r9, 6
    je .arg6

    ; Arguments 7+
    mov rdi, [r13]
    add r13, 8
    jmp .jump

.arg1:
    mov rdi, r15
    jmp .jump
.arg2:
    mov rdi, rbx
    jmp .jump
.arg3:
    mov rdi, r12
    jmp .jump
.arg4:
    mov rdi, r11
    jmp .jump
.arg5:
    mov rdi, r10
    jmp .jump
.arg6:
    mov rdi, [r13]
    add r13, 8

.jump:
    call [jmp_table + rax * 8]
    inc rsi
    jmp .process

.done:
    call flush_buffer

    pop rbx
    pop rbp
    ret