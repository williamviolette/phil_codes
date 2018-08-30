function   [W_realized,X_realized,U_realized,Total_Pay,P_realized] ...
                =utility_calc_input_tune(STO,pref,k,p,inc,errors,TUNE)

%{
i=1;
Y = 10000;
    sto = 1;
    ep  = 0;
    nu  = 0.*ones(i,1);
    beta = 0 + 50.*(1:i)'./i;
    alpha_1 =ones(i,1).* .8;

    p_1 =10.*ones(i,1);
    p_2 =30.*ones(i,1);
    p_3 =35.*ones(i,1);
    p_4 =40.*ones(i,1);
    k_1 =10.*ones(i,1);
    k_2 =20.*ones(i,1);
    k_3 =40.*ones(i,1);
    sig_ep = 5.*ones(i,1);

true_length=length(beta);

gamma=repelem(gamma,sto,1);
alpha_1=repelem(alpha_1,sto,1);

p_1  =repelem(p_1,sto,1).*ones(i,1);
p_2  =repelem(p_2,sto,1).*ones(i,1);
p_3  =repelem(p_3,sto,1).*ones(i,1);
p_4  =repelem(p_4,sto,1).*ones(i,1);

F = 400;
                
p_1  =repelem(p_1,sto,1).*ones(i,1);
p_2  =repelem(p_2,sto,1).*ones(i,1);
p_3  =repelem(p_3,sto,1).*ones(i,1);
p_4  =repelem(p_4,sto,1).*ones(i,1);

F = 400;
 
STO = 1;
%}

                
%                beta,alpha_1,sig_ep,k_1,k_2,k_3,p_1,p_2,p_3,p_4,Y,F
%                ep,nu

%{
pref = input1(:,1:3);
k    = input1(:,5:7);
p    = input1(:,8:11);
inc  = input1(:,13:14);
errors = errors1;
STO=5;
%}

beta     = pref(:,1);
alpha_1  = pref(:,2);
sig_ep   = pref(:,3);               
k_1      = k(:,1);
k_2      = k(:,2);
k_3      = k(:,3);
p_1      = p(:,1);
p_2      = p(:,2);
p_3      = p(:,3);
p_4      = p(:,4);
Y        = inc(:,1);
F        = inc(:,2);

ep = errors(:,1);
nu = errors(:,2);


    sto=STO(1);
    
if STO(1)>0
    true_length = length(p_2);
    sig_ep  = repelem(sig_ep,sto,1);
    beta    = repelem(beta,sto,1);
    alpha_1 = repelem(alpha_1,sto,1);
    Y       = repelem(Y,sto,1);
    k_1 = repelem(k_1,sto,1);
    k_2 = repelem(k_2,sto,1);
    k_3 = repelem(k_3,sto,1);
    p_1 = repelem(p_1,sto,1);
    p_2 = repelem(p_2,sto,1);
    p_3 = repelem(p_3,sto,1);
    p_4 = repelem(p_4,sto,1);
    F   = repelem(F,sto,1);  % note that ep and nu are NOT repeated here
end

gamma_censor = 1; %%% !~SENSOR THE GAMMA REALIZATIONS~!
gamma = ( beta + nu ).*(beta + nu >  gamma_censor) + ...
         gamma_censor.*(beta + nu <= gamma_censor);

kd1 = kd_norm_tune(gamma ,alpha_1,sig_ep,p_1,p_2,k_1,TUNE) ;
kd2 = kd_norm_tune(gamma ,alpha_1,sig_ep,p_2,p_3,k_2,TUNE) ;
kd3 = kd_norm_tune(gamma ,alpha_1,sig_ep,p_3,p_4,k_3,TUNE) ;

q2med=kd_norm_med_tune(gamma,alpha_1,sig_ep,p_1,p_2,p_3,k_1,k_2,TUNE);

q1 = gamma - alpha_1.*p_1  ;
q2 = gamma - alpha_1.*p_2  ;
q3 = gamma - alpha_1.*p_3  ;
q4 = gamma - alpha_1.*p_4  ;

kL_1 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_1  - 2.*sig_ep).*sqrt(2) ;
kH_1 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_1  + 2.*sig_ep).*sqrt(2) ;

kL_2 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_2  - 2.*sig_ep).*sqrt(2) ;
kH_2 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_2  + 2.*sig_ep).*sqrt(2) ;

kL_3 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_3  - 2.*sig_ep).*sqrt(2) ;
kH_3 =  (1/(2.*TUNE)).*(TUNE.*sqrt(2).*k_3  + 2.*sig_ep).*sqrt(2) ;


total_vars=13;
L = length(q1);

