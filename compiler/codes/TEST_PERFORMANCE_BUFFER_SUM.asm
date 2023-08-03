// int a[128], sum = 0;
// for (i=0; i<128; i++) { sum += a[i]; }

ldw r2, r0, 128; // 0x50 -> 128
ldw r8, r0, 132; // 0x54 -> 4 (Fake inmm)
add r3, r0, r0; // sum
add r1, r0, r0; // i
ldw r4, r1, 136; // 0x58 -> a[i]
add r3, r3, r4; // sum += a[i]
add r1, r1, r8; // i++
beq r1, r2, 2; // i < 128
jump -4;
