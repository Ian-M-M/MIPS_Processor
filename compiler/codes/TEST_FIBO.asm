ldw r2, r0, 128:    //niter
ldw r3, r0, 132;    //sum -> 1
ldw r7, r0, 136;    //4 const
add r5, r0, r0;     //0
add r4, r0, r3;     //1 const
add r6, r0, r0;     //i

mul r2, r7, r2;

add r1, r0, r3;     // 1 - 1 - 2
add r3, r5, r3;     // 1 - 2 - 3
add r5, r0, r1;     // 1 - 1 - 2
stw r1, r6, 140;    //fibo[i]

add r6, r6, r7;     //i++

beq r6, r2, 2;
jump -6;