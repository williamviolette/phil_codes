function  h = ltest2a(input,Bobs,wobs,p1,S,y,c,SC,given)

alpha0   = input(1);
alpha1   = input(2);
theta0   = input(3);
theta1   = input(4);
gamma    = input(5);
sig      = input(6);

%  alpha0   = given(1);
%  alpha1   = given(2);
% %  theta0   = given(3);
%  theta1   = given(4);
% %  gamma    = given(5);
%  sig      = given(6);



v1 = exp( ua(  S,alpha0,alpha1,p1,theta0,theta1,y)./SC                );
v2 = exp( ua(  S  + gamma,alpha0,alpha1,p1,theta0,theta1,y - c)./SC  );

Bprob1=v1./(v1 + v2);
Bprob2=v2./(v1 + v2);

w1 = normpdf( (wobs - wa(  S,alpha0,alpha1,p1,theta0,theta1) ),0,sig );
w2 = normpdf( (wobs - wa(  S  + gamma ,alpha0,alpha1,p1,theta0,theta1)   ),0,sig );

% w1=1;
% w2=1;

h = -1.*sum( (Bobs==1).*(log(Bprob1) + log(w1)) ...
           + (Bobs==2).*(log(Bprob2) + log(w2)) );

% h = -1.*sum( (Bobs==1).*(log(Bprob1) + 100000.*log(w1)) ...
%            + (Bobs==2).*(log(Bprob2) + 100000.*log(w2)) );

end