%{
function h = first_best_graph(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_max,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,boot_max,boot_estimates,alt_sample,income_opt,group_percentile,COST_INPUTS,cd_dir,cd_out)
%}                


                
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

                
                
if mac==1
    table_pre= 'tables/';
else
    table_pre= 'tables\';  
end
              




%%%% HERE IS WHERE IT'S ACTIVATED !
%%%% HERE IS WHERE IT'S ACTIVATED !
%%%% HERE IS WHERE IT'S ACTIVATED !
%%%% HERE IS WHERE IT'S ACTIVATED !


for PHC=1:2
    if PHC==1
        PH_COUNTER = []  ;
    elseif PHC==2
        PH_COUNTER = [1200]  ;
    end
    
           

%%% TEMP SET !!
group_percentile = 50;

                sub_sample = .05   ;

                groups     = [  group_percentile  group_percentile  ];
                sort_condition=0;
                split_F_condition=0;
                transfer_option=1;
            
    capital_real=0;
    income_opt = 0   ;

    
    
        
if isempty(sub_sample)~=1
    rng(1)
    sub = rand(size(input1s,1),1)<sub_sample;
    error_sub=repelem(sub,reps*sto,1);
    input1sub=input1s(sub==1,:);
    input2sub=input2s(sub==1,:);
    input3sub=input3s(sub==1,:);
    errors1sub=errors1s(error_sub==1,:);
    errors2sub=errors2s(error_sub==1,:);
    errors3sub=errors3s(error_sub==1,:);
    if isempty(alt_error)~=1
        alt_errorsub=alt_error(sub==1,:);
    end
end



if capital_real==1
    PH_TEMP = [];
else
    PH_TEMP = PH_COUNTER;
end

    %PH_COUNTER = [];
    MARGINAL_COST   = COST_INPUTS(1);
    CONNECTION_COST = COST_INPUTS(2);
    GIVEN_P = [  CONNECTION_COST 0  ]; % payment is equal to cost!
    alternative_parameters =  x1(2:end)' ;
    
[~,~,~,~,CAPITAL]   = smm_shell_counterfactual_v3(  0 ,GIVEN_P, alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    [   MARGINAL_COST          CONNECTION_COST  (x1(1)-CONNECTION_COST)   ],PH_TEMP,TUNE,alt_errorsub);
   
     COST_PARAMETERS   = [   MARGINAL_COST  CONNECTION_COST  (x1(1)-CONNECTION_COST)  CAPITAL  ];
     
COST_PARAMETERS
            



%%% INPUT = OPTIMAL PRICES 


%%% FIRST BEST:
    [HA,TU,TOTAL_CONNECTED,NET_REV,CAPITAL,Total_Share,gamma,incomes,Choices,Total_Utility_Alt,Total_Consumption] ...
                    =  smm_shell_counterfactual_v3(  MARGINAL_COST, CONNECTION_COST, alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub);   
                             
UTILITY_GAP = TU   -  Total_Utility_Alt;

mean(mean(UTILITY_GAP))

TOTAL_CONNECTED
NET_REV

    g_id1 = gamma<=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),groups(1));
    g_id2 = gamma>=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),groups(2));                                
       
    
AVG_SURPLUS = mean(mean(UTILITY_GAP)) 
  % average surplus generated (without fixed cost) 

FIXED_COST = (  NET_REV.*size(Choices,1).*size(Choices,2)  ) ./(size(Choices,1).*size(Choices,2) - sum(sum(Choices==1)))  ;  
  % fixed cost covered by each person  

% total transfer to the poor
TOTAL_TRANSFER_TO_POOR=(sum(UTILITY_GAP(g_id2==1)) + ...
                    FIXED_COST.*size(Choices,1).*size(Choices,2))./(sum(sum(g_id1)))  ;
  
%%% mean(mean(UTILITY_GAP(g_id2==1).*(UTILITY_GAP(g_id2==1)>0)))

POOR_SURPLUS = mean(UTILITY_GAP(g_id1==1)) + TOTAL_TRANSFER_TO_POOR   ;

RES_first_best = [ CONNECTION_COST ; ...
        mean(mean(Choices==1)) ; ...
        mean(mean(Choices==2)) ; ...
        mean(  AVG_SURPLUS + NET_REV  ) ; ...
        POOR_SURPLUS ; ...
        mean(mean(Total_Consumption))
        ]    
    

    
RES_current = produce_results(CONNECTION_COST,[],alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,groups)

                                
%          PH_COUNTER=[];


if isempty(PH_COUNTER)~=1
    tagline = 'high_ph';
else
    tagline = 'normal';
end    
tpt = csvread(strcat(cd_dir,table_pre,tagline,'_optimal_prices_groups.csv'));

tpt0 = [tpt(1) tpt(4)];

[RES_tpt0,NR] = produce_results(tpt0(1),tpt0(2),alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,groups)

tpt1 = [tpt(2) tpt(5)];

[RES_tpt1,NR] = produce_results(tpt1(1),tpt1(2),alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,groups)


                                
                                
                                
                               
 %{        
                 %%%   THIS IS FOR THE ESTIMATION OF THE TPT3  !!!
iterations   =  40;                                
stepsize = [60 4];

LOW=0;
tic
h = tp3_stepwise_groups(tpt0, stepsize, iterations, alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub, groups,mac,tagline, LOW,cd_dir)
toc

%{
stepsize = [5 .75];
iterations   =  4;
if isempty(PH_COUNTER)==1                                    
    stepsize = [50 5];
    iterations   =  20;  
end
%}             

%iterations   =  3;                                
%stepsize = [50 .75];


LOW=1;
tic
h = tp3_stepwise_groups(tpt1, stepsize, iterations, alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub, groups,mac,tagline, LOW,cd_dir)
toc 

  %}                  
                                
  
  
