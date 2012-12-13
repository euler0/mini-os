;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

%include "inc/system.asm"

org 0h
bits 16

jmp 07C0h:start ; ensure that CS is set to 07C0h

start:
  ; DS = CS
  mov ax, cs
  mov ds, ax
  mov ss, ax

%if 0
  ; Disable the A20 gate for test.
  call disable_a20
%endif

  call enable_a20

  call test_a20
  or ax, ax
  jz a20_failed

read:
  ; ES:BX = 1000:0000
  mov ax, 1000h
  mov es, ax
  mov bx, 0

  mov ah, 2 ; read sectors from drive
  mov al, 1 ; sectors to read count
  mov ch, 0 ; track(cylinder)
  mov cl, 2 ; sector
  mov dh, 0 ; head
  mov dl, 0 ; drive
  int 13h

  mov si, msgErr
  jc halt

  mov si, msgOk
  call println

  ; jump to ES:BX (where the kernel is loaded)
  push es
  push bx
  retf

  ;
  ; SHOULD NOT REACH HERE
  ;

a20_failed:
  mov si, msgA20
  jmp halt

enable_a20:
  ; Who uses the keyboard controller to enable the A20 gate
  ; in the 21st century? LOL
  mov ax, A20_ENABLE
  int 15h
  ret

disable_a20:
  mov ax, A20_DISABLE
  int 15h
  ret

test_a20:
  push cx
  push ax

  xor cx, cx
  mov fs, cx ; FS = 0000h
  not cx
  mov gs, cx ; GS = FFFFh
  mov ax, word [fs:A20_TEST_ADDR]
  push ax

  inc ax
  mov word [fs:A20_TEST_ADDR], ax
  dw 00EBh, 00EBh
  cmp ax, word [gs:A20_TEST_ADDR + 10h]

  mov ax, 1
  jne test_a20.end

  mov ax, 0

test_a20.end:
  pop word [fs:A20_TEST_ADDR]
  pop ax
  pop cx

  ret

; esi: message to print
halt:
  call println
  cli
  hlt

%include "inc/print.asm"

msgOk  db "Kernel going up...", 0
msgErr db "Error!", 0
msgA20 db "Could not enable A20 gate.", 0

times 510 - ($-$$) db 0 ; pad remainder of boot sector with 0s
dw 0AA55h ; boot signature
