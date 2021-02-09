

loc = '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/';


 

M   = csvread(strcat(loc,'mat_counter.csv'),1);
% NRW = csvread(strcat(loc,'mat_counter_nrw.csv'),1);
NRW = 188.*ones(size(M,1),1);
CSt = M(:,1) + M(:,2);
PSt = M(:,3) + NRW;
TLt = M(:,4);
Wm  = M(:,5);
We  = M(:,6);
Wbar=.2;

MC = csvread(strcat(loc,'mat_counter_comm.csv'),1);
PSc = MC(:,1).*MC(:,2);

PSt=PSc+PSt;


% CSe BSe Ae CPe 

%%% simulate every 30!


beta_up = .03/12;
beta = 1/( 1 + beta_up );

N = 500;

A = repmat((0:N)',1,N+1)';
Aprime = A';
nA = size(A,1);

pipe_age  =  28*12;

loan_term = 5;
r = .05/12;

Q0_CS = 161 ;
Q0_PS = 131 ;
total_loan = 17021;

wbar=0;
t=0;
wm=0;
we=0;

alt = 10*12;

%%% TEST FULL WELFARE
welfare=1;

[h,v,v_PS,v_CS] = sim_reps_pa(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(1) )
h
v(1,1)/1000
v_PS(1,1)/1000
v_CS(1,1)/1000

%%%% FULL WELFARE %%%%

welfare=1;

results = zeros(size(CSt,1),4);
results_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt]=sim_reps_pa(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(i) );
    results(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    results_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
    
end

[results(:,1)  results(:,2:4)/1000]


%%%% QUAL LIMIT TEST %%%%

welfare=2;

wbar=.2;
t=5000;
wm=0;
we=-.17;

[h,v,v_PS,v_CS] = sim_reps_pa(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(1) );

%%%% FULL QUAL LIMIT %%%%

results_qual = zeros(size(CSt,1),4);
results_qual_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt]=sim_reps_pa(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,  Wm(i)  ,  We(i)  ,wbar,t,  NRW(i)  );
    results_qual(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    results_qual_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
    
end

results_qual(:,1)

[ results(:,2) results_qual(:,2)]./1000

wbar=.1;

results_high_qual = zeros(size(CSt,1),4);
results_high_qual_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt]=sim_reps_pa(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,  Wm(i)  ,  We(i)  ,wbar,t, NRW(i) );
    results_high_qual(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    results_high_qual_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
    
end

results_high_qual(:,1)



%%%% PRODUCER SURPLUS %%%%

welfare=3;

results_prod = zeros(size(CSt,1),4);
results_prod_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt]=sim_reps_pa(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(i) );
    results_prod(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    results_prod_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
end

% [results(:,1)  results(:,2:4)/1000]



%%%% PIPEAGE %%%%
% 
% welfare=4;
% 
% results_age = zeros(size(CSt,1),4);
% results_age_alt = zeros(size(CSt,1),4);
% 
% for i=1:size(CSt,1)
%     [ht,vt,v_PSt,v_CSt]=sim_reps_pa(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t ,NRW(i) );
%     results_age(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
%     results_age_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
% end


%%%% NRW %%%%

welfare=5;

results_age = zeros(size(CSt,1),4);
results_age_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt]=sim_reps_pa(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(i) );
    results_age(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    results_age_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
end



round([ results(:,1) results_high_qual(:,1) results_qual(:,1) results_prod(:,1) results_age(:,1) ]/12,1)


round([ results(:,2) results_high_qual(:,2) results_qual(:,2) (results_prod(:,3)+results_prod(:,4)) results_age(:,2) ]./1000,1)

set = [1 2 3 4 5 6 9 10 11];
round([ results(set,2) results_high_qual(set,2) results_qual(set,2) (results_prod(set,3)+results_prod(set,4)) results_age(set,2) ]./1000,1)


r1_cs=round(mean([ results(:,4) results_high_qual(:,4) results_qual(:,4) (results_prod(:,4)) results_age(:,4) ])./1000,1)
r1_cs(2:end)./r1_cs(1)

r1=round(mean([ results(:,2) results_high_qual(:,2) results_qual(:,2) (results_prod(:,3)+results_prod(:,4)) (results_age(:,3) + results_age(:,4))  ])./1000,1)

r2=round(mean([ results(set,2) results_high_qual(set,2) results_qual(set,2) (results_prod(set,3)+results_prod(set,4)) results_age(set,2) ])./1000,1)


% round([ results_alt(:,2) results_high_qual_alt(:,2) results_qual_alt(:,2) (results_prod_alt(:,3)+results_prod_alt(:,4)) results_age_alt(:,2) ]./1000,1)

% r1alt=round(mean([ results(:,2) results_high_qual(:,2) results_qual(:,2) (results_prod(:,3)+results_prod(:,4)) results_age(:,2) ])./1000,1)

r1alt=round(mean([ results_alt(:,2) results_high_qual_alt(:,2) results_qual_alt(:,2) (results_prod_alt(:,3)+results_prod_alt(:,4)) (results_age_alt(:,3)+results_age_alt(:,4)) ])./1000,1)

r1alt(2:end)./r1alt(1)


r1p=round(mean([ results(:,2) results_high_qual(:,2) results_qual(:,2) (results_prod(:,4)) (results_age(:,3) + results_age(:,4))  ])./1000,1)
r1p(2:end)./r1p(1)


r1alt

r1(2:end) - r1(1)

r1alt(2:end) - r1alt(1)


%%% non-zero
% ans =  -23.1000  -34.4000   -3.8000  -10.4000
% ans =  -29.2000  -45.1000   -4.7000  -13.6000
%%% with-zero (BASICALLY THE SAME!)
% ans =  -22.6000  -33.8000   -3.8000  -10.4000
% ans =  -28.7000  -44.6000   -4.7000  -13.6000



% r2(2:end) - r2(1)
% 
% 
% 
% r1(2:end)./r1(1)
% 
% r1cs=round(mean([ results(:,4) results_high_qual(:,4) results_qual(:,4) (results_prod(:,4)) (results_age(:,4))  ])./1000,1)
% r1cs(2:end)./r1cs(1)