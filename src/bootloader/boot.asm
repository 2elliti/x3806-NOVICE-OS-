ORG 0x7C00
BITS 16
jmp short main
nop
bdb_oem:                    db 'MSWIN4.1'           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0
; extended boot record
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
                            db 0                    ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:           db '  JAZZ OS  '        ; 11 bytes, padded with spaces
ebr_system_id:              db 'FAT12   '           ; 8 bytes  '
main:
    MOV ax,0
    MOV ds,ax
    MOV es,ax
    MOV ss,ax
    MOV sp,0x7C00
    MOV [ebr_drive_number], dl
    MOV ax, 1
    MOV cl, 1
    MOV bx, 0x7E00
    CALL disk_read
    MOV si,os_boot_msg
    CALL print
    HLT
halt:
    JMP halt

floppy_error:
    MOV si, read_failure
    call print
    hlt
;disk routines
;cx [bits 0-5]: sector number
;cx [bits 6-15]: cylinder
;dh: head
lba_to_chs:
    push ax
    push dx
    
    XOR dx,dx
    div word [bdb_sectors_per_track]
    inc dx
    mov cx, dx
    xor dx,dx
    div word [bdb_heads]
    mov dh,dl
    mov ch,al
    shl ah,6
    or cl,ah
    pop ax
    mov dl,al
    pop ax
    RET
;ax: LBA address
;cl: number of sectors to read
;dl: drive number
;es:bx: memory address where to store read data
disk_read:
    push ax
    push bx
    push cx
    push dx
    push di
    push cx
    call lba_to_chs
    pop ax
    
    mov ah, 02h
    mov di, 3 ;retry count
.retry:
    pusha
    stc                 ;some bios don't set carry
    int 13h
    jnc .done
    
    popa 
    call disk_reset
    dec di
    test di, di
    jnz .retry
.fail:
    jmp floppy_error
.done:
    popa
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa 
    ret

print:
    PUSH si
    PUSH ax
    PUSH bx
print_loop:
    LODSB
    OR al,al
    JZ done_print
    MOV ah, 0x0E
    MOV bh, 0
    INT 0x10
    JMP print_loop
done_print:
    POP bx
    POP ax
    POP si
    RET
os_boot_msg: DB 'Our OS has booted!', 0x0D, 0x0A, 0
read_failure: DB 'Failed to read floppy', 0x0D, 0x0A, 0
TIMES 510-($-$$) DB 0
DW 0AA55h