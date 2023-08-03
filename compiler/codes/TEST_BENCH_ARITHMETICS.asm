//a = 4;
//b = 1;
//res2 = a-b;         //4-1=3
//res1 = a+res2;      //4+3=7 EX_BYPASS
//res5 = a*b;         //4*1=4
//res1 = a+b          //4+1=5
//NOP;
//res4 = res1&res5;   //4&4= 4 MUL5_BYPASS and ROB_BYPASS
//res5 = a|b;         //4*1=4

ldw r1, r0, 128;    // a = 4;
ldw r2, r0, 132;    // b = 1;

sub r3, r1, r2; // C_BYPASSi
add r4, r1, r3; // EX_BYPASS

mul r5, r1, r2;
add r6, r1, r2;
nop;
and r7, r6, r5; // MUL5_BYPASS && ROB_BYPASS
or r8, r1, r2;