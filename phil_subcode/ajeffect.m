syms k r alpha s  lambda

assume(alpha>0)
assume(alpha<1)

% R(k) - rk
% s = R(k)/k

opt = k^.5 - r*k
con = k^.5 - s*k

ll = opt+lambda*con

dk=diff(ll,k)
dl=diff(ll,lambda)

[s1,s2]=solve([dk,dl],[k,lambda])

s1
s2






