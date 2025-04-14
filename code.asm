include irvine32.inc

HEAP_START = 2000000
HEAP_MAX = 400000000

.data
hHeap HANDLE ?
pArray DWORD ?
temp_buffer sword 4 DUP(?) 
adv_size_prompt byte "Choose matrix size:", 0Dh, 0Ah
                byte "[2] 2x2  [3] 3x3", 0
error_square byte "Matrix must be square!", 0
div_const_prompt byte "Enter divisor (non-zero): ", 0
error_div_zero byte "Cannot divide by zero!", 0

; Menu strings
options byte "Choose operation:", 0Dh, 0Ah
        byte "[1] Add  [2] Subtract  [3] Multiply by constant  [4] Divide by a constant", 0Dh, 0Ah
        byte "[5] Multiply matrices  [6] Determinant  [7] Transpose", 0Dh, 0Ah
        byte "[8] Adjoint  [9] Inverse  [10] Exit", 0

; Error messages
error_input byte "Invalid input! Try again.", 0
error_dim byte "Dimension mismatch!", 0
error_singular byte "Matrix is singular!", 0

; Input prompts
input_dim byte "Enter matrix dimensions (rows columns): ", 0
input_mat1 byte "Enter first matrix elements:", 0
input_mat2 byte "Enter second matrix elements:", 0
input_const byte "Enter constant: ", 0
output_label byte "Result:", 0

; Matrix storage
MAX_SIZE = 16
matrix1 sword MAX_SIZE DUP(?)
matrix2 sword MAX_SIZE DUP(?)
result sword MAX_SIZE DUP(?)
temp sword MAX_SIZE DUP(?)

rows1 byte ?
cols1 byte ?
rows2 byte ?
cols2 byte ?
const sword ?

.code
main proc
    INVOKE HeapCreate, 0, HEAP_START, HEAP_MAX
    mov hHeap, eax

main_loop:
    call Clrscr
    mov edx, OFFSET options
    call WriteString
    call Crlf
    call ReadInt

    cmp eax, 1
    je addition
    cmp eax, 2
    je subtraction
    cmp eax, 3
    je multiply_const
    cmp eax, 4
    je divide_const
    cmp eax, 6
    je multiply_matrices
    cmp eax, 7
    je determinant
    cmp eax, 8
    je transpose
    cmp eax, 9
    je adjoint
    cmp eax, 10
    je inverse
    cmp eax, 11
    je exit_program

    ; Invalid input handling
    mov edx, OFFSET error_input
    call WriteString
    call Crlf
    call WaitMsg
    jmp main_loop

divide_const:
    call get_one_matrix
    call get_constant
    call matrix_div_const
    call show_result
    jmp main_loop

addition:
    call get_two_matrices
    call matrix_add
    call show_result
    jmp main_loop

subtraction:
    call get_two_matrices
    call matrix_sub
    call show_result
    jmp main_loop

multiply_const:
    call get_one_matrix
    call get_constant
    call matrix_mul_const
    call show_result
    jmp main_loop

multiply_matrices:
    call get_dimensions_mul
    call input_matrix1
    call input_matrix2
    call matrix_mul
    call show_result
    jmp main_loop

transpose:
    call get_one_matrix
    call matrix_transpose
    call show_result
    jmp main_loop

determinant:
    call handle_determinant
    jmp main_loop

adjoint:
    call handle_adjoint
    jmp main_loop

inverse:
    call handle_inverse
    jmp main_loop

exit_program:
    exit
main endp

;------------------- Utility Procedures -------------------
get_two_matrices proc
    call get_dimensions
    call input_matrix1
    call input_matrix2
    ret
get_two_matrices endp

get_one_matrix proc
    call get_dimensions
    call input_matrix1
    ret
get_one_matrix endp

handle_advanced_matrix proc
    mov edx, OFFSET adv_size_prompt
    call WriteString
    call Crlf
    call ReadInt

    cmp eax, 2
    je valid_size
    cmp eax, 3
    je valid_size
    mov edx, OFFSET error_input
    call WriteString
    call Crlf
    xor al, al
    ret

valid_size:
    mov rows1, al
    mov cols1, al
    mov edx, OFFSET input_mat1
    call WriteString
    call Crlf
    movzx ecx, rows1
    imul ecx, ecx
    mov esi, OFFSET matrix1
    call read_matrix
    ret
handle_advanced_matrix endp


get_dimensions proc
    mov edx, OFFSET input_dim
    call WriteString
    call ReadInt
    mov rows1, al
    call ReadInt
    mov cols1, al
    mov rows2, al
    mov cols2, al
    ret
get_dimensions endp

