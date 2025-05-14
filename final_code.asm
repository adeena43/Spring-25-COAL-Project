include irvine32.inc

.data
temp_buffer sword 4 DUP(?)
adv_size_prompt byte "Choose matrix size:", 0Dh, 0Ah
                byte "[2] 2x2", 0
error_square byte "Matrix must be square!", 0
div_const_prompt byte "Enter divisor (non-zero): ", 0
error_div_zero byte "Cannot divide by zero!", 0
mul_const_prompt byte "Enter a constant value: ", 0
error_invalid_input byte "Error: Please enter a valid integer number", 0
input_buffer db 16 dup(0)  ; Buffer for input
const dd ?  
debug_input_msg byte "Input Matrix:",0dh,0ah,0
debug_minors_msg byte "Matrix of Minors:",0dh,0ah,0
debug_cofactors_msg byte "Cofactor Matrix:",0dh,0ah,0
debug_adjoint_msg byte "Adjoint Matrix:",0dh,0ah,0

success_msg db "Matrix multiplication completed successfully!", 0Dh, 0Ah, 0


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
round_temp dword ?

rows1 byte ?
cols1 byte ?
rows2 byte ?
cols2 byte ?


;------------------------------------------------For matrix multiplication--------------------------------------------------------------

.code
main proc
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
    cmp eax, 5
    je multiply_matrices
    cmp eax, 6
    je determinant
    cmp eax, 7
    je transpose
    cmp eax, 8
    je adjoint
    cmp eax, 9
    je inverse
    cmp eax, 10
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
    call getConstant
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
    call ReadInt         ; Reads into EAX

    cmp eax, 2
    je valid_size
    cmp eax, 3
    je valid_size

    ; Invalid size - clear rows1/cols1 and return
    mov rows1, 0
    mov cols1, 0
    mov edx, OFFSET error_input
    call WriteString
    call Crlf
    ret

valid_size:
    mov rows1, al        ; Store size (2 or 3)
    mov cols1, al
    mov edx, OFFSET input_mat1
    call WriteString
    call Crlf
    movzx ecx, rows1
    imul ecx, ecx        ; ECX = rows1 * cols1 (total elements)
    mov esi, OFFSET matrix1
    call read_matrix     ; Assume this reads ECX elements into [ESI]
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
    mov rows2, al
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
    movzx ecx, rows1        ; Load number of rows
    movzx ebx, cols1        ; Load number of columns
    imul ecx, ebx           ; Total elements = rows * cols
    mov esi, OFFSET matrix1 ; Source matrix address
    mov edi, OFFSET result  ; Result matrix address
   
    mov ebx, const           ; Load the constant
   
L1:
    mov ax, [esi]           ; Load matrix element
    imul bx                 ; Multiply by constant (result in AX)
    mov [edi], ax           ; Store result
    add esi, 2              ; Next source element
    add edi, 2              ; Next result element
    loop L1
   
    popad
    ret
matrix_mul_const endp

matrix_transpose proc
    pushad

    ; Verify rows1 and cols1 are > 0
    movzx ecx, byte ptr [rows1]
    test ecx, ecx
    jz exit_proc       ; If rows1=0, exit
    movzx edx, byte ptr [cols1]
    test edx, edx
    jz exit_proc       ; If cols1=0, exit

    xor ebx, ebx       ; i = 0 (row index)
   
outer_loop:
    xor eax, eax       ; j = 0 (col index)
   
inner_loop:
    ; Calculate source address: matrix1[i][j] = (i * cols1 + j) * 2
    mov esi, ebx       ; esi = i
    imul esi, edx      ; esi = i * cols1
    add esi, eax       ; esi = i * cols1 + j
    shl esi, 1         ; *2 for word size
    mov di, [matrix1 + esi]  ; Load word from matrix1

    ; Calculate destination address: result[j][i] = (j * rows1 + i) * 2
    mov esi, eax       ; esi = j
    imul esi, ecx      ; esi = j * rows1
    add esi, ebx       ; esi = j * rows1 + i
    shl esi, 1         ; *2 for word size
    mov [result + esi], di   ; Store transposed

    inc eax            ; j++
    cmp eax, edx
    jl inner_loop

    inc ebx            ; i++
    cmp ebx, ecx
    jl outer_loop

