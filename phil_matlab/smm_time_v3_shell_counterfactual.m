function [Choices,input1,input2,input3,Total_Utility,Total_Revenue,Total_Connections,Total_Consumption,Total_Share,Total_Utility_Alt] ...
      = smm_time_v3_shell_counterfactual(...
                input1,input2,input3,...
                errors1,errors2,errors3,...
                SIG_EP_INPUTS,reps,sto,...
                sort_condition,split_F_option,transfer_option,TUNE)

% INPUT :   BETA_FULL ALPHA_FULL SIG_EP_FULL SIG_NU_FULL K_FULL(3) P_FULL(4) PH_FULL  Y   F    PA  FA   
%              1           2       3           4         5 6 7    8 9 10 11     12    13  14   15 16

%{

 % input1B=input1;
 % input2B=input2;
 % input3B=input3;


input1A=input1B;
input2A=input2B;
input3A=input3B;

input1 = [input1A F PA1 FA1];
input2 = [input2A F PA3 FA2];
input3 = [input3A F PA2 FA3];

%input1 =[ 10 .8 140 ; 5 .5 140 ; 7 .5 120  ];
%input2 =[ 8 .7 160 ; 5 .5 166 ; 3 .5 120  ];
%input3 =[ 12 .6 170 ; 5 .5 170 ; 4 .5 170  ];

%}

input1 = repelem(  input1   ,reps,1);
input2 = repelem(  input2   ,reps,1);
input3 = repelem(  input3   ,reps,1);




