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

#include "kernel.h"

static void ssdtosd(struct soft_segment_descriptor *ssd, struct segment_descriptor *sd);

union descriptor gdt[NGDT];             /* global descriptor table */
static struct gate_descriptor idt0[NIDT];
struct gate_descriptor *idt = &idt0[0]; /* interrupt descriptor table */
struct region_descriptor r_gdt, r_idt;  /* table descriptors */

/*
 * software prototypes -- in more palatable form.
 *
 * All segments cover the full 4GB of address space
 * and permissions are enforced at page level.
 */
struct soft_segment_descriptor gdt_segs[] = {
/* GNULL_SEL    0 Null Descriptor */ {
  .ssd_base = 0x0,
  .ssd_limit = 0x0,
  .ssd_type = 0,
  .ssd_dpl = SEL_KPL,
  .ssd_p = 0,
  .ssd_xx = 0, .ssd_xx1 = 0,
  .ssd_def32 = 0,
  .ssd_gran = 0 },
/* GCODE_SEL    1 Code Descriptor for kernel */ {
  .ssd_base = 0x0,
  .ssd_limit = 0xfffff,
  .ssd_type = SDT_MEMERA,
  .ssd_dpl = SEL_KPL,
  .ssd_p = 1,
  .ssd_xx = 0, .ssd_xx1 = 0,
  .ssd_def32 = 1,
  .ssd_gran = 1 },
/* GDATA_SEL    2 Data Descriptor for kernel */ {
  .ssd_base = 0x0,
  .ssd_limit = 0xfffff,
  .ssd_type = SDT_MEMRWA,
  .ssd_dpl = SEL_KPL,
  .ssd_p = 1,
  .ssd_xx = 0, .ssd_xx1 = 0,
  .ssd_def32 = 1,
  .ssd_gran = 1 },
/* GUCODE_SEL    3 Code Descriptor for user */ {
  .ssd_base = 0x0,
  .ssd_limit = 0xfffff,
  .ssd_type = SDT_MEMERA,
  .ssd_dpl = SEL_UPL,
  .ssd_p = 1,
  .ssd_xx = 0, .ssd_xx1 = 0,
  .ssd_def32 = 1,
  .ssd_gran = 1 },
/* GUDATA_SEL    4 Data Descriptor for user */ {
  .ssd_base = 0x0,
  .ssd_limit = 0xfffff,
  .ssd_type = SDT_MEMRWA,
  .ssd_dpl = SEL_UPL,
  .ssd_p = 1,
  .ssd_xx = 0, .ssd_xx1 = 0,
  .ssd_def32 = 1,
  .ssd_gran = 1 }
};

extern inthand_t
  IDTVEC(div), IDTVEC(dbg), IDTVEC(nmi), IDTVEC(bpt), IDTVEC(ofl),
  IDTVEC(bnd), IDTVEC(ill), IDTVEC(dna), IDTVEC(fpusegm),
  IDTVEC(tss), IDTVEC(missing), IDTVEC(stk), IDTVEC(prot),
  IDTVEC(page), IDTVEC(mchk), IDTVEC(rsvd), IDTVEC(fpu), IDTVEC(align),
  IDTVEC(xmm),
  IDTVEC(int0x80_syscall);

void init386()
{
  for (int i = 0; i < NGDT; ++i)
    ssdtosd(&gdt_segs[i], &gdt[i].sd);

  // The limit is the size of the table subtracted by 1 because the GDT can be
  // up to 65536 bytes (a maximum of 8192 entries).
  r_gdt.rd_limit = NGDT * sizeof(gdt[0]) - 1;
  r_gdt.rd_base = (int)gdt;

  lgdt(&r_gdt);

  /* exceptions */
  for (int i = 0; i < NIDT; ++i)
    setidt(i, &IDTVEC(rsvd), SDT_SYS386TGT, SEL_KPL,
      GSEL(GCODE_SEL, SEL_KPL));
}

static void ssdtosd(struct soft_segment_descriptor *ssd,
             struct segment_descriptor *sd)
{
  sd->sd_lobase = (ssd->ssd_base) & 0xffffff;
  sd->sd_hibase = (ssd->ssd_base >> 24) & 0xff;
  sd->sd_lolimit = (ssd->ssd_limit) & 0xffff;
  sd->sd_hilimit = (ssd->ssd_limit >> 16) & 0xf;
  sd->sd_type = ssd->ssd_type;
  sd->sd_dpl = ssd->ssd_dpl;
  sd->sd_p = ssd->ssd_p;
  sd->sd_def32 = ssd->ssd_def32;
  sd->sd_gran = ssd->ssd_gran;
}

void setidt(int idx, inthand_t *func, int type, int dpl, int sel)
{
  struct gate_descriptor *ip;

  ip = idt +idx;
  ip->gd_looffset = (int)func;
  ip->gd_selector = sel;
  ip->gd_stkcpy = 0;
  ip->gd_xx = 0;
  ip->gd_type = type;
  ip->gd_dpl = dpl;
  ip->gd_p = 1;
  ip->gd_hioffset = ((int)func) >> 16;
}
