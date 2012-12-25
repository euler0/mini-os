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

#include <stdint.h>

#include "libc.h"

void printf(const char *msg)
{
  unsigned char *vram = (unsigned char *)(0xB8000 + (80 * 0 * 2) + (0 * 2));

  for (const char *c = msg; *c; c++) {
    *vram++ = *c;
    *vram++ = 0x07;
  }
}

void clear_screen()
{
  memset((void *)0xB8000, 0, 80 * 2 * 25);
}

struct gdt {
  uint16_t limit;
  uint32_t base_addr;
};

struct gdt_entry {
  uint16_t limit;
  uint16_t base_addr;
  uint16_t base_addr2:8;
  uint16_t type:4;
  uint16_t s:1;
  uint16_t dpl:2;
  uint16_t p:1;
  uint16_t limit2:4;
  uint16_t avl:1;
  uint16_t unused:1;
  uint16_t d:1;
  uint16_t g:1;
  uint16_t base_addr3:8;
};

int main()
{
  extern uint32_t magic;
  extern void *mbd;

  if (magic != 0x2BADB002)
    return 0;

  clear_screen();
  printf("Hello, world!");

  return 0;
}
