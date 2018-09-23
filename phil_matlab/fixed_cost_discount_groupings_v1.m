%{

function h = fixed_cost_discount_groupings_v1(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_max,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,boot_max,boot_estimates,alt_sample,...
                    C_FEE_DISCOUNT,income_opt,group_percentile,COST_INPUTS,cd_dir,cd_out)
  h=1;

%}

                
income_percentile=group_percentile;

income_opt = 0;
                
                
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
    
    GIVEN_P = [  CONNECTION_COST 0  ]; % payment is equal to cost!
    alternative_parameters =  x1(2:end)' ;
    
[~,~,~,~,CAPITAL]   = smm_shell_counterfactual_v3(  0 ,GIVEN_P, alternative_parameters,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    [   MARGINAL_COST          CONNECTION_COST  (x1(1)-CONNECTION_COST)   ],PH_COUNTER,TUNE,alt_error);
   
     COST_PARAMETERS   = [   MARGINAL_COST  CONNECTION_COST  (x1(1)-CONNECTION_COST)  CAPITAL  ];
     
     
     
if mac==1
    table_pre= 'tables/';
else
    table_pre= 'tables\';  
end

if C_FEE_DISCOUNT<1
    fileID = fopen(strcat(cd_out,table_pre,'c_fee_discount_group.tex'),'w');
    fprintf(fileID,'%s',num2str(C_FEE_DISCOUNT*100));
    fclose(fileID);
else
    fileID = fopen(strcat(cd_out,table_pre,'c_fee_discount_group.tex'),'w');
    fprintf(fileID,'%s',num2str(C_FEE_DISCOUNT));
    fclose(fileID);    
end

    fileID = fopen(strcat(cd_out,table_pre,'capital_costs_group.tex'),'w');
    fprintf(fileID,'%s',COST_PARAMETERS(4));
    fclose(fileID);

    
                           
     
[~,TU0,~,~,~,~,betas0,incomes0,Choices0,TA0] ...
                    =  smm_shell_counterfactual_v3(  [] , GIVEN_P(1) , alternative_parameters,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_error)   ;     
  mean(mean(Choices0==1))  
  mean(mean(Choices0==2))                                  
  mean(mean(Choices0==3))      
                                
if C_FEE_DISCOUNT<1                                
  GIVEN_P1 = [ ((x1(1) - COST_PARAMETERS(3)).*(1-C_FEE_DISCOUNT)) ...
                    0 ...
                    0 ];   %%% NEW FIXED COST !!!
else
  GIVEN_P1 = [ GIVEN_P(1)-C_FEE_DISCOUNT ...
                    0 ...
                    0 ];   %%% NEW FIXED COST !!!    
end
     
 obj =  @(a1)smm_shell_counterfactual_v3(  a1 , GIVEN_P1, alternative_parameters,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_error)   ;

