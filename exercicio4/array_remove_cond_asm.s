/*
size_t array_remove_cond(void **array, size_t size,
                    int (*eval)(const void *, const void *), void *context) {
	for (void **current = array, **last = array + size; current < last; ) {
		if (eval(*current, context)) {
			memmove(current, current + 1, (last - current - 1) * sizeof(void *));
			size -= 1;
			last -= 1;
		}
		else {
			current += 1;
		}
	}
	return size;
}
*/
	.text
	.global	array_remove_cond
array_remove_cond:
    # Prologue
    push %rbp
    mov %rsp, %rbp
    push %rbx  # Save %rbx
    push %r12  # Save %r12
    push %r13  # Save %r13
    push %r14  # Save %r14
    push %r15  # Save %r15

    # Initialize Pointers
    mov %rdi, %rbx  # *current
    mov %rsi, %r12  # size
    mov %rdx, %r13  # eval
    lea (%rdi, %r12, 8), %r14  # **last
    mov %rcx, %r15  # context

    # Loop through array
.loop:
    cmp %r14, %rbx  # Compare current pointer with end pointer
    jae .end        # If current >= end, exit loop

    # Evaluate condition
    mov (%rbx), %rdi  # Load current element into %rdi
    mov %r15, %rsi    # Load context into %rsi
    call *%r13        # Call eval function
    test %rax, %rax   # Test the result
    jz .else          # If eval returns 0, go to next element

    # memmove(current, current + 1, (last - current - 1) * sizeof(void *));
    # (last - current - 1) * sizeof(void *)) = (last - current) - 8
    mov %rbx, %rdi  # current
    lea 8(%rbx), %rsi  # current + 1
    mov %r14, %rdx  # last
    sub %rbx, %rdx  # last - current
    sub $8, %rdx  # last - current - 8

    # Call memmove
    call memmove

    # Update pointers and size
    sub $8, %r14       # last -= 1
    sub $1, %r12       # size -= 1
    jmp .loop          # Continue loop

.else:
    add $8, %rbx       # current += 1
    jmp .loop          # Continue loop

.end:
    mov %r12, %rax     # Return size

    # Epilogue
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    mov %rbp, %rsp
    pop %rbp
    ret

	.section	.note.GNU-stack

