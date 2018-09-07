function    [HA,TU,TOTAL_CONNECTED,NET_REV,CAPITAL,Total_Share,betas,incomes,Choices,Total_Utility_Alt] ...
                    =  smm_shell_counterfactual_v3(  a, GIVEN_P, alternative_parameters,...
                                    input1,input2,input3,...
                                    errors1,errors2,errors3,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_error)
% INPUT :   BETA_FULL ALPHA_FULL SIG_EP_FULL SIG_NU_FULL K_FULL(3) P_FULL(4) PH_FULL  Y   F    PA  FA   
%              1           2       3           4         5 6 7    8 9 10 11     12    13  14   15 16

%{
    a=400;
    GIVEN_P      = [ 1000 -100 ];
%}

F_PAY      = GIVEN_P(1);
     %  p_1         p_2     p_3  p_4
if length(GIVEN_P)==3  %%%% OPERATES THROUGH GIVEN_P BECAUSE ITS EASY!
       input1(:,8:11) =  input1(:,8:11) + a  ;
       input2(:,8:11) =  input2(:,8:11) + a  ; 
       input3(:,8:11) =  input3(:,8:11) + a  ;    
else
    if length(GIVEN_P)==2
        %p = [ GIVEN_P(2) GIVEN_P(2) a(1) a(1)]; %%% TRY SWAPPING THIS !
        p = [ a(1) a(1) GIVEN_P(2) GIVEN_P(2) ];
    elseif length(a)==1
        p = [ a(1) a(1) a(1) a(1)];
    end
    if length(COST_PARAMETERS)>3 && isempty(a)~=1  %%% key condition here !!!
       input1(:,8:11) =  repelem(p,length(input1),1)  ;
       input2(:,8:11) =  repelem(p,length(input1),1)  ;
       input3(:,8:11) =  repelem(p,length(input1),1)  ;    
    end
end


% COST_PARAMETERS:  MARGINAL_COST  CONNECTION_COST  F_ADDITIONAL  CAPITAL   
MARGINAL_COST   = COST_PARAMETERS(1);
CONNECTION_COST = COST_PARAMETERS(2);
F_ADDITIONAL    = COST_PARAMETERS(3);
if length(COST_PARAMETERS)>3
    CAPITAL     = COST_PARAMETERS(4);
end


if isempty(PH_COUNTER)~=1
    input1(:,12) = PH_COUNTER(1).*ones(length(input1),1);
    input2(:,12) = PH_COUNTER(1).*ones(length(input1),1);
    input3(:,12) = PH_COUNTER(1).*ones(length(input1),1);
end

if smm_est_option(1)==1
    %    F_mean      = a(1,1);
    FA_mean     = alternative_parameters(1,1);
    PA_mean     = alternative_parameters(1,2);
elseif smm_est_option(1)==2
    %    F_mean      = a(1,1);
    FA_mean     = 0;
    PA_mean     = alternative_parameters(1,1);   
elseif smm_est_option(1)==3
    %    F_mean      = a(1,1);
    FA_mean     = 0;
    PA_mean     = alternative_parameters(1,1);  
    a_sigma     = alternative_parameters(1,2);
elseif smm_est_option(1)==4
    %    F_mean      = a(1,1);
    FA_mean     = alternative_parameters(1,1);
    PA_mean     = alternative_parameters(1,2);  
    a_sigma     = alternative_parameters(1,3);
else
    %    F_mean      = a(1,1);
    FA_mean     = alternative_parameters(1,1);
    PA_mean     = given;
end

F      = (F_PAY + F_ADDITIONAL).*ones(size(input1,1),1);  %%% HERE THE ADDITIONAL COST IS ADDED IN !!!
FA     = FA_mean.*ones(size(input1,1),1);
FA1 = FA;
FA2 = FA;
FA3 = FA;
if smm_est_option(1)==3 || smm_est_option(1)==4
    PA1 = PA_mean + alt_error(:,1).*a_sigma;
    PA2 = PA_mean + alt_error(:,2).*a_sigma;
    PA3 = PA_mean + alt_error(:,3).*a_sigma;
else
    PA1 = PA_mean.*ones(size(input1,1),1);
    PA2 = PA_mean.*ones(size(input1,1),1);
    PA3 = PA_mean.*ones(size(input1,1),1);
end
%%% SET PRICES

if length(GIVEN_P)>10  %%% THIS IS FOR THE COUNTERFACTUAL!
    input1 = [input1 (GIVEN_P+F_ADDITIONAL) PA1 FA1];
    input2 = [input2 (GIVEN_P+F_ADDITIONAL) PA2 FA2];
    input3 = [input3 (GIVEN_P+F_ADDITIONAL) PA3 FA3];
else
    input1 = [input1 F PA1 FA1];
    input2 = [input2 F PA2 FA2];
    input3 = [input3 F PA3 FA3];
end


[Choices,input1f,input2f,input3f,Total_Utility,Total_Revenue,Total_Connections,Total_Consumption,Total_Share,Total_Utility_Alt] ...   
      = smm_time_v3_shell_counterfactual(...
                input1,input2,input3,...
                errors1,errors2,errors3,...
                SIG_EP_INPUTS,reps,sto,...
                sort_condition,split_F_option,transfer_option,TUNE);

betas = [input1f(:,1) input2f(:,1) input3f(:,1)]; %%% TAKE BETA'S FOR WEIGHTING MATRIX
incomes = [input1f(:,13) input2f(:,13) input3f(:,13)];  %%% TAKE INCOMES FOR ALTERNATIVE WEIGHTING


%CT = (Choices==3);
%groups=20;
%gamma=betas;
%mean(CT(gamma<=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),groups(1))))
%corr(betas,Choices==3)


TOTAL_REVENUE = Total_Revenue + Total_Connections.*F_PAY;

if length(COST_PARAMETERS)>3
    TOTAL_COSTS   = CAPITAL + Total_Consumption.*MARGINAL_COST + Total_Connections.*CONNECTION_COST;
    HA =   ( (TOTAL_COSTS - TOTAL_REVENUE).^2 )  +  10000.*(TOTAL_COSTS>TOTAL_REVENUE);
    NET_REV = TOTAL_REVENUE - TOTAL_COSTS ;
else        %% HERE IS WHERE WE SOLVE FOR CAPITAL
    CAPITAL = TOTAL_REVENUE - (Total_Consumption.*MARGINAL_COST + Total_Connections.*CONNECTION_COST);
    HA = -1;
    NET_REV=0;
end

TOTAL_CONNECTED = Total_Connections;

%%% for now!
TU              = Total_Utility;


end
    


            
