function   [W_realized,X_realized,U_realized,Total_Pay] ...
                =utility_calc_single_price_input(sto,pref,p,inc,errors)


            
       %     nu,beta,alpha_1,Y,p_1,F,ep
beta     = pref(:,1);
alpha_1  = pref(:,2);
p_1      = p(:,1);
Y        = inc(:,1);
F        = inc(:,2);

nu = errors(:,1);
ep = errors(:,2);


if sto>0
    true_length=length(beta);
    beta = repelem(beta,sto,1);
    alpha_1=repelem(alpha_1,sto,1);
    Y    = repelem(Y,sto,1);
    p_1  = repelem(p_1,sto,1);
    F    = repelem(F,sto,1);
end

gamma_censor = 1;

gamma = ( beta + nu ).*(beta + nu >  gamma_censor) + ...
         gamma_censor.*(beta + nu <= gamma_censor);

W_choice = gamma - alpha_1.*p_1;

W_realized     =    (W_choice+ep).*(W_choice+ep>0);  %% Here we censor for positive consumption  KEY !
X_realized     =    Y - p_1.*W_realized;
U_realized     =    X_realized + W_realized - (F) - (1./(2.*alpha_1)).*( (W_realized - gamma + alpha_1).^2 );  %% recompute utility
Total_Pay      =   W_realized.*p_1;

if sto>0
    W_realized = accumarray(repelem((1:true_length)',sto,1),W_realized)./sto;
    X_realized = accumarray(repelem((1:true_length)',sto,1),X_realized)./sto;
    U_realized = accumarray(repelem((1:true_length)',sto,1),U_realized)./sto;
    Total_Pay  = accumarray(repelem((1:true_length)',sto,1),Total_Pay )./sto;
end

end