get_dimensions_mul proc
    mov edx, OFFSET input_dim
    call WriteString
    call ReadInt
    mov rows1, al
    call ReadInt
    mov cols1, al
    mov edx, OFFSET input_dim
    call WriteString
    call ReadInt
    mov cols2, al
    ret
get_dimensions_mul endp

input_matrix1 proc
    mov edx, OFFSET input_mat1
    call WriteString
    call Crlf
    movzx ecx, rows1
    movzx ebx, cols1
    imul ecx, ebx
    mov esi, OFFSET matrix1
    call read_matrix
    ret
input_matrix1 endp

input_matrix2 proc
    mov edx, OFFSET input_mat2
    call WriteString
    call Crlf
    movzx ecx, rows2
    movzx ebx, cols2
    imul ecx, ebx
    mov esi, OFFSET matrix2
    call read_matrix
    ret
input_matrix2 endp

read_matrix proc
    pushad
    L1:
        call ReadInt
        mov [esi], ax
        add esi, 2
        loop L1
    popad
    ret
read_matrix endp

show_matrix proc
    pushad
    movzx ecx, rows1
    movzx ebx, cols1
    mov esi, OFFSET result
    row_loop:
        push ecx
        mov ecx, ebx
        col_loop:
            movsx eax, sword ptr [esi]
            call WriteInt
            mov al, ' '
            call WriteChar
            add esi, 2
            loop col_loop
        call Crlf
        pop ecx
        loop row_loop
    popad
    ret
show_matrix endp

;------------------- Matrix Operations -------------------
matrix_add proc
    pushad
    mov al, rows1
    cmp al, rows2
    jne add_err
    mov al, cols1
    cmp al, cols2
    jne add_err

    movzx ecx, rows1
    movzx ebx, cols1
    imul ecx, ebx
    mov esi, OFFSET matrix1
    mov edi, OFFSET matrix2
    mov edx, OFFSET result
    L1:
        mov ax, [esi]
        add ax, [edi]
        mov [edx], ax
        add esi, 2
        add edi, 2
        add edx, 2
        loop L1
    jmp add_done

    add_err:
    mov edx, OFFSET error_dim
    call WriteString
    call WaitMsg

    add_done:
    popad
    ret
matrix_add endp

matrix_sub proc
    pushad
    mov al, rows1
    cmp al, rows2
    jne sub_err
    mov al, cols1
    cmp al, cols2
    jne sub_err

    movzx ecx, rows1
    movzx ebx, cols1
    imul ecx, ebx
    mov esi, OFFSET matrix1
    mov edi, OFFSET matrix2
    mov edx, OFFSET result
    L1:
        mov ax, [esi]
        sub ax, [edi]
        mov [edx], ax
        add esi, 2
        add edi, 2
        add edx, 2
        loop L1
    jmp sub_done

    sub_err:
    mov edx, OFFSET error_dim
    call WriteString
    call WaitMsg

    sub_done:
    popad
    ret
matrix_sub endp

matrix_mul_const proc
    pushad
    movzx ecx, rows1
    movzx ebx, cols1
    imul ecx, ebx
    mov esi, OFFSET matrix1
    mov edx, OFFSET result
    L1:
        mov ax, [esi]
        imul const
        mov [edx], ax
        add esi, 2
        add edx, 2
        loop L1
    popad
    ret
matrix_mul_const endp

matrix_transpose proc
    pushad
    movzx ecx, rows1
    movzx edx, cols1
    mov esi, OFFSET matrix1
    mov edi, OFFSET result
    
    xor ebx, ebx
    transpose_outer:
        xor eax, eax
        transpose_inner:
            mov edi, ebx
            imul edi, edx
            add edi, eax
            shl edi, 1
            
            mov esi, eax
            imul esi, ecx
            add esi, ebx
            shl esi, 1
            
            mov ax, [matrix1 + esi]
            mov [result + edi], ax
            
            inc eax
            cmp eax, edx
            jl transpose_inner
        inc ebx
        cmp ebx, ecx
        jl transpose_outer
    popad
    ret
matrix_transpose endp

matrix_div_const proc
    pushad
    ; Check for division by zero (should be prevented by get_constant, but double-check)
    cmp const, 0
    je div_zero_error

    movzx ecx, rows1
    movzx ebx, cols1
    imul ecx, ebx
    mov esi, OFFSET matrix1
    mov edi, OFFSET result

divide_loop:
    mov ax, [esi]       ; Load current element
    cwd                 ; Sign extend AX into DX:AX
    idiv const          ; Divide by constant
    mov [edi], ax       ; Store result
    add esi, 2
    add edi, 2
    loop divide_loop
    jmp div_done

