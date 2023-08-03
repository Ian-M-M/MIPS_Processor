// int a[128][128], b[128][128], c[128][128];
// for (i=0; i<128; i++) { 
//      for(j =0;j<128;j++) {
//           c[i][j] = 0;
//           for(k = 0; k <128; k++ ) {
//                 c[i][j] = c[i][j] + a[i][k] * b[k][j];
//           }
//      }
// }

// 16384
// dir A -> 136
// next_dir -> 4*128*128 -> 65536
// dir B -> 65616
// dir C -> 131152

// base dir
// 184 -> a
// 65664 -> b
// 131200 -> c

ldw r15, r0, 128;   // 128
ldw r16, r0, 132;   // 4
mul r22, r15, r16;  // size * dataSize
        // inicio bucle i
add r1, r0, r0;     // i
    // inicio bucle j
add r2, r0, r0;     // j
mul r4, r1, r15;    // i*sizeA
add r8, r4, r2;     // i*sizeA+j
stw r0, r8, 131200;    // c[i][j] = 0
// inicio bucle k
add r3, r0, r0;     // k
mul r9, r3, r15;    // k*sizeB
add r10, r9, r2;    // k*sizeB+j
add r11, r4, r3;    // i*sizeA+k
ldw r18, r10, 65664;  // b[k][j]
ldw r17, r11, 184;  // a[i][k]
ldw r19, r8,  131200;  // c[i][j]
mul r20, r17, r18;  // a[i][k] * b[k][j]
add r21, r20, r19;  // c[i][j] + a[i][k] * b[k][j]
stw r21, r8,  131200;  // c[i][j] = c[i][j] + a[i][k] * b[k][j];
add r3, r3, r16;    // k++
beq r3, r22, 2;     // k == 128
jump -11;
// fin bucle k
add r2, r2, r16;    // j++
beq r2, r22, 2;     // j == 128
jump -18;
    // fin bucle j
add r1, r1, r16;    // i++
beq r1, r22, 2;     // i == 128
jump -22;
        // fin bucle i