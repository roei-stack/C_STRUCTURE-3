# Roei Cohen 325714152 #
.file	"func_select.s"
.section	  .rodata	# set up jump table for switch-case
.case5060_print:    .string    "first pstring length: %d, second pstring length: %d\n"
.case52_scan:       .string    " %c %c"
.case52_print:      .string    "old char: %c, new char: %c, first string: %s, second string: %s\n"
.case5355_scan:     .string    "%hhd %hhd"
.case5354_print:    .string    "length: %d, string: %s\n"
.case55_print:      .string    "compare result: %d\n"
.error_msg:         .string    "invalid option!\n"

.align	8	# Align address to multiple of 8
.switch:
	.quad	.case5060   # Case 50: pstrlen
	.quad	.case51     # Case 51: default
	.quad	.case52     # Case 52: replaceChar
	.quad	.case53     # Case 53: pstrijcpy
	.quad	.case54     # Case 54: swapCase
	.quad	.case55     # Case 55: pstrijcpy
	.quad	.case56     # Case 56: default
	.quad	.case57     # Case 57: default
	.quad	.case58     # Case 58: default
	.quad	.case59     # Case 59: default
    .quad	.case5060   # Case 60: pstrlen
.section    .text
.global run_func
.type	run_func, @function
run_func:
    # rdi = option, rsi = &pstr1, rdx = &pstr2
	pushq	%rbp		        # set up stack
	movq	%rsp, %rbp
    subq    $32, %rsp           # allocate stack space, 16 bytes for saving rdi&rsi, and 16 bytes for other use
    movq    %rsi, -8(%rbp)      # save pointer to pstr2
    movq    %rdx, -16(%rbp)     # save pointer to pstr1
	# input in rdi, set up the jump table access
	leaq	-50(%rdi), %rcx	    # Calculate rcx = x - 50
	cmpq	$10, %rcx		    # compare with 10, the switch range
	ja		.default			# if rcx>10 or rcx<0, goto default case
	jmp		*.switch(, %rcx, 8)	# goto (switch + 8*rcx)
    .case5060:
        movq    %rsi, %rdi              # pass pstrlen argument to rdi
        call    pstrlen                 # returned lenght at rax
        movq    %rax, %rsi              # second printf argument at rsi
        movq    %rdx, %rdi              # using pstrlen one more time
        call    pstrlen
        movq    %rax, %rdx              # third printf argument at rdx
        movq    $.case5060_print, %rdi  # first printf argument at rdi
        xorq    %rax, %rax              # same as rax = 0
        call    printf
        jmp     .end
    .case51:
        jmp     .default                # Undefined case, jump to default
    .case52:
        movq    $.case52_scan, %rdi     # load format = " %c %c"
        leaq    -18(%rbp), %rsi         # rsi will point to variable
        leaq    -17(%rbp), %rdx         # rdx will point to variable
        xorq    %rax, %rax              # rax = 0
        call    scanf
        movzbq  -18(%rbp), %rsi         # rsi = second argument
        movzbq  -17(%rbp), %rdx         # rdx = third argument
        # rsi = oldChar, rdx = newChar => calling replace char for both strings
        movq    -8(%rbp), %rdi          # rdi = &pstr1
        call    replaceChar
        movq    -16(%rbp), %rdi         # rdi = &pstr2
        call    replaceChar
        movq    $.case52_print, %rdi    # load format at rdi
        movq    -8(%rbp), %rcx          # rcx = 4th argument
        incq    %rcx                    # ignore the first byte
        movq    -16(%rbp), %r8          # r8 = 5th argument
        incq    %r8                     # ignore the first byte
        xorq    %rax, %rax              # rax = 0
        call    printf 
        jmp     .end
    .case53:
        movq    $.case5355_scan, %rdi   # load format = " %d %d"
        leaq    -18(%rbp), %rsi         # rsi will point to variable
        leaq    -17(%rbp), %rdx         # rdx will point to variable
        xorq    %rax, %rax              # rax = 0
        call    scanf
        movq    -8(%rbp), %rdi          # rdi = pstr1
        movq    -16(%rbp), %rsi         # rsi = pstr2
        movzbq  -18(%rbp), %rdx         # rdx = i (only taking first byte)
        movzbq  -17(%rbp), %rcx         # rcx = j (only taking first byte)
        call    pstrijcpy
        # print "length: {dest.len}, string: {dest.str}"
        movq    $.case5354_print, %rdi  # load format string
        movzbq  (%rax), %rsi            # rsi = dest.len
        movq    -8(%rbp), %rdx          # rcx = 4th argument
        incq    %rdx
        xorq    %rax, %rax              # rax = 0
        call    printf
        # print "length: {dest.len}, string: {dest.str}"
        movq    $.case5354_print, %rdi  # load format string
        movq    -16(%rbp), %rsi         # rsi = src
        movzbq  (%rsi), %rsi            # derefrence pointer to get src.len
        movq    -16(%rbp), %rdx         # rdx = pointer to src.str
        inc     %rdx                    # ignore first byte
        xorq    %rax, %rax              # rax = 0
        call    printf
        jmp     .end
    .case54:
        movq    %rsi, %rdi
        call    swapCase
        movq    $.case5354_print, %rdi  # first argument = format
        movzbq  (%rax), %rsi            # second printf argument = str.len
        leaq    1(%rax), %rdx           # third argument = string
        xorq    %rax, %rax              # rax = 0
        call    printf
        movq    -16(%rbp), %rdi         # load pstr2 for function
        call    swapCase
        movq    $.case5354_print, %rdi  # first argument = format
        movzbq  (%rax), %rsi            # second printf argument = str.len
        leaq    1(%rax), %rdx           # third argument = string
        xorq    %rax, %rax              # rax = 0
        call    printf
        jmp     .end
    .case55:
        movq    $.case5355_scan, %rdi   # load format = " %d %d"
        leaq    -18(%rbp), %rsi         # rsi will point to variable
        leaq    -17(%rbp), %rdx         # rdx will point to variable
        xorq    %rax, %rax              # rax = 0
        call    scanf
        movq    -8(%rbp), %rdi          # rdi = pstr1
        movq    -16(%rbp), %rsi         # rsi = pstr2
        movzbq  -18(%rbp), %rdx         # rdx = i (only taking first byte)
        movzbq  -17(%rbp), %rcx         # rcx = j (only taking first byte)
        call    pstrijcmp
        movq    $.case55_print, %rdi    # load format at rdi
        movq    %rax, %rsi              # rsi = second argument (compare result)
        xorq    %rax, %rax              # rax = 0
        call    printf
        jmp     .end
    .case56:
        jmp     .default                # Undefined case, jump to default
    .case57:
        jmp     .default                # Undefined case, jump to default
    .case58:
        jmp     .default                # Undefined case, jump to default
    .case59:
        jmp     .default                # Undefined case, jump to default
    .default:
        leaq    .error_msg(%rip), %rdi  # load the string adress into rdi
        xorq %rax, %rax                 # rax = 0
        call printf                     # print('invalid option!')
    .end:
        movq    %rbp, %rsp      # adjust rsp
        popq    %rbp
        ret
