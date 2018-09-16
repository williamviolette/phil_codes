function h=table_step_3_estimates...
    (est_version,tag,boot_max,mac,control_size,size_smp,alt_sample,COST_INPUTS,cd_out,cd_dir)



TOTAL_HH_POST = csvread(strcat(cd_dir,'results/post_sample_hhs.csv'));
TOTAL_HH_PRE  = csvread(strcat(cd_dir,'results/pre_sample_hhs.csv'));

%%% PRINT QUICK CORRELATION TABLE


%corr_ep_O_B corr_ep_B_B corr_nu_O_B corr_nu_B_B
CORR=csvread(strcat(cd_dir,'results/correlation_estimatesgroup',num2str(est_version),'_','.csv'));


corrb = zeros(4,boot_max);
for i = 1:boot_max
   corrb(:,i)= csvread(strcat(cd_dir,'BOOT/correlation_estimatesgroup',num2str(est_version),'_',num2str(i),'.csv'))  ;
end

corr_sd = std(corrb,0,2);

if mac==1
    slash = '/';
else
    slash = '\';
end

fileID = fopen(strcat(cd_out,'tables',slash,'corr_table_group.tex'),'w');
    
fprintf(fileID,'%s\n','\begin{tabular}{lcc}'); 
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','& $\epsilon$ & $\eta$ \\');
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n',strcat('Corr. Owner-Buyer: $\rho_{O,B}$ &', ...
                    num2str(CORR(1),'%5.2f'),'&', num2str(CORR(3),'%5.2f'),'\\'));
fprintf(fileID,'%s\n',strcat('  & (', ...
                    num2str(corr_sd(1),'%5.2f'),') & (', num2str(corr_sd(3),'%5.2f'),') \\'));
fprintf(fileID,'%s\n',strcat('Corr. Buyer-Buyer: $\rho_{B_1,B_2}$ &', ...
                    num2str(CORR(2),'%5.2f'),'&', num2str(CORR(4),'%5.2f'),'\\')); 
fprintf(fileID,'%s\n',strcat(' & (', ...
                    num2str(corr_sd(2),'%5.2f'),') & (', num2str(corr_sd(4),'%5.2f'),') \\')); 
