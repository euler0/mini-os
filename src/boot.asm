;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

org 0h
bits 16

jmp 07C0h:start ; ensure that CS is set to 07C0h

start:
  ; DS = CS
  mov ax, cs
  mov ds, ax
  mov ss, ax

  call enableA20

  call checkA20
  or ax, ax
  jz test1

  mov si, msgA20
  call println

test1:
  jmp $

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

  mov si, msgOk
  call println

  ; jump to ES:BX (where the kernel is loaded)
  push es
  push bx
  retf

  ;
  ; SHOULD NOT REACH HERE
  ;

error:
  mov si, msgErr
  call println
  cli
  hlt

enableA20:
  ; keyboard controller (8042) method
  cli

  call a20_wait
  mov al, 0ADh
  out 64h, al

  call a20_wait
  mov al, 0D0h
  out 64h, al

  call a20_wait2
  in al, 60h
  push eax

  call a20_wait
  mov al, 0D1h
  out 64h, al

  call a20_wait
  pop eax
  or al, 02h
  out 60h, al

  call a20_wait
  mov al, 0AEh
  out 64h, al

  call a20_wait
  sti
  ret

a20_wait:
  in al, 64h
  test al, 02h
  jnz a20_wait
  ret

a20_wait2:
  in al, 64h
  test al, 01h
  jz a20_wait2
  ret

  ; BIOS method
  ;mov ax, 2401h
  ;int 15h

  ; fast A20 method
  ;in al, 92h
  ;test al, 02h
  ;jnz enableA20End
  ;or al, 02h
  ;and al, 0FEh
  ;out 92h, al
enableA20End
  ret

checkA20:
  pushf
  push ds
  push es
  push di
  push si

  cli

  xor ax, ax ; ax = 0
  mov es, ax

  not ax      ; ax = FFFFh
  mov ds, ax

  mov di, 500h
  mov si, 510h

  mov al, byte [es:di]
  push ax

  mov al, byte [ds:si]
  push ax

  mov byte [es:di], 00h
  mov byte [ds:si], 0FFh

  cmp byte [es:di], 0FFh

  pop ax
  mov byte [ds:si], al

  pop ax
  mov byte [es:di], al

  mov ax, 0
  je checkA20End

  mov ax, 1

checkA20End:
  pop si
  pop di
  pop es
  pop ds
  popf

  ret

%include "inc/print.asm"

msgOk  db "Kernel going up...", 0
msgErr db "Error!", 0
msgA20 db "A20 enabled!", 0

times 510 - ($-$$) db 0 ; pad remainder of boot sector with 0s
dw 0AA55h ; boot signature