%{
a_low=-5;
a_high=20;
V=10;
av=((1:V)'./V).*(a_high-a_low) + a_low;
OBJ=ones(V,1);
for vv = 1:V
     ot=obj(av(vv,1));
     OBJ(vv,1)=ot;
end
plot(av,OBJ)
%}
                             
x_r  =  fminsearch(obj,1);
x_r

[~,TU,~,~,~,~,betas,incomes,Choices,TA] ...
                    =  smm_shell_counterfactual_v3(  x_r , GIVEN_P1, alternative_parameters,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_error)   ;
  
 if income_opt==0
     incomes=betas;
     incomes0=betas0;
 end

 
csvwrite(strcat(cd_dir,table_pre,'price_increase_for_fixed_cost_group.csv'),x_r);
 
fileID = fopen(strcat(cd_out,table_pre,'discount_tariff_rise_group.tex'),'w');
    fprintf(fileID,'%s',num2str(x_r,'%5.2f'));
    fclose(fileID);

 

low_income  =   incomes  < prctile(reshape(incomes,size(incomes,1)*size(incomes,2),1),income_percentile);
low_income0 =   incomes0 < prctile(reshape(incomes0,size(incomes0,1)*size(incomes0,2),1),income_percentile);                                 
                                
%TU_change = (mean(mean(TU)) - mean(mean(TU0))  )   /   mean(mean(TU0))   ;                                  
%TU_change_low_income = (mean(mean(TU(low_income==1))) - mean(mean(TU0(low_income0==1)))  )   /   mean(mean(TU0(low_income0==1)))   ;                    

TU_change = (mean(mean(TU)) - mean(mean(TU0))  )    ;                                  
TU_change_low_income = (mean(mean(TU(low_income==1))) - mean(mean(TU0(low_income0==1)))  )      ;                    
 

SHR0 = mean(mean(Choices0==2))  ;                                
SHR = mean(mean(Choices==2))  ;                       
  
  ALT0 = mean(mean(Choices0==1));
  ALT = mean(mean(Choices==1));
  
    surplus_current = mean(mean(TU0-TA0));
    surplus_discount = mean(mean(TU-TA));
    
    surplus_current_low = mean(mean(TU0(low_income0==1)-TA0(low_income0==1)));
    surplus_discount_low = mean(mean(TU(low_income==1)-TA(low_income==1)));
    
    
    
    
  
    fileID = fopen(strcat(cd_out,table_pre,'group_percentile_group.tex'),'w');
    fprintf(fileID,'%s',num2str(group_percentile,'%5.0f'));
    fclose(fileID); 
    
    fileID = fopen(strcat(cd_out,table_pre,'discount_avg_surplus_change_group.tex'),'w');
    fprintf(fileID,'%s',num2str(abs(TU_change),'%5.1f'));
    fclose(fileID); 
    
    fileID = fopen(strcat(cd_out,table_pre,'discount_low_surplus_change_group.tex'),'w');
    fprintf(fileID,'%s',num2str(abs(TU_change_low_income),'%5.1f'));
    fclose(fileID);
    
    
    fileID = fopen(strcat(cd_out,table_pre,'discount_avg_welfare_change_group.tex'),'w');
    fprintf(fileID,'%s',num2str(abs(100*TU_change/mean(mean(TU0))),'%5.2f'));
    fclose(fileID); 
    
    fileID = fopen(strcat(cd_out,table_pre,'discount_low_welfare_change_group.tex'),'w');
    fprintf(fileID,'%s',num2str(abs(100*TU_change_low_income/mean(mean(TU0(low_income0==1)))),'%5.2f'));
    fclose(fileID);
    

    fileID = fopen(strcat(cd_out,table_pre,'discount_sharing_change_group.tex'),'w');
    fprintf(fileID,'%s',num2str(  (SHR-SHR0)*100  ,'%5.2f'));
    fclose(fileID);
   
    fileID = fopen(strcat(cd_out,table_pre,'discount_vendor_change_group.tex'),'w');
    fprintf(fileID,'%s',num2str(  (ALT-ALT0)*100  ,'%5.2f'));
    fclose(fileID);
       
    
    
    HLINE=0;
fileID = fopen(strcat(cd_out,table_pre,'discount_estimates_group.tex'),'w');

%fprintf(fileID,'%s\n','\begin{table}');
%fprintf(fileID,'%s\n','\centering');

%fprintf(fileID,'%s\n','\caption{Welfare Impacts of a Fixed Fee Discount Policy}'); 
fprintf(fileID,'%s\n','\begin{tabular}{lcc}');
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','& Current & Discount \\');
%fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');


    

if C_FEE_DISCOUNT>1
    fprintf(fileID,'%s\n',strcat('Fixed Fee &', ...
                        num2str(225,'%5.0f'),'&', num2str(225-C_FEE_DISCOUNT,'%5.0f'),'\\'));
                        %num2str(x1(1),'%5.0f'),'&', num2str(x1(1)-C_FEE_DISCOUNT,'%5.0f'),'\\'));

if HLINE==1                    
    fprintf(fileID,'%s\n','\hline');  
end
else
    fprintf(fileID,'%s\n',strcat('Fixed Fee  &', ...
                        num2str(x1(1),'%5.0f'),'&', num2str(x1(1)+GIVEN_P1-GIVEN_P,'%5.0f'),'\\'));
if HLINE==1                    
    fprintf(fileID,'%s\n','\hline');  
end
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
%    fprintf(fileID,'%s\n','\hline');    
else
    fprintf(fileID,'%s\n',strcat('Gain HH Inc: Low Inc & &', ...
                        num2str(TU_change_low_income,'%5.1f'),' \\'));
%    fprintf(fileID,'%s\n','\hline');
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




  
  