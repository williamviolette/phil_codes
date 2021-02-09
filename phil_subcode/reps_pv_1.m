

loc = '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp/';
cd_out = '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes/phil_paper/tables/';

 

M   = csvread(strcat(loc,'mat_counter.csv'),1);
% NRW = csvread(strcat(loc,'mat_counter_nrw.csv'),1);
NRW = 188.*ones(size(M,1),1);
CSt = M(:,1) + M(:,2);
PSt = M(:,3) + NRW;
TLt = M(:,4);
Wm  = M(:,5);
We  = M(:,6);
ee  = M(:,7);
Wbar=.2;

MC = csvread(strcat(loc,'mat_counter_comm.csv'),1);
PSc = MC(:,1).*MC(:,2);

PSt=PSc+PSt;


% CSe BSe Ae CPe 

%%% simulate every 30!


beta_up = .05/12;
beta = 1/( 1 + beta_up );

N = 500;

A = repmat((0:N)',1,N+1)';
Aprime = A';
nA = size(A,1);

pipe_age  =  25*12;
% 28

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

[h,v,v_PS,v_CS] = sim_reps_va(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(1) )
h
v(1,1)/1000
v_PS(1,1)/1000
v_CS(1,1)/1000

%%%% FULL WELFARE %%%%

welfare=1;

results = zeros(size(CSt,1),6);
results_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt,v_PSm,v_CSm]=sim_reps_va(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(i) );
    results(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) v_PSm(1) v_CSm(1) ];
    results_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
    
end

[results(:,1)  results(:,2:4)/1000]


%%%% QUAL LIMIT TEST %%%%

welfare=2;

wbar=.2;
t=5000;
wm=0;
we=-.17;

[h,v,v_PS,v_CS] = sim_reps_va(welfare,Q0_PS,Q0_CS,pipe_age,total_loan,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(1) );

%%%% FULL QUAL LIMIT %%%%

results_qual = zeros(size(CSt,1),6);
results_qual_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt,v_PSm,v_CSm]=sim_reps_va(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,  Wm(i)  ,  We(i)  ,wbar,t,  NRW(i)  );
    results_qual(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) v_PSm(1) v_CSm(1) ];
    results_qual_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
    
end

results_qual(:,1)

[ results(:,2) results_qual(:,2)]./1000

wbar=.1;

results_high_qual = zeros(size(CSt,1),6);
results_high_qual_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    
    [ht,vt,v_PSt,v_CSt,v_PSm,v_CSm]=sim_reps_va(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,  Wm(i)  ,  We(i)  ,wbar,t, NRW(i) );
    results_high_qual(i,:) = [ht vt(1) v_PSt(1) v_CSt(1)  v_PSm(1) v_CSm(1) ];
    results_high_qual_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
    
end

results_high_qual(:,1)



%%%% PRODUCER SURPLUS %%%%

welfare=3;

results_prod = zeros(size(CSt,1),6);
results_prod_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt,v_PSm,v_CSm]=sim_reps_va(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(i) );
    results_prod(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) v_PSm(1) v_CSm(1)];
    results_prod_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
end

% [results(:,1)  results(:,2:4)/1000]



%%% PIPEAGE %%%%

welfare=4;

results_age = zeros(size(CSt,1),6);
results_age_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt,v_PSm,v_CSm]=sim_reps_va(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t ,NRW(i) );
    results_age(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) v_PSm(1) v_CSm(1) ];
    results_age_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
end


%%%% NRW %%%%

welfare=5;

results_nrw = zeros(size(CSt,1),6);
results_nrw_alt = zeros(size(CSt,1),4);

for i=1:size(CSt,1)
    [ht,vt,v_PSt,v_CSt,v_PSm,v_CSm]=sim_reps_va(welfare,  PSt(i)  ,  CSt(i)  ,  pipe_age,  TLt(i)  ,r,loan_term,nA,Aprime,A,beta,wm,we,wbar,t, NRW(i) );
    results_nrw(i,:) = [ht vt(1) v_PSt(1) v_CSt(1) v_PSm(1) v_CSm(1)];
    results_nrw_alt(i,:) = [ht vt(alt) v_PSt(alt) v_CSt(alt) ];
end


ee9 = [ee(1:8); ee(10:11)];
ee9 = ee9./sum(ee9);


h1 = round([results(:,1) results_age(:,1) results_high_qual(:,1) results_qual(:,1) results_nrw(:,1) results_prod(:,1)  ]./12,0)

vf1=round([ (results(:,5)+results(:,6)) ...
    (results_age(:,5)+results_age(:,6)) ...
    (results_high_qual(:,5)+results_high_qual(:,6)) ...
    (results_qual(:,5)+results_qual(:,6)) ...
    (results_nrw(:,5)+results_nrw(:,6)) ...
    (results_prod(:,5)+results_prod(:,6)) ... 
    ],0);

vf1

vf1(:,2:end) - vf1(:,1)
h1

h1m = round(sum(h1.*ee),0)
h1m9= round(sum([h1(1:8,:); h1(10:11,:)].*ee9),0)


v1=round([ (results(:,5)+results(:,6)) ...
    (results_age(:,5)+results_age(:,6)) ...
    (results_high_qual(:,5)+results_high_qual(:,6)) ...
    (results_qual(:,5)+results_qual(:,6)) ...
    (results_nrw(:,5)+results_nrw(:,6)) ...
    (results_prod(:,5)+results_prod(:,6)) ... 
    ],0)

