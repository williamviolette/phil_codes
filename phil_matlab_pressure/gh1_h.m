function hh = gh1_h(alpha0,alpha1,es,pi,pr,theta1)
%GH1_H
%    HH = GH1_H(ALPHA0,ALPHA1,ES,PI,PR,THETA1)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    29-Jun-2020 09:22:46

t2 = alpha1.*pr.*2.0;
t3 = t2+1.0;
t4 = 1.0./t3.^2;
t5 = pr.*t4.*2.0;
t6 = -t5;
hh = [es,t6,t6,pr.^2.*1.0./t3.^3.*(alpha0+theta1-alpha1.*pi).*8.0+pi.*pr.*t4.*4.0];
