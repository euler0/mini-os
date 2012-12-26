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

#ifndef kernel_h
#define kernel_h

#include <stdint.h>

 #define countof(array) (sizeof(array) / sizeof(array[0]))

typedef struct {
  uint16_t limit;
  uint32_t base_addr;
} __attribute__((packed)) DescriptorTable;

typedef enum {
  SEGTYPE_CODE,
  SEGTYPE_DATA,
  SEGTYPE_USERCODE,
  SEGTYPE_USERDATA
} SegmentType;

typedef struct {
  unsigned int limit;
  unsigned int base;
  SegmentType type;
} SegmentDescriptor;

typedef struct {
  uint16_t offset;
  uint16_t selector;
  uint8_t always0;
  uint8_t flags;
  uint16_t offset_hi;
} __attribute__((packed)) InterruptDescriptor;

#if 0
typedef struct {
  uint16_t limit;         // Segment limit
  uint32_t base_addr:24;  // Segment base address
  uint32_t type:4;        // Segment type
  uint32_t S:1;           // Descriptor type (0 = system; 1 = code or data)
  uint32_t DPL:2;         // Descriptor privilege level
  uint32_t P:1;           // Segment present
  uint16_t limit_high:4;
  uint16_t A:1;           // Available for use by system software
  uint16_t L:1;           // 64-bit code segment (IA-32e only)
  uint16_t DB:1;          // Default operation size (0 = 16-bit segment; 1 = 32-bit segment)
  uint16_t G:1;           // Granularity
  uint16_t base_addr_high:8;
} __attribute__((packed)) SegmentDescriptor;
#endif

#endif
