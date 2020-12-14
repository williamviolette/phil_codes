

loc = '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/';

M = csvread(strcat(loc,'mat_counter.csv'),1);
CSt = M(:,1)+M(:,2);
PSt = M(:,3)+74;
TLt = M(:,4);
% CSe BSe Ae CPe 

%%% simulate every 30!


beta_up = .04/12;
beta = 1/( 1 + beta_up );

N = 500;

A = repmat((0:N)',1,N+1)';
Aprime = A';
nA = size(A,1);

pipe_age  =  28*12;

loan_term = 8;
r = .05/12;

Q0_CS = 161 ;
Q0_PS = 131 ;
total_loan = 17021;

[h,v,v_PS,v_CS]=sim_reps(Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta);

h
v(1,1)/1000
v_PS(1,1)/1000
v_CS(1,1)/1000

results = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt]=sim_reps(  PSt(i)  ,  CSt(i)  ,pipe_age,  TLt(i) ,r,loan_term,nA,Aprime,A,beta);
    results(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    
end

[results(:,1) results(:,2:4)/1000]


% [h]=sim_reps(Q0,Q1,F,Aprime,A,loan_term,beta);



% pay=0;
% for i=0:loan_term*12-1
%     pay = pay + surplus_rec - slope_rec*i;
% end
% pay = pay/(loan_term*12);





% 
% decis=(decis-1)*inA + minA; %%% try to understand this better...
% 
% Amark = size(Agrid,1);
% Athis = Agrid(Amark,1);        % initial level of assets        
% states   = zeros(n-1,2);
% controls = zeros(n-1,2);
% for i = 1:n-1
%     Aprime = decis(Amark,chain(i));
%     Amark  = tdecis(Amark,chain(i));
%     
%     [~,~,~,~,cons1,cons2,cons3,cons4] = ...
%     u_w1loan3(Athis,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);
%     
%     cons_full = [cons1 cons2 cons3 cons4];
%     cons = cons_full(chain(i));
%     
%     states(i,:) = [ Athis chain(i) ];
%     controls(i,:) = [ cons Aprime ];
%     Athis = Aprime;
% end
% 
% 
% w_debt_max = p.*controls(:,1);
% w_debt = ( controls(:,2).*(controls(:,2)>w_debt_max) + ...
%             w_debt_max.*(controls(:,2)<=w_debt_max) ).* ...
%             (controls(:,2)<0).*(states(:,2)<=2);  %%% only measured when no default (and when negative) (otherwise zero)
% 
%         
% %SAV = controls(:,2);
% C = controls(:,1);
% C1 = [1;1;1;1;1;1;1;1;1];
% %S1 = [1;1;1;1;1;1;1;1;1];
% for i=6:size(states,1)-6
%    if states(i,2)>=3 && controls(i,2)<0
%       C1=[C1 C(i-4:i+4,1)]; 
%       %S1=[S1 SAV(i-4:i+4,1)]; 
%    end 
% end
% 
% %avg_debt = mean( controls(:,2) < 0 );
% 
% CM=mean(C1(:,2:end),2);
% 
% % C_def = C(states(:,2)>=3);
% % mean(C_def); std(C_def);
% 
% 
% h = [mean(mean(C)); std(C);  mean(w_debt);  std(w_debt); corr(w_debt,C);  CM ];

