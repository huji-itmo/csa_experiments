    .data
    .org 0x00

full_buffer:    .byte 7, 'Hello, '              \ 8 bytes
name_buffer:    .byte '_______________________' \ 23 bytes
buffer_end:     .byte '_'                       \ 1 bytes
                                                \ total: 32 = 0x20
input:          .word 0x80
output:         .word 0x84
byte_mask:      .word 0xFF
prompt:         .byte 19, 'What is your name?\n'
newline_char:   .word '\n'

\ def hello_user_pstr(input):
\     """Greet the user with Pascal string: ask the name and greet by `Hello, <name>!` message.
\
\     - Result string with greet message should be represented as a correct Pascal string.
\     - Buffer size for the message -- `0x20`, starts from `0x00`.
\     - End of input -- new line.
\     - Initial buffer values -- `_`.


    .text

    .org 0x88                   \ 0x80 and 0x84 are for io,
                                \ we need to start 0x84 + 0x4

write_buf_to_memio:             \ void (const char* from /*a*/, char* to /*b*/)
    prepare:
                                \ push mem[a] to data stack (its string length)
    @+                          \ byte loaded = *from++;
    @p byte_mask                \ loaded = loaded & 0xFF
    and
    dup                         \ dup to push to returnStack and to memio
    >r                          \ returnStack.push(string_length)
    drop                        \ dataStack.pop()

    loop:
    next write_next_char        \ return if all chars has been written
    r>                          \ drop the value from return stack
    drop
    ;

    write_next_char:
                                \ /* post-increment write to data stack */
    @+                          \ byte loaded = *from++;
    @p byte_mask                \ loaded = loaded & 0xFF
    and

    @p byte_mask                \ loaded = loaded & 0xFF
    and

    !b                          \ *memio = loaded
    loop ;                      \ //jump to loop

write_question:
    @p output                   \ output -> b
    b!
    lit prompt                  \ address of prompt -> a
    a!
    write_buf_to_memio          \ (/*from*/ prompt, /*to*/ output)
    ;

write_hello:
    @p output                   \ output -> b
    b!
    lit full_buffer             \ address of full_buffer -> a
    a!
    write_buf_to_memio          \ (/*from*/ full_buffer, /*to*/ output)
    ;

read_name:
    lit name_buffer
    a!                          \ a = address of name_buffer
    @p input
    b!                          \ b = address of input

read_name_cycle:
    check_overflow:
    a                           \ dataStack.push(a)
    lit buffer_end
    inv lit 1 + +               \ -current_pointer + 1 + buffer_end = buffer_end - current_pointer+1
    -if overflow                \ if (buffer_end - current_pointer + 1>=0) {return to overflow}

    @b
    dup
    if read_name_cycle_skip     \ if (new_char == \0) { jump read_name_cycle_skip }
    dup
    @p newline_char
    xor
    if read_name_end
    !+                          \ a++
    read_name_cycle ;           \ jump to read_name_cycle
read_name_cycle_skip:
    @b
    dup
    @p newline_char
    xor                         \
    if read_name_end            \ if (new_char=='\n') { jump to read_name_end}
    drop
    read_name_cycle_skip ;      \ jump to read_name_cycle
read_name_end:
    drop
    lit 0x5f5f5f21              \ exclamation mark
    !
                                \ calculate string len
    lit full_buffer             \ push address of full_buffer
    inv                         \ ~full_buffer
    lit 1
    +                           \ full_buffer = ~full_buffer + 1    /* name_buffer=-name_buffer */
    a                           \
    +                           \ dataStack.top = string_end - full_buffer(start)

    @p full_buffer
    @p byte_mask                \ loaded = loaded & ~0xFF = loaded & 0xFFFFFF00
    inv
    and
    xor                         \ merge two
    !p full_buffer              \ write
    ;

overflow:
    @p output
    a!
    lit 0xCCCC_CCCC
    !
    halt

_start:
    write_question
    read_name
    write_hello
    halt
