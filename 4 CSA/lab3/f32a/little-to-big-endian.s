    .data
input_addr:      .word  0x80
output_addr:     .word  0x84

SHIFT_INIT:      .word  23
COUNTER_INIT:    .word  3
SHIFT_BYTE:      .word  7
SHIFT_DEC:       .word  -8
MASK_BYTE:       .word  0xFF
MASK_SIGN:       .word  0x7FFFFFFF

    .text
    .org 0x88

_start:
    @p input_addr a! @
    convert
    @p output_addr a! !
    exit ;

convert:
    @p SHIFT_INIT
    lit 0 a!
    @p COUNTER_INIT >r

loop:
    dup >r
    over dup
    @p MASK_BYTE and
    shift_left
    a + a!
    @p SHIFT_BYTE >r shift_right
    over
    @p SHIFT_DEC +
    dup -if loop_continue

    drop
    r> drop
    a +
    ;

loop_continue:
    next loop

shift_left:
    r> over
left_loop:
    2*
    next left_loop
    over >r
    ;

shift_right:
    r> over
right_loop:
    2/
    @p MASK_SIGN and
    next right_loop
    over >r
    ;

exit:
    halt