div_zero_error:
    mov edx, OFFSET error_div_zero
    call WriteString
    call WaitMsg

div_done:
    popad
    ret
matrix_div_const endp

; Updated get_constant to prevent zero input
get_constant proc
get_input:
    mov edx, OFFSET div_const_prompt
    call WriteString
    call ReadInt
    cmp ax, 0
    jne valid_divisor
    mov edx, OFFSET error_div_zero
    call WriteString
    call Crlf
    jmp get_input
valid_divisor:
    mov const, ax
    ret
get_constant endp

matrix_mul proc
    pushad
    mov al, cols1
    cmp al, rows2
    jne mul_err
    
    movzx eax, rows1
    movzx ebx, cols2
    imul eax, ebx
    mov ecx, eax
    mov edi, OFFSET result
    xor eax, eax
    rep stosw

    movzx ecx, rows1
    mov esi, OFFSET matrix1
    mov edi, OFFSET result

    row_loop:
        push ecx
        movzx ecx, cols2
        mov ebx, OFFSET matrix2
        
        col_loop:
            push ecx
            movzx ecx, cols1
            mov edx, esi
            mov ax, 0
            
            dot_product:
                push ax
                mov ax, [edx]
                imul word ptr [ebx]
                pop dx
                add ax, dx
                mov dx, ax
                add edx, 2
                add ebx, 2
                loop dot_product
            
            mov [edi], dx
            add edi, 2
            pop ecx
            loop col_loop
        
        movzx eax, cols1
        shl eax, 1
        add esi, eax
        pop ecx
        loop row_loop
    jmp mul_done

    mul_err:
    mov edx, OFFSET error_dim
    call WriteString
    call WaitMsg
    
    mul_done:
    popad
    ret
matrix_mul endp

;------------------- Advanced Operations -------------------
determinant_2x2 proc
    pushad
    mov esi, OFFSET matrix1
    mov ax, [esi]
    imul word ptr [esi+6]
    mov bx, ax
    mov ax, [esi+2]
    imul word ptr [esi+4]
    sub bx, ax
    mov [result], bx
    popad
    ret
determinant_2x2 endp

determinant_3x3 proc
    pushad
    mov esi, OFFSET matrix1
    mov ax, [esi]        ; a
    imul word ptr [esi+8] ; f
    imul word ptr [esi+16] ; i
    mov bx, ax
    
    mov ax, [esi+4]      ; d
    imul word ptr [esi+12] ; c
    imul word ptr [esi+20] ; j
    add bx, ax
    
    mov ax, [esi+6]      ; g
    imul word ptr [esi+14] ; b
    imul word ptr [esi+22] ; k
    add bx, ax
    
    sub bx, [esi+2]      ; b
    imul word ptr [esi+10] ; e
    imul word ptr [esi+18] ; h
    
    sub bx, [esi+6]      ; g
    imul word ptr [esi+16] ; i
    imul word ptr [esi+4] ; d
    
    sub bx, [esi+0]      ; a
    imul word ptr [esi+14] ; b
    imul word ptr [esi+22] ; k
    
    mov [result], bx
    popad
    ret
determinant_3x3 endp

adjoint_2x2 proc
    mov esi, OFFSET matrix1
    mov edi, OFFSET temp
    
    mov ax, [esi+6]
    mov [edi], ax
    mov ax, [esi]
    mov [edi+6], ax
    
    mov ax, [esi+2]
    neg ax
    mov [edi+2], ax
    
    mov ax, [esi+4]
    neg ax
    mov [edi+4], ax
    
    ret
adjoint_2x2 endp

inverse_2x2 proc
    call determinant_2x2
    cmp word ptr [result], 0
    je singular
    
    call adjoint_2x2
    mov cx, [result]
    mov esi, OFFSET temp
    mov edi, OFFSET result
    mov ecx, 4
    scale_loop:
        mov ax, [esi]
        cwd
        idiv cx
        mov [edi], ax
        add esi, 2
        add edi, 2
        loop scale_loop
    ret
    
    singular:
    mov edx, OFFSET error_singular
    call WriteString
    call WaitMsg
    ret
inverse_2x2 endp

;======================= 3x3 ADJOINT =======================
adjoint_3x3 proc
    pushad
    ; 1. Calculate matrix of minors
    mov esi, OFFSET matrix1
    mov edi, OFFSET temp
    mov ecx, 9
    minor_loop_adj:
        call get_minor_3x3
        add edi, 2
        add esi, 2
        loop minor_loop_adj

    ; 2. Create cofactor matrix
    mov esi, OFFSET temp
    mov edi, OFFSET result
    mov ecx, 9
    mov ebx, 1
    cofactor_loop_3x3:
        mov ax, [esi]
        imul bx
        mov [edi], ax
        neg bx
        add esi, 2
        add edi, 2
        loop cofactor_loop_3x3

    ; 3. Transpose (adjugate)
    call transpose_3x3
    popad
    ret
