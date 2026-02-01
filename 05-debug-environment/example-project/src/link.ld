ENTRY(_start);

MEMORY
{
  flash0    (rx!w) : ORIGIN = 0x08000000, LENGTH = 0x00200000  /* 2MB Flash */
  ram0      (rw!x) : ORIGIN = 0x20000000, LENGTH = 0x00010000  /* 64KB RAM */
}

SECTIONS
{
  .text :
  {
    KEEP(*(vector))
    *(.text*)
  } > flash0

  .ARM.exidx : {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
  } >flash0

  .data :
  {
     microzig_data_start = .;
     *(.rodata*)
     *(.data*)
     microzig_data_end = .;
  } > ram0 AT> flash0

  .bss (NOLOAD) :
  {
      microzig_bss_start = .;
      *(.bss*)
      microzig_bss_end = .;
      . = ALIGN(4);
      microzig_stack_start = .;
      . = . + 0x800;  /* 2KB堆栈 */
      . = ALIGN(4);
      microzig_stack_end = .;
  } > ram0

  microzig_data_load_start = LOADADDR(.data);
}
