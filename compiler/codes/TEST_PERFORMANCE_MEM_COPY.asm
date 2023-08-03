// int a[128], b[128];
// for (i=0; i<128; i++) { a[i] = 5; }
// for (i=0; i<128; i++) { b[i] = a[i]; }

ldw r2, r0, 128; // 128
ldw r3, r0, 132; // 4 (Fake inmm)
ldw r4, r0, 136; // 5
add r1, r0, r0; // i

stw r4, r1, 140; // a[i] = 5
add r1, r1, r3; // i++

beq r1, r2, 2; // i < 128
jump -3;

add r1, r0, r0;  // i

ldw r14, r1, 140; // a[i]
stw r4, r1, 652; // b[i] = a[i]
add r1, r1, r3;  // i++

beq r1, r2, 2; // i < 128
jump -4;

ldw r15, r1, 140; // a[i]