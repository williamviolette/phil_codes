


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

p = p_i+p_r*w;
% p = pi ;

BC = ( y -   (p*w+x) ) 

u = x + (1/alpha1).*(theta1*w - .5*( w - alpha0 )^2)

% u = x + alpha1*sqrt(w)
lan  =  u  + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)

[wa,xa,la]  =  solve([dw,dx,dl],[w,x,l]);
expand(wa)

wa1 = subs(wa,[alpha0,theta1],[alpha0_1*A_1+alpha0_2*A_2+AC,theta0_1*T_1+theta0_2*T_2+TC]);

wab1 = subs(wa,[alpha0,theta1],[alpha0_1*A_1+alpha0_2*A_2+AC,theta0_1*T_1b+theta0_2*T_2b+TCb]);

ua = simplify(subs(u,[w,x],[wa,xa]));
ua1= simplify(subs(u,[w,x],[wa1,xa]));
expand(ua)

uabb1= simplify(subs(u,[w,x],[wab1,xa]));
uab1=subs(uabb1,[y],[yb]);

simplify(uab1-ua1)


x = [alpha0_1; alpha0_2; theta0_1; theta0_2; alpha1; sig ];





obju = -(...
          bobs*log( (1/2)*(1+ erf((wobs-simplify(uab1-ua1))/(siga*sqrt(2))) ) )  ...
    + (1-bobs)*log( 1 -  (1/2)*(1+ erf((wobs-simplify(uab1-ua1))/(siga*sqrt(2))) ) ) ...
        );

% jju=np*subs(jacobian(obju,x),0,es)
% hhu=np*reshape(subs(hessian(obju,x),0,es),1,size(x,1)^2)
% matlabFunction(obju,simplify(jju),simplify(hhu),'File','ghu3.m',...
%                     'Outputs',{'val','g','h'})
                
                
                
obj = simplify(-log((1/(sig*nc))*exp(-.5*(((wobs-wa1)/sig)^2))));

jj=np*subs(jacobian(obj,x),0,es)
hh=np*reshape(subs(hessian(obj,x),0,es),1,size(x,1)^2)
matlabFunction(obj,simplify(jj),simplify(hh),'File','gh4.m',...
                    'Outputs',{'val','g','h'})

                
matlabFunction(simplify(wa,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','wpnl.m')
matlabFunction(simplify(ua,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','upnl.m')




% jj=subs(jacobian((wobs-wa)/sig,x),0,es)
% hh=reshape(subs(hessian((wobs-wa)/sig,x),0,es),1,4)
% 
% % matlabFunction(jj,'File','gh1_g.m');
% % matlabFunction(hh,'File','gh1_h.m');
% 
% matlabFunction(simplify(jj),simplify(hh),'File','gh1.m',...
%                     'Outputs',{'name1','name2'})


% u_pre  = eval(subs(ua,[alpha0,alpha1,theta1,S,pi,y],[30,.5,1,0,20,1000]))
% u_post = eval(subs(ua,[alpha0,alpha1,theta1,S,pi,y],[30,.5,1,3,20,1000]))

% wp = subs(wa,[alpha0,alpha1,theta1,S,pi,y],[30,.5,1,0,20,1000]) - 3;
% xp = 1000 - 20*wp;
% 
% u_alt = subs(u,[x,w,alpha0,alpha1,theta1,S],[xp,wp,30,.5,1,0])


% 
% 
% wa
% 
% expand(wa)
% 
% % alpha0h = alpha0/(2*alpha1*pr+1)
% % alpha1h = alpha1/(2*alpha1*pr+1)
% % thetah  = theta1/(2*alpha1*pr+1)
% 
% % [a0s,a1s,ts]=solve([alpha0h-a0h,alpha1h-a1h,thetah-th],[alpha0,alpha1,theta1])
% 
% was = subs(wa,[alpha0],[alpha0_1*A_1 + ...
%                   alpha0_2*A_2 + ...
%                   alpha0_3*A_3 + ...
%                   alpha0_4*A_4 + ...
%                   alpha0_5*A_5 + ...
%                   alpha0_6*A_6 + ...
%                   alpha0_7*A_7]);
% wan = subs(was,theta1, theta1_2*T_2 );
% wab = subs(was,theta1,theta1_1*T_1 + theta1_2*T_2 + theta1_3*T_3);
%              
%               
% uas = subs(ua,[alpha0],[alpha0_1*A_1 + ...
%                   alpha0_2*A_2 + ...
%                   alpha0_3*A_3 + ...
%                   alpha0_4*A_4 + ...
%                   alpha0_5*A_5 + ...
%                   alpha0_6*A_6 + ...
%                   alpha0_7*A_7]);
%               
% uan = subs(uas,[theta1],[  theta1_2*T_2 ]);
% uab = subs(uas,[theta1,y],[theta1_1*T_1 + theta1_2*T_2 + theta1_3*T_3,y-c]);
% 
% uanp = exp(uan/SC);
% uabp = exp(uab/SC);
% np = uanp/(uanp+uabp);
% bp = uabp/(uanp+uabp);
% 
% wnp = normpdf((wobs-wan)/sig)/sig;
% wbp = normpdf((wobs-wab)/sig)/sig;
% 
% 
% x = [alpha0_1; alpha0_2; alpha0_3; alpha0_4; alpha0_5; alpha0_6; alpha0_7;...
%        sig; alpha1; theta1_1; theta1_2; theta1_3 ];
%   
% gu=jacobian(uab-uan,x);
% hu=jacobian(gu,x);
% 
% gus = subs(gu,0,g1);
% hus = subs(hu,0,g1);
% 
% matlabFunction(simplify(gus,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','gus.m','Optimize',false)
% matlabFunction(simplify(hus,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','hus.m','Optimize',false)



% diff(normcdf(es))
% simplify(diff(normpdf(es)))
   
% matlabFunction(gp,'File','gp.m','Optimize',false)
% matlabFunction(hp,'File','hp.m','Optimize',false)






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
