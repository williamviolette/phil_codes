


clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab_new/';

syms y p p_i p_r a1 a2 a3 g g1 g2 g3 w x F l ws wbar1 wbar2 wbar3 es esq t1 t2 S a0h a1h th
syms alpha0 alpha1 p1
syms alpha0_1 alpha0_2 alpha0_3 alpha0_4 alpha0_5 alpha0_6 alpha0_7
syms A_1 A_2 A_3 A_4 A_5 A_6 A_7 A  AC

syms theta1   theta1b yb
syms theta0_1 theta0_2 theta0_3
syms T_1 T_2 T_3  T TC  T_1b T_2b T_3b  Tb TCb

syms wobs
syms bobs
syms sig siga
syms SC

syms c   nc   np
syms EV  AV AVB  TV TVB DV UV  A1UV A2UV OV KV

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

%  p = p_i+p_r*w;
 p = p_i ;
alpha0 = alpha0_1*A_1+alpha0_2*A_2+AC;
theta1 = theta0_1*T_1+theta0_2*T_2+TC;
 
BC = ( y -   (p*w+x) ) 

u = x + (1/alpha1).*(theta1*w - .5*( w - alpha0 )^2)

% u = x + alpha1*sqrt(w)
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[wa,xa,la]  =  solve([dw,dx,dl],[w,x,l]);

ua = simplify(subs(u,[w,x],[wa,xa]));
uab = subs(ua,[T_1,T_2,TC,y],[T_1b,T_2b,TCb,yb]);

ud = simplify(ua-uab)

% obju = -(          bobs*log( (1/2)*(1+ erf((wobs-ud)/(siga*sqrt(2))) ) )  ...
%     + (1-bobs)*log( 1 -  (1/2)*(1+ erf((wobs-ud)/(siga*sqrt(2))) ) )        );
 
obju1 = -(  bobs*log( (1/2)*(1+ erf((wobs-ud)/(siga*sqrt(2))) ) )  );
obju2 = -(1-bobs)*log( 1 -  (1/2)*(1+ erf((wobs-ud)/(siga*sqrt(2))) ) ) ;
           
obj = simplify(-log((1/(sig*nc))*exp(-.5*(((wobs-wa)/sig)^2))));


Eval = (1/2)*(1+ erf((wobs-ud)/(siga*sqrt(2))) );
Oval = (1/(sig*nc))*exp(-.5*(((wobs-wa)/sig)^2));
Kval = (((wobs-wa)/sig)^2);
Uval = ud;
Aval = (alpha0_1*A_1+alpha0_2*A_2+AC + theta0_1*T_1+theta0_2*T_2+TC  - alpha1*p_i );
Avalb = (alpha0_1*A_1+alpha0_2*A_2+AC + theta0_1*T_1b+theta0_2*T_2b+TCb  - alpha1*p_i );
Tval = theta0_1*T_1+theta0_2*T_2+TC;
Tvalb = theta0_1*T_1b+theta0_2*T_2b+TCb;

sub_set = [Eval,Oval,Kval,Uval,Aval,Avalb,Tval,Tvalb];
sub_var = [EV,OV,KV,UV,AV,AVB,TV,TVB];
sub_name = {'EV','OV','KV','UV','AV','AVB','TV','TVB'};

tic 
matlabFunction(Eval,Oval,Kval,Uval,Aval,Avalb,Tval,Tvalb ...
    ,'File','ghu7_input.m',...
                    'Outputs',sub_name,'Optimize',true) 
toc



x = [alpha0_1; alpha0_2; theta0_1; theta0_2; alpha1; sig; siga ];

j1 = subs(jacobian(obju1 + obju2 + obj,x),sub_set,sub_var);
j1s = simplify(j1);

tic
h1s = simplify(subs( hessian(obju1 + obju2  + obj,  x ),sub_set,sub_var)) ;
toc

tic
jj=np*subs(j1s,0,es)
hh=np*reshape(subs(h1s,0,es),1,size(x,1)^2)
matlabFunction(obju1 + obju2 + obj,jj,hh,'File','ghu7.m',...
                    'Outputs',{'val','g','h'},'Optimize',true) % 77 sec with full + siga  
toc

                
matlabFunction(simplify(wa,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','wpnl.m')
matlabFunction(simplify(ua,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','upnl.m')



