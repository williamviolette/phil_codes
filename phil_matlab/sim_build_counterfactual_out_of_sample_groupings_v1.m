function [h] = sim_build_counterfactual_out_of_sample_groupings_v1(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_max,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,boot_max,boot_estimates,alt_sample,income_opt,group_percentile,COST_INPUTS,cd_dir,cd_out)

                
                
                income_opt=0;
                
est_opt=0;
BOOT=[];

[x1,given,moments,smm_est_option,...
                input1s,input2s,input3s,...
                errors1s,errors2s,errors3s,...
                SIG_EP_INPUTS,reps,sto,alt_error,...
                sort_condition,split_F_option,transfer_option,TUNE]=...
est3(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_size,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,BOOT,boot_max,boot_estimates,est_opt,many_sv_smm,cd_dir);

                
                        
 PH_COUNTER = [];
    MARGINAL_COST   = COST_INPUTS(1);
    CONNECTION_COST = COST_INPUTS(2);
    
    
    %{
        MARGINAL_COST = 5;
        CONNECTION_COST=150;
        PH_COUNTER=[];  
    %}
        % COST_PARAMETERS:    MARGINAL_COST                CONNECTION_COST  F_ADDITIONAL             CAPITAL  
        
  %  p_3/p_4
  %  a = 0 ;
                % F_PAY  p_1/p_2
    GIVEN_P = [  CONNECTION_COST 0  ]; % payment is equal to cost!
                              % FA    PA etc.
    alternative_parameters =  x1(2:end)' ;
    
                  [~,~,~,~,CAPITAL]   = smm_shell_counterfactual_v3(  0 ,GIVEN_P, alternative_parameters,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    [   MARGINAL_COST          CONNECTION_COST  (x1(1)-CONNECTION_COST)   ],PH_COUNTER,TUNE,alt_error);
   
     COST_PARAMETERS   = [   MARGINAL_COST  CONNECTION_COST  (x1(1)-CONNECTION_COST)  CAPITAL  ];

     
     
    
     
     
[~,TU0,~,~,~,~,betas0,incomes0,Choices0,TA0] ...
                    =  smm_shell_counterfactual_v3(  [] , GIVEN_P(1) , alternative_parameters,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_error)   ;     
     
DISCOUNT = 45;                                
%%%  cfee_out_of_sample = GIVEN_P(1) - DISCOUNT ;     

cfee_out_of_sample = GIVEN_P(1) - (rand(size(input1s,1),1)<=.28)  .*  DISCOUNT;

[~,TU,~,~,~,~,betas,incomes,Choices,TA] ...
                    =  smm_shell_counterfactual_v3(  [] , cfee_out_of_sample , alternative_parameters,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_error)   ;
 if income_opt==0
     incomes=betas;
     incomes0=betas0;
 end                                
                                

if mac==1
    table_pre= 'tables/';
else
    table_pre= 'tables\';  
end

income_percentile = group_percentile;

inc_ind=mean(mean(Choices==3))  -  mean(mean(Choices0==3))

    fileID = fopen(strcat(cd_out,table_pre,'out_of_sample_inc_ind_conn_group.tex'),'w');
    fprintf(fileID,'%s',num2str(round(inc_ind*100,2)));
    fclose(fileID);

    fileID = fopen(strcat(cd_out,table_pre,'group_percentile_oos_group.tex'),'w');
    fprintf(fileID,'%s',num2str(group_percentile,'%5.0f'));
    fclose(fileID);                                 
                
low_income  =   incomes  < prctile(reshape(incomes,size(incomes,1)*size(incomes,2),1),income_percentile);
low_income0 =   incomes0 < prctile(reshape(incomes0,size(incomes0,1)*size(incomes0,2),1),income_percentile);                                 
                                         
% TU_change = (mean(mean(TU)) - mean(mean(TU0))  )   /   mean(mean(TU0))   ;                                  
% TU_change_low_income = (mean(mean(TU(low_income==1))) - mean(mean(TU0(low_income0==1)))  )   /   mean(mean(TU0(low_income0==1)))   ;                    

 TU_change = (mean(mean(TU)) - mean(mean(TU0))  )     ;                                  
 TU_change_low_income = (mean(mean(TU(low_income==1))) - mean(mean(TU0(low_income0==1)))  )   ;                    

