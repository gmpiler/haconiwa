/* リンカスクリプト例：メモリ構成とセクション定義 */

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 512K
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

/* スタックサイズ */
_estack = ORIGIN(RAM) + LENGTH(RAM);
_stack_size = 0x4000; /* 16KBスタック */

/* リザーブ領域: 結果確認用（RAMの末尾近くに4バイト） */
RESULT_ADDR = 0x2001FFFC; /* RAMの最後から4バイト手前 */

SECTIONS
{
    /* テキスト（コード）領域: FLASHに配置 */
    .text :
    {
        _stext = .;
        *(.text*)
        *(.rodata*)
        _etext = .;
    } > FLASH

    /* データ初期値をFLASHに置く */
    .data_load :
    {
        _ldata = .;
        *(.data*)
        _edata_load = .;
    } > FLASH

    /* 実行時のデータ領域: RAMに配置、初期値は.data_loadの値からコピー */
    .data : AT(_ldata)
    {
        _sdata = .;
        *(.data*)
        _edata = .;
    } > RAM

    /* BSSセクション: RAMに配置、ゼロ初期化 */
    .bss :
    {
        _sbss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > RAM

    /* スタック領域（RAM末尾から確保） */
    .stack (NOLOAD) :
    {
        _sstack = .;
        . = ALIGN(8);
        . += _stack_size;
        _estack = .;
    } > RAM

    /* 結果確認用領域: RAM末尾の4バイトを空ける */
    .result (NOLOAD) :
    {
        PROVIDE(result_addr = RESULT_ADDR);
        KEEP(*(.result))
        . = RESULT_ADDR + 4;
    } > RAM AT> RAM
}
