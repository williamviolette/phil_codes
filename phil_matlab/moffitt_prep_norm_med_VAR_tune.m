function  [Q_true]=moffitt_prep_norm_med_VAR_tune(t,k_1,k_2,k_3,p_1,p_2,p_3,p_4,...
                       gamma,sigma_1,sig_ep,alpha_1,TUNE)

                   
                   
%{
reps = 100;
i = 10000;
sigma_1=18;
sig_ep=5.5;
alpha_1=.5;
Q_obs_range=[2 60];
p_var=0;

t = repelem(reps,i,1);

Q_obs = ((1:i)./(i))'.*(Q_obs_range(2)) + Q_obs_range(1);
Q_obs = repelem(Q_obs,reps,1);

p_1 = 5   + rand(sum(t),1).*p_var;
p_2 = p_1 + 5 + rand(sum(t),1).*p_var;
p_3 = p_2 + 5 + rand(sum(t),1).*p_var;
p_4 = p_3 + 5 + rand(sum(t),1).*p_var;

k_1=ones(sum(t),1).*10;
k_2=ones(sum(t),1).*20;
k_3=ones(sum(t),1).*40; 
    gamma1=(accumarray(repelem((1:length(t))',t,1), Q_obs+alpha_1.*mean(p_2) )./t)'; %% fill in gamma!
    gamma=repelem(gamma1',t,1);     
%}
                   
nu = normrnd(0,sigma_1,sum(t),1);
ep = normrnd(0,sig_ep,sum(t),1);

%%% NO VAR TERM!!! which means the + nu is on the outside!

kd1 = kd_norm_tune(gamma+ nu ,alpha_1,sig_ep,p_1,p_2,k_1,TUNE) ;
kd2 = kd_norm_tune(gamma+ nu ,alpha_1,sig_ep,p_2,p_3,k_2,TUNE) ;
kd3 = kd_norm_tune(gamma+ nu ,alpha_1,sig_ep,p_3,p_4,k_3,TUNE) ;

q2med=kd_norm_med_tune(gamma+nu,alpha_1,sig_ep,p_1,p_2,p_3,k_1,k_2,TUNE);

q_1 = gamma - alpha_1.*p_1 ;
q_2 = gamma - alpha_1.*p_2 ;
q_3 = gamma - alpha_1.*p_3 ;
q_4 = gamma - alpha_1.*p_4 ;

q1=q_1+nu;
q2=q_2+nu;
q3=q_3+nu;
q4=q_4+nu;

kL_1 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_1  - 2.*sig_ep).*sqrt(2) ;
kH_1 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_1  + 2.*sig_ep).*sqrt(2) ;

kL_2 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_2  - 2.*sig_ep).*sqrt(2) ;
kH_2 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_2  + 2.*sig_ep).*sqrt(2) ;

kL_3 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_3  - 2.*sig_ep).*sqrt(2) ;
kH_3 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_3  + 2.*sig_ep).*sqrt(2) ;



Q_true = q1.*(q1<=kL_1) + ...
         kd1.*(q1>kL_1 & q2<=kL_2) + ...
         q2med.*(q2>kL_2 & q2<=kH_1) + ...
         kd2.*(q2>kH_1 & q3<=kH_2) + ...
         q3.*(q3>kH_2 & q3<=kL_3) + ...
         kd3.*(q3>kL_3 & q4<=kH_3) + ...
         q4.*(q4>kH_3);

     
Q_true = Q_true + ep;


%{
kL_1 = (1/2).*(sqrt(2).*k_1 -sqrt(2).*q_1 - sqrt(pi).*sig_ep).*sqrt(2);
kH_1 = (1/2).*(sqrt(2).*k_1 -sqrt(2).*q_2 + sqrt(pi).*sig_ep).*sqrt(2);

kL_2 = (1/2).*(sqrt(2).*k_2 -sqrt(2).*q_2 - sqrt(pi).*sig_ep).*sqrt(2);
kH_2 = (1/2).*(sqrt(2).*k_2 -sqrt(2).*q_3 + sqrt(pi).*sig_ep).*sqrt(2);

kL_3 = (1/2).*(sqrt(2).*k_3 -sqrt(2).*q_3 - sqrt(pi).*sig_ep).*sqrt(2);
kH_3 = (1/2).*(sqrt(2).*k_3 -sqrt(2).*q_4 + sqrt(pi).*sig_ep).*sqrt(2);


Q_true1 = q1.*(nu<=kL_1) + ...
         kd1.*(nu>kL_1 & nu<=kH_1) + ...
         q2.*(nu>kH_1 & nu<=kL_2) + ...
         kd2.*(nu>kL_2 & nu<=kH_2) + ...
         q3.*(nu>kH_2 & nu<=kL_3) + ...
         kd3.*(nu>kL_3 & nu<=kH_3) + ...
         q4.*(nu>kH_3);
%}
     