if sort_condition~=99
    if sort_condition==1
            [~,~,U1_I] =utility_calc_input_tune(sto,input1(:,1:3),input1(:,5:7),input1(:,8:11),input1(:,13:14),errors1,TUNE);
            [~,~,U2_I] =utility_calc_input_tune(sto,input2(:,1:3),input2(:,5:7),input2(:,8:11),input2(:,13:14),errors2,TUNE);
            [~,~,U3_I] =utility_calc_input_tune(sto,input3(:,1:3),input3(:,5:7),input3(:,8:11),input3(:,13:14),errors3,TUNE);

            [~,~,U1_A] =utility_calc_single_price_input(sto,input1(:,1:2),input1(:,15),[input1(:,13) input1(:,16)],errors1);
            [~,~,U2_A] =utility_calc_single_price_input(sto,input2(:,1:2),input2(:,15),[input2(:,13) input2(:,16)],errors2);
            [~,~,U3_A] =utility_calc_single_price_input(sto,input3(:,1:2),input3(:,15),[input3(:,13) input3(:,16)],errors3);

            UD_1=U1_I-U1_A;
            UD_2=U2_I-U2_A;
            UD_3=U3_I-U3_A;

            U_M=[UD_1 UD_2 UD_3];

                    [~,S2]=sort(U_M,2,'descend');
    elseif sort_condition==2
           w1a =utility_calc_single_price_input(sto,input1(:,1:2),ptest.*ones(size(input1,1),1),[input1(:,13) input1(:,16)],errors1);
           w2a =utility_calc_single_price_input(sto,input2(:,1:2),ptest.*ones(size(input2,1),1),[input2(:,13) input2(:,16)],errors2);
           w3a =utility_calc_single_price_input(sto,input3(:,1:2),ptest.*ones(size(input3,1),1),[input3(:,13) input3(:,16)],errors3);
            U_M=[w1a w2a w3a];
                    [~,S2]=sort(U_M,2,'descend');
    else
            U_M=[ input1(:,1) input2(:,1) input3(:,1) ];
                    [~,S2]=sort(U_M,2,'descend');
    end


            %%%%%%% INPUTS
                    S2input = repmat(S2,size(input1,2),1); %%% FIRST FOR INPUTS 
                    [m,n]=size(S2input);
                    ind = sub2ind([m n],repmat((1:m)',1,n),S2input);

                    inputr = [ reshape(input1,size(input1,1).*size(input1,2),1) ...
                               reshape(input2,size(input2,1).*size(input2,2),1) ...
                               reshape(input3,size(input3,1).*size(input3,2),1) ];
                    inputr  = inputr(ind);

            input1 = reshape(inputr(:,1),size(input1,1),size(input1,2));
            input2 = reshape(inputr(:,2),size(input1,1),size(input1,2));
            input3 = reshape(inputr(:,3),size(input1,1),size(input1,2));

            %%%%%%% ERRORS
                    S2einput = repmat(repelem(S2,sto,1),size(errors1,2),1); %%% SECOND FOR ERRORS
                    [me,ne]=size(S2einput);
                    inde = sub2ind([me ne],repmat((1:me)',1,ne),S2einput);       

                    errorsr = [ reshape(errors1,size(errors1,1).*size(errors1,2),1) ...
                                reshape(errors2,size(errors2,1).*size(errors2,2),1) ...
                                reshape(errors3,size(errors3,1).*size(errors3,2),1) ];
                    errorsr = errorsr(inde);
            errors1 = reshape(errorsr(:,1),size(errors1,1),size(errors1,2));
            errors2 = reshape(errorsr(:,2),size(errors1,1),size(errors1,2));
            errors3 = reshape(errorsr(:,3),size(errors1,1),size(errors1,2));                        
end

        %%%% NOW : BEGIN COMPUTATIONS !
            beta1 = input1(:,1) ;
            beta2 = input2(:,1) ;
            beta3 = input3(:,1) ;
        alpha1 = input1(:,2) ;
        alpha2 = input2(:,2) ;
        alpha3 = input3(:,2) ;
      %      sig_ep1 = input1(:,3) ;
      %      sig_ep2 = input2(:,3) ;        
      %      sig_ep3 = input3(:,3) ;        
      %  K1  = input1(:,5:7);
      %  K2  = input2(:,5:7);
      %  K3  = input3(:,5:7);
      %      P1  = input1(:,8:11);
      %      P2  = input2(:,8:11);
      %      P3  = input3(:,8:11);
      %          PH1 = input1(:,12);
                PH2 = input2(:,12);
                PH3 = input3(:,12);
        Y1  = input1(:,13);
        Y2  = input2(:,13);
        Y3  = input3(:,13);
            F1  = input1(:,14);
            F2  = input2(:,14);
       %     F3  = input3(:,14);
       %     PA1 = input1(:,15);
       %     PA2 = input2(:,15);
       %     PA3 = input3(:,15);
            nu1 = errors1(:,1);
            nu2 = errors2(:,1);
            nu3 = errors3(:,1);
        ep1 = errors1(:,2);
        ep2 = errors2(:,2);
        ep3 = errors3(:,2);            
       
        [WT1_I,~,U1_I,TP1_I] =utility_calc_input_tune(sto,input1(:,1:3),input1(:,5:7),input1(:,8:11),input1(:,13:14),errors1,TUNE);
        [WT2_I,~,U2_I,TP2_I] =utility_calc_input_tune(sto,input2(:,1:3),input2(:,5:7),input2(:,8:11),input2(:,13:14),errors2,TUNE);
        [WT3_I,~,U3_I,TP3_I] =utility_calc_input_tune(sto,input3(:,1:3),input3(:,5:7),input3(:,8:11),input3(:,13:14),errors3,TUNE);
        
        [~,~,U1_A] =utility_calc_single_price_input(sto,input1(:,1:2),input1(:,15),[input1(:,13) input1(:,16)],errors1);
        [~,~,U2_A] =utility_calc_single_price_input(sto,input2(:,1:2),input2(:,15),[input2(:,13) input2(:,16)],errors2);
        [~,~,U3_A] =utility_calc_single_price_input(sto,input3(:,1:2),input3(:,15),[input3(:,13) input3(:,16)],errors3);
        
  
  if split_F_option==1
        F_B1_21 = .5;
        F_B2_21 = .5;
        F_B1_31 = .5;
        F_B3_31 = .5;
        F_B2_32 = .5;
        F_B3_32 = .5;
        F_B1_321 = 1/3;
        F_B2_321 = 1/3;
        F_B3_321 = 1/3;
  else
        F_B1_21 = 1;
        F_B2_21 = 0;
        F_B1_31 = 1;
        F_B3_31 = 0;
        F_B2_32 = 1;
        F_B3_32 = 0;
        F_B1_321 = 1;
        F_B2_321 = 0;
        F_B3_321 = 0;
  end
  
       %%% 2 to 1 %%%            
           [WT_2_1S,~,~,TP_2_1S,P_2_1S] = utility_calc_input_tune([sto 1], [ ( beta1 + beta2 - alpha2.*PH2 )  ... %% sum beta's but subtract hassle
                                                             (alpha1+alpha2)./2  ... %% ALPHA (take average)
                                                             (SIG_EP_INPUTS(2).*ones(length(beta1),1))], ... %% SIG_EP (input sharing~!)
                                                            input1(:,5:7),input1(:,8:11),input1(:,13:14),... %% other parameters are for the owner!
                                                             [(nu1 + nu2) ... % nu
                                                              (ep1 + ep2)],TUNE);  % epsilon
            % owner usage      (beta  + nu)                    alpha               (divide by 2) price faced
             WO_2_1S = ( repelem(beta1,sto,1)+nu1 ) -     ( repelem(alpha1,sto,1) ).*(P_2_1S./2) + ep1 ;
                WO_2_1S = WO_2_1S.*(WT_2_1S>WO_2_1S & WO_2_1S>0) + WT_2_1S.*(WT_2_1S<=WO_2_1S) ; % deal with cases where this is negative..                    ( IN THE FUTURE, DEAL WITH THIS BETTER )
             WB_2_1S = WT_2_1S - WO_2_1S; % leftover consumption for the buyer
                WB_2_1S = WB_2_1S.*(WB_2_1S>0); % deal with cases where this is negative..
             U1_2_S =  ( repelem(Y1,sto,1) - (TP_2_1S./2)  - repelem(F1,sto,1).*F_B1_21) + WO_2_1S - ...
                        (1./(2.*repelem(alpha1,sto,1))).*( (WO_2_1S - ( repelem(beta1,sto,1)+nu1 ) + repelem(alpha1,sto,1))).^2  ;
             U2_1_S =  ( repelem(Y2,sto,1) - (TP_2_1S./2) - repelem(F1,sto,1).*F_B2_21 - WB_2_1S.*repelem(PH2,sto,1) )                    + WB_2_1S - ...
                        (1./(2.*repelem(alpha2,sto,1))).*( (WB_2_1S - ( repelem(beta2,sto,1)+nu2 ) + repelem(alpha2,sto,1))).^2  ;
                    %{
             Quick little testing sesh:                                                    WO_2_1S_test = ( repelem(beta1,sto,1)+nu1 ) -     ( repelem(alpha1,sto,1) ).*(P_2_1S./2) + ep1 ;
               Main conclusions: 1.) lots of zeros, but they don't matter too much         WB_2_1S_test = ( repelem(beta2,sto,1)+nu2 ) -     ( repelem(alpha2,sto,1) ).*((P_2_1S)./2 + repelem(PH2,sto,1)) + ep2 ;
                                              on average, just caused by erorrs            mean(WT1_I + WT2_I)
                                              pushing consumption low                      mean(WO_2_1S_test)
                                                                                           mean(WO_2_1S_test + WB_2_1S_test)                      
                                                                                           mean(WO_2_1S_test + WB_2_1S_test)
                                                                                           mean(WT_2_1S)
                    %}
                 WT_2_1S = accumarray(repelem((1:length(beta1))',sto,1),WT_2_1S)./sto; %%% need to collapse over all of the draws!               
                 TP_2_1S = accumarray(repelem((1:length(beta1))',sto,1),TP_2_1S)./sto;        
                 U1_2_S  = accumarray(repelem((1:length(beta1))',sto,1),U1_2_S)./sto;       
                 U2_1_S  = accumarray(repelem((1:length(beta1))',sto,1),U2_1_S)./sto;                    
                                   
       %%% 3 to 1 %%%            
           [WT_3_1S,~,~,TP_3_1S,P_3_1S] = utility_calc_input_tune([sto 1], [ ( beta1 + beta3 - alpha3.*PH3 )  ... %% sum beta's but subtract hassle
                                                             (alpha1+alpha3)./2  ... %% ALPHA (take average)
                                                             (SIG_EP_INPUTS(2).*ones(length(beta3),1))], ... %% SIG_EP (input sharing~!)
                                                            input1(:,5:7),input1(:,8:11),input1(:,13:14),... %% other parameters are for the owner!
                                                             [(nu1 + nu3) ... % nu
                                                              (ep1 + ep3)],TUNE);  % epsilon
            % owner usage      (beta  + nu)                    alpha               (divide by 2) price faced
             WO_3_1S = ( repelem(beta1,sto,1)+nu1 ) -     ( repelem(alpha1,sto,1) ).*(P_3_1S./2) + ep1 ;
                WO_3_1S = WO_3_1S.*(WT_3_1S>WO_3_1S & WO_3_1S>0)  + WT_3_1S.*(WT_3_1S<=WO_3_1S) ; % deal with cases where this is negative..                    ( IN THE FUTURE, DEAL WITH THIS BETTER )
             WB_3_1S = WT_3_1S - WO_3_1S; % leftover consumption for the buyer
                WB_3_1S = WB_3_1S.*(WB_3_1S>0); % deal with cases where this is negative..
             U1_3_S =  ( repelem(Y1,sto,1) - (TP_3_1S./2) - repelem(F1,sto,1).*F_B1_31 ) + WO_3_1S - ...
                        (1./(2.*repelem(alpha1,sto,1))).*( (WO_3_1S - ( repelem(beta1,sto,1)+nu1 ) + repelem(alpha1,sto,1))).^2  ;
             U3_1_S =  ( repelem(Y3,sto,1) - (TP_3_1S./2) - repelem(F1,sto,1).*F_B3_31   - WB_3_1S.*repelem(PH3,sto,1) )                    + WB_3_1S - ...
                        (1./(2.*repelem(alpha3,sto,1))).*( (WB_3_1S - ( repelem(beta3,sto,1)+nu3 ) + repelem(alpha3,sto,1))).^2  ;
                 WT_3_1S = accumarray(repelem((1:length(beta1))',sto,1),WT_3_1S)./sto; %%% need to collapse over all of the draws!               
                 TP_3_1S = accumarray(repelem((1:length(beta1))',sto,1),TP_3_1S)./sto;        
                 U1_3_S  = accumarray(repelem((1:length(beta1))',sto,1),U1_3_S)./sto;       
                 U3_1_S  = accumarray(repelem((1:length(beta1))',sto,1),U3_1_S)./sto;                   
              
       %%% 3 to 2 %%%            
           [WT_3_2S,~,~,TP_3_2S,P_3_2S] = utility_calc_input_tune([sto 1], [ ( beta2 + beta3 - alpha3.*PH3 )  ... %% sum beta's but subtract hassle
                                                             (alpha2+alpha3)./2  ... %% ALPHA (take average)
                                                             (SIG_EP_INPUTS(2).*ones(length(beta3),1))], ... %% SIG_EP (input sharing~!)
                                                            input2(:,5:7),input2(:,8:11),input2(:,13:14),... %% other parameters are for the owner!
                                                             [(nu2 + nu3) ... % nu
                                                              (ep2 + ep3)],TUNE);  % epsilon
            % owner usage      (beta  + nu)                    alpha               (divide by 2) price faced
             WO_3_2S = ( repelem(beta2,sto,1)+nu2 ) -     ( repelem(alpha2,sto,1) ).*(P_3_2S./2) + ep2 ;
                WO_3_2S = WO_3_2S.*(WT_3_2S>WO_3_2S & WO_3_2S>0)  + WT_3_2S.*(WT_3_2S<=WO_3_2S) ; % deal with cases where this is negative..                    ( IN THE FUTURE, DEAL WITH THIS BETTER )
             WB_3_2S = WT_3_2S - WO_3_2S; % leftover consumption for the buyer
                WB_3_2S = WB_3_2S.*(WB_3_2S>0); % deal with cases where this is negative..
             U2_3_S =  ( repelem(Y2,sto,1) - (TP_3_2S./2) - repelem(F2,sto,1).*F_B2_32 ) + WO_3_2S - ...
                        (1./(2.*repelem(alpha2,sto,1))).*( (WO_3_2S - ( repelem(beta2,sto,1)+nu2 ) + repelem(alpha2,sto,1))).^2  ;
             U3_2_S =  ( repelem(Y3,sto,1) - (TP_3_2S./2) - repelem(F2,sto,1).*F_B3_32 - WB_3_2S.*repelem(PH3,sto,1) )         + WB_3_2S - ...
                        (1./(2.*repelem(alpha3,sto,1))).*( (WB_3_2S - ( repelem(beta3,sto,1)+nu3 ) + repelem(alpha3,sto,1))).^2  ;
                 WT_3_2S = accumarray(repelem((1:length(beta1))',sto,1),WT_3_2S)./sto; %%% need to collapse over all of the draws!               
                 TP_3_2S = accumarray(repelem((1:length(beta1))',sto,1),TP_3_2S)./sto;        
                 U2_3_S  = accumarray(repelem((1:length(beta1))',sto,1),U2_3_S)./sto;       
                 U3_2_S  = accumarray(repelem((1:length(beta1))',sto,1),U3_2_S)./sto;                   
       
        %%% 3 to 2 to 1 %%%
            [WT_3_2_1S,~,~,TP_3_2_1S,P_3T] = utility_calc_input_tune([sto 1], [ ( beta1 + beta2 + beta3 - alpha3.*PH3 - alpha2.*PH2 )  ... %% sum beta's but subtract hassle
                                                             (alpha1+alpha2+alpha3)./3  ... %% ALPHA (take average) over 3 in this case!
                                                             (SIG_EP_INPUTS(3).*ones(length(beta3),1))], ... %% SIG_EP (input sharing~!)
                                                            input1(:,5:7),input1(:,8:11),input1(:,13:14),... %% other parameters are for the owner!
                                                             [(nu1 + nu2 + nu3) ... % nu
                                                              (ep1 + ep2 + ep3)],TUNE);  % epsilon
            % owner usage      (beta  + nu)                    alpha               (divide by 2) price faced
             WO_3_2_1S = ( repelem(beta1,sto,1)+nu1 ) -     ( repelem(alpha1,sto,1) ).*(P_3T./3) + ep1 ;
                WO_3_2_1S = WO_3_2_1S.*(WT_3_2_1S>WO_3_2_1S & WO_3_2_1S>0)  + WT_3_2_1S.*(WT_3_2_1S<=WO_3_2_1S) ; % deal with cases where this is negative..                    ( IN THE FUTURE, DEAL WITH THIS BETTER )
             WB2_3_2_1S = ( repelem(beta2,sto,1)+nu2 ) -     ( repelem(alpha2,sto,1) ).*(P_3T./3) + ep2 ;
                WB2_3_2_1S = WB2_3_2_1S.*((WT_3_2_1S-WO_3_2_1S)>WB2_3_2_1S & WB2_3_2_1S>0) +(WT_3_2_1S-WO_3_2_1S).*((WT_3_2_1S-WO_3_2_1S)<=WB2_3_2_1S) ; % deal with cases where this is negative..                    ( IN THE FUTURE, DEAL WITH THIS BETTER )
             
             WB3_3_2_1S = WT_3_2_1S - WO_3_2_1S - WB2_3_2_1S; % leftover consumption for the buyer
                WB3_3_2_1S = WB3_3_2_1S.*(WB3_3_2_1S>0); % deal with cases where this is negative..
             
             U1_SC   =  ( repelem(Y1,sto,1) - (TP_3_2_1S./3) - repelem(F1,sto,1).*F_B1_321 ) + WO_3_2_1S - ... % SPLIT PAYMENT 3 WAYS NOW!
                        (1./(2.*repelem(alpha1,sto,1))).*( (WO_3_2_1S - ( repelem(beta1,sto,1)+nu1 ) + repelem(alpha1,sto,1))).^2  ;
             U2_1_SC =  ( repelem(Y2,sto,1) - (TP_3_2_1S./3) - repelem(F1,sto,1).*F_B2_321     - WB2_3_2_1S.*repelem(PH2,sto,1)  ) + WB2_3_2_1S - ...
                        (1./(2.*repelem(alpha2,sto,1))).*( (WB2_3_2_1S - ( repelem(beta2,sto,1)+nu2 ) + repelem(alpha2,sto,1))).^2  ;
             U3_1_SC =  ( repelem(Y3,sto,1) - (TP_3_2_1S./3) - repelem(F1,sto,1).*F_B3_321      - WB3_3_2_1S.*repelem(PH3,sto,1)  ) + WB3_3_2_1S  - ...
                        (1./(2.*repelem(alpha3,sto,1))).*( (WB3_3_2_1S  - ( repelem(beta3,sto,1)+nu3 ) + repelem(alpha3,sto,1))).^2  ;
                    
                 WT_3_2_1S = accumarray(repelem((1:length(beta1))',sto,1),WT_3_2_1S)./sto; %%% need to collapse over all of the draws!               
                 TP_3_2_1S = accumarray(repelem((1:length(beta1))',sto,1),TP_3_2_1S)./sto;        
                 U1_SC     = accumarray(repelem((1:length(beta1))',sto,1),U1_SC)./sto;       
                 U2_1_SC   = accumarray(repelem((1:length(beta1))',sto,1),U2_1_SC)./sto;
                 U3_1_SC   = accumarray(repelem((1:length(beta1))',sto,1),U3_1_SC)./sto;
                 
        %%% ALTERNATIVE %%%
        %    [~,~,U1_A] =utility_calc_single_price_input(sto,input1(:,1:2),input1(:,15),[input1(:,13) input1(:,16)],errors1);
        %    [~,~,U2_A] =utility_calc_single_price_input(sto,input2(:,1:2),input2(:,15),[input2(:,13) input2(:,16)],errors2);
        %    [~,~,U3_A] =utility_calc_single_price_input(sto,input3(:,1:2),input3(:,15),[input3(:,13) input3(:,16)],errors3);

        %%% TRANSFERS %%%    
if transfer_option>=1 && transfer_option<=2
        T2_1_S = ( U2_1_S - max(U2_I,U2_A) )  ;
        T1_2_S = ( U1_2_S - max(U1_I,U1_A) )  ;
        T2_1   = .5 .* ( T2_1_S - T1_2_S )    ;
                if transfer_option==2
            T2_1 = T2_1.*(T2_1>0);
                end
        T3_1_S = ( U3_1_S - max(U3_I,U3_A) )  ;
        T1_3_S = ( U1_3_S - max(U1_I,U1_A) )  ;
        T3_1   = .5 .* ( T3_1_S - T1_3_S )    ;    
                if transfer_option==2
        T3_1 = T3_1.*(T3_1>0);
                end
        T3_2_S = ( U3_2_S - max(U3_I,U3_A) )  ;
        T2_3_S = ( U2_3_S - max(U2_I,U2_A) )  ;
        T3_2   = .5 .* ( T3_2_S - T2_3_S )    ; 
                if transfer_option==2
        T3_2   = T3_2.*(T3_2>0);
                end
            U1_A1  = ( U1_SC - max(U1_I,U1_A) )  ;
            U2_A2  = ( U2_1_SC - max(U2_I,U2_A) );
            U3_A3  = ( U3_1_SC - max(U3_I,U3_A) );
        T2_1SC = U2_A2.*(2/3) - U3_A3.*(1/3) - U1_A1.*(1/3)  ;
                if transfer_option==2
        T2_1SC   = T2_1SC.*(T2_1SC>0);
                end
        T3_1SC = U3_A3.*(2/3) - U2_A2.*(1/3) - U1_A1.*(1/3)  ;
                if transfer_option==2        
        T3_1SC   = T3_1SC.*(T3_1SC>0);
                end
else
    T2_1=0;
    T3_1=0;
    T3_2=0;
    T2_1SC=0;
    T3_1SC=0;
end

%%%% TEST THIS HARDCORE!
%{
    U1_I = [ 3; 0; 2.5];
    U2_I = [ 0; 4; 5];
    U3_I = [ 7; 6; 0];
    U1_A = (U1_I==0);
    U2_A = (U2_I==0);
    U3_A = (U3_I==0);

    TP3_I = 40.*ones(3,1);
    TP2_I = 60.*ones(3,1);
    TP1_I = 1000.*ones(3,1);
    TP_3_1S= -99.*ones(3,1);
    TP_3_2_1S=-999.*ones(3,1);
    TP_2_1S=-99.*ones(3,1);
    TP_3_2S=-88.*ones(3,1);
   
    WT3_I = 4.*ones(3,1);
    WT2_I = 6.*ones(3,1);
    WT1_I = 100.*ones(3,1);
    WT_3_1S= -9.*ones(3,1);
    WT_3_2_1S=-99.*ones(3,1);
    WT_2_1S=-9.*ones(3,1);
    WT_3_2S=-8.*ones(3,1);
    
PH2 = 1000;
%}


    % players: [1]  [2]  [3]
if max(PH2)>500
    T3_2 = 0.*ones(length(U1_A),1);
    T3_1 = 0.*ones(length(U1_A),1);
    T2_1 = 0.*ones(length(U1_A),1);
    T2_1SC=0.*ones(length(U1_A),1);
    T3_1SC=0.*ones(length(U1_A),1);
    U1_3_S= -10000.*ones(length(U1_A),1);
    U3_1_S= -10000.*ones(length(U1_A),1);
    U1_2_S= -10000.*ones(length(U1_A),1);
    U2_1_S= -10000.*ones(length(U1_A),1);
    U2_3_S= -10000.*ones(length(U1_A),1);
    U3_2_S= -10000.*ones(length(U1_A),1);
    U2_1_SC=-10000.*ones(length(U1_A),1);
    U3_1_SC=-10000.*ones(length(U1_A),1);
    U1_SC=-10000.*ones(length(U1_A),1);
end


    AA_1 =     [  U1_A     U1_A  ];  % AA : order [ A I ];
    AA_2 =     [  U2_A     U2_A  ];
    AA_3 =     [  U3_A     U3_I  ];
    AI_1 =     [  U1_A     U1_A        U1_A  ] ;        % AI : order [ A S(3,2) I ]
    AI_2 =     [  U2_I   (U2_3_S+T3_2) U2_I  ] ; 
    AI_3 =     [  U3_A   (U3_2_S-T3_2) U3_I  ] ;
    
    IA_1 =     [  U1_I          (U1_3_S+T3_1)            U1_I  ];        % IA : order [ A S(3,1) I ]
    IA_2 =     [  U2_A               U2_A                U2_A  ];
    IA_3 =     [  U3_A            (U3_1_S-T3_1)          U3_I  ];
    IS_1 =     [ (U1_2_S+T2_1)  (U1_SC+T2_1SC+T3_1SC)  (U1_2_S+T2_1)     ];    % IS : order [ A  S(3,1) I ]
    IS_2 =     [ (U2_1_S-T2_1)  (U2_1_SC-T2_1SC)       (U2_1_S-T2_1)     ];
    IS_3 =     [  U3_A          (U3_1_SC-T3_1SC)         U3_I            ];
    II_1 =     [  U1_I          (U1_3_S+T3_1)            U1_I               U1_I    ];    % II : order [ A S(3,1) S(3,2) I ]
    II_2 =     [  U2_I                U2_I              (U2_3_S+T3_2)       U2_I    ];
    II_3 =     [  U3_A            (U3_1_S-T3_1)         (U3_2_S-T3_2)       U3_I    ];

    
% CHOICE 3: % the third person makes this decision
    [~,AA_C3]=max(AA_3,[],2); %%% FIRST BRANCH HERE (WHERE PLAYER ONE PICKS ALTERNATIVE)
    ind_AA=sub2ind(size(AA_3),(1:length(AA_C3))',AA_C3);
    AA_U3 = AA_3(ind_AA);
    AA_U2 = AA_2(ind_AA);
    AA_U1 = AA_1(ind_AA); 

    [~,AI_C3]=max(AI_3,[],2); 
    ind_AI=sub2ind(size(AI_3),(1:length(AI_C3))',AI_C3);
    AI_U3 = AI_3(ind_AI);
    AI_U2 = AI_2(ind_AI);
    AI_U1 = AI_1(ind_AI);                          

    [~,IA_C3]=max(IA_3,[],2);  %%% SECOND BRANCH HERE (WHERE PLAYER ONE PICKS INDIVIDUAL)
    ind_IA=sub2ind(size(IA_3),(1:length(IA_C3))',IA_C3);
    IA_U3 = IA_3(ind_IA);
    IA_U2 = IA_2(ind_IA);
    IA_U1 = IA_1(ind_IA);
    
    [~,IS_C3]=max(IS_3,[],2); 
    ind_IS=sub2ind(size(IS_3),(1:length(IS_C3))',IS_C3);
    IS_U3 = IS_3(ind_IS);
    IS_U2 = IS_2(ind_IS);
    IS_U1 = IS_1(ind_IS);
    
    [~,II_C3]=max(II_3,[],2); 
    ind_II=sub2ind(size(II_3),(1:length(II_C3))',II_C3);
    II_U3 = II_3(ind_II);
    II_U2 = II_2(ind_II);
    II_U1 = II_1(ind_II);
    
    C3M_branch_A = [AA_C3 AI_C3 ];
    C3M_branch_I = [IA_C3 IS_C3 II_C3];
    
    A3 = [AA_U3 AI_U3]; % CHOICE 2:  [ A I ]
    A2 = [AA_U2 AI_U2]; %%% ( for alternatives, use original utilities, because there's no decision to be made )
    A1 = [AA_U1 AI_U1];   
    
    I3 = [IA_U3 IS_U3 II_U3]; % CHOICE 2:  [ A S(2,1) I ]
    I2 = [IA_U2 IS_U2 II_U2]; 
    I1 = [IA_U1 IS_U1 II_U1];

    [~,A_C2]=max(A2,[],2); % now we see the second player makes this decision
    ind_A=sub2ind(size(A2),(1:length(A2))',A_C2);
    
    [~,I_C2]=max(I2,[],2); 
    ind_I=sub2ind(size(I2),(1:length(I2))',I_C2);
 
    C2M = [A_C2 I_C2];
    
     U3_C2=[A3(ind_A) I3(ind_I)];
     U2_C2=[A2(ind_A) I2(ind_I)];
     U1_C2=[A1(ind_A) I1(ind_I)];
    
    [~,C1] = max(U1_C2,[],2); % CHOICE 1: % now the first player compares their utility to the outside option!
    ind_1=sub2ind(size(U1_C2),(1:length(U1_C2))',C1);

    U3_C1 = U3_C2(ind_1);
    U2_C1 = U2_C2(ind_1);
    U1_C1 = U1_C2(ind_1);
   
    C2   = C2M(ind_1);
    C3_B = [C3M_branch_A(ind_A) C3M_branch_I(ind_I)];
    C3   = C3_B(ind_1);
    
    %%% FIX 3 FIRST
        c3=C3;
        %%% BRANCH AA : AAA ok
        c3(C1==1 & C2==1 & C3==2) = 3; % AAI
        %%% BRANCH AI : AIA, AIS, AII ok
        %%% BRANCH IA : IAA, IAS, IAI ok
        %%% BRANCH IS : ISA, ISS, ISI ok
        %%% BRANCH II : IIA, ok
        c3(C1==2 & C2==3 & (C3==2 | C3==3))=2; % IIS21, IIS32
        c3(C1==2 & C2==3 & C3==4)=3; % III
    %%% FIX 2 SECOND
        c2=C2;
        %%% BRANCH A: A ok
        c2(C1==1 & C2==2)=3; % I
        %%% BRANCH I: A, S, I ok
    %%% FIX 1 LAST
        c1=C1;
        c1(C1==2)=3;
        
    AC = [c1 c2 c3];

    Choices=AC;
    
if nargout>4
    i = size(input1,1);
 
    TP_AA =     [  zeros(length(TP3_I),1)  TP3_I    ]; % TOTAL PAYMENTS
    TP_AI =     [  (TP2_I)  (TP_3_2S)  (TP2_I+TP3_I)     ];

    TP_IA =     [  (TP1_I+0+0)  (TP_3_1S+0+0) (TP1_I+TP3_I)    ]; % TOTAL PAYMENTS
    TP_IS =     [  (TP_2_1S+0)  (TP_3_2_1S)  (TP_2_1S+TP3_I)     ];
    TP_II =     [  (TP1_I+TP2_I+0)   (TP_3_1S+TP2_I)      (TP1_I+TP_3_2S)  (TP1_I+TP2_I+TP3_I)    ];

    TPA_C3= [TP_AA(ind_AA) TP_AI(ind_AI)] ;
    TPI_C3= [TP_IA(ind_IA) TP_IS(ind_IS) TP_II(ind_II)] ;
    TPA_C2= [TPA_C3(ind_A) TPI_C3(ind_I)];
    TP_C1=TPA_C2(ind_1);
    
    WT_AA =     [  zeros(length(WT3_I),1)  WT3_I    ]; % TOTAL USAGE
    WT_AI =     [  (WT2_I)  (WT_3_2S)  (WT2_I+WT3_I)     ];

    WT_IA =     [  (WT1_I+0+0)  (WT_3_1S+0+0) (WT1_I+WT3_I)    ]; % TOTAL USAGE
    WT_IS =     [  (WT_2_1S+0)  (WT_3_2_1S)  (WT_2_1S+WT3_I)     ];
    WT_II =     [  (WT1_I+WT2_I+0)   (WT_3_1S+WT2_I)      (WT1_I+WT_3_2S)  (WT1_I+WT2_I+WT3_I)    ];

    WTA_C3= [WT_AA(ind_AA) WT_AI(ind_AI)] ;
    WTI_C3= [WT_IA(ind_IA) WT_IS(ind_IS) WT_II(ind_II)] ;
    WTA_C2= [ WTA_C3(ind_A) WTI_C3(ind_I) ];
    WT_C1=WTA_C2(ind_1);

    Total_Utility = [U1_C1 U2_C1 U3_C1];
    Total_Revenue = sum(TP_C1)./(3.*i);
    Total_Connections = sum(sum((AC==3)))./(3.*i);
    Total_Consumption = sum(WT_C1)./(3.*i);
    Total_Share       = sum(sum((AC==2)))./(3.*i);
    
    Total_Utility_Alt = [U1_A U2_A U3_A];
    
end
    
  end

    