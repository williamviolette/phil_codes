function jj = gh1_g(alpha0,alpha1,pi,pr,theta1)
%GH1_G
%    JJ = GH1_G(ALPHA0,ALPHA1,PI,PR,THETA1)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    29-Jun-2020 09:22:46

t2 = alpha1.*pr.*2.0;
t3 = t2+1.0;
t4 = 1.0./t3;
jj = [t4,-pi.*t4-pr.*t4.^2.*(alpha0+theta1-alpha1.*pi).*2.0];
