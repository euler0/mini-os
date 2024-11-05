;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

println:
  lodsb
  test al, al
  jz printlnEnd
  mov ah, 0Eh ; teletype output
  int 10h
  jmp println
printlnEnd:
  mov al, 0Dh
  int 10h
  mov al, 0Ah
  int 10h
  ret
