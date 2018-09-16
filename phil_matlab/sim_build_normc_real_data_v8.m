function [TRUTH,a,x1,se,TOC]=sim_build_normc_real_data_v8(print,tag,mac,sample,size_smp,...
                    sig_ep,sigma_1,alpha_1,...
                    perf_var,Q_obs_range,p_var,i,reps,fileID,options,only_alpha,real_data,est_version,controls,BOOT,TUNE,cd_dir)

                
                
if mac==1
    slash = '/';
else
    slash = '\';
end

                
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

SIG_GUESS = 0;
if length(TUNE)>1
   SIG_GUESS = TUNE(2);
   TUNE = TUNE(1);
end

%%% REAL DATA OPTION
if length(real_data)>1
    RLENGTH=real_data(2);
         fprintf(fileID,'%s\r\n',strcat('Time Periods:  ',num2str(RLENGTH)));
else
    RLENGTH=0;
end
real_data = real_data(1);

  
 if perf_var==1
     fprintf(fileID,'%s\r\n',...
        strcat('   PERF   Q_obs_range: ',num2str(Q_obs_range(1)),'to',num2str(Q_obs_range(2)),...
      '   PVAR: ',num2str(p_var),'  i: ',num2str(i),'  Reps:  ',num2str(reps)));
        
     [t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4]=...
        perfect_var(i,reps,Q_obs_range,p_var);
    
        CONTROL = rand(sum(t),control_size);
 else
     fprintf(fileID,'%s\r\n',...
        strcat('   Data   Standard: ',num2str(sample(1)),'  R-to-S:  ',num2str(sample(2)),...
        '  R-to-C:  ',num2str(sample(3)),...
      '   Sizes: ',num2str(size_smp(1)),'   ',num2str(size_smp(2)),'    ',num2str(size_smp(3))));
      
    [t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,CONTROL] =...
        data_prepc_v4(est_version,sample,size_smp,tag,control_size,RLENGTH,BOOT,cd_dir);
 end
 
       [CA,SE,D,control_id]=...
           generate_controls( controls , SHH_control, CONTROL ,Q_obs,t );
           
       [SIG_EP,SIG_NU,ALPHA_1] = control_predict(sig_ep,sigma_1,alpha_1,CA,SE,D);

 
    gamma1=(accumarray(repelem((1:length(t))',t,1), Q_obs+ALPHA_1.*mean(p_2) )./t)'; %% fill in gamma!
    gamma=repelem(gamma1',t,1);   
    


if real_data~=1
    Q_obs=moffitt_prep_norm_med_VAR_tune(t,k_1,k_2,k_3,p_1,p_2,p_3,p_4,...
                gamma,SIG_NU,SIG_EP,ALPHA_1,TUNE);
end
	if SIG_GUESS==1
                obj = @(a)est_no_mid_general_tune(a,t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,D,SE,CA,control_id,TUNE);    
	elseif SIG_GUESS==2
                obj = @(a)est_full_mid_general_tune(a,t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,D,SE,CA,control_id,TUNE);   
	else
                obj = @(a)est_nmid_general_tune(a,t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,D,SE,CA,control_id,TUNE);                
	end
    %obj = @(a)est_nmid_general_tune(a,t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,D,SE,CA,control_id,TUNE);


    TRUTH = [ sig_ep sigma_1 alpha_1 gamma1 ];

    a = 1.05.*TRUTH;
 
         tic
            x1=fminunc(obj,a,options);   %  options=optimoptions('fminunc','Algorithm','trust-region','GradObj','on','Hessian','on','MaxIter',10000,'TolX',1e-10, 'TolFun', 1e-10 );
         TOC=toc;
                            %TRUTH(1:10)
                            %a(1:10)
                            %x1(1:10)
                        [~,~,hess]=obj(x1);
                        se=diag(sqrt(inv(hess)));
                            %se(1:10)
    if isempty(BOOT)~=1
        %{
        if BOOT(1)>1
            x_pre=csvread(strcat('BOOT\xBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
            x_post=[x_pre x1'];
            csvwrite(strcat('BOOT\xBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),x_post);
        else
            csvwrite(strcat('BOOT\xBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),x1');            
        end
        %}
            dlmwrite(strcat('BOOT',slash,'xBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),x1','delimiter',',','precision',20);    
    else
        dlmwrite(strcat(cd_dir,'results',slash,'x',num2str(est_version),'.csv'),x1','delimiter',',','precision',20);
    end
    
                            
if print==1                            
            vnum = sum(control_id);    %%% SET VNUM HERE !!!
    dev =   [((TRUTH(1:vnum)-x1(1:vnum))./TRUTH(1:vnum)) ...
                            mean(TRUTH(vnum+1:end)-x1(vnum+1:end)./TRUTH(vnum+1:end))];
                        TRUTHp = [TRUTH(1:vnum) mean(TRUTH(vnum+1:end))];
                        x1p    = [x1(1:vnum) mean(x1(vnum+1:end))];
                        sep    = [se(1:vnum)' mean(se(vnum+1:end))];
                        
    if only_alpha==1
        dev=dev(3);
        TRUTHp=TRUTHp(3);
        x1p=x1p(3);
        sep=sep(3);
    end
fprintf(fileID,'%s\r\n',' ');
fprintf(fileID,'%s %1.3f\r\n','Time : ',TOC);
fprintf(fileID,'%s\t %s\t %s\t %s\t \r\n','Truth','Est','SE','Dev');

fprintf(fileID,'%1.2f\t %1.2f\t %1.2f\t %1.2f\t \r\n',[TRUTHp; x1p; sep; dev]);
fprintf(fileID,'%s\r\n',' ');


dlmwrite(strcat(cd_dir,slash,'tables',slash,'TRUTH_step1_',num2str(est_version),'.csv'),TRUTH','delimiter',',','precision',20);
dlmwrite(strcat(cd_dir,slash,'tables',slash,'TRUTHp_step1_',num2str(est_version),'.csv'),TRUTHp,'delimiter',',','precision',20);
dlmwrite(strcat(cd_dir,slash,'tables',slash,'ESTp_step1_',num2str(est_version),'.csv'),x1p,'delimiter',',','precision',20);
dlmwrite(strcat(cd_dir,slash,'tables',slash,'OBS_step1_',num2str(est_version),'.csv'),length(Q_obs),'delimiter',',','precision',20);


end

