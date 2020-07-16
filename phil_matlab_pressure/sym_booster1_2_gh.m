


clear;
% cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_matlab_new/';

syms y p pi pr a1 a2 a3 g g1 g2 g3 w x F l ws wbar1 wbar2 wbar3 es esq t1 t2 S a0h a1h th
syms alpha0 alpha1 p1
syms alpha0_1 alpha0_2 alpha0_3 alpha0_4 alpha0_5 alpha0_6 alpha0_7
syms A_1 A_2 A_3 A_4 A_5 A_6 A_7

syms theta1
syms theta1_1 theta1_2 theta1_3
syms T_1 T_2 T_3

syms wobs
syms Bobs
syms sig
syms SC

syms c



assume(sig>0)
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

% p = pi+pr*w;
p = pi ;

BC = ( y -   (p*w+x) ) 

u = x + (1/alpha1).*(theta1*w - .5*( w - alpha0 )^2)

% u = x + alpha1*sqrt(w)
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[wa,xa,la]  =  solve([dw,dx,dl],[w,x,l]);

expand(wa)

ua = simplify(subs(u,[w,x],[wa,xa]));

expand(ua)

u_pre  = eval(subs(ua,[alpha0,alpha1,theta1,S,pi,y],[30,.5,1,0,20,1000]))
u_post = eval(subs(ua,[alpha0,alpha1,theta1,S,pi,y],[30,.5,1,3,20,1000]))

wp = subs(wa,[alpha0,alpha1,theta1,S,pi,y],[30,.5,1,0,20,1000]) - 3;
xp = 1000 - 20*wp;

u_alt = subs(u,[x,w,alpha0,alpha1,theta1,S],[xp,wp,30,.5,1,0])

wa

expand(wa)

% alpha0h = alpha0/(2*alpha1*pr+1)
% alpha1h = alpha1/(2*alpha1*pr+1)
% thetah  = theta1/(2*alpha1*pr+1)

% [a0s,a1s,ts]=solve([alpha0h-a0h,alpha1h-a1h,thetah-th],[alpha0,alpha1,theta1])

was = subs(wa,[alpha0],[alpha0_1*A_1]);
wan = subs(was,theta1, theta1_2*T_2 );
wab = subs(was,theta1,theta1_1*T_1 + theta1_2*T_2 + theta1_3*T_3);
             
              
uas = subs(ua,[alpha0],[alpha0_1*A_1]);

uan = subs(uas,[theta1],[  theta1_2*T_2 ]);
uab = subs(uas,[theta1,y],[theta1_1*T_1 + theta1_2*T_2 + theta1_3*T_3,y-c]);

uanp = exp(uan/SC);
uabp = exp(uab/SC);
np = uanp/(uanp+uabp);
bp = uabp/(uanp+uabp);

wnp = normpdf((wobs-wan)/sig)/sig;
wbp = normpdf((wobs-wab)/sig)/sig;


x = [alpha0_1;...
       sig; alpha1; theta1_1; theta1_2; theta1_3 ];

ll = -1.*((1-Bobs)*(log(np) + log(wnp))  + ...
          (Bobs)*(log(bp) + log(wbp))  );

gnp= jacobian(log(np),x)
hnp = jacobian(gnp,x)
   
matlabFunction(gnp,'File','grad_test.m')
matlabFunction(hnp,'File','hess_test.m') %% 800s (200s faster, kind of makes sense...)



%          x1    x2     y     z
%   x1   x1,x1 x1,x2  x1,y  x1,z
%   x2
%   y
%   z

% gradf=jacobian(ll,x)
% hessf=jacobian(gradf,x)



%  matlabFunction(simplify(wa,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','wp1.m')
%  matlabFunction(simplify(ua,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','up1.m')
% 



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
