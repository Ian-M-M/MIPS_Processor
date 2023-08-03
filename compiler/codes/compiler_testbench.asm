// ADD r1, r2, r3
// TYPE R
add r1,r2,r3; // Comentario
SUB r4, r5, r6; // Comentario
MuL  r7, r8, r9    ; // Comentario
Or  r10,    r11,    r12; // Comentario
AND  r13,   r14,  r15 ;
// TYPE M
LDB r16, r17, 10;
LDW r18, r19, -10;
STB r20, r21, 1000;
STW r22, r23, -13123;
// TYPE B1
BEQ r24, r25, -1000;
// SPECIAL
NOP;
MOV r26, rm1;
JUMP 1000;
ITLBWRITE r27, r28;
dTLBWRITE r27, r28;
IRET;
// FIN
// AHORA ERRORES
// ADDUUUUDU r1, r2, r3; // Error
// ADD r32, r2, r2; // Error