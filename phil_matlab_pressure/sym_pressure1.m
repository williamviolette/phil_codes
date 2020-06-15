


clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab_new/';

syms y p pi pr a1 a2 a3 g g1 g2 g3 w x F l ws wbar1 wbar2 wbar3 es esq t1 t2 S
syms alpha0 alpha1 p1 theta0 theta1
assume(y>0)
assume(p1>0)
assume(pi>0)
assume(pr>0)
assume(a1>0)
assume(g1>0)
assume(w>0)
assume(x>0)
assume(l>0)
assume(t1>0)
assume(t2>0)
assume(S>0)

steps=10;

%%% ALONE %%%

BC = ( y -   (p1*w+x) ) 

u = x + (1/alpha1).*(theta1*S*w - .5*( w - alpha0 )^2)
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[wa,xa,la]  =  solve([dw,dx,dl],[w,x,l]);

expand(wa)

ua = simplify(subs(u,[w,x],[wa,xa]));

simplify(ua)
expand(ua)

diff(ua,S)

 matlabFunction(simplify(wa,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','wp.m')
 matlabFunction(simplify(ua,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','up.m')




% 
% %%% ALONE %%%
% 
% BC = ( y -   (p1*w+x) ) 
% 
% u = x + (w - (1/(2*alpha1))*( w + alpha1 - alpha0  )^2)
% lan  =  u  + l*BC
% 
% dw = simplify(diff(lan,w))
% dx = diff(lan,x)
% dl = diff(lan,l)
% 
% [walt,xalt,lalt]  =  solve([dw,dx,dl],[w,x,l]);
% 
% expand(walt)
% 
% ualt = simplify(subs(u,[w,x],[walt,xalt]));
% 
% expand(ualt)
% 
% 
% BC = ( y -   (p1*w+x) ) 
% 
% u = x + (w - (1/(2*alpha1))*( w + alpha1 - alpha0 - theta0  )^2)
% lan  =  u  + l*BC
% 
% dw = simplify(diff(lan,w))
% dx = diff(lan,x)
% dl = diff(lan,l)
% 
% [walt,xalt,lalt]  =  solve([dw,dx,dl],[w,x,l]);
% 
% expand(walt)
% 
% ualt = simplify(subs(u,[w,x],[walt,xalt]));
% 
% expand(ualt)
