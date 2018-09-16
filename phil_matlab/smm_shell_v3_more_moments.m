function    [h,moments_output,Choices,input3a] ...
                    =  smm_shell_v3_more_moments(a,given,moments,smm_est_option,...
                                    input1,input2,input3,...
                                    errors1,errors2,errors3,...
                                    SIG_EP_INPUTS,reps,sto,alt_error,...
                                    sort_condition,split_F_option,transfer_option,TUNE)
                                
% INPUT :   BETA_FULL ALPHA_FULL SIG_EP_FULL SIG_NU_FULL K_FULL(3) P_FULL(4) PH_FULL  Y   F    PA  FA   
%              1           2       3           4         5 6 7    8 9 10 11     12    13  14   15 16

if smm_est_option(1)==1
    F_mean      = a(1,1);
    FA_mean     = a(1,2);
    PA_mean     = a(1,3);
elseif smm_est_option(1)==2
    F_mean      = a(1,1);
    FA_mean     = 0;
    PA_mean     = a(1,2);   
elseif smm_est_option(1)==3
    F_mean      = a(1,1);
    FA_mean     = 0;
    PA_mean     = a(1,2);  
    a_sigma     = a(1,3);
elseif smm_est_option(1)==4
    F_mean      = a(1,1);
    FA_mean     = a(1,2);
    PA_mean     = a(1,3);  
    a_sigma     = a(1,4);
elseif smm_est_option(1)==5
    F_mean      = a(1,1);
    PA_mean     = given(1);
    FA_mean     = given(2);
else
    F_mean      = a(1,1);
    FA_mean     = a(1,2);
    PA_mean     = given;
end


F     = F_mean.*ones(size(input1,1),1);
F1 = F;
F2 = F;
F3 = F;
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
input1 = [input1 F1 PA1 FA1];
input2 = [input2 F2 PA2 FA2];
input3 = [input3 F3 PA3 FA3];

%[Choices,input1,input2,input3,Total_Utility,Total_Revenue,Total_Connections,Total_Consumption,Total_Share] ...
if smm_est_option(2)==1 || smm_est_option(2)==2
      %[Choices,input1a,input2a,input3a,Total_Utility,Total_Revenue,Total_Connections,Total_Consumption,Total_Share] ...   
      [Choices,input1a,input2a,input3a] ...
      = smm_time_v3_shell_counterfactual(...
                input1,input2,input3,...
                errors1,errors2,errors3,...
                SIG_EP_INPUTS,reps,sto,...
                sort_condition,split_F_option,transfer_option,TUNE);
else
    
    %[Choices,input1a,input2a,input3a,Total_Utility,Total_Revenue,Total_Connections,Total_Consumption,Total_Share] ...
    Choices ...
    = smm_time_v3_shell_counterfactual(...
                input1,input2,input3,...
                errors1,errors2,errors3,...
                SIG_EP_INPUTS,reps,sto,...
                sort_condition,split_F_option,transfer_option,TUNE);
end
%%Choices = accumarray(repelem((1:(size(Choices,1)/reps))',reps,1),Choices)./reps;
if smm_est_option(2)==4
    moments_new=moments;
    SHR2 = sum(Choices==2,2)==2 ;
    SHR_I= sum(Choices==2,2)==1 & sum(Choices==3,2)==2  ;
    SHR_A= sum(Choices==2,2)==1 & sum(Choices==1,2)==1  ;
    III  = sum(Choices==3,2)==3  ;
    IIA  = sum(Choices==3,2)==2 & sum(Choices==1,2)==1  ;
    IAA  = sum(Choices==3,2)==1 & sum(Choices==1,2)==2  ;
    AAA  = sum(Choices==1,2)==3   ;   

    moments_est=mean([SHR2 SHR_I SHR_A III IIA IAA AAA]);
    if smm_est_option(3)>0
        WEIGHT=smm_est_option(3);
    else
        WEIGHT=1;
    end

    h =   WEIGHT.*sum(( moments_new(1:3)-moments_est(1:3) ).^2) ...
          + sum(( moments_new(4:7)-moments_est(4:7) ).^2 ) ;
else
    
    EM_individual = sum(sum(Choices==3))/(3*size(Choices,1));
    EM_shared = sum(sum(Choices==2))/(3*size(Choices,1));
    EM_alternative = sum(sum(Choices==1))/(3*size(Choices,1));
    
h = ( moments(1) - EM_individual  ).^2 + ...
    ( moments(2) - EM_shared      ).^2 + ...
    ( moments(3) - EM_alternative ).^2 ;

    if smm_est_option(2)==1 || smm_est_option(2)==2
    %     cc1 = corrcoef(Choices(:,3)==3,input3a(:,1));
    %     cc2 = corrcoef(Choices(:,3)==2,input3a(:,1));
    %     cc3 = corrcoef(Choices(:,3)==1,input3a(:,1)); 
         cc1 = corrcoef([Choices(:,1)==3;Choices(:,2)==3;Choices(:,3)==3],[input1a(:,1);input2a(:,1);input3a(:,1)]);
         cc2 = corrcoef([Choices(:,1)==2;Choices(:,2)==2;Choices(:,3)==2],[input1a(:,1);input2a(:,1);input3a(:,1)]);
         cc3 = corrcoef([Choices(:,1)==1;Choices(:,2)==1;Choices(:,3)==1],[input1a(:,1);input2a(:,1);input3a(:,1)]);
         cc1(isnan(cc1)==1) = 2; %%% Plug in 2 for cov moments! %%%
         cc2(isnan(cc2)==1) = 2;
         cc3(isnan(cc3)==1) = 2;
         cov_moments = [ cc1(1,2) cc2(1,2) cc3(1,2) ];
    end


    if smm_est_option(3)>0
        h    = h.*smm_est_option(3);
    end
    
    if smm_est_option(2)==1
        h = h + ( moments(4) - cc1(1,2) ).^2 + ...
                ( moments(5) - cc2(1,2) ).^2 + ...
                ( moments(6) - cc3(1,2) ).^2 ;
    elseif smm_est_option(2)==2
        h = h + ( moments(4) - cc1(1,2) ).^2 + ...
                ( moments(5) - cc2(1,2) ).^2 ;    
    end

end


 
if nargout>1

   EM_individual = sum(sum(Choices==3))/(3*size(Choices,1));
   EM_shared = sum(sum(Choices==2))/(3*size(Choices,1));
   EM_alternative = sum(sum(Choices==1))/(3*size(Choices,1));
   moments_output=[EM_individual EM_shared EM_alternative];
   if smm_est_option(2)==1 || smm_est_option(2)==2
       moments_output=[moments_output cov_moments];
   end
   if smm_est_option(2)==4
        moments_output = [moments_est EM_individual EM_shared EM_alternative];
   end
end
    


            