adjoint_3x3 endp

get_minor_3x3 proc
    pushad
    mov eax, esi
    sub eax, OFFSET matrix1
    shr eax, 1
    
    xor edx, edx
    mov ebx, 3
    div ebx
    
    push eax
    push edx
    
    mov ecx, 3
    mov esi, OFFSET matrix1
    mov edi, OFFSET temp_buffer
    xor ebx, ebx
    
    row_loop_minor:
        cmp ebx, eax
        je skip_row_minor
        xor edx, edx
        col_loop_minor:
            cmp edx, [esp+4]
            je skip_col_minor
            mov ax, [esi]
            mov [edi], ax
            add edi, 2
            skip_col_minor:
            add esi, 2
            inc edx
            cmp edx, 3
            jl col_loop_minor
        jmp next_row_minor
        skip_row_minor:
        add esi, 6
        next_row_minor:
        inc ebx
        loop row_loop_minor
    
    call determinant_2x2
    pop edx
    pop eax
    popad
    ret
get_minor_3x3 endp

transpose_3x3 proc
    pushad
    mov ecx, 3
    mov ebx, 0
    transpose_loop:
        mov eax, ebx
        imul eax, 6
        mov ax, [result + eax]
        xchg ax, [result + ebx*2 + 2]
        mov [result + eax], ax
        
        mov eax, ebx
        imul eax, 6
        add eax, 4
        mov ax, [result + eax]
        xchg ax, [result + ebx*2 + 4]
        mov [result + eax], ax
        
        inc ebx
        loop transpose_loop
    popad
    ret
transpose_3x3 endp

;======================= 3x3 INVERSE =======================
inverse_3x3 proc
    pushad
    ; 1. Calculate determinant
    call determinant_3x3
    cmp word ptr [result], 0
    je singular_3x3
    
    ; 2. Calculate adjugate
    call adjoint_3x3
    
    ; 3. Divide by determinant
    mov cx, [result] ; determinant
    mov esi, OFFSET result
    mov ecx, 9
    scale_inverse_3x3:
        mov ax, [esi]
        cwd
        idiv word ptr [result] ; divide by determinant
        mov [esi], ax
        add esi, 2
        loop scale_inverse_3x3
    jmp inverse_done_3x3

    singular_3x3:
    mov edx, OFFSET error_singular
    call WriteString
    call WaitMsg
    
    inverse_done_3x3:
    popad
    ret
inverse_3x3 endp

;======================= UPDATED HANDLERS =======================
handle_adjoint proc
    call handle_advanced_matrix
    cmp rows1, 0
    je adj_exit

    mov al, rows1
    cmp al, cols1
    jne adj_err

    cmp al, 2
    je adj2
    cmp al, 3
    je adj3

adj2:
    call adjoint_2x2
    jmp show_adj

adj3:
    call adjoint_3x3

show_adj:
    mov esi, OFFSET result
    call show_matrix
    call WaitMsg
    ret

adj_err:
    mov edx, OFFSET error_square
    call WriteString
    call WaitMsg

adj_exit:
    ret
handle_adjoint endp


;------------------- Advanced Handlers -------------------
handle_determinant proc
    call handle_advanced_matrix
    cmp rows1, 0
    je det_exit

    mov al, rows1
    cmp al, cols1
    jne det_err

    cmp al, 2
    je det2
    cmp al, 3
    je det3

det2:
    call determinant_2x2
    jmp show_det

det3:
    call determinant_3x3

show_det:
    movsx eax, word ptr [result]
    call WriteInt
    call Crlf
    call WaitMsg
    ret

det_err:
    mov edx, OFFSET error_square
    call WriteString
    call WaitMsg

det_exit:
    ret
handle_determinant endp


handle_inverse proc
    call handle_advanced_matrix
    cmp rows1, 0
    je inv_exit

    mov al, rows1
    cmp al, cols1
    jne inv_err

    cmp al, 2
    je inv2

inv2:
    call inverse_2x2
    call show_matrix
    call WaitMsg
    ret

inv_err:
    mov edx, OFFSET error_square
    call WriteString
    call WaitMsg

inv_exit:
    ret
handle_inverse endp

show_result proc
    mov edx, OFFSET output_label
    call WriteString
    call Crlf
    call show_matrix
    call WaitMsg
    ret
show_result endp

end main
