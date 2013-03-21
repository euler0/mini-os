/*
 * Copyright (c) 2012, 2013 Vincent Lee. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* The magic field should contain this. */
#define MULTIBOOT_HEADER_MAGIC	0x1badb002
	
/* Align all boot modules on 4KB boundaries. */
#define MULTIBOOT_PAGE_ALIGN	0x00000001

/* Pass memory information to OS. */
#define MULTIBOOT_MEMORY_INFO	0x00000002

/* The flags for the Multiboot header. */
#define MULTIBOOT_HEADER_FLAGS	(MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEMORY_INFO)

/* The size of our stack *16KB) */
#define STACK_SIZE		0x4000
	
	.text

	.global	start
start:
	jmp	multiboot_entry

	/* Align 32 bits boundry. */
	.align	4

	/* Multiboot header. */
multiboot_header:
	/* magic */
	.long	MULTIBOOT_HEADER_MAGIC
	/* flags */
	.long	MULTIBOOT_HEADER_FLAGS
	/* checksum */
	.long	-(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

multiboot_entry:
	/* Initialize the stack pointer. */
	movl	$(stack + STACK_SIZE), %esp

	/* Reset EFLAGS. */
	pushl	$0
	popf

	/* Push the pointer to the Multiboot information structure. */
	pushl	%ebx
	/* Push the magic value. */
	pushl	%eax

	/* Enter the C main function. */
	call	cstart

	/* Halt. */
loop:	hlt
	jmp	loop

	/* Stack area. */
	.comm	stack, STACK_SIZE
