%%% 


clear;
rng(1);

nn = 2000;
T  = 80;
N  = T*nn;
t  = ones(nn,1).*T;
sig_ep    = 5    ;
sig_nu    = 10   ;
alpha     = .5;


beta_start= linspace(10,60,nn)';

nu_errors = normrnd(0,sig_nu,N,1);
beta_1  = repelem( beta_start ,t,1) + nu_errors;
ep_errors = normrnd(0,sig_ep,N,1);

alpha_1 = alpha.*ones(N,1);
%pH_1    = 20.*ones(N,1);
%pL_1    = 10.*ones(N,1);

pH_max = 45;
pH_min = 20;

pL_max = 20;
pL_min = 0;

pH_1    = rand(N,1).*(pH_max-pH_min) + pH_min;
pL_1    = rand(N,1).*(pL_max-pL_min) + pL_min;

k_1     = 20.*ones(N,1);
sigma_1 = sig_ep.*ones(N,1);
L      =  1000;

w_eqm_true=zeros(N,1);
for n=1:N
    w_eqm_true(n,1) = approx_true(beta_1(n),alpha_1(n),pL_1(n),pH_1(n),k_1(n),sigma_1(n),L);
end
w_eqm_false = approx_false(beta_1,alpha_1,pL_1,pH_1,k_1,sigma_1);

plot(beta_1,w_eqm_true,beta_1,w_eqm_false)

controls = [1 1 1];
TUNE = 1;
D  = ones(N,1);
SE = ones(N,1);
CA = ones(N,1);

a = [sig_ep sig_nu alpha beta_start'];

Q_obs = w_eqm_false + ep_errors;
p_1 = pL_1;
p_2 = pH_1;


 [ll]= est_nmid_general_tune_approx (a,t,Q_obs,k_1,p_1,p_2,D,SE,CA,controls,TUNE)

 
%%%% THIS IS THE APPROXIMATOR
    obj=@(a)est_nmid_general_tune_approx (a,t,Q_obs,k_1,p_1,p_2,D,SE,CA,controls,TUNE);

    options=optimoptions('fminunc','Algorithm','trust-region','GradObj','on','Hessian','on','MaxIter',10000,'TolX',1e-10, 'TolFun', 1e-10 );

x1 = fminunc(obj,a,options);
x1(1:5)
a(1:5)


%%%% THIS IS THE TRUE ESTIMATES
Q_obs = w_eqm_true + ep_errors;
    obj1=@(a)est_nmid_general_tune_approx (a,t,Q_obs,k_1,p_1,p_2,D,SE,CA,controls,TUNE);

    options=optimoptions('fminunc','Algorithm','trust-region','GradObj','on','Hessian','on','MaxIter',10000,'TolX',1e-10, 'TolFun', 1e-10 );

x2 = fminunc(obj1,a,options);
x2(1:5)
a(1:5)

mac = 0;
if mac==1
    slash = '/';
else
    slash = '\';
end

        
YY = 20000;

UU_approx = U_approx(w_eqm_false + ep_errors,k_1,p_1,p_2,beta_1,alpha_1,YY);
  %  mean(UU_approx)

UU_true = U_approx(w_eqm_true + ep_errors,k_1,p_1,p_2,beta_1,alpha_1,YY);
  %  mean(UU_true)


fileID = fopen(strcat('tables',slash,'approx_welfare.tex'),'w');
fprintf(fileID,'%s\n',num2str(mean(UU_approx-UU_true),'%5.3f'));
fclose(fileID);


fileID = fopen(strcat('tables',slash,'approx_simulation.tex'),'w');

fprintf(fileID,'%s\n','\begin{tabular}{|lcccc|}');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','Parameters & Value & Est: Approx.  &  Est: Exact  & Difference   \\');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n',strcat('$\sigma_{\epsilon}$  &  ',num2str(sig_ep,'%5.0f'), ...
                      ' & ', num2str(x2(1),'%5.2f'), ...
                      ' & ', num2str(x1(1),'%5.2f'), ...
                      ' & ', num2str(100.*(x2(1)-x1(1))./x2(1),'%5.2f'), '\% \\'));
fprintf(fileID,'%s\n',strcat('$\sigma_{\eta}$  &  ',num2str(sig_nu,'%5.0f'), ...
                      ' & ', num2str(x2(2),'%5.2f'), ...
                      ' & ', num2str(x1(2),'%5.2f'), ...
                      ' & ', num2str(100.*(x2(2)-x1(2))./x2(2),'%5.2f'), '\%   \\'));
fprintf(fileID,'%s\n',strcat('$\alpha$  &  ',num2str(alpha,'%5.0f'), ...
                      ' & ', num2str(x2(3),'%5.2f'), ...
                      ' & ', num2str(x1(3),'%5.2f'), ...
                      ' & ', num2str(100.*(x2(3)-x1(3))./x2(3),'%5.2f'), '\%   \\'));
fprintf(fileID,'%s\n',strcat('$\gamma$  &  ','[10,60]', ...
                      ' & ', num2str(mean(x2(4:end)),'%5.2f'), ...
                      ' mean & ', num2str(mean(x1(4:end)),'%5.2f'), ...
                      ' mean & ', num2str(100.*mean((x2(4:end)-x1(4:end))./x2(4:end)),'%5.2f'), '\%  \\'));
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','Simulated Data &   &   &    &     \\');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n',strcat('$P_L$ &  ','[0,20]', ...
                      ' & ',  ...
                      ' & ', ...
                      ' & ',  '  \\'));
fprintf(fileID,'%s\n',strcat('$P_H$ &  ','[20,45]', ...
                      ' & ',  ...
                      ' & ', ...
                      ' & ',  '  \\'));
fprintf(fileID,'%s\n',strcat('Kink Point &  ','20', ...
                      ' & ',  ...
                      ' & ', ...
                      ' & ',  '    \\'));
fprintf(fileID,'%s\n',strcat('Households &  ',num2str(nn,'%5.0f'), ...
                      ' & ',  ...
                      ' & ', ...
                      ' & ',  '   \\'));
fprintf(fileID,'%s\n',strcat('Months &  ',num2str(T,'%5.0f'), ...
                      ' & ',  ...
                      ' & ', ...
                      ' & ',  '  \\'));
fprintf(fileID,'%s\n','\hline');                  
fprintf(fileID,'%s\n','\end{tabular}');
fclose(fileID);




%{
w      =  linspace(0,50,L)';
beta   =  beta_1.*ones(L,1);
alpha  =  alpha_1.*ones(L,1);
k      =  k_1.*ones(L,1);
sigma  =  sigma_1.*ones(L,1);

pH     = pH_1.*ones(L,1);
pL     = pL_1.*ones(L,1);

f_1 = w - beta;
f_2 = alpha.*(pH-pL).*normcdf(  (1/sqrt(2)).*((k-w)./sigma)  );

 [x0,y0,iout,jout] = intersections(w,f_1,w,f_2);
 %}
 
%[x0,y0,iout,jout] 
%plot(w,f_1,w,f_2)
