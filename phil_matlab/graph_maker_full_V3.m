function [solutions1, choices1, mean_utility1, F_MAX1, SOL_MAX1, sharing1, US_TOTAL] = graph_maker_full_V3(F_GRID,TRIALS,groups,...
                    alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub,start_value,income_opt)

          %     F_GRID=500;
            %    TRIALS=1;
            
    SL=3;

solutions1=zeros(TRIALS,1);
choices1=zeros(TRIALS,SL); 
mean_utility1=zeros(TRIALS,SL);
sharing1=zeros(TRIALS,SL);
US_TOTAL=zeros(TRIALS,1);

for r=1:TRIALS
 
%{
    r=1
    F_GRID = -100
%}
    
    given_p = F_GRID(r);
    obj=@ (a_start)  smm_shell_counterfactual_v3(  a_start, given_p, alternative_parameters,...
                                    input1sub,input2sub,input3sub,...
                                    errors1sub,errors2sub,errors3sub,...
                                    SIG_EP_INPUTS,reps,sto,...
                                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                                    COST_PARAMETERS,PH_COUNTER,TUNE,alt_errorsub);


 %{
                                                    
psol_temp = fminsearch(obj,40)
obj(psol_temp)
a_low=0;
a_high=50;
V=10;
av=((1:V)'./V).*(a_high-a_low) + a_low;
OBJ=ones(V,1);
for vv = 1:V
     ot=obj(av(vv,1));
     OBJ(vv,1)=ot;
end
plot(av,OBJ)
          
%}                               
                                
                                
%tic
%threshold=.0001;
%start_value = [-30 -20 -10 0 5 10 20 30 ];
%start_value = [ 5 15 ];
PS          = zeros(length(start_value),1);
US          = zeros(length(start_value),1);

        for j = 1:length(start_value)
            psol_temp = fminsearch(obj,start_value(j));
            %[OBJ_test,U_temp] = obj(psol_temp);
            [OBJ_test,U_temp]=obj(psol_temp);
            PS(j) = psol_temp;
            valid = (OBJ_test<10 & OBJ_test>=0);
            U_temp = (U_temp).*valid + -100000.*(1-valid);
            US(j) = mean(mean(U_temp));
        end

 [UM,u_max] = max(US);
 p_sol     = PS(u_max);

 US_TOTAL(r,1)=UM;
    solutions1(r,1)=p_sol;
        [~,TU,~,~,~,~,gamma,incomes,C]=obj(p_sol);

        if income_opt==1
            gamma=incomes;
        end
        
            g_id1 = gamma<=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),groups(1));
            g_id2 = gamma>=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),groups(2));

            choices1(r,:)= [mean(mean(C==3)) ...
                mean(mean(C(g_id1==1)==3)) ...
                mean(mean(C(g_id2==1)==3)) ...
                ];

            mean_utility1(r,:)=[mean(mean(TU)) ...
                mean(mean(TU(g_id1==1))) ...
                mean(mean(TU(g_id2==1))) ...
                ] ;
%{
               mean_utility2(r,:)=[mean(mean(TU)) ...
                mean(mean(TU(g_id1==1))) ...
                mean(mean(TU(g_id2==1))) ...
                ] ;
            
            g_id11 = gamma<=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),20);
            g_id21 = gamma>=prctile(reshape(gamma,size(gamma,1)*size(gamma,2),1),80);
               mean_utility3(r,:)=[mean(mean(TU)) ...
                mean(mean(TU(g_id11==1))) ...
                mean(mean(TU(g_id21==1))) ...
                ] 
%}            
                sharing1(r,:)= [mean(mean(C==2)) ...
                mean(mean(C(g_id1==1)==2)) ...
                mean(mean(C(g_id2==1)==2)) ...
                ];

end


%{
                subplot(1,2,1)
          hold on 
     plot(F_GRID,  (mean_utility1(:,2)-mean_utility1(1,2)),'LineWidth',2,'Color','red','DisplayName','Low');
     plot(F_GRID,  (mean_utility1(:,3)-mean_utility1(1,3)),'LineWidth',2,'Color','blue','DisplayName','High');
     yyaxis right
      plot(F_GRID,   solutions1,'LineWidth',2,'DisplayName','Price');
     legend('show')
     hold off
 
vline(F_GRID(mean_utility1(:,2)==max(mean_utility1(:,2)),1),'black','1')
vline(F_GRID(mean_utility1(:,3)==max(mean_utility1(:,3)),1),'black','2')


                 subplot(1,2,2)
            hold on
             plot(F_GRID,  (choices1(:,2)),'LineWidth',2,'Color','red','DisplayName','Low I');
             plot(F_GRID,  (choices1(:,3)),'LineWidth',2,'Color','blue','DisplayName','High I');
             plot(F_GRID,  (sharing1(:,2)),'LineWidth',2,'Color','magenta','LineStyle','--','DisplayName','Low S');
             plot(F_GRID,  (sharing1(:,3)),'LineWidth',2,'Color','black','LineStyle','--','DisplayName','High S');
             %legend('Low I','High I','Low S','High S')      
             legend('show')
            hold off

            vline(F_GRID(mean_utility1(:,2)==max(mean_utility1(:,2)),1),'black','1')
            vline(F_GRID(mean_utility1(:,3)==max(mean_utility1(:,3)),1),'black','2')
                    
 %}            
            
F_MAX1=[F_GRID(mean_utility1(:,1)==max(mean_utility1(:,1)),1) ...
       F_GRID(mean_utility1(:,2)==max(mean_utility1(:,2)),1) ...
       F_GRID(mean_utility1(:,3)==max(mean_utility1(:,3)),1) ...
        ];
    
    
SOL_MAX1=[solutions1(mean_utility1(:,1)==max(mean_utility1(:,1)),1) ...
       solutions1(mean_utility1(:,2)==max(mean_utility1(:,2)),1) ...
       solutions1(mean_utility1(:,3)==max(mean_utility1(:,3)),1) ...
        ];   


 
 
 
 
 
 
 
 
 
 
 

