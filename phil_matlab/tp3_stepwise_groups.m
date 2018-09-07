function h = tp3_stepwise_groups(a, stepsize, iterations, alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub, groups,mac,tagline, LOW,cd_dir)

                                
                                
                       
%{
LOW      = 1; 
a        = tpt1;
LOW      = 0;
a       =  tpt0;
%a = [1050 2];                                    
stepsize = [2 .5];
iterations   =  3;
%}

                                    
compression  = .95;

%%% OUTPUTS : TU and PRICES
Z   = iterations ;
NR  = zeros(Z,4);
US  = zeros(Z,4);
FEE = zeros(Z,4);
P1  = zeros(Z,4);
P2  = zeros(Z,4);
GAP = zeros(Z,1);
U_MAX = zeros(Z,1);
NEW_STORE    = zeros(Z,3);
MAX_ID_STORE = zeros(Z,1);

    for z=1:Z
        if z==1
                GIVEN_P_START = [ a + stepsize.*[1 1]; ...
                       a + stepsize.*[1 -1]; ...
                       a + stepsize.*[-1 1]; ...
                       a + stepsize.*[-1 -1] ];      
        else
                GIVEN_P_START = [ NEW + stepsize_NEW.*[1 1]; ...
                       NEW + stepsize_NEW.*[1 -1]; ...
                       NEW + stepsize_NEW.*[-1 1]; ...
                       NEW + stepsize_NEW.*[-1 -1] ];  
        end

        for r = 1:size(GIVEN_P_START,1)

                   GIVEN_P1 = GIVEN_P_START(r,:);

                           obj =@(a1)  smm_shell_counterfactual_v3(  a1, GIVEN_P1, alternative_parameters,...
                                        input1sub,input2sub,input3sub,...
                                        errors1sub,errors2sub,errors3sub,...
                                            SIG_EP_INPUTS,reps,sto,...
                                            sort_condition,split_F_option,transfer_option,smm_est_option,...
                                            COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub);

                    a_start = GIVEN_P_START(r,2);
                    p_sol   = fminsearch(obj,a_start);
                    [~,TU,~,NET_REV,~,~,gamma] = obj(p_sol);
                    
                    %if NET_REV>1
                    %    a_start=a_start.*.9;
                    %     p_sol   = fminsearch(obj,a_start);
                    %    [~,TU,~,NET_REV,~,~,gamma] = obj(p_sol);  
                    %end

                if LOW==1
                    g_id1 = gamma<=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),groups(1));
                    U_OPT = sum(sum(TU(g_id1==1)))./(size(TU,1)*size(TU,2));
                else
                    U_OPT = sum(sum(TU))./(size(TU,1)*size(TU,2));
                end

                NR(z,r) = NET_REV;
                US(z,r) = U_OPT.*(NET_REV>=0) + -1.*(NET_REV<0);
                FEE(z,r) = GIVEN_P1(1);
                P1(z,r)  = p_sol;
                P2(z,r)  = GIVEN_P1(2);
        end

        %%% TAKE MAX
        [UM,max_id] = max(US(z,:));
        US_2 = US(z,:).*(US(z,:)~=max(US(z,:)));
        UM_2 = max(US_2); 
        NEW = [ FEE(z,max_id)  P2(z,max_id) ];

        GAP(z,1)=UM-UM_2; 

        if z==1
            stepsize_NEW=stepsize;
        else
            %if GAP(z,1)>GAP(z-1,1)
            %    stepsize_NEW = stepsize_NEW.*1.1;
            %else
                stepsize_NEW = stepsize_NEW.*compression;
            %end
        end
        MAX_ID_STORE(z,:)=max_id;
        NEW_STORE(z,:) = [ NEW(1) P1(z,max_id) NEW(2)];
        U_MAX(z,1)=UM;
    end
    
NR
FEE    
P1
P2
US

    
h = NEW_STORE(end,:)  
    

plot((1:Z)',U_MAX)

NSS = NEW_STORE(U_MAX==max(U_MAX),:);
NSS(1)
NSS(2)
NSS(3)
NR(U_MAX==max(U_MAX),:)



if mac==1
    table_pre= 'tables/';
else
    table_pre= 'tables\';  
end


if LOW==0
    dlmwrite(strcat(cd_dir,table_pre,tagline,'_avg_optimal_prices_tpt3_groups.csv'),...
                NEW_STORE(U_MAX==max(U_MAX),:),'delimiter',',','precision',15)
else
    dlmwrite(strcat(cd_dir,table_pre,tagline,'_low_optimal_prices_tpt3_groups.csv'),...
                NEW_STORE(U_MAX==max(U_MAX),:),'delimiter',',','precision',15)    
end


%[~,TU,~,NR1,~,~,gamma] = smm_shell_counterfactual_v3( NSS(2) , [NSS(1) NSS(3)], alternative_parameters,...
 %                                       input1sub,input2sub,input3sub,...
  %                                      errors1sub,errors2sub,errors3sub,...
   %                                         SIG_EP_INPUTS,reps,sto,...
    %                                        sort_condition,split_F_option,transfer_option,smm_est_option,...
     %                                       COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub);


 %%%  tt = [ 251.4829   10.9704   10.0906 ]
    

    