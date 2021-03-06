function out1 = wnl(S,alpha0,alpha1,pi,pr,theta1)
%WNL
%    OUT1 = WNL(S,ALPHA0,ALPHA1,PI,PR,THETA1)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    05-Jun-2020 10:34:49

out1 = (alpha0+S.*theta1-alpha1.*pi)./(alpha1.*pr.*2.0+1.0);
