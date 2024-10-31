/*
	void rotate_right(unsigned long value[], size_t n);
*/

	.text
	.global rotate_right
rotate_right:
    # Prologue
    push %rbp
    mov %rsp, %rbp
    push %rbx  # Save %rbx

    # Load parameters
    mov %rdi, %r8  # value (array)
    mov %rsi, %rcx  # n

    # Calculate nbits (number of bits in a 64-bit unsigned long)
    mov $64, %r9  # nbits = 64

    # Adjust n to be within the range [0, 2 * nbits)
    mov %rcx, %r10
    shl $1, %r9  # nbits * 2
    and %r9, %r10  # n %= nbits * 2

    # If n is zero, return
    test %r10, %r10
    jz .done

    # If n >= nbits, swap value[0] and value[1]
    cmp %r9, %r10
    jb .no_swap
    mov (%r8), %rax
    mov 8(%r8), %rdx
    mov %rdx, (%r8)
    mov %rax, 8(%r8)
    sub %r9, %r10  # n -= nbits

.no_swap:
    # If n == nbits, return
    cmp %r9, %r10
    je .done

    # Perform the rotation
    mov (%r8), %rax
    mov 8(%r8), %rdx
    mov %rax, %rbx  # tmp = value[0]

    # value[0] = (value[0] >> n) + (value[1] << (nbits - n))
    mov %r9, %rcx
    sub %r10, %rcx  # nbits - n
    shr %r10, %rax
    shl %rcx, %rdx
    or %rdx, %rax
    mov %rax, (%r8)

    # value[1] = (value[1] >> n) + (tmp << (nbits - n))
    mov %rbx, %rax
    mov 8(%r8), %rdx
    shr %r10, %rdx
    shl %rcx, %rax
    or %rax, %rdx
    mov %rdx, 8(%r8)

.done:
    # Epilogue
    pop %rbx  # Restore %rbx
    mov %rbp, %rsp
    pop %rbp
    ret

	.section .note.GNU-stack