exit_proc:
    popad
    ret
matrix_transpose endp

matrix_div_const proc
    pushad                  ; Save all general-purpose registers
   
    ; Check for division by zero
    cmp const, 0
    je div_zero_error

    ; Calculate total number of elements (rows * cols)
    movzx eax, rows1        ; Load rows (unsigned extend to 32 bits)
    movzx ebx, cols1        ; Load cols (unsigned extend to 32 bits)
    mul ebx                ; EAX = rows * cols
    mov ecx, eax           ; ECX will be our loop counter
   
    mov esi, OFFSET matrix1 ; Source matrix
    mov edi, OFFSET result  ; Destination matrix

divide_loop:
    mov ax, [esi]          ; Load current element (16-bit)
    cwd                    ; Sign extend AX into DX:AX (32-bit)
    idiv const             ; Signed division: DX:AX / const
    mov [edi], ax          ; Store quotient (16-bit)
   
    add esi, 2             ; Move to next element (16-bit values)
    add edi, 2
    loop divide_loop       ; Repeat for all elements
   
    jmp div_done

div_zero_error:
    mov edx, OFFSET error_div_zero
    call WriteString
    call WaitMsg
    ; Optionally set some error flag here

div_done:
    popad                   ; Restore all general-purpose registers
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
    mov const, eax
    ret
get_constant endp

getConstant proc
    push edx        ; Save used registers
    push eax
   
input_loop:
    ; Display prompt
    mov edx, OFFSET input_const
    call WriteString
   
    ; Read integer input
    call ReadInt    ; Result in EAX
    jno valid_input ; Jump if no overflow
   
    ; Handle invalid input
    mov edx, OFFSET error_input
    call WriteString
    call Crlf
    jmp input_loop
   
valid_input:
    mov const, eax  ; Store in double word variable
   
    pop eax         ; Restore registers
    pop edx
    ret
getConstant endp

matrix_mul proc
    pushad                  ; Save all general-purpose registers
   
    ; Check if cols1 == rows2 (matrix multiplication requirement)
    mov al, [cols1]
    cmp al, [rows2]
    jne clean_exit          ; Silently exit if dimensions don't match

    ; Clear result matrix (initialize all elements to 0)
    movzx eax, byte ptr [rows1]
    movzx ebx, byte ptr [cols2]
    imul eax, ebx           ; Calculate total elements (rows1 * cols2)
    mov ecx, eax
    mov edi, OFFSET result
    xor ax, ax              ; Zero out AX
clear_loop:
    mov [edi], ax           ; Store zero
    add edi, 2              ; Move to next word (16-bit elements)
    loop clear_loop

    ; Setup pointers
    mov esi, OFFSET matrix1 ; Source matrix 1
    mov edi, OFFSET result  ; Result matrix
    mov ebx, OFFSET matrix2 ; Source matrix 2

    ; Outer loop - rows of matrix1
    movzx ecx, byte ptr [rows1]
row_loop:
    push ecx                ; Save row counter
    push ebx                ; Save matrix2 start address

    ; Middle loop - columns of matrix2
    movzx ecx, byte ptr [cols2]
col_loop:
    push ecx                ; Save column counter
    push esi                ; Save current row start in matrix1
    push ebx                ; Save current column start in matrix2

    ; Inner loop - dot product calculation
    movzx ecx, byte ptr [cols1]  ; Same as rows2
    xor ax, ax                   ; Clear accumulator
