

clear


c = 700;

sig = 3;
alpha0 =  60;
alpha1 = -.2;

theta0 = -.2;
theta1 = .1;
beta = .005;

n = 20000;

rng(1);

SC = 1;

y = 8000 + 2000.*rand(n,1);
S  = 100.*rand(n,1);
p1 = normrnd(50,20,n,1);

e  = evrnd(0,1,n,2);
ep = normrnd(0,sig,n,2);

u1 = u( alpha0,alpha1,p1,theta0,theta1,S, 0 ,beta,y,c).*SC + e(:,1);
u2 = u( alpha0,alpha1,p1,theta0,theta1,S, 1 ,beta,y,c).*SC + e(:,2);

w1 =  w(alpha0,alpha1,p1,theta0,theta1,S, 0 ,beta,y,c) + ep(:,1);
w2 =  w(alpha0,alpha1,p1,theta0,theta1,S, 1 ,beta,y,c) + ep(:,2);

Bobs = 1.*(u1>u2) + 2.*(u2>u1);
mean(Bobs)

wobs = w1.*(u1>u2) + w2.*(u2>u1);
mean(wobs)

given = [alpha0 alpha1 theta0 theta1 beta sig];

obj=@(input1)ltest2(input1,Bobs,wobs,p1,S,y,c,given);

input= .9.*[alpha0 alpha1 theta0 theta1 beta sig]

% input= .9.*[  alpha0 alpha1 theta0 theta1   ];

out=fminunc(obj,input)