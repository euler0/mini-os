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

#include <stdarg.h>

#include "kernel.h"
#include "libc.h"
#include "system.h"

#define vram_next_line(addr) ((unsigned char *) \
  ((unsigned int)addr + 160 - ((unsigned int)addr % 160) + 64) \
)

static int putchar(int ch)
{
  static unsigned char *vram = (unsigned char *)0xB8000;

  if (ch == '\n') {
    vram = vram_next_line(vram);
    return ch;
  }

  *vram++ = ch;
  *vram++ = 0x07;
  return ch;
}

static void vprintf(const char *format, va_list arg)
{
  static char buf[10];
  char *s;
  unsigned u;
  int c;

  while ((c = *format++)) {
    if (c == '%') {
      c = *format++;
      switch (c) {
      case 'c':
        putchar(va_arg(arg, int));
        continue;
      case 's':
        for (s = va_arg(arg, char *); *s; s++)
          putchar(*s);
        continue;
      case 'u':
        u = va_arg(arg, unsigned);
        s = buf;
        do
          *s++ = '0' + u % 10U;
        while (u /= 10U);
        while (--s >= buf)
          putchar(*s);
        continue;
      }
    }
    putchar(c);
  }
}

static void printf(const char *format, ...)
{
  va_list arg;

  va_start(arg, format);
  vprintf(format, arg);
  va_end(arg);
}

void panic(const char *format, ...)
{
  va_list arg;

  va_start(arg, format);
  vprintf(format, arg);
  va_end(arg);

  halt();
}

static void clear_screen()
{
  memset((void *)0xB8000, 0, 80 * 2 * 25);
}

typedef struct {
  uint32_t ds;
  uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
  uint8_t int_no, err_code;
  uint32_t eip, cs, eflags, useresp, ss;
} Registers;

void isr_handler(Registers regs)
{
}

#if 0
static void idt_set_gate(int num, uint32_t addr, uint16_t sel, uint8_t flags)
{
  idt[num].offset = addr & 0xFFFF;
  idt[num].offset_hi = (addr >> 16) & 0xFFFF;
  idt[num].selector = sel;
  idt[num].always0 = 0;
  idt[num].flags = flags;
}

static void idt_init()
{
  memset(idt, 0, sizeof(idt));

  extern uint32_t  isr0,  isr1,  isr2,  isr3,  isr4,  isr5,  isr6,  isr7,
                   isr8,  isr9, isr10, isr11, isr12, isr13, isr14, isr15,
                  isr16, isr17, isr18, isr19, isr20, isr21, isr22, isr23,
                  isr24, isr25, isr26, isr27, isr28, isr29, isr30, isr31;

  idt_set_gate(0, isr0, 0x08, 0x8E);
  idt_set_gate(1, isr1, 0x08, 0x8E);
  idt_set_gate(2, isr2, 0x08, 0x8E);
  idt_set_gate(3, isr3, 0x08, 0x8E);
  idt_set_gate(4, isr4, 0x08, 0x8E);
  idt_set_gate(5, isr5, 0x08, 0x8E);
  idt_set_gate(6, isr6, 0x08, 0x8E);
  idt_set_gate(7, isr7, 0x08, 0x8E);
  idt_set_gate(8, isr8, 0x08, 0x8E);
  idt_set_gate(9, isr9, 0x08, 0x8E);
  idt_set_gate(10, isr10, 0x08, 0x8E);
  idt_set_gate(11, isr11, 0x08, 0x8E);
  idt_set_gate(12, isr12, 0x08, 0x8E);
  idt_set_gate(13, isr13, 0x08, 0x8E);
  idt_set_gate(14, isr14, 0x08, 0x8E);
  idt_set_gate(15, isr15, 0x08, 0x8E);
  idt_set_gate(16, isr16, 0x08, 0x8E);
  idt_set_gate(17, isr17, 0x08, 0x8E);
  idt_set_gate(18, isr18, 0x08, 0x8E);
  idt_set_gate(19, isr19, 0x08, 0x8E);
  idt_set_gate(20, isr20, 0x08, 0x8E);
  idt_set_gate(21, isr21, 0x08, 0x8E);
  idt_set_gate(22, isr22, 0x08, 0x8E);
  idt_set_gate(23, isr23, 0x08, 0x8E);
  idt_set_gate(24, isr24, 0x08, 0x8E);
  idt_set_gate(25, isr25, 0x08, 0x8E);
  idt_set_gate(26, isr26, 0x08, 0x8E);
  idt_set_gate(27, isr27, 0x08, 0x8E);
  idt_set_gate(28, isr28, 0x08, 0x8E);
  idt_set_gate(29, isr29, 0x08, 0x8E);
  idt_set_gate(30, isr30, 0x08, 0x8E);
  idt_set_gate(31, isr31, 0x08, 0x8E);

  idtr.limit = sizeof(idt) - 1;
  idtr.base_addr = (uint32_t)&idt;

  idt_flush(&idtr);
}
#endif

void cstart(uint32_t magic, uint32_t addr)
{
  if (magic != 0x2BADB002)
    panic("Multiboot: Magic number mismatch.\n");

  clear_screen();

  init386();

  pic_init();
#if 0
  idt_init();
#endif

  panic("Hello, world!\n");
}
