function  [ut,bobs,wobs] = counter_gh10(input,A,Tb,Tn,p_i,y,c)

sa = size(A,2);
st = size(Tb,2);
alpha0       = input(1:sa);
theta1       = input(sa+1:sa+st);
alpha1   = input(sa+st+1);
% sig = 10;
sig      = input(sa+st+2);
siga     = input(sa+st+3);

    ep  = normrnd(0,sig,size(A,1),1);
    epa = normrnd(0,siga,size(A,1),1);
    
    ub = upnl(A*alpha0,0,0,Tb*theta1,0,0,alpha1,0,0,p_i,0,0,y-c);
    un = upnl(A*alpha0,0,0,Tn*theta1,0,0,alpha1,0,0,p_i,0,0,y  );

    bobs=ub-un>epa;

    wobs =   (bobs==1).*wpnl(A*alpha0,0,0,Tb*theta1,0,0,alpha1,0,0,p_i,0,0) + ...
             (bobs==0).*wpnl(A*alpha0,0,0,Tn*theta1,0,0,alpha1,0,0,p_i,0,0) + ep;
    
    ut    = (bobs==1).*(ub-epa) + (bobs==0).*(un);