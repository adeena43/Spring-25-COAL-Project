include irvine32.inc
INCLUDE Macros.inc
HEAP_START = 2000000
HEAP_MAX = 400000000
.data
HeapCreate PROTO,
flOptions:DWORD,
	  dwInitialSize : DWORD,
				  dwMaximumSize : DWORD
								  hHeap HANDLE ?
								  pArray DWORD ?
								  operation byte "enter: [1] addition  [2] subtract [3]multiply by constant [4]mul by matrice [5]determinant [6]transpose  ", 0
								  determmsg byte "[2]determinant 2*2  [3]determinant 3*3 [4]determinant 4*4 ", 0
								  errorinput byte "it's an error input please try again", 0
								  input byte "Enter the dimension of the matrix:", 0
								  strr byte "enter the elements of the matrix:", 0
								  str1 byte"Enter the elements of the first matrix:", 0
								  str2 byte "Enter the elements of the Second matrix:", 0
								  output byte "Output:", 0
								  constmsg byte "enter the constant", 0

								  str3 byte "Enter the elements of the matrix for transpose: ", 0

								  count dword ?
								  count2 dword ?

								  rows byte ?
								  columns byte ?
								  rows2 byte ?
								  columns2 byte ?
								  constant sbyte ?

								  matrix1 sbyte 0, 0, 0, 0, 0, 0, 0, 0
								  sbyte 0, 0, 0, 0, 0, 0, 0, 0
								  sbyte 0, 0, 0, 0, 0, 0, 0, 0
								  rowsize1 = ($ - matrix1)


								  matrix2 sword 0, 0, 0, 0, 0, 0, 0, 0
								  sword 0, 0, 0, 0, 0, 0, 0, 0
								  sword 0, 0, 0, 0, 0, 0, 0, 0
								  rowsize2 = ($ - matrix2)

								  matrix3 sbyte  0, 0, 0, 0, 0, 0, 0, 0
								  sbyte 0, 0, 0, 0, 0, 0, 0, 0
								  sbyte 0, 0, 0, 0, 0, 0, 0, 0
								  rowsize3 = ($ - matrix3)


								  matrix sbyte  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
								  sbyte  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
								  rowsize1 = ($ - matrix)


								  newmatrix sbyte  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
								  sbyte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
								  rowsize1 = ($ - newmatrix)

								  .code
								  main proc
								  INVOKE HeapCreate, 0, HEAP_START, HEAP_MAX
								  .IF eax == NULL
								  call WriteWindowsMsg
								  exit
								  .ELSE
								  mov hHeap, eax
								  .ENDIF

								  INVOKE HeapAlloc, hHeap, HEAP_ZERO_MEMORY, 1000
								  .IF eax == NULL
								  mWrite "HeapAlloc failed"
								  exit
								  .ELSE
								  mov pArray, eax
								  .ENDIF

								  ; ------------------------------------------------------------------------------------------------------------ -
								  ; ----------------------------------------
								  ; Ask the user which process to choose : 1 - add two matrixes, , 2 - sub two matrixes
								  ; 1 - add two matrixes, , 2 - sub two matrixes
								  ; 3 - mul matrix by constant, , 4 - mul matrix by matrix
								  ; 5 - determinant operation, , 6 - transpose a matrix
								  ; if the user enter another choice out of this it will show the error message input
								  ; ----------------------------------------
							  choose :
mwritestring operation
call crlf
call readdec
cmp eax, 1
je addition
cmp eax, 2
je subtraction
cmp eax, 3
je mulc
cmp eax, 4
je mulm
cmp eax, 5
je determinant
cmp eax, 6
je transpose
mwritestring errorinput
jmp choose
; ------------------------------
; ----------------------------------------
; calculates the addition of two matrixes that the user enter them and it's dimentions
; ----------------------------------------

addition :

mwritestring input
call crlf
call readint
mov rows, al
call readint
mov columns, al

mwritestring str1
call crlf
call enter_matrix1
mwritestring str2
call crlf
call enter_matrix2

call crlf
call matrix_addition
mwritestring output
call crlf
call outputt
jmp choose
; -------------------------------- -
; ----------------------------------------
; calculates the subtraction of two matrixes that the user enter them and it's dimentions
; ----------------------------------------

