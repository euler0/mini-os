; -*- x86 assembly -*-
;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

[org 0h]
[bits 16]

jmp 07C0h:start ; ensure that CS is set to 07C0h

start:
  ; DS = CS
  mov ax, cs
  mov ds, ax

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

  jc error

  mov si, success
  call println

  ; jump to ES:BX (where the kernel is loaded)
  push es
  push bx
  retf

  ;
  ; SHOULD NOT REACH HERE
  ;

error:
  mov si, errorMsg
  call println
  cli
  hlt

println:
  lodsb
  or al, al
  jz printlnDone
  mov ah, 0Eh ; teletype output
  int 10h
  jmp println
printlnDone:
  mov ax, 0E0Dh
  xor bx, bx
  int 10h
  mov al, 0Ah
  int 10h
  ret

success db "Kernel going up...", 0
errorMsg db "Error.", 0

times 510 - ($-$$) db 0 ; pad remainder of boot sector with 0s
dw 0AA55h ; boot signature
