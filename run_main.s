# Roei Cohen 325714152 #
.file   "run_main.s"
    .section    .rodata
.scan_int:       .string    "%d"
.scan_string:    .string    "%s"
    .section    .text
.global run_main
.type   run_main, @function
run_main:
    pushq   %rbp                        # set up stack frame
    movq    %rsp, %rbp
    subq    $512, %rsp                  # allocate space for pstrings
    # calling scanf for first pstring
    movq    $.scan_int, %rdi            # load format ("%d") into rdi
    movq    %rsp, %rsi                  # load variable address into rsi
    xorq    %rax, %rax                  # rax = 0
    call    scanf
    movzbq  (%rsp), %rcx                # rcx = len
    movb    $0, 1(%rsp, %rcx, 1)        # last string byte = NULL              
    # calling scanf to scan string
    movq    $.scan_string, %rdi         # load format ("%s") into rdi
    leaq    1(%rsp), %rsi               # the string is stored at the second byte
    xorq    %rax, %rax                  # rax = 0
    call scanf
    # calling scanf for second pstring
    movq    $.scan_int, %rdi            # load format ("%d") into rdi
    leaq    -256(%rbp), %rsi            # load variable address into rsi
    xorq    %rax, %rax                  # rax = 0
    call    scanf
    leaq    -256(%rbp), %rax            # load pstring address
    movzbq  (%rax), %rcx                # rcx = len
    movb    $0, 1(%rax, %rcx, 1)        # last byte = NULL              
    # calling scanf to scan string
    movq    $.scan_string, %rdi         # load format ("%s") into rdi
    leaq    1(%rax), %rsi               # the string is stored at the second byte
    xorq    %rax, %rax                  # rax = 0
    call scanf
    # calling scanf for option
    subq    $16, %rsp                   # allocate for option
    movq    $.scan_int, %rdi            # load format ("%d") into rdi
    movq    %rsp, %rsi                  # load option address into rsi
    xorq    %rax, %rax                  # rax = 0
    call    scanf
    # now call run_func:
    movzbq  (%rsp), %rdi                # rdi = option (first byte at rsp)
    leaq    -512(%rbp), %rsi            # rsi = &p1
    leaq    -256(%rbp), %rdx            # rdx = &p2
    call    run_func
    # deallocation
    movq    %rbp, %rsp
    popq    %rbp
    ret                                 # return
