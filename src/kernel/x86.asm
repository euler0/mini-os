;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

global idt_flush
global halt

idt_flush:
  mov eax, [esp+4]
  lidt [eax]
  ret

halt:
  cli
.hang
  hlt
  jmp .hang