subtraction :

mwritestring input
call crlf
call readint
mov rows, al
call readint
mov columns, al

mwritestring str1
call crlf
call enter_matrix1
mwritestring str2
call crlf
call enter_matrix2

call crlf
call matrix_subtraction
mwritestring output
call crlf
call outputt
jmp choose
; ----------------------------------
; ----------------------------------------
; calculates the mul of matrix that the user enter it and it's dimentions and the constant 
; ----------------------------------------

mulc :

mwritestring input
call crlf
call readint
mov rows, al
call readint
mov columns, al
mwritestring constmsg
call crlf
call readint
mov constant, al
mwritestring str1
call crlf
call enter_matrix1

call matrix_mul_constant
mwritestring output
call crlf
call outputt
jmp choose
; --------------------------------------
; ----------------------------------------
; calculates the mul of two matrixes that the user enter them and thier dimentions
; ----------------------------------------
mulm :

mwritestring input
call crlf
call readint
mov rows, al
call readint
mov columns, al
mwritestring str1
call crlf
call enter_matrix1
again :
mwritestring input
call crlf
call readint
cmp al, columns
jne again
mov rows2, al
call readint
mov columns2, al
mwritestring str2
call crlf
call enter_matrix3
call crlf
call matrix_mul_matrix
mwritestring output
call crlf
call outputt_for_matrix_multiplication
jmp choose
; ----------------------------------
; ----------------------------------------
; it returns the transpose of an matrix that the user enter it and it's dimentions 
; ----------------------------------------
transpose :

mwritestring input
call crlf
call readint
mov rows, al
call readint
mov columns, al

mwritestring str3
call crlf
call enter_the_matrix
call crlf
call matrix_transpose
mwritestring output
call crlf
call output_trans
jmp choose
; == == == == == == == == == == == == == == == == == == == == == == == == =
; ----------------------------------------
; calculates the determ of two matrixe that the user enter them and thier dimentions
; and there are 3 types of it 1 - 2 * 2 determ, , 2 - 3 * 3 determ, , 3 - 4 * 4 determ
; ----------------------------------------
determinant :

mwritestring determmsg
call crlf
call readint
cmp eax, 2
je determ_2_2
cmp eax, 3
je determ_3_3
cmp eax, 4
je determ_4_4
; ----------------------
determ_2_2:

mov rows, 2
mov columns, 2
mwritestring strr
call crlf
call enter_matrix1
call determinant_2_2
mwritestring output
call crlf

call writeint
call crlf
jmp choose
; ------------------------
determ_3_3:

mov rows, 3
mov columns, 3
mwritestring strr
call crlf
call enter_matrix1
call determinant_3_3
mwritestring output
call crlf

call writeint
call crlf
jmp choose
; -------------------- -
determ_4_4:

mov rows, 4
mov columns, 4
mwritestring strr
call crlf
call enter_matrix1
call determinant_4_4
mwritestring output
call crlf
call writeint
call crlf
jmp choose
; ---------------------- -
main endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; it uses in the matrix_mul_constant proc
; enter the elements of the matrix 3
; esi contains the offset of the matrix 3
; ----------------------------------------
enter_matrix3 proc

mov esi, offset matrix3
mov al, rows2
mul columns2
mov ecx, eax
l7 :
call readint
mov[esi], eax
inc esi
loop l7
ret
enter_matrix3 endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
; ----------------------------------------
; it uses in more than one proc to enter the first marix
; ebx contains the offset of the matrix 1
; it uses to enter the elements in the matrix
; ----------------------------------------
enter_matrix1 proc

mov ebx, offset matrix1
mov al, rows
mul columns
movzx ecx, al
push ecx
l1 :
call readint
mov[ebx], eax
inc ebx
loop l1
pop ecx
ret
enter_matrix1 endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
; ----------------------------------------
; it uses in more than one proc to enter the second marix
; esi contains the offset of the matrix 2
; it uses to enter the elements in the matrix
; like the enter_matrix1 proc
; ----------------------------------------
enter_matrix2 proc
mov esi, offset matrix2
push ecx
l2 :
call readint
mov[esi], eax
inc esi
loop l2
pop ecx
ret
enter_matrix2 endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; it calculates the addition of two matrixes
; ebx contains the offset of the matrix 1
; esi contains the offset of the matrix 2
; it add each element of the first matrix to
; the opposite element in the secon matrix
; ----------------------------------------
matrix_addition proc

