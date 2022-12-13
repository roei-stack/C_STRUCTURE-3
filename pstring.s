# Roei Cohen 325714152 #
.file   "pstring.s"
    .section    .rodata
.invalid_input_msg: .string "invalid input!\n"
    .section    .text
.global pstrlen
.type   pstrlen, @function
pstrlen:
    # rdi = Pstring* pstr (no need for stack frame)
    movzbq  (%rdi), %rax    # rdi points to length, move first byte to rax
    ret                     # return to caller

.global replaceChar
.type   replaceChar, @function
replaceChar:
    # rdi = pstr, rsi = oldChar, rdx = newChar (no need for stack frame)
    xorq    %rcx, %rcx      # cl = 0, we will iterate over the string using cl
    incb    %cl             # cl = 1, first character is at 1 byte offset
    movb    (%rdi), %r8b    # r8b = len + 1, so we can bound check
    incb    %r8b
    .while0:
        movb    (%rdi, %rcx, 1), %r9b   # r9b = *(rdi + 1*cl), rdi = arr[i]
        cmpb    %sil, %r9b              # compare A[i] : oldchar (sil has the first byte of rsi)
        jnz      .endif
        movb    %dl, (%rdi, %rcx, 1)     # Arr[i] = newChar (dl is rdx's first byte)
        .endif:
            incb    %cl                        # cl++
            cmpb    %r8b, %cl                  # compare cl with length + 1
            jnz     .while0                    # loop back if cl!=len+1
    movq    %rdi, %rax      # move return value to rax
    ret                     # return to caller

.global pstrijcpy
.type   pstrijcpy, @function
pstrijcpy:
    # rdi = dest, rsi = src, rdx = i(= dl), rcx = j (=cl)
    # dst[i:j] <- src[i:j]
    pushq   %rbp            # set up stack
    movq    %rsp, %rbp
    pushq   %rdi            # save return pointer value
    cmpb    %cl, %dl        # compare i with j
    ja      .invalid        # if (i > j or i < 0): goto invalid
    cmpb    (%rdi), %cl     # compare j : dest.len()
    jae     .invalid
    cmpb    (%rsi), %cl     # compare j : src.len()
    jae     .invalid
    .while1:                # loop for i to j:
        #dst[i] = src[i]
        movb    1(%rsi, %rdx, 1), %r8b      # x = src[i]
        movb    %r8b, 1(%rdi, %rdx, 1)      # dest[i] = x
        incb    %dl                         # i++
        cmpb    %cl, %dl                    # compare j:i
        jbe     .while1                     # if i<=j: goto while
    jmp     .end            # skip invalid section
    .invalid:
        movq    $.invalid_input_msg, %rdi   # load argument to rdi
        xorq    %rax, %rax                  # rax = 0
        call    printf
    .end:
        popq    %rax                        # return pointer in stack
        popq    %rbp                        # clear stack
        ret

.global swapCase
.type   swapCase, @function
swapCase:
    # rdi = pointer to pstring, (no need for stack frame)
    xorq    %rcx, %rcx      # cl = 0, we will iterate over the string using cl
    movb    (%rdi), %r8b    # r8b = len + 1, so we can bound check
    incb    %r8b
    # note: UPPER CASE letters have the ascii range of 65-90
    # note: lower case letters have the ascii range of 97-122
    # which means that for every letter, it's ascii distance from it's other form IS 32!
    .while3:
        movb    1(%rdi, %rcx, 1), %r9b      # x = r9b = pstr.str[i]
        subb    $65, %r9b                   # 65<=x<=90 iff 0<=(x-65)<=25
        cmpb    $25, %r9b
        jbe     .lower_case
        # NOTE: i added back 65 previously subtracted, then subtracted 97
        subb    $32, %r9b                   # hence subtracting only 32 and not 97
        cmpb    $25, %r9b                   
        jbe     .upper_case    
        jmp     .end_if
        .lower_case:
            addb    $32, 1(%rdi, %rcx, 1)       # add 32 to any lower case letter to make it higher case
            jmp     .end_if                     # skip else code
        .upper_case:
            subb    $32, 1(%rdi, %rcx, 1)       # subtract 32 to any upper case letter to make it lower case
        .end_if:
            incb    %cl                         # i++
            cmpb    %r8b, %cl                   # compare i:len+1
            jnz     .while3                     # if i!=len+1 : goto while
    movq    %rdi, %rax      # return pointer at rax
    ret                     # return to caller

.global pstrijcmp
.type   pstrijcmp, @function
pstrijcmp:
    # rdi = pstr1, rsi = pstr2, rdx = i, rcx = j
    cmpb    %cl, %dl        # compare i with j
    ja      .invalid2       # if (i > j or i < 0): goto invalid
    cmpb    (%rdi), %cl     # compare j : dest.len()
    jae     .invalid2
    cmpb    (%rsi), %cl     # compare j : src.len()
    jae     .invalid2
    xorq    %rax, %rax      # rax = 0
    .while4:
        movb    1(%rdi, %rdx, 1), %r8b      # r8b = pstr1[i]
        cmpb    1(%rsi, %rdx, 1), %r8b      # pstr1[i] : pstr2[i]
        je      .continue                   # if pstr1[i] == pstr2[i] => continue
        jb      .lower
        # in case both conditions failed, pstr1>pstr2
        movq    $1, %rax
        jmp .end2
        .lower:
            movq    $-1, %rax
            jmp     .end2
        .continue:
            incb    %dl                         # i++
            cmpb    %cl, %dl                    # compare j:i
            jle     .while4                     # if i<=j: goto while
    jmp     .end2           # skip invalid section
    .invalid2:
        movq    $.invalid_input_msg, %rdi   # load argument to rdi
        xorq    %rax, %rax                  # rax = 0
        call    printf
        movq    $-2, %rax                   # in case of invalid input, functions returns -2
    .end2:
        ret
