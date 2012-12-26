ENTRY(loader)

SECTIONS {
  . = 0x00010000;

  .text ALIGN (0x1000): {
    *(.text)
  }

  /* Read-only initialized data */
  .rodata ALIGN (0x1000): {
    *(.rodata*)
  }

  /* Initialized static data */
  .data ALIGN (0x1000): {
    *(.data)
  }

  /* Uninitialized static data */
  .bss : {
    sbss = .;
    *(COMMON)
    *(.bss)
    ebss = .;
  }
}