mov ebx, offset matrix1
mov esi, offset matrix2
push ecx
l3 :
mov al, sbyte ptr[esi]
add sbyte ptr[ebx], al
add esi, 1
add ebx, 1
loop l3
pop ecx
ret
matrix_addition endp
; == == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; more than 1 poc uses it two show the output of the function
; ebx contains the offset of the matrix 1 that will show the result
; reutrn the output in each function
; ----------------------------------------
outputt proc uses ecx

mov ebx, offset matrix1
movzx ecx, rows
l5 :
push ecx
movzx ecx, columns
l4 :
movsx eax, sbyte ptr[ebx]
call writeint
mov al, ' '
call writechar
add ebx, 1
loop l4
call crlf
pop ecx
loop l5
ret
outputt endp
; == == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; calculate subtraction of two matrixies
; esi contains the offset of the matrix 2 that would be subtracted from the matrix 1
; ebx contains the offset of the matrix 1 that will subtract matrix 2
; ----------------------------------------
matrix_subtraction proc

mov esi, offset matrix2
mov ebx, offset matrix1
push ecx
l3 :
mov al, sbyte ptr[esi]
neg al
add sbyte ptr[ebx], al
add esi, 1
add ebx, 1
loop l3
pop ecx
ret
matrix_subtraction endp
; == == == == == == == == == == == == == == == == == == == == == == == == =
; == == == == == == == == == == == == == == == == == == == == == == == == =
; ----------------------------------------
; it takes constant and mul it with each elment of the matrix
; ebx contains the offset of the matrix 1
; the result will put in ebx register
; ----------------------------------------
matrix_mul_constant proc uses ecx ebx

mov ebx, offset matrix1
l6 :
mov al, sbyte ptr[ebx]
imul constant
mov sbyte ptr[ebx], al
inc ebx
loop l6
ret
matrix_mul_constant endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == =
; ----------------------------------------
;takes two matrix first one n*m 
;second should have the same columns of first means m*t
;and the size result matrix  equal the number of rows of first multiplies the number of columns of  
;second matrix means n*t
; ----------------------------------------
matrix_mul_matrix proc uses ecx

mov edx, offset matrix1
mov esi, offset matrix3
mov edi, offset matrix2
mov al, rows
mul columns2
movzx ecx, al
mov count, 0
mov count2, 0
mov eax, 0
mov ebx, 0
l1:
push ecx

mov esi, offset matrix3
add esi, count
add edx, count2

movzx ecx, columns
l9 :
push ecx


mov al, sbyte ptr[edx]
imul sbyte ptr[esi]
add sword ptr[edi], ax

movzx ecx, columns2
l3 :
inc esi
loop l3
inc edx
pop ecx
loop l9
cmp columns2, 1
jna ll
inc count
mov edx, offset matrix1
jmp h
ll :
mov count, 0
h :
  add edi, 2
  mov ebx, count
  cmp bl, columns2
  jne skip
  mov edx, offset matrix1
  mov al, columns
  add count2, eax
  mov count, 0
skip:
pop ecx
loop l1
ret
matrix_mul_matrix endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; it uses to show the output of the matrix_multiplication proc
; edi conatins the offset of the matrix 2 that will contain the result of the operation mul
; the result in ax register
; ----------------------------------------
outputt_for_matrix_multiplication proc
mov eax, 0
mov edi, offset matrix2
movzx ecx, rows
l5 :
push ecx
movzx ecx, columns2
l4 :
mov ax, sword ptr[edi]
cwd
call writeint
mov al, ' '
call writechar
add edi, 2
loop l4
call crlf
pop ecx
loop l5
ret
outputt_for_matrix_multiplication endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
; == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
; ----------------------------------------
; it calculated determent of the matrix
; it calculated like "(the first elem * the forth elem) - (the third elem * the second elem)"
; and retrun the result in eax register
; esi contains the offset of the matrix 1
; ----------------------------------------
determinant_2_2 proc