dot_product:
    ; Load element from matrix1 (row)
    mov ax, [esi]
    ; Load element from matrix2 (column)
    mov bp, [ebx]
    ; Multiply and accumulate
    imul bp
    add [edi], ax

    ; Move to next element in matrix1 row
    add esi, 2
    ; Move to next element in matrix2 column
    movzx edx, byte ptr [cols2]
    shl edx, 1              ; Multiply by 2 (word size)
    add ebx, edx

    loop dot_product

    ; Prepare for next column
    pop ebx                  ; Restore column start
    add ebx, 2               ; Next column in matrix2
    pop esi                  ; Restore row start
    pop ecx                  ; Restore column counter
    add edi, 2               ; Next position in result matrix
    loop col_loop

    ; Prepare for next row
    pop ebx                  ; Restore matrix2 start
    pop ecx                  ; Restore row counter
    ; Move to next row in matrix1
    movzx eax, byte ptr [cols1]
    shl eax, 1               ; Multiply by 2 (word size)
    add esi, eax
    loop row_loop

clean_exit:
    popad                   ; Restore all general-purpose registers
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
   
    ; Assuming matrix is stored in row-major order as words (2 bytes each)
    ; [0] a  [2] b  [4] c
    ; [6] d  [8] e [10] f
    ; [12]g [14]h [16]i
   
    mov esi, OFFSET matrix1
   
    ; Calculate a(ei - fh)
    mov ax, [esi+8]      ; e
    imul word ptr [esi+16] ; e*i
    mov bx, ax           ; store low word
    mov cx, dx           ; store high word
   
    mov ax, [esi+10]     ; f
    imul word ptr [esi+14] ; f*h
    sub bx, ax           ; ei - fh (low)
    sbb cx, dx           ; ei - fh (high with borrow)
   
    mov ax, [esi]        ; a
    cwd                  ; sign extend a to dx:ax
    imul bx              ; multiply a*(ei-fh) low
    mov [result], ax
    mov [result+2], dx   ; store first term
   
    ; Calculate -b(di - fg)
    mov ax, [esi+6]      ; d
    imul word ptr [esi+16] ; d*i
    mov bx, ax
    mov cx, dx
   
    mov ax, [esi+10]     ; f
    imul word ptr [esi+12] ; f*g
    sub bx, ax           ; di - fg (low)
    sbb cx, dx           ; di - fg (high)
   
    mov ax, [esi+2]      ; b
    cwd                  ; sign extend b
    imul bx              ; b*(di-fg)
    neg ax
    adc dx, 0
    neg dx               ; -b*(di-fg)
   
    add [result], ax
    adc [result+2], dx   ; add second term
   
    ; Calculate c(dh - eg)
    mov ax, [esi+6]      ; d
    imul word ptr [esi+14] ; d*h
    mov bx, ax
    mov cx, dx
   
    mov ax, [esi+8]      ; e
    imul word ptr [esi+12] ; e*g
    sub bx, ax           ; dh - eg (low)
    sbb cx, dx           ; dh - eg (high)
   
    mov ax, [esi+4]      ; c
    cwd                  ; sign extend c
    imul bx              ; c*(dh-eg)
   
    add [result], ax     ; add third term
    adc [result+2], dx
   
    ; Now check if we got zero for the test case
    ; For debugging: You can remove this after verification
    cmp word ptr [result], 0
    jne not_zero
    cmp word ptr [result+2], 0
    jne not_zero
   
    ; If we get here, determinant is zero
    mov word ptr [result], 0
    mov word ptr [result+2], 0
   
not_zero:
    popad
    ret
determinant_3x3 endp

adjoint_2x2 proc
    push esi
    push edi
   
    mov esi, OFFSET matrix1
    mov edi, OFFSET result
   
    ; Swap a and d
    mov ax, [esi+6]      ; d
    mov [edi], ax        ; new a
    mov ax, [esi]        ; a
    mov [edi+6], ax      ; new d
   
    ; Negate b and c
    mov ax, [esi+2]      ; b
    neg ax
    mov [edi+2], ax      ; new b
   
    mov ax, [esi+4]      ; c
    neg ax
    mov [edi+4], ax      ; new c
   
    pop edi
    pop esi
    ret
adjoint_2x2 endp

determinant_2x2_new proc
    ; Computes determinant = a*d - b*c
    mov ax, matrix1[0]    ; a
    mov bx, matrix1[6]    ; d
    imul bx              ; ax = a*d
    mov si, ax           ; store in si

    mov ax, matrix1[2]    ; b
    mov bx, matrix1[4]    ; c
    imul bx              ; ax = b*c
    sub si, ax           ; si = a*d - b*c

    mov [result], si
    ret
