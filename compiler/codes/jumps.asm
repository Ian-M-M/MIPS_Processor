ldw r1, r0, 128;   // r1 = 5;

jump 3;         // r2 should not be modified.

add r2, r0, r1; // Should not be executed.

jump 3;         // go to 12

add r3, r0, r1; // r3 = 5;
jump -2;        // go to 7

add r4, r0, r0; // r4 = 0
add r5, r0, r1; // r5 = 5
add r6, r0, r1; // r6 = 5

beq r4, r5, 100; // r4 != r5 so should not jump
beq r5, r6, 2;   // r5 == r6 so should go to 19
add r7, r5, r5;  // should not be executed
add r8, r0, r0;  // r8 = 0
add r8, r8, r1;  // r8 = r8 + 5
beq r5, r6, -1;  // go to 20
