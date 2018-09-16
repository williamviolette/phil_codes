%{
function h = graph_time_v4_group_comparison_graph(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_size,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,boot_max,boot_estimates,alt_sample,...
                    PH_COUNTER,group_percentile,COST_INPUTS,cd_dir)
%}


 %PH_SET = [  4  8 12 16 20  ];
 
 
 PH_SET  =  (1:1:40)  ;
  
for j = 1:size(PH_SET,2)       
    
 PH_COUNTER   = PH_SET(j)  ; 

% PH_COUNTER=[1]
h       = 1;
est_opt = 0;
BOOT    = [];

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
    table_pre= 'tables/tariff_graph/';
else
    table_pre= 'tables\tariff_graph\';  
end



%%%%%%%%%%%%%%% SETTINGS FROM SIM PRINT ! %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% SETTINGS FROM SIM PRINT ! %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% SETTINGS FROM SIM PRINT ! %%%%%%%%%%%%%%%

%%% TEMP SET !!
group_percentile = 50;

            %    sub_sample = .02   ;
    sub_sample = .05   ;

                groups     = [  group_percentile  group_percentile  ];
                sort_condition=0;
                split_F_condition=0;
                transfer_option=1;
            
    TRIALS = 1 + 200;            

            F_MIN = 10;
            F_MAX = 400;
            start_value = [ 0 15 20 30 40 ] ;


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

 
        %PH_COUNTER = [];
        MARGINAL_COST   = COST_INPUTS(1);
        CONNECTION_COST = COST_INPUTS(2);
        GIVEN_P = [  CONNECTION_COST 0  ]; % payment is equal to cost!
        alternative_parameters =  x1(2:end)' ;
    
    

    
   % PH_COUNTER = [3];
     
   % PH_COUNTER = [16];
   % PH_COUNTER=[15];
    income_opt   = 0   ;    

    
    PH_TEMP = 16;

    [~,~,~,~,CAPITAL]   = smm_shell_counterfactual_v3(  0 ,GIVEN_P, alternative_parameters,...
                                        input1sub,input2sub,input3sub,...
                                        errors1sub,errors2sub,errors3sub,...
                                        SIG_EP_INPUTS,reps,sto,...
                                        sort_condition,split_F_option,transfer_option,smm_est_option,...
                                        [   MARGINAL_COST          CONNECTION_COST  (x1(1)-CONNECTION_COST)   ],PH_TEMP,TUNE,alt_errorsub);

    COST_PARAMETERS   = [   MARGINAL_COST  CONNECTION_COST  (x1(1)-CONNECTION_COST)  CAPITAL  ];

    tic
        [solutions1, choices1, mean_utility1, F_MAX1, SOL_MAX1, sharing1, US_TOTAL] = graph_maker_full_V3_comparison(F_GRID,TRIALS,groups,...
                            alternative_parameters,   input1sub,input2sub,input3sub, errors1sub,errors2sub,errors3sub, SIG_EP_INPUTS,reps,sto,sort_condition,split_F_option,transfer_option,smm_est_option,...
                                            COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,start_value,income_opt);
    toc             

    F_MAX1
    SOL_MAX1        
    mean(choices1)
    mean(sharing1)
    mean(mean_utility1)
    
    RESULTS_MATRIX = [  F_GRID  solutions1    choices1     sharing1   mean_utility1 ...
                    F_MAX1(1).*ones(length(solutions1),1)   F_MAX1(2).*ones(length(solutions1),1)     F_MAX1(3).*ones(length(solutions1),1) ...
                    SOL_MAX1(1).*ones(length(solutions1),size(F_MAX1,1))   SOL_MAX1(2).*ones(length(solutions1),size(F_MAX1,1))  SOL_MAX1(3).*ones(length(solutions1),size(F_MAX1,1))   ];

  dlmwrite(strcat(cd_dir,table_pre,'tpt_graph_',num2str(j),'.csv'),RESULTS_MATRIX,'delimiter',',','precision',15);
%   dlmwrite(strcat(cd_dir,table_pre,'tpt_graph_PHTEMP_',num2str(j),'.csv'),RESULTS_MATRIX,'delimiter',',','precision',15);

end




plot(F_GRID(:,1),solutions1)

plot(F_GRID((mean_utility1(:,1)>0),1),mean_utility1(mean_utility1(:,1)>0,1))

plot(F_GRID((mean_utility1(:,1)>0),1),choices1(mean_utility1(:,1)>0,1))

plot(F_GRID((mean_utility1(:,1)>0),1),sharing1(mean_utility1(:,1)>0,1))



plot(F_GRID((mean_utility1(:,1)>0),1),mean_utility1(mean_utility1(:,1)>0,2))


plot(F_GRID(:,1),mean_utility1(:,1)./max(mean_utility1(:,1)),...
     F_GRID(:,1),mean_utility1(:,2)./max(mean_utility1(:,2)),...
     F_GRID(:,1),mean_utility1(:,3)./max(mean_utility1(:,3))...
    )



PEQ=zeros(length(PH_SET),1);
FEQ=zeros(length(PH_SET),1);
SHR=zeros(length(PH_SET),1);
CON=zeros(length(PH_SET),1);

for lp=1:length(PH_SET)
    
    x_temp=csvread(strcat(cd_dir,table_pre,'tpt_graph_',num2str(lp),'.csv'));
 
 %   x_temp=csvread(strcat(cd_dir,table_pre,'tpt_graph_PHTEMP_',num2str(lp),'.csv'));   
    PEQ(lp,1)=x_temp(1,15);
    FEQ(lp,1)=x_temp(1,12);
    CON(lp,1)=mean(x_temp(:,3));
    SHR(lp,1)=mean(x_temp(:,6));
end



plot( PH_SET , PEQ./max(PEQ), ...
      PH_SET,SHR./max(SHR),  ...
      PH_SET,CON./max(CON),  ...
      PH_SET,FEQ./max(FEQ) )



dlmwrite(strcat(cd_dir,table_pre,'tpt_graph_full.csv'),[PH_SET' PEQ FEQ CON SHR],'delimiter',',','precision',15);


%plot(F_GRID(:,1),mean_utility1(:,2))
%plot(F_GRID(:,1),mean_utility1(:,3))



%plot((1:size(solutions1)),mean_utility1(:,3))











%if isempty(PH_COUNTER)~=1
%    tagline='high_ph';
%else
%    tagline='normal';
%end


%dlmwrite(strcat(cd_dir,table_pre,tagline,'_optimal_prices_groups.csv'),[F_MAX1 SOL_MAX1],'delimiter',',','precision',15)




%{
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


