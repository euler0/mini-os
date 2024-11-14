;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

%include "system.asm"

; disable A20 gate for test
%define DISABLE_A20 0

org 0h
bits 16

jmp 07C0h:start ; ensure that CS is set to 07C0h

start:
  ; DS, SS = CS
  mov ax, cs
  mov ds, ax
  mov ss, ax

%if DISABLE_A20
  call disable_a20
%endif

  call test_a20
  test ax, ax
  jnz loadkern

  mov si, msgA20Disabled
  call println

  call enable_a20

  call test_a20
  test ax, ax
  jnz loadkern

  mov si, msgA20Failed
  jmp halt

loadkern:
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

  ; switch off the floppy drive motor
  mov dx, 3F2h
  xor al, al
  out dx, al

  mov si, msgOk
  call println

  ; jump to ES:BX (where the kernel is loaded)
  push es
  push bx
  retf

  ;
  ; SHOULD NOT REACH HERE
  ;

enable_a20:
  mov ax, A20_ENABLE
  int 15h
  ret

%if DISABLE_A20
disable_a20:
  mov ax, A20_DISABLE
  int 15h
  ret
%endif

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

; Arguments:
;   si: message to print
halt:
  call println
  cli
  hlt

%include "print.asm"

msgOk  db "Kernel going up...", 0
msgErr db "Could not read the next sector.", 0
msgA20Disabled  db "A20 gate disabled. Trying to enable it...", 0
msgA20Failed    db "Could not enable A20 gate.", 0

times 510 - ($-$$) db 0 ; pad remainder of boot sector with 0s
dw 0AA55h ; boot signature
