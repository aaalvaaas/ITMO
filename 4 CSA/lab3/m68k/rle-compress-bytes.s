    .data
input_addr:      .word  0x80
output_addr:     .word  0x84
in_buf_start:    .word  0x0100
out_buf_start:   .word  0x0200
stack_top:       .word  0x1000
max_shift:       .word  24
shift_offset:    .word  8

    .text
    .org     0x200

_start:
    movea.l  stack_top, A7
    movea.l  (A7), A7

    movea.l  input_addr, A0
    movea.l  (A0), A0

    movea.l  output_addr, A1
    movea.l  (A1), A1

    jsr      main
    jmp      exit

empty_input:
    move.l   0, (A1)
    jmp      exit

error:
    move.l   -1, (A1)

exit:
    halt

main:
    link     A6, -4
    move.l   (A0), D1

    bmi      main_error
    beq      main_empty

    move.l   D1, -(A7)
    jsr      read_input
    jsr      compress
    jsr      write_output
    move.l   (A7)+, D1

    unlk     A6
    rts

main_error:
    unlk     A6
    jmp      error

main_empty:
    unlk     A6
    jmp      empty_input

read_input:
    link     A6, -8
    movea.l  in_buf_start, A2
    movea.l  (A2), A2
    move.l   D1, D2
    move.l   D2, -4(A6)

read_input_word_loop:
    cmp.l    0, D2
    ble      read_input_done

    jsr      read_input_word
    move.l   D2, -4(A6)

    jmp      read_input_word_loop

read_input_done:
    unlk     A6
    rts

read_input_word:
    link     A6, -4
    move.l   (A0), D3

    clr.l    D4
    movea.l  max_shift, A3
    move.l   0(A3,D4), D5
    movea.l  shift_offset, A3
    move.l   0(A3,D4), D6
    move.l   D6, -4(A6)

read_input_byte_loop:
    move.l   D3, D4
    lsr.l    D5, D4
    move.b   D4, (A2)+
    sub.l    1, D2
    beq      read_input_word_exit

    sub.l    -4(A6), D5
    beq      read_input_word_last
    jmp      read_input_byte_loop

read_input_word_last:
    move.b   D3, (A2)+
    sub.l    1, D2

read_input_word_exit:
    unlk     A6
    rts

compress:
    link     A6, -4
    movea.l  in_buf_start, A0
    movea.l  (A0), A0
    movea.l  out_buf_start, A2
    movea.l  (A2), A2
    clr.l    D6
    move.l   D1, D2

compress_loop:
    cmp.l    0, D2
    ble      compress_done

    move.b   (A0)+, D3
    move.l   1, D5
    sub.l    1, D2

    jsr      count_run

    move.b   D5, (A2)+
    move.b   D3, (A2)+
    add.l    2, D6
    jmp      compress_loop

compress_done:
    unlk     A6
    rts

count_run:
    beq      count_run_exit
    cmp.l    255, D5
    beq      count_run_exit

    move.b   (A0)+, D4
    cmp.b    D4, D3
    bne      count_run_mismatch

    add.l    1, D5
    sub.l    1, D2
    jmp      count_run

count_run_mismatch:
    move.b   -(A0), D4

count_run_exit:
    rts

write_output:
    link     A6, -8
    move.l   D6, (A1)

    movea.l  out_buf_start, A0
    movea.l  (A0), A0
    move.l   D6, D2
    move.l   D2, -8(A6)

write_output_loop:
    cmp.l    0, D2
    ble      write_output_done

    jsr      pack_output_word

    move.l   D0, (A1)
    jmp      write_output_loop

write_output_done:
    unlk     A6
    rts

pack_output_word:
    link     A6, -4
    clr.l    D0

    clr.l    D4
    movea.l  max_shift, A3
    move.l   0(A3,D4), D7
    movea.l  shift_offset, A3
    move.l   0(A3,D4), D6
    move.l   D6, -4(A6)

write_input_byte_loop:
    clr.l    D4
    move.b   (A0)+, D4
    and.l    255, D4
    lsl.l    D7, D4
    or.l     D4, D0
    sub.l    1, D2
    beq      pack_output_word_emit

    sub.l    -4(A6), D7
    bmi      pack_output_word_emit
    jmp      write_input_byte_loop

pack_output_word_emit:
    unlk     A6
    rts
