

loc = '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/';

M = csvread(strcat(loc,'mat_counter.csv'),1);
CSt = M(:,1) + M(:,2);
PSt = M(:,3) + 74;
TLt = M(:,4);
Wm  = M(:,5);
We  = M(:,6);
Wbar=.2;

% CSe BSe Ae CPe 

%%% simulate every 30!


beta_up = .04/12;
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

%%% TEST FULL WELFARE
welfare=1;

[h,v,v_PS,v_CS] = sim_reps(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t)
h
v(1,1)/1000
v_PS(1,1)/1000
v_CS(1,1)/1000

%%%% FULL WELFARE %%%%

welfare=1;

results = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt]=sim_reps(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t);
    results(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    
end

[results(:,1)  results(:,2:4)/1000]


%%%% QUAL LIMIT TEST %%%%

welfare=2;

wbar=.2;
t=5000;
wm=0;
we=-.17;

[h,v,v_PS,v_CS] = sim_reps(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t);


%%%% FULL QUAL LIMIT %%%%

results_qual = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt]=sim_reps(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,  Wm(i)  ,  We(i)  ,wbar,t);
    results_qual(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    
end

results_qual(:,1)

[ results(:,2) results_qual(:,2)]./1000


wbar=.1;

results_high_qual = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt]=sim_reps(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,  Wm(i)  ,  We(i)  ,wbar,t);
    results_high_qual(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
    
end

results_high_qual(:,1)



%%%% PRODUCER SURPLUS %%%%

welfare=3;

results_prod = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt]=sim_reps(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t);
    results_prod(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
end

% [results(:,1)  results(:,2:4)/1000]



%%%% PIPEAGE %%%%

welfare=4;

results_age = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt]=sim_reps(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t);
    results_age(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) ];
end



round([ results(:,1) results_high_qual(:,1) results_qual(:,1) results_prod(:,1) results_age(:,1) ]/12,1)


round([ results(:,2) results_high_qual(:,2) results_qual(:,2) (results_prod(:,3)+results_prod(:,4)) results_age(:,2) ]./1000,1)


round(mean([ results(1:9,2) results_high_qual(1:9,2) results_qual(1:9,2) (results_prod(1:9,3)+results_prod(1:9,4)) results_age(1:9,2) ])./1000,1)

