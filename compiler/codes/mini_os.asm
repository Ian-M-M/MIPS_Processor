// OS takes from 0x2000 to 0x3000 included
// TRANSLATION (0x8000)
// A = @0x2504 == 9476
// B = @0x2508 == 9480
// B = @0x250C == 9484
stw r5, r0, 9476;  // push(r5)
stw r6, r0, 9480;  // push(r6)
stw r7, r0, 9484;  // push(r7)

ldw r6, r0, 9472;  // r6 = 0x8000
mov r5, rm1;       // r5 = rm1
add r6, r6, r5;    // r6 = r5 + 0x8000

mov r7, rm2;       // r5 = rm1 // r7 = 0 if iTLB or 1 if dTLB.
beq r0, r7, 3;     // r7 == 0 ? -> iTLB

DTLBWRITE r6, r5;  // (r6 = physical @, r5 = virtual @) write in dTLB
jump 2;            // exit

ITLBWRITE r6, r5;   // (r6 = physical @, r5 = virtual @) write in iTLB

ldw r5, r0, 9476; // pop(r5)
ldw r6, r0, 9480; // pop(r6)
ldw r7, r0, 9484; // pop(r7)

IRET;
