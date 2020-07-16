function  [val,g,h] = lbooster_gh2(input,wobs,bobs,p_i,p_r,y,c,given)

% alen=size(A,2);
% tlen=size(T,2);
alpha0   = input(1);
alpha1   = input(2);
sig      = input(3);
siga     = input(4);
theta1   = given(5);
% t1   = input(alen +3);
% t3   = input(alen +4);
% t2   = input(alen +5);
% siga     = input(alen +5);
% alpha0   = given(1:alen);
% sig      = given(alen +1);
% alpha1   = given(alen +2);
% theta1   = given(alen +3);
% theta2   = given(alen +4);
% theta3   = given(alen +5);

% alpha0 = A*a0;

% es=zeros(1,size(A,2));


yb=y-c;
theta1b=theta1;

nc = sqrt(pi*2);
np = ones(size(wobs,1),1);
es = zeros(size(wobs,1),1);

[valw,gw,hw] = gh2(alpha0,alpha1,es,nc,np,p_i,p_r,sig,theta1,wobs);

[valu,gu,hu] = ghu2(alpha0,alpha1,bobs,es,np,p_i,p_r,siga,theta1,theta1b,wobs,y,yb);


val = sum(valw + valu);
g   = sum(gw + gu);
h = sum(hw + hu);

h = reshape(h,sqrt(size(h,2)),sqrt(size(h,2)));


%        
% v1 =  upnl(  a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y) ;
% v2 =  upnl(  a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c) ;
% 
% Bprob1=normcdf(v1-v2,0,siga);
% Bprob2=1-normcdf(v1-v2,0,siga);
% 
% w1 = normpdf( (wobs - wpnl( a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) ),0,sig );
% w2 = normpdf( (wobs - wpnl( a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3)  ),0,sig );
% 
% m = -1.*sum( (Bobs==0).*(log(Bprob1) + log(w1)) ...
%            + (Bobs==1).*(log(Bprob2) + log(w2)) );


       
       
%        
%        
% if nargout>1
%     rng(3);
%     n = size(A,1);
%     e  = normrnd(0,siga,n,2);
% %     ep = normrnd(0,sig,n,2);
% 
%     v1s = upnl(  a0,alpha1,pi,pr,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y)  + e(:,1);
%     v2s = upnl(  a0,alpha1,pi,pr,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c) + e(:,2);
% %     w1s = wp1( a0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3) + ep(:,1);
% %     w2s = wp1( a0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3)   + ep(:,2);
%     
% %     um = mean( upn1.*(v1s>=v2s) + upn2.*(v2s>v1s) );
%     um = mean( v1s.*(v1s>v2s) + v2s.*(v2s>v1s) );
%     bm = mean((v2s>v1s));
% end
       
end