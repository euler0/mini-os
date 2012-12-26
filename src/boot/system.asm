;
; This source code is licensed under the Simplified BSD License.
; See the file LICENSE for more details.
;

;
; INT 15h (A20 gate)
;

A20_DISABLE       equ 2400h
A20_ENABLE        equ 2401h
A20_QUERY_STATUS  equ 2402h
A20_QUERY_SUPPORT equ 2403h

A20_TEST_ADDR     equ 4*80h ; int 80h vector
