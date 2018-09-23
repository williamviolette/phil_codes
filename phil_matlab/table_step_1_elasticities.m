function h=table_step_1_elasticities...
    (est_version,tag,controls,sample,size_smp,boot_max,mac,TUNE,cd_out,cd_dir)

% generate step 1 estimates

if length(controls)>=4
    control_size=controls(4);
else
    control_size=1;
end
if length(controls)>=5
    SHH_control=controls(5);
else
    SHH_control=0;
end





        t=csvread(strcat(cd_dir,'standard_t_',tag,'.csv'),1,0);
        X= csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0);
        X = X(1:sum(t),:);
            k_1    = 10.*ones(size(X,1),1);
            k_2    = 20.*ones(size(X,1),1);
            k_3    = 40.*ones(size(X,1),1);
            p_1    = X(:,2) ;
            p_2    = X(:,3) ;
            p_3    = X(:,4) ;
            p_4    = X(:,5) ;
            Q_obs  = X(:,1) ; 
            CONTROL = X(:,6:5+control_size);

        [CA,SE,D,~]=...
                   generate_controls( controls , SHH_control, CONTROL ,Q_obs,t );
        if mac==1
           x_r = csvread(strcat(cd_dir,'BOOT/xBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
        else
           x_r = csvread(strcat(cd_dir,'BOOT\xBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
        end
        
       sig_ep = x_r(1:controls(1));
       sigma_1 = x_r(controls(1)+1:controls(1)+controls(2)+SHH_control);
       alpha_1 = x_r(controls(1)+controls(2)+SHH_control+1:...
           controls(1)+controls(2)+SHH_control+controls(3));
       gamma = repelem(x_r(length(sig_ep)+length(sigma_1)+length(alpha_1)+1 ...
                    :length(sig_ep)+length(sigma_1)+length(alpha_1)+length(t)),t,1);
      
           [SIG_EP,SIG_NU,ALPHA_1] = control_predict(sig_ep,sigma_1,alpha_1,CA,SE,D);

        Q_obs_pred = moffitt_prep_norm_med_VAR_tune(t,k_1,k_2,k_3,p_1,p_2,p_3,p_4,...
                           gamma,SIG_NU,SIG_EP,ALPHA_1,TUNE);

dlmwrite(strcat(cd_dir,'results/','q_obs_pred.csv'),Q_obs_pred,'precision',5); 
dlmwrite(strcat(cd_dir,'results/','q_obs_true.csv'),Q_obs,'precision',5); 
                     
                     

                       
%t = data_prepc_v4(est_version,sample,size_smp,mac,tag,control_size,0,[]);
t = data_prep(est_version,sample,size_smp,tag,tag_g,control_size,0,[],cd_dir);

OBS=sum(t);
HH=length(t);

%R_to_S=size_smp(2);



%%%% ELASTICITY!!! %%%%%%
elasticity = zeros(boot_max,7);
    
    for i = 1:boot_max

        t=csvread(strcat(cd_dir,'BOOT/tBOOT',num2str(est_version),'_',num2str(i),'.csv'));
        i_SB=csvread(strcat(cd_dir,'BOOT/iBOOT',num2str(est_version),'_',num2str(i),'.csv'));


        X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 max(i_SB) (4+control_size) ]);
        X=X(i_SB,:);

        INC          = csvread(strcat(cd_dir,'standard_inc_',tag,'.csv'),1,0);
        INC=INC(i_SB,:);

        
            k_1    = 10.*ones(size(X,1),1);
            k_2    = 20.*ones(size(X,1),1);
            k_3    = 40.*ones(size(X,1),1);
            p_1    = X(:,2) ;
            p_2    = X(:,3) ;
            p_3    = X(:,4) ;
            p_4    = X(:,5) ;

            Q_obs  = X(:,1) ; 

            CONTROL = X(:,6:5+control_size);


        [CA,SE,D,~]=...
                   generate_controls( controls , SHH_control, CONTROL ,Q_obs,t );
        if mac==1
           x_r = csvread(strcat(cd_dir,'BOOT/xBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
        else
           x_r = csvread(strcat(cd_dir,'BOOT\xBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
        end
        
       sig_ep = x_r(1:controls(1));
       sigma_1 = x_r(controls(1)+1:controls(1)+controls(2)+SHH_control);
       alpha_1 = x_r(controls(1)+controls(2)+SHH_control+1:...
           controls(1)+controls(2)+SHH_control+controls(3));
        
      % gamma = repelem(x_r(length(x_r)-length(t)+1:end),t,1);
        gamma = repelem(x_r(length(sig_ep)+length(sigma_1)+length(alpha_1)+1 ...
                    :length(sig_ep)+length(sigma_1)+length(alpha_1)+length(t)),t,1);
      
           [SIG_EP,SIG_NU,ALPHA_1] = control_predict(sig_ep,sigma_1,alpha_1,CA,SE,D);

          % SIG_NU=ones(length(SIG_NU),1);
           
        Q_obs_pred = moffitt_prep_norm_med_VAR_tune(t,k_1,k_2,k_3,p_1,p_2,p_3,p_4,...
                           gamma,SIG_NU,SIG_EP,ALPHA_1,TUNE);
        Q_obs_pred1 = moffitt_prep_norm_med_VAR_tune(t,k_1,k_2,k_3,...
                        p_1+1,p_2+(p_2./100),p_3+(p_3./100),p_4+(p_4./100),...
                           gamma,SIG_NU,SIG_EP,ALPHA_1,TUNE);
        elasticity(i,1) = 100.*(mean(Q_obs_pred)-mean(Q_obs_pred1))./mean(Q_obs_pred);
        
        
        
        %%% BY TERCILE OF INCOME
        inc_low = (INC<prctile(INC,33));
        inc_mid = (INC>=prctile(INC,33) & INC<prctile(INC,67));
        inc_high = (INC>=prctile(INC,67));
        
        use_low = Q_obs<prctile(Q_obs,33);
        use_mid = (Q_obs>=prctile(Q_obs,33) & Q_obs<prctile(Q_obs,67));
        use_high = Q_obs>prctile(Q_obs,67);
        
            elasticity(i,2) = 100.*(mean(Q_obs_pred(inc_low==1))-...
                                                mean(Q_obs_pred1(inc_low==1)))./...
                                                mean(Q_obs_pred(inc_low==1));
            elasticity(i,3) = 100.*(mean(Q_obs_pred(inc_mid==1))-...
                                                mean(Q_obs_pred1(inc_mid==1)))./...
                                                mean(Q_obs_pred(inc_mid==1));
            elasticity(i,4) = 100.*(mean(Q_obs_pred(inc_high==1))-...
                                                mean(Q_obs_pred1(inc_high==1)))./...
                                                mean(Q_obs_pred(inc_high==1));        
            elasticity(i,5) = 100.*(mean(Q_obs_pred(use_low==1))-...
                                                mean(Q_obs_pred1(use_low==1)))./...
                                                mean(Q_obs_pred(use_low==1));
            elasticity(i,6) = 100.*(mean(Q_obs_pred(use_mid==1))-...
                                                mean(Q_obs_pred1(use_mid==1)))./...
                                                mean(Q_obs_pred(use_mid==1));
            elasticity(i,7) = 100.*(mean(Q_obs_pred(use_high==1))-...
                                                mean(Q_obs_pred1(use_high==1)))./...
                                                mean(Q_obs_pred(use_high==1));                             
    end
    
   
    
    
    
    
    %%% Fix later!! (there's a print issue...)
   % clear print
   % hist(Q_obs(Q_obs>=-10 & Q_obs<120),1000);
   %      xlabel('Consumption (m3 per month)')
   % print -dpng 'tables/Q_obs_histogram.png';
   % hist(round(Q_obs_pred(Q_obs_pred>=-20 & Q_obs_pred<120)),1000)
   %     xlabel('Consumption (m3 per month)')
   % print -dpng 'tables/Q_obs_pred_histogram.png';    
   

    
Xmean=mean(elasticity,1);
Xstd=std(elasticity,0,1);

%%% WRITE OUT ESTIMATES IN TEXT FILE

fileID = fopen(strcat(cd_out,'tables/mean_elasticity.tex'),'w');
fprintf(fileID,'%s',num2str(Xmean(1),'%5.2f'));
fclose(fileID);

fileID = fopen(strcat(cd_out,'tables/low_income_elasticity.tex'),'w');
fprintf(fileID,'%s',num2str(Xmean(2),'%5.2f'));
fclose(fileID);

fileID = fopen(strcat(cd_out,'tables/med_income_elasticity.tex'),'w');
fprintf(fileID,'%s',num2str(Xmean(3),'%5.2f'));
fclose(fileID);

fileID = fopen(strcat(cd_out,'tables/high_income_elasticity.tex'),'w');
fprintf(fileID,'%s',num2str(Xmean(4),'%5.2f'));
fclose(fileID);





%%% WRITE FULL TABLE


fileID = fopen(strcat(cd_out,'tables/elasticity_estimates.tex'),'w');

fprintf(fileID,'%s\n','\begin{tabular}{lcc}');
fprintf(fileID,'%s\n','& Estimate & Standard Error \\');
%fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');

HLINE=0;

%%%%%%% ALPHA! (PUT MORE IN AND DESCRIBE THEM
fprintf(fileID,'%s\n',strcat('Mean Elasticity &', ...
                    num2str(Xmean(1),'%5.3f'),'&', num2str(Xstd(1),'%5.3f'),'\\'));

%fprintf(fileID,'%s\n','\hline');

fprintf(fileID,'%s\n',strcat(' & &  \\'));

fprintf(fileID,'%s\n',strcat('Elasticities by Income Tercile & & \\'));
    fprintf(fileID,'%s\n','\hline');
%    fprintf(fileID,'%s\n','\hline');    
fprintf(fileID,'%s\n',strcat('Low Income &', ...
                    num2str(Xmean(2),'%5.3f'),'&', num2str(Xstd(2),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('Medium Income &', ...
                    num2str(Xmean(3),'%5.3f'),'&', num2str(Xstd(3),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('High Income &', ...
                    num2str(Xmean(4),'%5.3f'),'&', num2str(Xstd(4),'%5.3f'),'\\'));

                
fprintf(fileID,'%s\n',strcat(' & &  \\'));


fprintf(fileID,'%s\n',strcat('Elasticities by Usage Tercile & & \\'));
fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n',strcat('Low Usage &', ...
                    num2str(Xmean(5),'%5.3f'),'&', num2str(Xstd(5),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('Medium Usage &', ...
                    num2str(Xmean(6),'%5.3f'),'&', num2str(Xstd(6),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('High Usage &', ...
                    num2str(Xmean(7),'%5.3f'),'&', num2str(Xstd(7),'%5.3f'),'\\'));
%fprintf(fileID,'%s\n','\hline');


fprintf(fileID,'%s\n','\end{tabular} '); 

%fprintf(fileID,'%s\n','\end{tabular} \\'); 

%fprintf(fileID,'%s\n','\vspace{.5cm}'); 

%fprintf(fileID,'%s','Total Observations:  ');
%fprintf(fileID,'%s',num2str(OBS));
%fprintf(fileID,'%s','   Total Connections:  ');
%fprintf(fileID,'%s',num2str(HH));
               

fclose(fileID);


h=1;