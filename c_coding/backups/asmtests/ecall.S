la x1,__vec
csrrw x0,mtvec,x1
li x1,0b1100000000000 // MPP = user
csrrc x0,mstatus,x1
la x1,__user
csrrc x0,mepc,x1
mret

__vec:
li x1,1
li x2,2
li x3,3
li x4,4
mret

__user:
li x1,4
li x2,5
ecall
li x3,6
li x4,7