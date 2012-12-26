/*
 * Copyright (c) 2012 Vincent Lee. All rights reserved.
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

static int putchar(int ch)
{
  static unsigned char *vram = (unsigned char *)0xB8000;

  *vram++ = ch;
  *vram++ = 0x07;
  return ch;
}

// Source: freebsd:/sys/boot/i386/boot2/boot2.c
static void printf(const char *fmt, ...)
{
  va_list ap;
  static char buf[10];
  char *s;
  unsigned u;
  int c;

  va_start(ap, fmt);
  while ((c = *fmt++)) {
    if (c == '%') {
      c = *fmt++;
      switch (c) {
      case 'c':
        putchar(va_arg(ap, int));
        continue;
      case 's':
        for (s = va_arg(ap, char *); *s; s++)
          putchar(*s);
        continue;
      case 'u':
        u = va_arg(ap, unsigned);
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
  va_end(ap);
}

static void clear_screen()
{
  memset((void *)0xB8000, 0, 80 * 2 * 25);
}

static void sd_encode(uint8_t *dest, const SegmentDescriptor *seg)
{
  unsigned int limit = seg->limit;

  //if ((seg->limit > 0xFFFF) && (seg->limit & 0xFFF) != 0xFFF)
  //  ;

  if (limit > 0xFFFF) {
    limit = limit >> 12;
    dest[6] = 0xC0;
  } else {
    dest[6] = 0x40;
  }

  // Encode the limit
  dest[0] = limit & 0xFF;
  dest[1] = (limit >> 8) & 0xFF;
  dest[6] |= (limit >> 16) & 0xF;

  // Encode the base address
  dest[2] = seg->base & 0xFF;
  dest[3] = (seg->base >> 8) & 0xFF;
  dest[4] = (seg->base >> 16) & 0xFF;
  dest[7] = (seg->base >> 24) & 0xFF;

  if (seg->type == SEGTYPE_CODE)
    dest[5] = 0x9A;
  else if (seg->type == SEGTYPE_DATA)
    dest[5] = 0x92;
}

static SegmentDescriptor segments[] = {
  { .limit = 0x1FFFE, .base = 0, .type = SEGTYPE_CODE },
  { .limit = 0xFFFF, .base = 0, .type = SEGTYPE_DATA },
  //{ .limit = 0xFFFF, .base = 0xB8000, .type = SEGTYPE_DATA } // Video memory
};

// Global Descriptor Table (GDT)
static DescriptorTable gdtr;
static uint8_t gdt[(countof(segments) + 1) * 8];

static DescriptorTable idtr;
static InterruptDescriptor idt[256];

extern void gdt_flush(void *gdtr);
extern void idt_flush(void *idtr);

static void gdt_init()
{
  memset(gdt, 0, 8); // Null descriptor (unused)
  for (int i = 0; i < countof(segments); ++i)
    sd_encode(&gdt[(i + 1) * 8], &segments[i]);

  gdtr.limit = sizeof(gdt) - 1;
  gdtr.base_addr = (uint32_t)gdt;

  gdt_flush(&gdtr);
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

void start(void *mbd, uint32_t magic)
{
  if (magic != 0x2BADB002)
    return;

  gdt_init();
  idt_init();

  clear_screen();
  printf("Hello, world!\n");
}
