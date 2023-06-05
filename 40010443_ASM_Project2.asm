%include "asm_io.inc"
segment .data 
array:	dq 5.5, 12.4, 7.12, 9.58, -3.98, 1.2, 2.0, 4.0, 6.0, -8.7, 0.0
len:	equ ($-array)/8
msg1:	db "ARRAY BEFORE SORT:", 10, 0
msg2:	db "ARRAY AFTER SORT:", 10, 0
format: db "%f, ", 0
empty:	db "Array is empty!", 10, 0

segment .bss 

segment .text
        global  asm_main
	extern printf
asm_main:
        enter   0,0               ; setup routine
        pusha
	;***************CODE STARTS HERE***************************
	mov eax, 0
	cmp eax, len
	je empty_label

	mov eax, msg1
	call print_string
	push array
	push len
	call print_float_array
	call print_nl

	push array
	push 0
	push 10
	call quick_sort

	mov eax, msg2
	call print_string
	push array
	push len
	call print_float_array

	jmp end

empty_label:
	mov eax, empty
	call print_string
	call print_nl
	jmp end


; int partition(int array[], int left, int right)
partition:
	enter 0,0

	push ebx
	push ecx
	push edx
	push edi
	push esi

	mov ebx, [ebp+16]		; array address
	mov ecx, [ebp+12]		; leftPointer
	mov edx, [ebp+8]		; rightPointer
	fld qword [ebx+8*edx]	; save pivot in top of stack (ST0)
	dec edx					; rightPointer--

	outer_loop:
		; while leftPointer <= rightPointer && array[leftPointer] <= pivot
		inner_loop_one:
			; if leftPointer > rightPointer, then break
			cmp ecx, edx
			jg end_inner_loop_one
			
			; if array[leftPointer] > pivot, then break
			fld qword [ebx+8*ecx]	; save array[leftPointer] in top of stack (ST0)
			fcomip st1				; fcomip instruction that compares ST0(array[leftPointer]), ST1(pivot)
			ja end_inner_loop_one 	; if ST0 > ST1, then jump to end_inner_loop_one

			; leftPointer++
			inc ecx
			jmp inner_loop_one
		end_inner_loop_one:

		; while leftPointer <= rightPointer && array[rightPointer] > pivot
		inner_loop_two:
			; if leftPointer > rightPointer, then break
			cmp ecx, edx
			jg end_inner_loop_two

			; if array[rightPointer] <= pivot, then break
			fld qword [ebx+8*edx]	; save array[rightPointer] in top of stack (ST0)
			fcomip st1				; fcomip instruction that compares ST0(array[rightPointer]), ST1(pivot)
			jbe end_inner_loop_two ; if ST0 <= ST1, then jump to end_inner_loop_two

			; rightPointer--
			dec edx
			jmp inner_loop_two
		end_inner_loop_two:

		; if leftPointer >= rightPointer, then break
		cmp ecx, edx
		jge end_outer_loop	

		; else, swap array[leftPointer] and array[rightPointer]
		fld qword [ebx+8*ecx]	; save array[leftPointer] in top of stack (ST0)
		fld qword [ebx+8*edx]	; save array[rightPointer] in top of stack (ST0)
		fstp qword [ebx+8*ecx]	; array[leftPointer] <- array[rightPointer]
		fstp qword [ebx+8*edx]	; array[rightPointer] <- array[leftPointer]
		jmp outer_loop
	end_outer_loop:
		
		; swap array[leftPointer] and array[right]
		mov eax, [ebp+8]		; eax <- right
		fld qword [ebx+8*eax]	; save array[right] in top of stack (ST0)
		fld qword [ebx+8*ecx]	; save array[leftPointer] in top of stack (ST0)
		fstp qword [ebx+8*eax]	; array[right] <- array[leftPointer]
		fstp qword [ebx+8*ecx]	; array[leftPointer] <- array[right]

		; return leftPointer
		mov eax, ecx

		pop esi
		pop edi
		pop edx
		pop ecx
		pop ebx
		leave
		ret 12

quick_sort: ; void quick_sort(int array[], int left,int right)
	enter 0, 0

	push eax
	push ebx
	push ecx
	push edx
	push edi

	mov ebx, [ebp+16]	; array address
	mov ecx, [ebp+12]	; left
	mov edx, [ebp+8]	; right	

	; if left >= right, then return
	cmp ecx, edx
	jge end_quick_sort
	
	push ebx
	push ecx
	push edx
	call partition

	mov edi, eax	; edi <- pivot_index
	dec edi
	; quick_sort(left, pivot_index-1)
	push ebx
	push ecx
	push edi
	call quick_sort

	mov edi, eax	; edi <- pivot_index
	inc edi
	; quick_sort(array, pivot_index+1, right)
	push ebx
	push edi
	push edx
	call quick_sort

end_quick_sort:
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret 12

print_float_array:
	enter 0, 0

	push eax
	push ebx
	push ecx

	mov ebx, [ebp+12] ; array address
	mov ecx, [ebp+8] ; array length
	loop1:
		push ecx
		push dword [ebx+4]
		push dword [ebx]
		push format
		call printf
		add esp, 12
		pop ecx

		add ebx, 8
		loop loop1

	mov al, 10
	call print_char

	pop ecx
	pop ebx
	pop eax
	leave
	ret 8

end:
	;***************CODE ENDS HERE*****************************
        popa
        mov     eax, 0            ; return back to C
        leave                     
        ret
