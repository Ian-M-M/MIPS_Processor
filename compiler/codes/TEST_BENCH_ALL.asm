ldw r2, r0, 128;    // 0x50 -> 128
ldw r3, r0, 132;    // 0x54 -> 4 (Fake inmm)

add r4, r0, r0;     // sum
add r5, r0, r0;     // sub
add r6, r0, r0;     // mul
add r7, r0, r0;     // and
add r8, r0, r0;     // or

add r1, r0, r0;     // i

ldw r9, r1, 136;    // 0x58 -> a[i]

add r4, r4, r9;     // sum += a[i]
sub r5, r5, r9;     // sub -= a[i]
mul r6, r6, r9;     // mul *= a[i]
and r7, r7, r9;     // and &= a[i]
or  r8, r8, r9;     // or |= a[i]

add r1, r1, r3;     // i++
beq r1, r2, 2;      // i < 128
jump -8;

stw r4, r0, 648;     // sum
stw r5, r0, 672;     // sub
stw r6, r0, 676;     // mul
stw r7, r0, 680;     // and
stw r8, r0, 684;     // or