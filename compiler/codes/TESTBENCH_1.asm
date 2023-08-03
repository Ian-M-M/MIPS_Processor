// .dat
// valueA = 2  // 0x80
// valueB = 4  // 0x84
// resAdd = 6  // 0x88
// resSub = 2  // 0x8c
// resAnd = 0  // 0x90
// resOR  = 6  // 0x94
// res MUL= 8  // 0x98
// i      = 1  // 0x9c
// .text

ldw r6, r0, +128; // A
ldw r7, r0, +132; // B

mul r5, r6, r7;
add r1, r6, r7;
sub r2, r6, r7;
and r3, r6, r7;
or  r4, r6, r7;

stw r1, r0, +152; // -> add
stw r2, r0, +136; // -> sub
stw r3, r0, +140; // -> and
stw r4, r0, +144; // -> or
stw r5, r0, +148; // -> mul

ldw r2, r0, +132;
ldw r3, r0, +156; // i
ldw r1, r0, +128;
sub r1, r1, r3;
beq r0, r2, -1;
add r2, r2, r3;
beq r0, r1, -4;
