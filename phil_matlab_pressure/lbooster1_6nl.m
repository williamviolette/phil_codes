function  [h,um,bm] = lbooster1_6nl(input,Bobs,wobs,pi,pr,y,c,post,A,T,given)

B=1;
alen=size(A,2);
% tlen=size(T,2);
alpha0   = input(1:alen);
sig      = input(alen +1);
alpha1   = input(alen +2);
theta1   = input(alen +3);
theta3   = input(alen +4);
siga     = input(alen +5);
t2       = input(alen +6:end);

% alpha0   = given(1:alen);
% sig      = given(alen +1);
% alpha1   = given(alen +2);
% theta1   = given(alen +3);
% theta2   = given(alen +4);
% theta3   = given(alen +5);

a0 = A*alpha0;
theta2=T*t2;

v1 =  upnl(  a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y) ;
v2 =  upnl(  a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c) ;

Bprob1=normcdf(v1-v2,0,siga);
Bprob2=1-normcdf(v1-v2,0,siga);

w1 = normpdf( (wobs - wpnl( a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) ),0,sig );
w2 = normpdf( (wobs - wpnl( a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3)  ),0,sig );

h = -1.*sum( (Bobs==0).*(log(Bprob1) + log(w1)) ...
           + (Bobs==1).*(log(Bprob2) + log(w2)) );


if nargout>1
    rng(3);
    n = size(A,1);
    e  = normrnd(0,siga,n,2);
%     ep = normrnd(0,sig,n,2);

    v1s = upnl(  a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y)  + e(:,1);
    v2s = upnl(  a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c) + e(:,2);
%     w1s = wp1( a0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) + ep(:,1);
%     w2s = wp1( a0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3)   + ep(:,2);
    
%     um = mean( upn1.*(v1s>=v2s) + upn2.*(v2s>v1s) );
    um = mean( v1s.*(v1s>v2s) + v2s.*(v2s>v1s) );
    bm = mean((v2s>v1s));
end
       
end