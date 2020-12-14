
clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab';

syms y p a g1 g2 w x F
assume(y>0)
assume(p>0)
assume(a>0)
assume(g1>0)
assume(g2>0)
assume(w>0)
assume(x>0)
assume(Q>0)

BC = ( y -   (p*w+x) ) 

% u = x + w - (1/(2*a))*( w + a - g1 )^2

u = (1/a)*(Q*w - (1/2)*(w-g1)^2) + x

lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls]  =  solve([dw,dx,dl],[w,x,l])

%%% ASSUME NO EPSILON FOR NOW!

% UTILITY SHARE
u_alone1 = collect(simplify(subs(u,[w,x],[ws,xs])),g1)
u_share1 = subs(u_alone1,p1,p1s)

u_alone2 = subs(u_alone1,g1,g2)
u_share2 = subs(u_share1,g1,g2)

simplify(u_share1 + u_share2 - u_alone1 - u_alone2 - F)




