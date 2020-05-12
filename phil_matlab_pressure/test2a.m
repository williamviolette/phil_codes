

clear


c = 300;

sig = 3;
alpha0 =  60;
alpha1 = -.2;

gamma = .5;

theta0 = .2;
theta1 = 5;

n = 30000;

rng(1);

SC = 10;

y = 10000;
S  = 1+1.*rand(n,1);
p1 = normrnd(50,10,n,1);

e  = evrnd(0,1,n,2);
ep = normrnd(0,sig,n,2);

ua1 = ua(  S,alpha0,alpha1,p1,theta0,theta1,y);
% hist(ua1)


u1 = ua(  S,alpha0,alpha1,p1,theta0,theta1,y)./SC + e(:,1);
u2 = ua(  S  + gamma ,alpha0,alpha1,p1,theta0,theta1,y - c)./SC + e(:,2);
mean(u2>u1)

u1s = ua(  S         , alpha0 ,alpha1,p1,theta0,theta1,y)./SC + e(:,1);
u2s = ua(  S + gamma , alpha0 ,alpha1,p1,theta0,theta1,y - c)./SC + e(:,2);
mean(u2s>u1s)



wa1=wa(  S      ,alpha0,alpha1,p1,theta0,theta1);
% hist(wa1)

w1 = wa(  S      ,alpha0,alpha1,p1,theta0,theta1)  + ep(:,1);
w2 = wa(  S+gamma,alpha0,alpha1,p1,theta0,theta1)  + ep(:,2);

Bobs = 1.*(u1>u2) + 2.*(u2>u1);
mean(Bobs)

wobs = w1.*(u1>u2) + w2.*(u2>u1);
mean(wobs)

given = [alpha0 alpha1 theta0 theta1 gamma sig];

obj=@(input1)ltest2a(input1,Bobs,wobs,p1,S,y,c,SC,given);

given
input= .9.*[alpha0 alpha1 theta0 theta1 gamma sig]

% input= [alpha0 alpha1 1.1.*theta0 theta1 1.1.*gamma sig]

out=fminunc(obj,input)



