/*
struct data { short flags:6; short length:10; short vals[]; };

struct info { double ref; struct data **data; int valid; };

short *get_val_ptr(struct info items[],
                      size_t item_idx, size_t data_idx, size_t val_idx, short mask)
{
	return items[item_idx].valid
		&& val_idx < items[item_idx].data[data_idx]->length
		&& (items[item_idx].data[data_idx]->flags & mask)
			? &items[item_idx].data[data_idx]->vals[val_idx]
			: NULL;
}
*/


# data = short + short + short[] = 4 bytes + vals 
# info = double + struct data ** + int = 8 + 8 + 4 = 20 bytes -> 24 bytes

	.text
	.global	get_val_ptr
get_val_ptr:
    # Prologue
    push %rbp
    mov %rsp, %rbp
    push %rbx  # Save %rbx
    push %r11  # Save %r11
    push %r10  # Save %r10

    # Parameters: rdi = items, rsi = item_idx, rdx = data_idx, rcx = val_idx, r8 = mask

    # Calculate address of items[item_idx]
    mov %rsi, %rax
    imul $24, %rax  # Multiply item_idx by 24 (size of struct info)
    add %rdi, %rax  # Add base address of items

    # Check if items[item_idx].valid is non-zero (working)
    mov 16(%rax), %r11d     # Load items[item_idx].valid into %r11d (assuming valid is at offset 16)
    test $0x1, %r11d        # Test the 17th bit of items[item_idx].valid
    jz .return_null

    # Calculate address of items[item_idx].data
    mov 8(%rax), %rbx  # Load items[item_idx].data into %rbx

    # Check if items[item_idx].data is NULL
    cmp $0, %rbx
    je .return_null

    # Calculate address of items[item_idx].data[data_idx]
    shl $3, %rdx        # Multiply data_idx by 8 (size of pointer)
    add %rbx, %rdx      # Add base address of items[item_idx].data
    mov (%rdx), %rax    # Load items[item_idx].data[data_idx] into %rax

    # Check if val_idx < items[item_idx].data[data_idx]->length
    mov 0(%rax), %r11w  # Load items[item_idx].data[data_idx]->length into %r11w
    and $0xFFC0, %r11w  # Clear the 10 least significant bits
    shr $6, %r11w       # Shift the 10 most significant bits to the right
    movzx %r11w, %r11   # Zero-extend %r11w to %r11 (64-bit)
    cmp %rcx, %r11      # Compare val_idx with items[item_idx].data[data_idx]->length
    jb .return_null

    # Check if items[item_idx].data[data_idx]->flags & mask is non-zero
    mov 0(%rax), %r11w   # Load the first 16 bits (flags and length) into %r11w
    and $0x003F, %r11w   # Mask out the length (keep only the flags bits)
    and %r8w, %r11w      # Mask flags with the provided mask
    jz .return_null      # Jump if the result is zero

    # Return address of items[item_idx].data[data_idx]->vals[val_idx]
    lea 2(%rax), %rax    # Calculate base address of vals (2 bytes offset for flags and length)
    add %rcx, %rcx       # Multiply val_idx by 2 (size of short)
    add %rcx, %rax       # Add val_idx * 2 to base address
    jmp .done            # Jump to done


    .return_null:
    xor %rax, %rax      # Return NULL

    .done:
    # Epilogue
    pop %r10  # Restore %r10
    pop %r11  # Restore %r11
    pop %rbx  # Restore %rbx
    mov %rbp, %rsp
    pop %rbp
    ret

    .section	.note.GNU-stack
