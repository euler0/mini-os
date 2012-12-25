;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

global loader
global magic
global mbd

extern main

MODULEALIGN equ 1<<0
MEMINFO     equ 1<<1
FLAGS       equ MODULEALIGN | MEMINFO
MAGIC       equ 0x1BADB002
CHECKSUM    equ -(MAGIC + FLAGS)

section .text

align 4
  dd MAGIC
  dd FLAGS
  dd CHECKSUM

STACKSIZE equ 0x4000

loader:
  mov esp, stack + STACKSIZE
  mov [magic], eax
  mov [mbd], ebx

  call main

  cli
.hang
  hlt
  jmp .hang

section .bss

align 4
stack: resb STACKSIZE
magic: resd 1
mbd:   resd 1