WW         =   [q1.*(q1>0 & q1<=kL_1);  ...        % interior (add zero)
                kd1.*(q1>kL_1 & q2<=kL_2);  ...
                q2med.*(q2>kL_2 & q2<=kH_1);  ...
                kd2.*(q2>kH_1 & q3<=kH_2);  ...
                q3.*(q3>kH_2 & q3<=kL_3);  ...
                kd3.*(q3>kL_3 & q4<=kH_3);  ...
                q4.*(q4>kH_3); ...
                      kL_1.*ones(length(q1),1); ... % kinks
                      kH_1.*ones(length(q1),1); ...
                      kL_2.*ones(length(q1),1); ...
                      kH_2.*ones(length(q1),1); ...
                      kL_3.*ones(length(q1),1); ...
                      kH_3.*ones(length(q1),1) ];

P_1 = repmat(p_1,total_vars,1);
P_2 = repmat(p_2,total_vars,1);
P_3 = repmat(p_3,total_vars,1);
P_4 = repmat(p_4,total_vars,1);

K_1 = repmat(k_1,total_vars,1);
K_2 = repmat(k_2,total_vars,1);
K_3 = repmat(k_3,total_vars,1);
FF  = repmat(F,total_vars,1);

YY  = repmat(Y,total_vars,1);

XX     = (YY - P_1.*WW).*(WW<=K_1) + ...
         (YY - P_2.*WW + (P_2-P_1).*K_1).*(WW>K_1 & WW<=K_2) + ...
         (YY - P_3.*WW + (P_3-P_1).*K_1 + (P_3-P_2).*(K_2-K_1)).*(WW>K_2 & WW<=K_3) +  ...
         (YY - P_4.*WW + (P_4-P_1).*K_1 + (P_4-P_2).*(K_2-K_1) + (P_4-P_3).*(K_3-K_2)).*(WW>K_3);

GAMMA   = repmat( gamma ,total_vars,1); 
ALPHA_1 = repmat(alpha_1,total_vars,1);
     
UU     = XX + WW - (FF) - (1./(2.*ALPHA_1)).*( (WW - GAMMA + ALPHA_1).^2 );
                  
U_choice_set = reshape(UU,L,total_vars);
W_choice_set = reshape(WW,L,total_vars);

[~,U_choice_id]=max(U_choice_set,[],2);
W_choice = W_choice_set(sub2ind(size(U_choice_set),(1:length(U_choice_id))',U_choice_id));

W_realized     =    (W_choice+ep).*(W_choice+ep>0);  %% Here we censor for positive consumption  KEY !

X_realized     =    (Y - p_1.*W_realized).*(W_realized<=k_1) + ...
                    (Y - p_2.*W_realized + (p_2-p_1).*k_1).*(W_realized>k_1 & W_realized<=k_2) + ...
                    (Y - p_3.*W_realized + (p_3-p_1).*k_1 + (p_3-p_2).*(k_2-k_1)).*(W_realized>k_2 & W_realized<=k_3) +  ...
                    (Y - p_4.*W_realized + (p_4-p_1).*k_1 + (p_4-p_2).*(k_2-k_1) + (p_4-p_3).*(k_3-k_2)).*(W_realized>k_3);

U_realized     =    X_realized + W_realized - (F) - (1./(2.*alpha_1)).*( (W_realized - gamma + alpha_1).^2 );  %% recompute utility
            
Total_Pay      =  (W_realized<=k_1                  ).* (W_realized.*p_1)                 + ...
                  (W_realized> k_1 & W_realized<=k_2).*((W_realized-k_1).*p_2 + k_1.*p_1) + ...
                  (W_realized> k_2 & W_realized<=k_3).*((W_realized-k_2).*p_3 + (k_2-k_1).*p_2 + k_1.*p_1) + ...
                  (                  W_realized> k_3).*((W_realized-k_3).*p_4 + ...
                  (k_3-k_2).*p_3 + (k_2-k_1).*p_2 + k_1.*p_1);

             
P_realized     = (                  W_realized<=k_1).*(p_1) + ...
                 (W_realized> k_1 & W_realized<=k_2).*(p_2) + ...
                 (W_realized> k_2 & W_realized<=k_3).*(p_3) + ...
                 (W_realized> k_3                  ).*(p_4) ;
              
if STO(1)>0 && length(STO)==1
    W_realized = accumarray(repelem((1:true_length)',sto,1),W_realized)./sto;
    X_realized = accumarray(repelem((1:true_length)',sto,1),X_realized)./sto;
    U_realized = accumarray(repelem((1:true_length)',sto,1),U_realized)./sto;
    Total_Pay  = accumarray(repelem((1:true_length)',sto,1),Total_Pay )./sto;
    P_realized  = accumarray(repelem((1:true_length)',sto,1),P_realized )./sto;
end
              
              
%XX_choice_set = reshape(WW,L,total_vars);
%XX_choice = XX_choice_set(sub2ind(size(UU_choice_set),(1:length(U_choice_id))',U_choice_id));



end