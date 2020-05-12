
clear

y = 1000;
F = 500;

sig = 3;
g = 50;
a = .4;
n = 50000;


rng(1);

p1=normrnd(50,10,n,1);
p2=p1 + 2;



e  = evrnd(0,1,n,3);
ep = normrnd(0,sig,n,4);

u1 = u(a,g,p1,y)./y   + u(a,g,p2,y )./y     + e(:,1); % IND
u2 = u(a,g,p1,y - F )./y   + u(a,g,p1,y - F )./y + e(:,2); % SHARE cheap
u3 = u(a,g,p2,y - F )./y   + u(a,g,p2,y - F )./y + e(:,3); % SHARE expensive

    w1   = w(a,g,p1)                + ep(:,1);
    w1_2 = w(a,g,p2)                + ep(:,2);
    w2   = w(a,g,p1) + w(a,g,p1)    + ep(:,3);
    w3   = w(a,g,p1) + w(a,g,p1)    + ep(:,4);


cobs=[];
wobs=[];
p1obs = [];
p2obs = [];

kk=1;
for k=1:n
   if u1(k)>u2(k) && u1(k)>u3(k)
       cobs(kk)=1;
       wobs(kk)=w1(k);
       p1obs(kk) = p1(k);
       p2obs(kk) = p2(k);
       kk=kk+1;
       cobs(kk)=1;
       wobs(kk)=w1(k);
       p1obs(kk) = p1(k);
       p2obs(kk) = p2(k);
   end
   if u2(k)>u1(k) && u2(k)>u3(k)
       cobs(kk)=2;
       wobs(kk)=w2(k);
       p1obs(kk) = p1(k);
       p2obs(kk) = p2(k);
   end
   if u3(k)>u1(k) && u3(k)>u2(k)
       cobs(kk)=3;
       wobs(kk)=w3(k);
       p1obs(kk) = p1(k);
       p2obs(kk) = p2(k);
   end
   kk=kk+1;
end
p1obs=p1obs';
p2obs=p2obs';
cobs=cobs';
wobs=wobs';


obj=@(input1)ltest3_post(input1,cobs,wobs,p1obs,p2obs,y);

input= .9.*[a g sig 250]

out=fminunc(obj,input)


% obj=@(input1)ltest3(input1,cobs,wobs,p1obs,p2obs,y,sig,F);
% 
% input= .9.*[a g ]
% 
% out=fminunc(obj,input)
