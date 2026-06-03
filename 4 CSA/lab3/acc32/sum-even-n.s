    .data

input_addr:      .word  0x80
output_addr:     .word  0x84
n:               .word  0x00
last_even_half:  .word  0x01
result:          .word  0x00
const_1:         .word  0x01
const_2:         .word  0x02

    .text

_start:
    load         input_addr
    load_acc
    store        n

    bgt          check_even
    jmp          not_in_domain

check_even:
    and          const_1
    bnez         is_odd
    load         n
    jmp          calculation

is_odd:
    load         n
    sub          const_1

calculation:
    ; m = last_even / 2
    div          const_2
    store        last_even_half

    ; sum = m * (m + 1)
    add          const_1
    mul          last_even_half

    bvs          overflow_handler

    store        result
    jmp          program_end

overflow_handler:
    load_imm     0xCCCC_CCCC
    store        result
    jmp          program_end

not_in_domain:
    load_imm     -1
    store        result

program_end:
    load         result
    store_ind    output_addr
    halt