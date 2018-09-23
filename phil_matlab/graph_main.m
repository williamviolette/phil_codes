%{
function h = graph_main(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_size,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,boot_max,boot_estimates,alt_sample,...
                    PH_COUNTER,group_percentile,COST_INPUTS,c_dir)
%}

%%% OLD NAME: graph_time_v4_groups.m


%%%%%% KEY : SET PH_COUNTER = ?


h =1;

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

%%%%%%%%%%%%%%% SETTINGS FROM SIM PRINT ! %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% SETTINGS FROM SIM PRINT ! %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% SETTINGS FROM SIM PRINT ! %%%%%%%%%%%%%%%

%%% TEMP SET !!
group_percentile = 50;

                sub_sample = .05   ;

                groups     = [  group_percentile  group_percentile  ];
                sort_condition=0;
                split_F_condition=0;
                transfer_option=1;
            
    capital_real = 0;
    PH_COUNTER   = []  ;   
    income_opt   = 0   ;

    
        TRIALS = 50  + 1;            
if isempty(PH_COUNTER)~=1
    if income_opt==0
        F_MIN = 0;
        F_MAX = 1200;
        start_value = [  5 15  ] ;
    else
        F_MIN=0;
        F_MAX=1200; 
        start_value = [  5 15  ] ;        
    end
else
    if income_opt==0
        F_MIN=0;
        F_MAX=1100;
        start_value = [ 0 2 5 15 ];
    else
        F_MIN=100;
        F_MAX=1100;
        start_value = [ 5 15 ];
    end
end


F_GRID = ((0:TRIALS-1)'./(TRIALS)).*(F_MAX-F_MIN) + F_MIN;

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

%%% NO PH_COUNTER FOR CAPITAL

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
           
%figure1=figure;

tic
    [solutions1, choices1, mean_utility1, F_MAX1, SOL_MAX1, sharing1, US_TOTAL] = graph_maker_full_V3(F_GRID,TRIALS,groups,...
                        alternative_parameters,...
                                        input1sub,input2sub,input3sub,...
                                        errors1sub,errors2sub,errors3sub,...
                                        SIG_EP_INPUTS,reps,sto,...
                                        sort_condition,split_F_option,transfer_option,smm_est_option,...
                                        COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,start_value,income_opt);
toc             
                                                                
F_MAX1
SOL_MAX1         
mean(mean_utility1)

if isempty(PH_COUNTER)~=1
    tagline='high_ph';
else
    tagline='normal';
end


dlmwrite(strcat(cd_dir,table_pre,tagline,'_optimal_prices_groups.csv'),[F_MAX1 SOL_MAX1],'delimiter',',','precision',15)




%{a
RESULTS_MATRIX = [  F_GRID ...
                    solutions1 ...
                    choices1 ... 
                    sharing1 ...
                    mean_utility1 ...
                    F_MAX1(1).*ones(length(solutions1),1) ...
                    F_MAX1(2).*ones(length(solutions1),1) ...
                    F_MAX1(3).*ones(length(solutions1),1) ...
                    SOL_MAX1(1).*ones(length(solutions1),size(F_MAX1,1)) ...
                    SOL_MAX1(2).*ones(length(solutions1),size(F_MAX1,1)) ...
                    SOL_MAX1(3).*ones(length(solutions1),size(F_MAX1,1)) ...
                    ];

 csvwrite(strcat(cd_dir,table_pre,tagline,'_1_groups.csv'),RESULTS_MATRIX);


mean_utility1(solutions1==SOL_MAX1(2),:)-mean_utility1(solutions1==SOL_MAX1(3),:)
mean_utility1(solutions1==SOL_MAX1(1),:)-mean_utility1(solutions1==SOL_MAX1(3),:)
mean_utility1(solutions1==SOL_MAX1(1),:)-mean_utility1(solutions1==SOL_MAX1(2),:)
%}




