function out1 = wa(S,alpha0,alpha1,p1,theta0,theta1)
%WA
%    OUT1 = WA(S,ALPHA0,ALPHA1,P1,THETA0,THETA1)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    09-May-2020 09:34:16

out1 = alpha0+S.*theta1-(alpha1.*p1)./(S.*theta0);
