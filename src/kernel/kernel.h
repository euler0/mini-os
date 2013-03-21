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

#ifndef kernel_h
#define kernel_h

#include <stdint.h>

#define countof(array) (sizeof(array) / sizeof(array[0]))

/*
 * x86 Segmentation Data Structures and definitions
 */

 /*
  * Selectors
  */
#define SEL_KPL   0   /* kernel priority level */
#define SEL_UPL   3   /* user priority level */
#define GSEL(s,r) (((s)<<3) | r)  /* a global selector */

/*
 * Software definitions are in this convenient format,
 * which are translated into inconvenient segment descriptors
 * when needed to be used by the 386 hardware
 */
struct soft_segment_descriptor {
  uint32_t ssd_base;      /* segment base address */
  uint32_t ssd_limit;     /* segment extent */
  uint32_t ssd_type:5;    /* segment type */
  uint32_t ssd_dpl:2;     /* segment descriptor priority level */
  uint32_t ssd_p:1;       /* segment descriptor present */
  uint32_t ssd_xx:4;      /* unused */
  uint32_t ssd_xx1:2;     /* unused */
  uint32_t ssd_def32:1;   /* default 32 vs 16 bit size */
  uint32_t ssd_gran:1;    /* limit granularity (byte/page units) */
};

/*
 * Segment descriptors
 */
struct segment_descriptor {
  uint32_t sd_lolimit:16; /* segment extent (lsb) */
  uint32_t sd_lobase:24;  /* segment base address (lsb) */
  uint32_t sd_type:5;     /* segment type */
  uint32_t sd_dpl:2;      /* segment descriptor priority level */
  uint32_t sd_p:1;        /* segment descriptor present */
  uint32_t sd_hilimit:4;  /* segment extent (msb) */
  uint32_t sd_xx:2;       /* unused */
  uint32_t sd_def32:1;    /* default 32 vs 16 bit size */
  uint32_t sd_gran:1;     /* limit granularity (byte/page units) */
  uint32_t sd_hibase:8;   /* segment base address (msb) */
} __attribute__((packed));

/*
 * Gate descriptors
 */
struct gate_descriptor {
  uint32_t gd_looffset:16; /* gate offset (lsb) */
  uint32_t gd_selector:16; /* gate segment selector */
  uint32_t gd_stkcpy:5;    /* IST table index */
  uint32_t gd_xx:3;        /* unused */
  uint32_t gd_type:5;      /* segment type */
  uint32_t gd_dpl:2;       /* segment descriptor priority level */
  uint32_t gd_p:1;         /* segment descriptor present */
  uint32_t gd_hioffset:16; /* gate offset (msb) */
} __attribute__((packed));

/*
 * Generic descriptor
 */
union descriptor {
  struct segment_descriptor sd;
  struct gate_descriptor gd;
};

        /* memory segment types */
#define SDT_MEMRO   16    /* memory read only */
#define SDT_MEMROA  17    /* memory read only accessed */
#define SDT_MEMRW   18    /* memory read write */
#define SDT_MEMRWA  19    /* memory read write accessed */
#define SDT_MEMROD  20    /* memory read only expand dwn limit */
#define SDT_MEMRODA 21    /* memory read only expand dwn limit accessed */
#define SDT_MEMRWD  22    /* memory read write expand dwn limit */
#define SDT_MEMRWDA 23    /* memory read write expand dwn limit accessed */
#define SDT_MEME    24    /* memory execute only */
#define SDT_MEMEA   25    /* memory execute only accessed */
#define SDT_MEMER   26    /* memory execute read */
#define SDT_MEMERA  27    /* memory execute read accessed */
#define SDT_MEMEC   28    /* memory execute only conforming */
#define SDT_MEMEAC  29    /* memory execute only accessed conforming */
#define SDT_MEMERC  30    /* memory execute read conforming  */
#define SDT_MEMERAC 31    /* memory execute read accessed conforming */

/*
 * Entries in the Global Descriptor Table (GDT)
 */
#define GNULL_SEL   0   /* Null descriptor */
#define GCODE_SEL   1   /* Kernel code descriptor */
#define GDATA_SEL   2   /* Kernel data descriptor */
#define GUCODE_SEL  3   /* User code descriptor */
#define GUDATA_SEL  4   /* User data descriptor */
#define NGDT        5

/*
 * Region descriptors, used to load GDT/IDT tables before segments yet exist.
 */
struct region_descriptor {
  uint32_t rd_limit:16; /* segment extent */
  uint32_t rd_base:32;  /* base address */
} __attribute__((packed));

extern union descriptor gdt[];

extern struct soft_segment_descriptor gdt_segs[];
extern struct gate_descriptor *idt;
extern struct region_descriptor r_gdt, r_idt;

extern void lgdt(struct region_descriptor *rdp);

extern void ssdtosd(struct soft_segment_descriptor *ssd, struct segment_descriptor *sd);

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

#endif
