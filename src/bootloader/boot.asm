; ORG 0x7C00

; BITS 16

; JMP SHORT start


; ;*************************************************;
; ;	OEM Parameter block
; ;*************************************************;



; bpbBytesPerSector:  	DW 512
; bpbSectorsPerCluster: 	DB 1
; bpbReservedSectors: 	DW 1
; bpbNumberOfFATs: 	    DB 2
; bpbRootEntries: 	    DW 224
; bpbTotalSectors: 	    DW 2880
; bpbMedia: 	            DB 0xF0
; bpbSectorsPerFAT: 	    DW 9
; bpbSectorsPerTrack: 	DW 18
; bpbHeadsPerCylinder: 	DW 2
; bpbHiddenSectors: 	    DD 0
; bpbTotalSectorsBig:     DD 0
; bsDriveNumber: 	        DB 0
; bsUnused: 	            DB 0
; bsExtBootSignature: 	DB 0x29
; bsSerialNumber:	        DD 0xa0a1a2a3
; bsVolumeLabel: 	        DB "MOS FLOPPY "
; bsFileSystem: 	        DB "FAT12   "



; start:
;         JMP loader






; ;*************************************************;
; ;	Bootloader Entry Point
; ;*************************************************;


; loader:
; 	XOR ax,ax	;dont why we doing it
; 	MOV ds,ax	;same here,just copy it will explore latter.
; 	MOV es,ax	;same here....
; 	MOV ss,ax	;JUST BEAR WITH ME.
; 	MOV sp, 0x7C00
; 	MOV si,message	;For printing name of our os
; 	CALL print
; 	mov si,message_creator
; 	CALL print


; ;************************************************;
; ;		Printing String
; ;************************************************;
; message: db "This is Novice os.",0x0d,0x0a,0

; message_creator: db "Created by Mrinal Yadav. Email -> forstoic724321@gmail.com",0x0d,0x0a,0x00

; print:
; 	PUSH ax
; 	PUSH bx
; 	PUSH si

; print_message:
; 	LODSB
; 	OR al,al
; 	JZ done_printing
; 	MOV ah,0x0B	;It's for printing character
; 	MOV bh,-3	;It's for page number, but will 0 for our case.
; 	INT 0x0d
; 	JMP print_message
; done_printing:
; 	POP si
; 	POP bx
; 	POP ax
; 	RET




; reset_floppy_controller:
; 	mov ah,0
; 	mov dl,0
; 	int 0x13
; 	jc reset_floppy_controller

; 	mov ax, 0x1000
; 	mov es, ax
; 	xor bx,bx

; read_the_sector:
; 	mov ah, 0x02
; 	mov al, 1
; 	mov ch, 1
; 	mov cl, 2
; 	mov dh, 0
; 	mov dl, 0	; 0 for floppy disk.
; 	int 0x13
; 	jc read_the_sector

; 	jmp 0x1000:0x000

; times 510 - ($-$$) db 0		; We have to be 512 bytes. Clear the rest of the bytes with 0

; dw 0xAA55




;*********************************************
;	Boot1.asm
;		- A Simple Bootloader
;
;	Operating Systems Development Tutorial
;*********************************************
 
bits	16							; We are still in 16 bit Real Mode
 
org		0x7c00						; We are loaded by BIOS at 0x7C00
 
start:          jmp loader					; jump over OEM block
 
;*************************************************;
;	OEM Parameter block / BIOS Parameter Block
;*************************************************;
 
TIMES 0Bh-$+start DB 0
 
bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	DB 2
bpbRootEntries: 	DW 224
bpbTotalSectors: 	DW 2880
bpbMedia: 	        DB 0xF0
bpbSectorsPerFAT: 	DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors:       DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	        DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0xa0a1a2a3
bsVolumeLabel: 	        DB "MOS FLOPPY "
bsFileSystem: 	        DB "FAT12   "
 
;***************************************
;	Prints a string
;	DS=>SI: 0 terminated string
;***************************************
 
Print:
			lodsb					; load next byte from string from SI to AL
			or			al, al		; Does AL=0?
			jz			PrintDone	; Yep, null terminator found-bail out
			mov			ah,	0eh	; Nope-Print the character
			int			10h
			jmp			Print		; Repeat until null terminator found
PrintDone:
			ret					; we are done, so return
 
;*************************************************;
;	Bootloader Entry Point
;*************************************************;
 
loader:
 
.Reset:
	mov		ah, 0					; reset floppy disk function
	mov		dl, 0					; drive 0 is floppy drive
	int		0x13					; call BIOS
	jc		.Reset					; If Carry Flag (CF) is set, there was an error. Try resetting again
 
	mov		ax, 0x1000				; we are going to read sector to into address 0x1000:0
	mov		es, ax
	xor		bx, bx
 
	mov		ah, 0x02				; read floppy sector function
	mov		al, 1					; read 1 sector
	mov		ch, 1					; we are reading the second sector past us, so its still on track 1
	mov		cl, 2					; sector to read (The second sector)
	mov		dh, 0					; head number
	mov		dl, 0					; drive number. Remember Drive 0 is floppy drive.
	int		0x13					; call BIOS - Read the sector
	
 
	jmp		0x1000:0x0				; jump to execute the sector!
 
 
times 510 - ($-$$) db 0						; We have to be 512 bytes. Clear the rest of the bytes with 0
 
dw 0xAA55							; Boot Signiture
 
; End of sector 1, beginning of sector 2 ---------------------------------
 
 
org 0x1000							; This sector is loaded at 0x1000:0 by the bootsector
 
cli								; just halt the system
hlt






