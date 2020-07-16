function  h = lbooster1(input,Bobs,wobs,p,S,y,SC,c,B,given)

alpha0   = input(1);
alpha1   = input(2);
theta    = input(3);
sig      = input(4);

% B        = input(3);

%  alpha0   = given(1);
%  alpha1   = given(2);
%  B    = given(3);
%   theta    = given(4);
%  sig      = given(5);


v1 = exp( up(  S  ,alpha0,alpha1,p,theta,y)./SC                );
v2 = exp( up(  S + B ,alpha0,alpha1,p ,theta,y - c)./SC  );

Bprob1=v1./(v1 + v2);
Bprob2=v2./(v1 + v2);

w1 = normpdf( (wobs - wp(  S ,alpha0,alpha1,p,theta)  ),0,sig );
w2 = normpdf( (wobs - wp(  S + B ,alpha0,alpha1,p,theta)  ),0,sig );

% w1=1;
% w2=1;

h = -1.*sum( (Bobs==1).*(log(Bprob1) + log(w1)) ...
           + (Bobs==2).*(log(Bprob2) + log(w2)) );

% h = -1.*sum( (Bobs==1).*(log(Bprob1) + 100000.*log(w1)) ...
%            + (Bobs==2).*(log(Bprob2) + 100000.*log(w2)) );

end