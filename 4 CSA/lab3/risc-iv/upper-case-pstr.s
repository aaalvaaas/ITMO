    .data
pstr_buffer:     .word  0x005F5F5F, 0x5F5F5F5F, 0x5F5F5F5F, 0x5F5F5F5F, 0x5F5F5F5F, 0x5F5F5F5F, 0x5F5F5F5F, 0x5F5F5F5F
pstr_buffer_end: .byte  0x5F5F5F5F

input_addr:      .word  0x80
output_addr:     .word  0x84
max_len:         .word  32
ascii_newline:   .word  10
to_upper_diff:   .word  -32
error:           .word  0xCCCCCCCC
ascii_a:         .word  97
ascii_z:         .word  122
buffer_size:     .word  33
sp_init:         .word  0xFF0
sp_dec:          .word  -4
one:             .word  1
zero:            .word  0

    .text
    .org     0x88

_start:
    lui      t0, %hi(input_addr)
    addi     t0, t0, %lo(input_addr)
    lw       s1, 0(t0)
    lui      t0, %hi(output_addr)
    addi     t0, t0, %lo(output_addr)
    lw       s2, 0(t0)
    lui      t0, %hi(to_upper_diff)
    addi     t0, t0, %lo(to_upper_diff)
    lw       s3, 0(t0)
    lui      t6, %hi(one)
    addi     t6, t6, %lo(one)
    lw       t6, 0(t6)

    lui      t0, %hi(sp_init)
    addi     t0, t0, %lo(sp_init)
    lw       sp, 0(t0)

    lui      t0, %hi(sp_dec)
    addi     t0, t0, %lo(sp_dec)
    lw       t4, 0(t0)
    add      sp, sp, t4

    sw       ra, 0(sp)
    jal      ra, process_pstr
    lw       ra, 0(sp)

    halt

write_to_io_proc:
    lui      t0, %hi(one)
    addi     t0, t0, %lo(one)
    lw       t4, 0(t0)
    add      t0, s0, t4
    mv       t1, zero
    lb       t2, 0(s0)
write_loop:
    beq      t1, t2, write_done
    lb       a0, 0(t0)
    sb       a0, 0(s2)
    add      t0, t0, t6
    add      t1, t1, t6
    j        write_loop
write_done:
    jr       ra

process_pstr:
    lui      t0, %hi(sp_dec)
    addi     t0, t0, %lo(sp_dec)
    lw       t4, 0(t0)
    add      sp, sp, t4
    sw       ra, 0(sp)

    lui      s0, %hi(pstr_buffer)
    addi     s0, s0, %lo(pstr_buffer)

    lui      t0, %hi(buffer_size)
    addi     t0, t0, %lo(buffer_size)
    lw       s6, 0(t0)
    add      s6, s0, s6

    lui      t0, %hi(ascii_newline)
    addi     t0, t0, %lo(ascii_newline)
    lw       s4, 0(t0)

    lui      t0, %hi(max_len)
    addi     t0, t0, %lo(max_len)
    lw       s5, 0(t0)

    lui      t0, %hi(ascii_a)
    addi     t0, t0, %lo(ascii_a)
    lw       s7, 0(t0)

    lui      t0, %hi(ascii_z)
    addi     t0, t0, %lo(ascii_z)
    lw       s8, 0(t0)

    lui      t0, %hi(one)
    addi     t0, t0, %lo(one)
    lw       t4, 0(t0)
    add      t0, s0, t4

    mv       t1, zero

read_loop:
    beq      t1, s5, overflow_case
    lb       a0, 0(s1)
    beq      a0, s4, finalize_mem
    bgt      s7, a0, skip_up
    bgt      a0, s8, skip_up
    add      a0, a0, s3
skip_up:
    sb       a0, 0(t0)
    add      t0, t0, t6
    add      t1, t1, t6
    j        read_loop

overflow_case:
    lui      t2, %hi(error)
    addi     t2, t2, %lo(error)
    lw       t2, 0(t2)
    sw       t2, 0(s2)
    j        exit_proc

finalize_mem:
    sb       t1, 0(s0)
    jal      ra, write_to_io_proc
    j        exit_proc

exit_proc:
    lw       ra, 0(sp)
    lui      t0, %hi(sp_dec)
    addi     t0, t0, %lo(sp_dec)
    lw       t4, 0(t0)
    sub      sp, sp, t4
    jr       ra
