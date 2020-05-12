
clear

y = 1000;
F = 100;

g = 50;
a = .1;
p1 = 20;
p2 = 30;

rng(1);

n = 10000;

e = evrnd(0,1,n,2);

u1 = a.*p1 + e(:,1);
u2 = a.*p2 + e(:,2);

mean(u1>u2)

c = 1.*(u1>u2) + 2.*(u2>u1);

obj=@(input1)ltest(input1,c,p1,p2);

aguess= .2;
fminunc(obj,aguess)