.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.global _estack
.global Reset_Handler

.section .isr_vector, "a", %progbits
.type g_pfnVectors, %object
g_pfnVectors:
    .word _estack
    .word Reset_Handler
    .word HardFault_Handler
    .word 0, 0, 0, 0, 0, 0, 0, 0
    .word 0, 0, 0, 0, 0, 0, 0, 0
    .word 0, 0, 0, 0, 0, 0, 0, 0
    .word 0, 0, 0, 0, 0, 0, 0, 0
    .size g_pfnVectors, .-g_pfnVectors

.section .text.Reset_Handler
.weak Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
    ldr r0, =_estack
    mov sp, r0

    ldr r0, =_etext
    ldr r1, =_sdata
    ldr r2, =_edata
    subs r2, r1
    ble .L_data_done
.L_data_loop:
    ldrb r3, [r0], #1
    strb r3, [r1], #1
    subs r2, r2, #1
    bgt .L_data_loop
.L_data_done:

    ldr r1, =_sbss
    ldr r2, =_ebss
    subs r2, r1
    ble .L_bss_done
    movs r3, #0
.L_bss_loop:
    strb r3, [r1], #1
    subs r2, r2, #1
    bgt .L_bss_loop
.L_bss_done:

    bl main
    b .

.weak HardFault_Handler
.type HardFault_Handler, %function
HardFault_Handler:
    b HardFault_Handler