determinant_2x2_new endp

; ========== ADJOINT ==========
adjoint_2x2_new proc
    ; Adjoint of 2x2:
    ; | a b |        =>  | d -b |
    ; | c d |            | -c a |
    mov ax, matrix1[6]    ; d
    mov temp[0], ax

    mov ax, matrix1[2]    ; b
    neg ax
    mov temp[2], ax

    mov ax, matrix1[4]    ; c
    neg ax
    mov temp[4], ax

    mov ax, matrix1[0]    ; a
    mov temp[6], ax

    ret
adjoint_2x2_new endp

inverse_2x2 proc
    pusha

    ; 1. Calculate determinant
    call determinant_2x2_new
    cmp word ptr [result], 0
    je singular_2x2       ; If zero, singular matrix

    mov bx, [result]      ; Store determinant in BX

    ; 2. Calculate adjoint and store in temp
    call adjoint_2x2_new

    ; 3. Scale adjoint by 1/determinant
    mov esi, OFFSET temp
    mov edi, OFFSET result
    mov cx, 4             ; Loop over 4 elements

scale_loop_2x2:
    mov ax, [esi]         ; Load adjoint element
    cwd                   ; Sign-extend AX into DX
    idiv bx               ; AX = AX / BX
    mov [edi], ax         ; Store result
    add esi, 2
    add edi, 2
    loop scale_loop_2x2

    popa
    clc                   ; Clear carry flag (success)
    ret

singular_2x2:
    mov edx, OFFSET error_singular
    call WriteString
    call WaitMsg
    popa
    stc                   ; Set carry flag (failure)
    ret
inverse_2x2 endp

;======================= 3x3 ADJOINT =======================
;----------------------------------------------------------
; Calculates adjoint of 3x3 matrix in matrix1, stores in result
;----------------------------------------------------------

handle_adjoint proc
    call handle_advanced_matrix
    cmp rows1, 0
    je adj_exit

    mov al, rows1
    cmp al, cols1
    jne adj_err

    cmp al, 2
    je adj2

adj2:
    call adjoint_2x2
    jmp show_adj

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

transpose_3x3 proc
    pushad
   
    ; Set matrix dimensions
    mov byte ptr [rows1], 3
    mov byte ptr [cols1], 3
   
    ; Pointers to matrix and result
    mov esi, OFFSET matrix1
    mov edi, OFFSET result
   
    ; Transpose the matrix
    ; Diagonal elements stay the same
    mov ax, [esi+0]     ; [0][0] -> [0][0]
    mov [edi+0], ax
   
    mov ax, [esi+8]     ; [1][1] -> [1][1]
    mov [edi+8], ax
   
    mov ax, [esi+16]    ; [2][2] -> [2][2]
    mov [edi+16], ax
   
    ; Swap off-diagonal elements
    ; [0][1] <-> [1][0]
    mov ax, [esi+2]     ; [0][1]
    mov bx, [esi+6]     ; [1][0]
    mov [edi+6], ax     ; [1][0] = original [0][1]
    mov [edi+2], bx     ; [0][1] = original [1][0]
   
    ; [0][2] <-> [2][0]
    mov ax, [esi+4]     ; [0][2]
    mov bx, [esi+12]    ; [2][0]
    mov [edi+12], ax    ; [2][0] = original [0][2]
    mov [edi+4], bx     ; [0][2] = original [2][0]
   
    ; [1][2] <-> [2][1]
    mov ax, [esi+10]    ; [1][2]
    mov bx, [esi+14]    ; [2][1]
    mov [edi+14], ax    ; [2][1] = original [1][2]
    mov [edi+10], bx    ; [1][2] = original [2][1]
   
    popad
    ret
transpose_3x3 endp

;======================= UPDATED HANDLERS =======================
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
    jmp inv_err  ; For other sizes (though your code only handles 2x2 and 3x3)

inv2:
    call inverse_2x2
    jmp inv_display

inv_display:
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
