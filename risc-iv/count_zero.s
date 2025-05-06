
    ; def count_zero(n):
    ;     """Count the number of zeros in the binary representation of a number"""
    ;     count = 0
    ;     for _ in range(32):
    ;         count += 0 if n & 1 else 1
    ;         n >>= 1
    ;     return count
    ;
    ;
    ; assert count_zero(5) == 30
    ; assert count_zero(7) == 29
    ; assert count_zero(247923789) == 19

    .data

input_addr:     .word   0x80
output_addr:    .word   0x84

    .text

_start:
    lui      t0, %hi(input_addr)             ; int * input_addr_const = 0x00;
    addi     t0, t0, %lo(input_addr)         ; // t0 <- 0x00;

    lw       t0, 0(t0)                       ; int input_addr = *input_addr_const;
    ; // t0 <- *t0;

    lw       t1, 0(t0)                       ; int number = *input_addr;
    ; // t1 <- *t0;

    ; t0 = last_address
    ; t1 = number
    ; t2 = mask
    ; t3 = counter
    ; t4 = tmp
    ; t5 = digits_gone
    ; t6 = digit_count

create_mask:
    addi     t2, zero, 1                     ; int mask = 1;

create_digit_count:
    addi     t6, zero, 32                    ; //setting up constant

loop:

    and t4, t1, t2                           ; int tmp = number & mask
    bnez     t4, go_next_digit               ; if (tmp != 0) {
increment_counter:
    addi     t3, t3, 1                       ;      counter++;
                                             ; }
go_next_digit:

    addi     t4, zero, 1                     ; tmp = 1
    srl      t1, t1, t4                      ; number = number >> tmp //number >> 1
    addi     t5, t5, 1                       ; digits_gone++;


check_finished:

    xor      t4, t6, t5                      ; tmp = 32 ^ digits_gone
    beqz     t4, return                      ; if (tmp == 0) { break; //goto return; }

go_back_to_loop:

    j        loop

return:

    lui      t0, %hi(output_addr)            ; int * output_addr_const = 0x04;
    addi     t0, t0, %lo(output_addr)        ; // t0 <- 0x04;

    lw       t0, 0(t0)                       ; int output_addr = *output_addr_const;
    ; // t0 <- *t0;

    sw       t3, 0(t0)                       ; *output_addr_const = counter;
    ; // *t0 = t3;

    halt
