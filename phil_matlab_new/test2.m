
clear

y = 1000;
F = 100;

sig = 3;
g = 50;
a = .4;
n = 10000;
p1v=50;
p2v=10;
p1 = repmat((1:p1v)',n/p1v,1);
p2 = repmat((1:p2v)',n/p2v,1);

rng(1);

p1=normrnd(50,10,n,1);
p2=normrnd(40,5,n,1);

e  = evrnd(0,1,n,2);
ep = normrnd(0,sig,n,2);

u1 = u(a,g,p1,y)./y + e(:,1);
u2 = u(a,g,p1,y)./y + e(:,2);

w1 = w(a,g,p1) + ep(:,1);
w2 = w(a,g,p2) + ep(:,2);


cobs = 1.*(u1>u2) + 2.*(u2>u1);

wobs = w1.*(u1>u2) + w2.*(u2>u1);

obj=@(input1)ltest2(input1,cobs,wobs,p1,p2,y);

input= .9.*[a g sig]

out=fminunc(obj,input)