fprintf(fileID,'%s\n','\end{tabular}'); 
fclose(fileID);



    t          = csvread(strcat(cd_dir,'standard_t_',tag,'.csv'),1,0)  ;
        if size_smp(1)>0
            t=t(1:size_smp(1));
        end
    X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 sum(t) (8) ]);
    X = grpstats(X,repelem((1:length(t))',t,1)); % take averages for each individual
    

smm_TRUE = csvread(strcat(cd_dir,'results/smm_group_',num2str(est_version),'.csv'));
smm = csvread(strcat(cd_dir,'BOOT',slash,'xsmmBOOTgroup',num2str(est_version),'_',num2str(1),'.csv'));
for i = 2:boot_max
   smm_r = csvread(strcat(cd_dir,'BOOT/xsmmBOOTgroup',num2str(est_version),'_',num2str(i),'.csv'))  ;
   smm   = [smm smm_r]            ;
end

Xmean=mean(smm_TRUE,2);
Xstd=std(smm,0,2);




%%%%%%% PRINT THE COSTS QUICK
    fileID = fopen(strcat(cd_out,'tables',slash,'/marginalcosts_group.tex'),'w');
fprintf(fileID,'%s\n',num2str(COST_INPUTS(1),'%5.0f'));
fclose(fileID);

%%%%%%% PRINT THE COSTS QUICK
    fileID = fopen(strcat(cd_out,'tables',slash,'/cfee_group.tex'),'w');
fprintf(fileID,'%s\n',num2str(COST_INPUTS(2),'%5.0f'));
fclose(fileID);



%%%%%%%% PRINT THE TOTAL ESTIMATES FOR THE FIXED FEE
    fileID = fopen(strcat(cd_out,'tables',slash,'/fixedfee_group.tex'),'w');
fprintf(fileID,'%s\n',num2str(Xmean(1),'%5.0f'));
fclose(fileID);

if size(smm,1)==3
fileID = fopen(strcat(cd_out,'tables',slash,'/vendorfixedfee_group.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(2),'%5.0f'));
    fclose(fileID);
fileID = fopen(strcat(cd_out,'tables',slash,'/vendorprice_group.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(3),'%5.0f'));
    fclose(fileID);

elseif size(smm,1)==4
fileID = fopen(strcat(cd_out,'tables',slash,'/vendorfixedfee_group.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(2),'%5.0f'));
    fclose(fileID);
fileID = fopen(strcat(cd_out,'tables',slash,'/vendorprice_group.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(3),'%5.0f'));
    fclose(fileID);
else
fileID = fopen(strcat(cd_out,'tables',slash,'/vendorprice_group.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(2),'%5.0f'));
    fclose(fileID);
end


%%%% PRINT TOTAL HH


fileID = fopen(strcat(cd_out,'tables',slash,'/totalhhsmm_group.tex'),'w');
    fprintf(fileID,'%s\n',num2bankScalar(round(TOTAL_HH_POST,1)));
    fclose(fileID);

    
fileID = fopen(strcat(cd_out,'tables',slash,'/totalhhsmm_pre_group.tex'),'w');
    fprintf(fileID,'%s\n',num2bankScalar(round(TOTAL_HH_PRE,1)));
    fclose(fileID);

    
    
fileID = fopen(strcat(cd_out,'tables/step_3_estimates_group.tex'),'w');


%fprintf(fileID,'%s\n','\begin{table}');
%fprintf(fileID,'%s\n','\centering');

%fprintf(fileID,'%s\n','\caption{Step 3: Cost Parameters}'); 
fprintf(fileID,'%s\n','\begin{tabular}{lcc}');
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','& Estimate & Standard Error \\');
fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');



%%%%%%% PRINT THE ESTIMATE TABLE

fprintf(fileID,'%s\n',strcat('Fixed Cost per Connection (PhP/Month): $F$ &', ...
                    num2str(Xmean(1),'%5.2f'),'&', num2str(Xstd(1),'%5.2f'),'\\'));

if size(smm,1)==3
    fprintf(fileID,'%s\n',strcat('Fixed Cost for Vended Water (PhP/Month): $F_{V}$ &', ...
                        num2str(Xmean(2),'%5.2f'),'&', num2str(Xstd(2),'%5.2f'),'\\'));

    fprintf(fileID,'%s\n',strcat('Price for Vended Water (PhP/m3): $P_{V}$ &', ...
                        num2str(Xmean(3),'%5.2f'),'&', num2str(Xstd(3),'%5.2f'),'\\'));

elseif size(smm,1)==4
    fprintf(fileID,'%s\n',strcat('Fixed Cost for Vended Water (PhP/Month): $F_{V}$ &', ...
                        num2str(Xmean(2),'%5.2f'),'&', num2str(Xstd(2),'%5.2f'),'\\'));

    fprintf(fileID,'%s\n',strcat('Price for Vended Water (PhP/m3): $P_{V}$ &', ...
                        num2str(Xmean(3),'%5.2f'),'&', num2str(Xstd(3),'%5.2f'),'\\'));

    fprintf(fileID,'%s\n',strcat('Vendor Price Variance: $\sigma_{V}^2$  &', ...
                        num2str(Xmean(4),'%5.2f'),'&', num2str(Xstd(4),'%5.2f'),'\\'));
else
    fprintf(fileID,'%s\n',strcat('Price for Vended Water (PhP/m3): $P_{V}$ &', ...
                        num2str(Xmean(2),'%5.2f'),'&', num2str(Xstd(2),'%5.2f'),'\\'));

end

    fprintf(fileID,'%s\n','\hline'); 
    
fprintf(fileID,'%s\n','\end{tabular}'); 

%fprintf(fileID,'%s\n','\vspace{.5cm}'); 



%fprintf(fileID,'%s\n','\label{table:step3estimates}'); 
%fprintf(fileID,'%s','Standard Errors are bootstrapped at the connection level.  Total Households:  ');
%fprintf(fileID,'%s',strcat(num2str(TOTAL_HH_POST,'%10.0f')));
            
%fprintf(fileID,'%s\n','\end{table}');                

fclose(fileID);


h=1;