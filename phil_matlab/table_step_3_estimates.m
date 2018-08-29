function h=table_step_3_estimates...
    (est_version,tag,boot_max,mac,control_size,size_smp,alt_sample,COST_INPUTS)

%  alt_sample = .0601;


%%% PRINT QUICK CORRELATION TABLE

%corr_ep_O_B corr_ep_B_B corr_nu_O_B corr_nu_B_B
CORR=csvread(strcat('correlation_estimates',num2str(est_version),'_','.csv'));

if mac==1
    slash = '/';
else
    slash = '\';
end

    fileID = fopen(strcat('tables',slash,'corr_table.tex'),'w');
    
fprintf(fileID,'%s\n','\begin{tabular}{|l|c|c|}'); 
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','& $\epsilon$ & $\eta$ \\');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n',strcat('Corr. Owner-Buyer: $\rho_{O,B}$ &', ...
                    num2str(CORR(1),'%5.2f'),'&', num2str(CORR(3),'%5.2f'),'\\'));
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n',strcat('Corr. Buyer-Buyer: $\rho_{B_1,B_2}$ &', ...
                    num2str(CORR(2),'%5.2f'),'&', num2str(CORR(4),'%5.2f'),'\\'));
fprintf(fileID,'%s\n','\hline');                
fprintf(fileID,'%s\n','\end{tabular}'); 
fclose(fileID);



    t          = csvread(strcat('standard_t_',tag,'.csv'),1,0)  ;
        if size_smp(1)>0
            t=t(1:size_smp(1));
        end
    X          = csvread(strcat('standard_',tag,'.csv'),1,0, [ 1 0 sum(t) (8) ]);
    X = grpstats(X,repelem((1:length(t))',t,1)); % take averages for each individual
    
    TOTAL_HH=sum(round(X(:,7)))+round(size_smp(1).*alt_sample);

smm_TRUE = csvread(strcat('smm_',num2str(est_version),'.csv'));
smm = csvread(strcat('BOOT',slash,'xsmmBOOT',num2str(est_version),'_',num2str(1),'.csv'));
for i = 2:boot_max
   if mac==1
       smm_r = csvread(strcat('BOOT/xsmmBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
   else
       smm_r = csvread(strcat('BOOT\xsmmBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
   end
   smm   = [smm smm_r]            ;
end

Xmean=mean(smm_TRUE,2);
Xstd=std(smm,0,2);




%%%%%%% PRINT THE COSTS QUICK
    fileID = fopen(strcat('tables',slash,'/marginalcosts.tex'),'w');
fprintf(fileID,'%s\n',num2str(COST_INPUTS(1),'%5.0f'));
fclose(fileID);

%%%%%%% PRINT THE COSTS QUICK
    fileID = fopen(strcat('tables',slash,'/cfee.tex'),'w');
fprintf(fileID,'%s\n',num2str(COST_INPUTS(2),'%5.0f'));
fclose(fileID);



%%%%%%%% PRINT THE TOTAL ESTIMATES FOR THE FIXED FEE
    fileID = fopen(strcat('tables',slash,'/fixedfee.tex'),'w');
fprintf(fileID,'%s\n',num2str(Xmean(1),'%5.0f'));
fclose(fileID);

if size(smm,1)==3
fileID = fopen(strcat('tables',slash,'/vendorfixedfee.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(2),'%5.0f'));
    fclose(fileID);
fileID = fopen(strcat('tables',slash,'/vendorprice.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(3),'%5.0f'));
    fclose(fileID);

elseif size(smm,1)==4
fileID = fopen(strcat('tables',slash,'/vendorfixedfee.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(2),'%5.0f'));
    fclose(fileID);
fileID = fopen(strcat('tables',slash,'/vendorprice.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(3),'%5.0f'));
    fclose(fileID);
else
fileID = fopen(strcat('tables',slash,'/vendorprice.tex'),'w');
    fprintf(fileID,'%s\n',num2str(Xmean(2),'%5.0f'));
    fclose(fileID);
end


%%%% PRINT TOTAL HH
fileID = fopen(strcat('tables',slash,'/totalhhsmm.tex'),'w');
    fprintf(fileID,'%s\n',num2str(TOTAL_HH,'%5.0f'));
    fclose(fileID);

    
    
if mac==1
    fileID = fopen('tables/step_3_estimates.tex','w');
else
    fileID = fopen('tables\step_3_estimates.tex','w');
end

%fprintf(fileID,'%s\n','\begin{table}');
%fprintf(fileID,'%s\n','\centering');

%fprintf(fileID,'%s\n','\caption{Step 3: Cost Parameters}'); 
fprintf(fileID,'%s\n','\begin{tabular}{|lcc|}');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','& Estimate & Standard Error \\');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');


HLINE=0;

%%%%%%% PRINT THE ESTIMATE TABLE

fprintf(fileID,'%s\n',strcat('Fixed Cost per Connection (PhP/Month): $F$ &', ...
                    num2str(Xmean(1),'%5.2f'),'&', num2str(Xstd(1),'%5.2f'),'\\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end
if size(smm,1)==3
    fprintf(fileID,'%s\n',strcat('Fixed Cost for Vended Water (PhP/Month): $F_{V}$ &', ...
                        num2str(Xmean(2),'%5.2f'),'&', num2str(Xstd(2),'%5.2f'),'\\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end
    fprintf(fileID,'%s\n',strcat('Price for Vended Water (PhP/m3): $P_{V}$ &', ...
                        num2str(Xmean(3),'%5.2f'),'&', num2str(Xstd(3),'%5.2f'),'\\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end
elseif size(smm,1)==4
    fprintf(fileID,'%s\n',strcat('Fixed Cost for Vended Water (PhP/Month): $F_{V}$ &', ...
                        num2str(Xmean(2),'%5.2f'),'&', num2str(Xstd(2),'%5.2f'),'\\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end
    fprintf(fileID,'%s\n',strcat('Price for Vended Water (PhP/m3): $P_{V}$ &', ...
                        num2str(Xmean(3),'%5.2f'),'&', num2str(Xstd(3),'%5.2f'),'\\'));
if HLINE==1
    fprintf(fileID,'%s\n','\hline');
end
    fprintf(fileID,'%s\n',strcat('Vendor Price Variance: $\sigma_{V}^2$  &', ...
                        num2str(Xmean(4),'%5.2f'),'&', num2str(Xstd(4),'%5.2f'),'\\'));
    fprintf(fileID,'%s\n','\hline');
else
    fprintf(fileID,'%s\n',strcat('Price for Vended Water (PhP/m3): $P_{V}$ &', ...
                        num2str(Xmean(2),'%5.2f'),'&', num2str(Xstd(2),'%5.2f'),'\\'));
    fprintf(fileID,'%s\n','\hline'); 
end

fprintf(fileID,'%s\n','\end{tabular} \\'); 

fprintf(fileID,'%s\n','\vspace{.5cm}'); 

%fprintf(fileID,'%s\n','\label{table:step3estimates}'); 
fprintf(fileID,'%s','Total Households:  ');
fprintf(fileID,'%s',strcat(num2str(TOTAL_HH,'%10.0f')));
            
%fprintf(fileID,'%s\n','\end{table}');                

fclose(fileID);


h=1;