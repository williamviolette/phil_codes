


clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab_new/';

syms y p p_i p_r a1 a2 a3 g g1 g2 g3 w x F l ws wbar1 wbar2 wbar3 es esq t1 t2 S a0h a1h th
syms alpha0 alpha1 p1
syms alpha0_1 alpha0_2 alpha0_3 alpha0_4 alpha0_5 alpha0_6 alpha0_7
syms A_1 A_2 A_3 A_4 A_5 A_6 A_7 A  AC

syms theta1   theta1b yb theta2 theta3 theta thetab
syms theta0_1 theta0_2 theta0_3
syms T_1 T_2 T_3  T TC  T_1b T_2b T_3b  Tb TCb
syms T_1n T_2n TCn

syms wobs
syms bobs
syms sig siga
syms SC

syms c   nc   np
syms EV  AV AVB  TV TVB DV UV  A1UV A2UV OV KV  AVN TVN

syms JJ1 JJ2 JJ3 JJ4 JJ5 JJ6 JJ7 JJ8 JJ9 JJ10 JJ11

assume(siga>0)
assume(sig>0)
assume(y>0)
assume(p1>0)
assume(p_i>0)
assume(p_r>0)
assume(a1>0)
assume(g1>0)
assume(w>0)
assume(x>0)
assume(l>0)
assume(t1>0)
assume(t2>0)
assume(S>0)

steps=1;

%%% ALONE %%%

 p = p_i ;
 
BC = ( y -   (p*w+x) ) 

u = x + (1/alpha1).*(theta*w - .5*( w - alpha0 )^2)

lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[wa,xa,la]  =  solve([dw,dx,dl],[w,x,l]);

ua = simplify(subs(u,[w,x],[wa,xa]));
uab = subs(ua,[theta,y],[thetab,y - c]);



ud = simplify(uab-ua);

obju1 = -(  bobs*log( (1/2)*(1+ erf(ud/(siga*sqrt(2))) ) )  );
obju2 = -(1-bobs)*log( 1 -  (1/2)*(1+ erf(ud/(siga*sqrt(2))) ) ) ;


x = [siga; c];

j1s = simplify(jacobian(obju1 + obju2  ,  x ));
tic
h1s = simplify(hessian(obju1 + obju2  ,  x )) ;
toc

tic
jj=np*subs(j1s,0,es)
hh=np*reshape(subs(h1s,0,es),1,size(x,1)^2)
matlabFunction(obju1 + obju2,jj,hh,'File','ghu2s.m',...
                    'Outputs',{'val','g','h'},'Optimize',true) % 77 sec with full + siga  
toc
                
matlabFunction(simplify(wa,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','wp2s.m')
matlabFunction(simplify(ua,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','up2s.m')