mov esi, offset matrix1
mov eax, 0
mov al, sbyte ptr[esi]
add esi, 3
imul sbyte ptr[esi]
movsx ebx, ax
dec esi
mov al, sbyte ptr[esi]
dec esi
imul sbyte ptr[esi]
neg ax
add bx, ax
movsx eax, bx
ret
determinant_2_2 endp
; ----------------------------------------------------
; ----------------------------------------
; it calculated determent of the matrix
; it take the first element and canceles the rest of the elements in it's row and column
; and mul it with the rest of the elment and them look like a determ 2 * 2
; calculated like "first element *(the first elem * the forth elem) - (the third elem * the second elem)"
; repeat this operation with the second element and the third elment and take the sum of the tree operation
; and retrun the result in eax register
; esi contains the offset of the matrix 1
; ----------------------------------------
determinant_3_3 proc

;;;;;;; first - element
mov esi, offset matrix1
mov eax, 0
mov ebx,0
movsx bx, sbyte ptr[esi]
add esi, 4
movsx ax, sbyte ptr[esi]
add esi, 4
imul sbyte ptr[esi]
mov edx, eax
dec esi
movsx ax, sbyte ptr[esi]
sub esi, 2
imul sbyte ptr[esi]

sub edx, eax
movsx eax, dx
imul bx
push eax
;;;;;;;;; second - element
mov eax, 0
mov ebx,0
mov esi, offset matrix1
inc esi
movsx bx, sbyte ptr[esi]
add esi, 2
movsx ax, sbyte ptr[esi]
add esi, 5
imul sbyte ptr[esi]
mov edi, eax
sub esi, 2
movsx ax, sbyte ptr[esi]
dec esi
imul sbyte ptr[esi]
sub edi, eax
movsx eax, di
imul bx
mov ebx, eax
pop eax
neg bx
add ax, bx
push eax
;;;;;;;;;;; third - element
mov eax, 0
mov ebx,0
mov esi, offset matrix1
add esi, 2
movsx bx, sbyte ptr[esi]
inc esi
movsx ax, sbyte ptr[esi]
add esi, 4
imul sbyte ptr[esi]
mov edi, eax
dec esi
movsx ax, sbyte ptr[esi]
sub esi, 2
imul sbyte ptr[esi]
sub edi, eax
movsx eax, di
imul bx
mov ebx, eax
pop eax
add eax, ebx
ret
determinant_3_3 endp

; == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
determinant_4_4 proc

ret
determinant_4_4 endp
; == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
; == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; we uses it in the transpose proc
; to enter the elements of the matrix
; -------------------------------------- -
enter_the_matrix proc

mov ebx, offset matrix
mov al, rows
mul columns
mov ecx, eax
push ecx
l1 :
call readint
mov[ebx], eax
inc ebx
loop l1
pop ecx
ret
enter_the_matrix endp
; == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; it's the fuction that do transpose
; ebx contains the offset of matrix, edx contains the offset of newmatrix
; ecx contains the length of columns, rows
; edx contains the calc of transpose
; ----------------------------------------
matrix_transpose proc

mov ebx, offset matrix
mov edx, offset newmatrix
mov cl, columns
l8 :
push ecx
push ebx
mov cl, rows
l9 :
mov al, [ebx]
add bl, columns
mov[edx], al
inc edx
loop l9
pop ebx
pop ecx
inc ebx
loop l8
ret
matrix_transpose endp
; == == == == == == == == == == == == == == == == == == == == == == == == ==
; ----------------------------------------
; it's show the result of transpose matrix
; ebx contains the offset of the newmatrix that holds the output
; the result will put in eax register
; ----------------------------------------
output_trans proc uses ecx

mov ebx, offset newmatrix
movzx ecx, columns
l5 :
push ecx
movzx ecx, rows
l4 :
movsx eax, byte ptr[ebx]
call writeint
mov al, ' '
call writechar
add ebx, 1
loop l4
call crlf
pop ecx
loop l5
ret
output_trans endp
; == == == == == == == == == == == == == == == == == == == == ==
end main
