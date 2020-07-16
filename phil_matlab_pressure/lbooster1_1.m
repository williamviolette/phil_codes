function  h = lbooster1_1(input,Bobs,wobs,p,y,SC,c,B,post,given)

alpha0   = input(1);
alpha1   = input(2);
theta1   = input(3);
theta2   = input(4);
theta3   = input(5);
sig      = input(6);

%  B        = input(3);
%  alpha0   = given(1);
%  alpha1   = given(2);
%  B    = given(3);
%  theta    = given(4);
%  sig      = given(5);


v1 = exp( up1(  alpha0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3,y)./SC                );
v2 = exp( up1(  alpha0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3,y - c)./SC  );

Bprob1=v1./(v1 + v2);
Bprob2=v2./(v1 + v2);

w1 = normpdf( (wobs - wp1( alpha0,alpha1,p,theta1.*(1-B) + post.*theta2  + post.*(1-B).*theta3)  ),0,sig );
w2 = normpdf( (wobs - wp1( alpha0,alpha1,p,theta1.*B + post.*theta2  + post.*(B).*theta3)  ),0,sig );

% w1=1;
% w2=1;

h = -1.*sum( (Bobs==1).*(log(Bprob1) + log(w1)) ...
           + (Bobs==2).*(log(Bprob2) + log(w2)) );

% h = -1.*sum( (Bobs==1).*(log(Bprob1) + 100000.*log(w1)) ...
%            + (Bobs==2).*(log(Bprob2) + 100000.*log(w2)) );

end