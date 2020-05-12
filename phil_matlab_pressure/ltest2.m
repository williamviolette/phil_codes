function  h = ltest2(input,Bobs,wobs,p1,S,y,c,given)

alpha0   = input(1);
 alpha1   = input(2);
 theta0   = input(3);
 theta1   = input(4);
  beta     = input(5);
 sig      = input(6);

% alpha1   = given(2);
% theta0   = given(3);
% theta1   = given(4);
%  beta     = given(5);
% sig      = given(6);

v1 = exp( u( alpha0,alpha1,p1,theta0,theta1,S, 0 ,beta,y,c) );
v2 = exp( u( alpha0,alpha1,p1,theta0,theta1,S, 1 ,beta,y,c) );

Bprob1=v1./(v1 + v2);
Bprob2=v2./(v1 + v2);

w1 = normpdf( (wobs - w(alpha0,alpha1,p1,theta0,theta1,S,0,beta,y,c)),0,sig );
w2 = normpdf( (wobs - w(alpha0,alpha1,p1,theta0,theta1,S,1,beta,y,c)),0,sig );

% h = -1.*sum( (Bobs==1).*(log(Bprob1) + log(w1)) ...
%            + (Bobs==2).*(log(Bprob2) + log(w2)) );

h = -1.*sum( (Bobs==1).*(log(Bprob1) + 100000.*log(w1)) ...
           + (Bobs==2).*(log(Bprob2) + 100000.*log(w2)) );

end