%%% TAKE THREE PART OPTIMUMS!

%%%  tpt_normal = csvread(strcat(table_pre,tagline,'_optimal_prices.csv'));
if mac==1
    table_pre= 'tables/';
else
    table_pre= 'tables\';  
end


%%% AVERAGE

price_normal = csvread(strcat(cd_dir,table_pre,tagline,'_avg_optimal_prices_tpt3_groups.csv'));
price_low    = csvread(strcat(cd_dir,table_pre,tagline,'_low_optimal_prices_tpt3_groups.csv'));


 [~,TU,~,NET_REV,~,~,gamma] =smm_shell_counterfactual_v3(  price_normal(2), [price_normal(1) price_normal(3)], alternative_parameters,...
                                        input1sub,input2sub,input3sub,...
                                        errors1sub,errors2sub,errors3sub,...
                                            SIG_EP_INPUTS,reps,sto,...
                                            sort_condition,split_F_option,transfer_option,smm_est_option,...
                                            COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub);
   NET_REV


[RES_tpt3_0,NR] = produce_results( [price_normal(1) price_normal(3)] ,price_normal(2),alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,groups)
                                
                                
[RES_tpt3_1,NR] = produce_results( [price_low(1) price_low(3)] ,price_low(2),alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,groups)
                                


 %%% GENERATE TABLE HERE !                               
                                

 %%% RES_first RES_current RES_tpt0 RES_tpt1 RES_tpt3_0 RES_tpt3_1
 
 % FEE
 % Vendor
 % Sharing
 % Surplus: Average
 % Surplus: Low

                                
if mac==1
    slash = '/';
else
    slash = '\';
end


RES_MATRIX = [RES_first_best, RES_current, RES_tpt0, RES_tpt1 RES_tpt3_0 RES_tpt3_1];

dlmwrite(strcat(cd_dir,'tables',slash,'RES_',tagline,'_group.csv'),RES_MATRIX,'delimiter',',','precision',20);


% MEAN_INC=mean(mean([input1s(:,13) input2s(:,13) input3s(:,13)])) ;
MEAN_INC =  csvread(strcat(cd_dir,table_pre,'mean_inc_descriptive.csv'));


dlmwrite(strcat(cd_dir,'tables',slash,'mean_inc_group.csv'),MEAN_INC,'delimiter',',','precision',20);



%{a


avg_tariff = (0 + 20 + 30 + 40)/4;
mc = 5;
tpt0_p1=tpt0(2);
tpt1_p1=tpt1(2);

tpt3_0_p1 = mean(price_normal(2:3));
tpt3_1_p1 = mean(price_low(2:3));

if isempty(PH_COUNTER)==1
    fileID = fopen(strcat(cd_out,'tables',slash,'welfare_sharing_groups.tex'),'w');
else
    fileID = fopen(strcat(cd_out,'tables',slash,'welfare_no_sharing_groups.tex'),'w');    
end

fprintf(fileID,'%s\n','\begin{tabular}{lcccccc}');
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','  & First-Best & Current & 2-Part  & 2-Part Social  & 3-Part & 3-Part Social \\');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');

[~] = table_print_welfare('Fixed Fee (PhP/month) &',1, '%5.0f',0,fileID ,RES_first_best, RES_current, RES_tpt0, RES_tpt1, RES_tpt3_0, RES_tpt3_1);
[~] = table_print_welfare('Avg. Tariff (PhP/m3) &',1, '%5.1f',0,fileID ,mc, avg_tariff, tpt0_p1 , tpt1_p1, tpt3_0_p1, tpt3_1_p1);
[~] = table_print_welfare('Source Vendor &',2, '%5.0f',1,fileID ,RES_first_best, RES_current, RES_tpt0, RES_tpt1, RES_tpt3_0, RES_tpt3_1);
[~] = table_print_welfare('Source Neighbor &',3, '%5.0f',1,fileID ,RES_first_best, RES_current, RES_tpt0, RES_tpt1, RES_tpt3_0, RES_tpt3_1);
[~] = table_print_welfare('Surplus &',4, '%5.1f',0,fileID ,RES_first_best, RES_current, RES_tpt0, RES_tpt1, RES_tpt3_0, RES_tpt3_1);
[~] = table_print_welfare('Surplus: Low Users &',5, '%5.1f',0,fileID ,RES_first_best, RES_current, RES_tpt0, RES_tpt1, RES_tpt3_0, RES_tpt3_1);

[~] = table_print_welfare('Consumption (m3/month) &',6, '%5.1f',0,fileID ,RES_first_best, RES_current, RES_tpt0, RES_tpt1, RES_tpt3_0, RES_tpt3_1);
%%%[~] = table_print_welfare('Cons.: Low Users (m3/month) &',7, '%5.1f',0,fileID ,RES_first_best, RES_current, RES_tpt0, RES_tpt1, RES_tpt3_0, RES_tpt3_1);


fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\end{tabular}'); 
fclose(fileID);
%}

end

         
    