SHR0 = mean(mean(Choices0==2))  ;                                
SHR = mean(mean(Choices==2))  ;                       
  
  ALT0 = mean(mean(Choices0==1));
  ALT = mean(mean(Choices==1));

    fileID = fopen(strcat(cd_out,table_pre,'oos_discount_low_welfare_change_group.tex'),'w');
    fprintf(fileID,'%s',num2str(abs(TU_change_low_income),'%5.1f'));
    fclose(fileID);

    
    surplus_current = mean(mean(TU0-TA0));
    surplus_discount = mean(mean(TU-TA));
    
    surplus_current_low = mean(mean(TU0(low_income0==1)-TA0(low_income0==1)));
    surplus_discount_low = mean(mean(TU(low_income==1)-TA(low_income==1)));
    
    
HLINE=0;    
    
fileID = fopen(strcat(cd_out,table_pre,'oos_discount_estimates_group.tex'),'w');

%fprintf(fileID,'%s\n','\begin{table}');
%fprintf(fileID,'%s\n','\centering');

%fprintf(fileID,'%s\n','\caption{Welfare Impacts of a Fixed Fee Discount Policy}'); 
fprintf(fileID,'%s\n','\begin{tabular}{lcc}');
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','& Current &  Discount \\');
fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');


fprintf(fileID,'%s\n',strcat('Fixed Fee (PhP/month) &', ...
                    num2str(x1(1),'%5.0f'),'&', num2str(x1(1) - DISCOUNT ,'%5.0f'),'\\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end

fprintf(fileID,'%s\n',strcat('Source Vendor &', ...
                    num2str(ALT0*100,'%5.1f'),'\% &', num2str(ALT*100,'%5.1f'),'\% \\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end


fprintf(fileID,'%s\n',strcat('Source Neighbor &', ...
                    num2str(SHR0*100,'%5.1f'),'\% &', num2str(SHR*100,'%5.1f'),'\% \\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end

fprintf(fileID,'%s\n',strcat(' Surplus  &',num2str(surplus_current,'%5.1f') ,'&', ...
                    num2str(surplus_discount,'%5.1f'),' \\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end

if income_opt==0
fprintf(fileID,'%s\n',strcat(' Surplus: Low Users  &',num2str(surplus_current_low,'%5.1f') ,'&', ...
                    num2str(surplus_discount_low,'%5.1f'),' \\'));
    fprintf(fileID,'%s\n','\hline');    
else
    fprintf(fileID,'%s\n',strcat('Gain HH Inc: Low Inc & &', ...
                        num2str(TU_change_low_income,'%5.1f'),' \\'));
    fprintf(fileID,'%s\n','\hline');
end

fprintf(fileID,'%s\n','\end{tabular}'); 
%fprintf(fileID,'%s\n','\vspace{.3cm}'); 

%fprintf(fileID,'%s\n','\label{table:discountestimates}'); 
%if income_opt==0
%    fprintf(fileID,'%s','Low Users include the bottom ');    
%    fprintf(fileID,'%s\n',strcat(num2str(income_percentile),'\% of water users'));
%else
%    fprintf(fileID,'%s','Low Inc. Users include the bottom ');
%    fprintf(fileID,'%s\n',strcat(num2str(income_percentile),'\%'));
%end
            
%fprintf(fileID,'%s\n','\end{table}');                

fclose(fileID);
    
    
h = 'worked';
    

%sum(  sum(Choices_pre(max(Choices_pre==2,[],2)~=1,:)==3)./(size(Choices_pre,1)*size(Choices_pre,2))  )
%sum(  sum(Choices_post(max(Choices_post==2,[],2)~=1,:)==3)./(size(Choices_post,1)*size(Choices_post,2))  )





%%%% CONNECTION FEE DISCOUNT

%{
   [~]  = fixed_cost_discount(alternative_parameters,...
                                    input1,input2,input3,...
                                    errors1,errors2,errors3,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,...
                                    transfer_option,censor_negative_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,...
                                    TUNE,C_FEE_DISCOUNT,mac,alt_error,income_percentile,x1);
%}     
                     
                
                
                