v1 = v1(:,2:end) -v1(:,1)
v1m= round(sum(v1.*ee),0)
v1m9= round(sum([v1(1:8,:); v1(10:11,:)].*ee9),0)


c1=round([ results(:,6) ...
    results_age(:,6) ...
    results_high_qual(:,6) ...
    results_qual(:,6) ...
    results_nrw(:,6) ...
    results_prod(:,6) ... 
    ],0)

c1 = c1(:,2:end) -c1(:,1)
c1m= round(sum(c1.*ee),0)
c1m9= round(sum([c1(1:8,:); c1(10:11,:)].*ee9),0)




%%% INPUT SAMPLE SIZE
    fileID = fopen(strcat(cd_out,'counter_results.tex'),'w');
    for i = 1:size(v1,1)
        
        fprintf(fileID,'%s', num2str(i,'%20.0f'));
        
        for l = 1:size(h1,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(h1(i,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.2em]' );
        
        fprintf(fileID,'%s', ' & ');
        for l = 1:size(v1,2)
            fprintf(fileID,'%s', ...
                    strcat(' & [',num2str(v1(i,l),'%20.0f'),',',num2str(c1(i,l),'%20.0f'),']'));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );
        
    end
%     fprintf(fileID,'%s\n',' \\[.5em]' );
    fclose(fileID);

    
        fileID = fopen(strcat(cd_out,'counter_results_one_line.tex'),'w');
    for i = 1:size(v1,1)
        
        fprintf(fileID,'%s', num2str(i,'%20.0f'));
        
            fprintf(fileID,'%s', ...
                    strcat(' & (',num2str(h1(i,1),'%20.0f'),' ,---,---) '));

        for l = 1:size(v1,2)
            fprintf(fileID,'%s', ...
                    strcat(' & (',num2str(h1(i,l+1),'%20.0f'),',',num2str(v1(i,l),'%20.0f'),',',num2str(c1(i,l),'%20.0f'),' )'));
        end
        
        fprintf(fileID,'%s\n',' \\[.2em]' );
    end
%     fprintf(fileID,'%s\n',' \\[.5em]' );
    fclose(fileID);

    
    
    fileID = fopen(strcat(cd_out,'counter_results_mean.tex'),'w');
    fprintf(fileID,'%s', 'Mean' );
        
        for l = 1:size(h1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(h1m(1,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.2em]' );
        
        fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & [',num2str(v1m(1,l),'%20.0f'),',',num2str(c1m(1,l),'%20.0f'),']'));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );
        
    fclose(fileID);
    
%%%% COUNTER RESULTS KEY

    fileID = fopen(strcat(cd_out,'counter_results_key.tex'),'w');
    fprintf(fileID,'%s', 'Years' );
        
        for l = 1:size(h1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(h1m(1,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );
        
    fprintf(fileID,'%s', 'Total' );
        fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(v1m(1,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );    
        
    fprintf(fileID,'%s', 'Consumer' );    
    fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(c1m(1,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );   
    fclose(fileID);
    
    
%%%%% 9999 COunter results KEY
    
    fileID = fopen(strcat(cd_out,'counter_results_key9.tex'),'w');
    fprintf(fileID,'%s', 'Years' );
        
        for l = 1:size(h1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(h1m9(1,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );
        
    fprintf(fileID,'%s', 'Total' );
        fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(v1m9(1,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );    
        
    fprintf(fileID,'%s', 'Consumer' );    
    fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(c1m9(1,l),'%20.0f')));
        end
        fprintf(fileID,'%s\n',' \\[.5em]' );   
    fclose(fileID);
    
    
    
    
    
    
%%%% COUNTER RESULTS KEY

    fileID = fopen(strcat(cd_out,'cr_y.tex'),'w');
        for l = 1:size(h1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(h1m(1,l),'%20.0f')));
        end
    fclose(fileID);
    
    fileID = fopen(strcat(cd_out,'cr_t.tex'),'w');
        fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(v1m(1,l),'%20.0f')));
        end    
    fclose(fileID);
    
    fileID = fopen(strcat(cd_out,'cr_c.tex'),'w');
        fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(c1m(1,l),'%20.0f')));
        end    
    fclose(fileID);
    
    
    
%%%%% 9999 COunter results KEY
    
    fileID = fopen(strcat(cd_out,'cr_y9.tex'),'w');
        for l = 1:size(h1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(h1m9(1,l),'%20.0f')));
        end
    fclose(fileID);
    
    fileID = fopen(strcat(cd_out,'cr_t9.tex'),'w');
        fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(v1m9(1,l),'%20.0f')));
        end    
    fclose(fileID);
    
    fileID = fopen(strcat(cd_out,'cr_c9.tex'),'w');
        fprintf(fileID,'%s', ' & --- ');
        for l = 1:size(v1m,2)
            fprintf(fileID,'%s', ...
                    strcat(' & ',num2str(c1m9(1,l),'%20.0f')));
        end    
    fclose(fileID);
    
    
    
% (r1(2:end) - r1(1))
% 
% r1alt(2:end) - r1alt(1)


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