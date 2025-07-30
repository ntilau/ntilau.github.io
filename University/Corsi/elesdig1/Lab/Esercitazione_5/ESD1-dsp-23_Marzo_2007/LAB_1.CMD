/*Allocazione di memoria*/

-m test.map

MEMORY
{
	IVECT: origin=0x000100  len=0x000100
	DATA:  origin=0x001000	len=0x00EFFF
	PROG:  origin=0x010000	len=0x00FFFF
}


SECTIONS
{
	intvect		> IVECT

 	.text		> PROG
	.data		> DATA
	.bbs 		> DATA
	.const		> DATA
	.sysmem		> DATA
	.stack		> DATA
	.sysstack	> DATA
	.cio		> DATA
	
	.switch		> DATA
	.cinit		> DATA
	.pinit		> DATA
	
	.vectors	> DATA
	.ioport		> DATA
}
