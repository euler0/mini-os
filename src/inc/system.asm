;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

;
; PIC (Programmable Interrupt Controller, 8259A)
;

PIC1           equ 20h  ; master
PIC2           equ 0A0h ; slave
PIC1_CMD       equ PIC1
PIC2_CMD       equ PIC2
PIC1_DATA      equ PIC1+1
PIC2_DATA      equ PIC2+1

ICW1_ICW4      equ 01h ; ICW4 (not) needed
ICW1_SINGLE    equ 02h ; single (cascade) mode
ICW1_INTERVAL4 equ 04h ; call address interval 4 (8)
ICW1_LEVEL     equ 08h ; level triggered (edge) mode
ICW1_INIT      equ 10h ; initialization

ICW4_8086       equ 01h ; 8086/88 (MCS-80/85) mode
ICW4_AUTO       equ 02h ; auto (normal) EOI(end of interrupt)
ICW4_BUF_SLAVE  equ 08h ; buffered mode - slave
ICW4_BUF_MASTER equ 0Ch ; buffered mode - master
ICW4_SFNM       equ 10h ; special fully nested (not)

;
; INT 15h (A20 gate)
;

A20_DISABLE       equ 2400h
A20_ENABLE        equ 2401h
A20_QUERY_STATUS  equ 2402h
A20_QUERY_SUPPORT equ 2403h

A20_TEST_ADDR     equ 4*80h ; int 80h vector
