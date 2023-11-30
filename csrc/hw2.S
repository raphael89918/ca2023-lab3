.data
    dataset1: .word 0x3fcccccd    #1.6
    dataset2: .word 0xbfc00000    #-1.5
    dataset3: .word 0x3fb33333    #1.4
    dataset4: .word 0xbfa66666    #-1.3
    dataset5: .word 0x3f99999a    #1.2
    dataset6: .word 0xbf8ccccd    #-1.1
    array_size: .word 0x00000006

    sign: .word 0x80000000
    exp: .word 0x7F800000
    man: .word 0x007FFFFF
    bf16man: .word 0x007F0000
    bf16format: .word 0xFFFF0000
    _EOL: .string "\n"


.global main

main:
    addi sp,sp,-24
    lw s0, dataset1
    lw s1, dataset2
    lw s2, dataset3
    lw s3, dataset4
    lw s4, dataset5
    lw s5, dataset6
    lw a0, sign
    lw a1, exp
    lw a2, man
    lw a3, bf16man
    lw a4, bf16format
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    lw s11, array_size
    jal ShellSort

ShellSort:
    lw t0, array_size
    srli t0, t0, 1
Whileinterval:
    beq t0, zero, Print
    add t1, zero, t0
Foriarraysize:
    beq t1, s11, Interval_div2
    add t2, zero, t1
    slli s0, t1, 2
    add s1, sp, s0
    lw t5, 0(s1)
ReadData_Temp_done:
    sub t3, t2, t0
    slli s0, t3, 2
    add s1, sp, s0
    lw t4, 0(s1)
    jal fp32_to_bf16
WhilejandFlag:
    beq s10, zero, arrayjtotemp
    bltu t2, t0, arrayjtotemp
    and t4, t4, a4
    slli s0, t2, 2
    add s1, sp, s0
    sw t4, 0(s1)
    sub t2, t2, t0
    jal ReadData_Temp_done
arrayjtotemp:
    and t5, t5, a4
    slli s0, t2, 2
    add s1, sp, s0
    sw t5, 0(s1)
    addi t1, t1, 1
    jal Foriarraysize
Interval_div2:
    srli t0, t0, 1
    jal Whileinterval

fp32_to_bf16:
    and s0, a0, t4
    and s1, a0, t5
    and s2, a1, t4
    and s3, a1, t5
    and s4, a2, t4
    and s5, a2, t5
    and s6, a3, t4
    and s7, a3, t5
    jal BOS
    ret

BOS:
    blt s0, s1, SMALL
    beq s0, s1, Sigsame
    jal BIG
Sigsame:
    beq s2, s3, Expsame
    beq s0, zero, Exp1
    jal Exp2
Expsame:
    beq s0, zero, Man1
    jal Man2
Exp1:
    blt s2, s3, BIG
    jal SMALL
Exp2:
    blt s2, s3, SMALL
    jal BIG
Man1:
    blt s6, s7, SMALL
    jal BIG
Man2:
    blt s6, s7, BIG
    jal SMALL
BIG:
    li s10, 1
    jalr ra
SMALL:
    li s10, 0
    jalr ra

Print:
    slli s0, t6, 2
    add s1, sp, s0
    lw a0, 0(s1)
    li a7, 2
    ecall
    addi t6, t6, 1
    la a0, _EOL
    li a7, 4
    ecall
    beq t6, s11, End
    jal Print
End:
    # Exit code can be placed here
    li a7, 10
    ecall
