function out1 = ua(a1,esq,g1,pi,pr,y)
%UA
%    OUT1 = UA(A1,ESQ,G1,PI,PR,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    27-Apr-2020 15:16:25

out1 = -(a1./2.0-g1-y+esq.*pr+g1.*pi-(a1.*pi.^2)./2.0+a1.^2.*pr+g1.^2.*pr-a1.*g1.*pr.*2.0-a1.*pr.*y.*2.0)./(a1.*pr.*2.0+1.0);
