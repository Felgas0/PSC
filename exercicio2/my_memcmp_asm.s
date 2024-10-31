/*
int my_memcmp(const void *ptr1, const void *ptr2, size_t num);
*/
    .global my_memcmp
my_memcmp:
    # Prologue
    push %rbp
    mov %rsp, %rbp
    push %rbx  # Save %rbx

    # Load parameters
    mov %rdi, %r8  # ptr1
    mov %rsi, %r9  # ptr2
    mov %rdx, %rcx # num

    # Initialize result to 0
    xor %eax, %eax


    # Loop to compare bytes
.compare_loop:
    test %rcx, %rcx
    jz .equal  # If num is 0, exit loop

    movsbl (%r8), %eax  # Load byte from ptr1 into %al and zero-extend to %eax

    movsbl (%r9), %ebx  # Load byte from ptr2 into %bl and zero-extend to %ebx

    cmp %al, %bl
    jne .not_equal  # If bytes are not equal, jump to not_equal

    # Increment pointers and decrement counter
    inc %r8
    inc %r9
    dec %rcx
    jmp .compare_loop

.not_equal:
    sub %bl, %al  # Calculate difference
    movsx %al, %eax # Sign-extend %al to %eax
    jmp .done

.equal:
    xor %eax, %eax  # Set result to 0
    jmp .done

.done:
    # Epilogue
    pop %rbx  # Restore %rbx
    mov %rbp, %rsp
    pop %rbp
    ret

	.section	.note.GNU-stack

