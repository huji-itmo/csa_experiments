    .data
input_addr:     .word   0x80
output_addr:    .word   0x84

tmp:            .word   -1
a:              .word   -1      ; will input data
b:              .word   -1
one_const:      .word   1

    ; def gcd(a, b):
    ;     """Find the greatest common divisor (GCD)"""
    ;     while b != 0:
    ;         a, b = b, a % b
    ;     return [abs(a)]

    ; program steps:
    ; 1. check loop condition
    ; 2. write b to a
    ; 3. load a and make division
    ; 4. load the remainder to b
    ; 5. jump to the start of the loop
    ; at the end:
    ; 1. check if a < 0 then neg it
    ; 2. write the a to the 0x84 addr


    .text
_start:
    load_ind input_addr
    store a
    load_ind input_addr
    store b

while_loop:
    load b          ; b -> acc
    beqz end        ; leave the while loop (the condition b != 0)
                    ; save the a value for later
    load a
    store tmp
                    ; write b variable to the a
    load b
    store a
                    ; perform rem operation
                    ; rem <addr>    acc <- acc % mem[<addr>]

    load tmp        ; where a value sits
    rem b           ; b is where a value sits
                    ; now in acc there is expr(a % b)

    store b         ; write the result to b

    jmp while_loop  ;continue with the loop

end:
    load a
    bgt return      ; if a > 0, skip neg and just return

                    ; make the neg operation
    not
    add one_const

return:
    store_ind output_addr
    halt
