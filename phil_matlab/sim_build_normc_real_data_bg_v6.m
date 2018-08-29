function [TRUTH,a,x1,TOC]=sim_build_normc_real_data_bg_v6(PH,print,tag,mac,...
                    fileID,est_version,controls,ph_controls,pollfish,real_data,BOOT,TUNE,cd_dir)


%%% CONTROLS OPTION
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
controls1 = controls(1:3);

%%% REAL DATA OPTION
if length(real_data)>1
    RLENGTH=real_data(2);
         fprintf(fileID,'%s\r\n',strcat('Time Periods:  ',num2str(RLENGTH)));
else
    RLENGTH=0;
end
real_data = real_data(1);


[t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,lambda,x,CONTROL,CONTROL_PH,beta_O,beta_B]=...
    data_prep_bg_v1(mac,tag,control_size,est_version,pollfish,BOOT,RLENGTH,  1  , cd_dir); %%% THIS USES REAL DATA
    
 [CA,SE,D,control_id]=generate_controls( controls1 , SHH_control, CONTROL , Q_obs, t ); 
 [~,SE_SHR,~,~]=generate_controls( controls1 , SHH_control, [CONTROL(:,1) (CONTROL(:,2)+1) CONTROL(:,3:end)], Q_obs, t ); 


 
sig_ep  = x(    1:control_id(1)  ); %%% DETERMINE CONTROLS VALUES !
sig_nu  = x(   (control_id(1)+1) : (control_id(1)+control_id(2))   );
alpha_1 = x(   (control_id(1)+control_id(2)+1) : (control_id(1)+control_id(2)+control_id(3))   );

[SIG_EP,SIG_NU,ALPHA] = control_predict(sig_ep,sig_nu,alpha_1,CA,SE,D);
[SIG_EP_SHR,~,~] = control_predict(sig_ep,sig_nu,alpha_1,CA,SE_SHR,D);

SHR = [ SIG_EP_SHR SIG_NU ALPHA (beta_O + beta_B) ]; 
REG = [ SIG_EP     SIG_NU ALPHA  beta_O ]; 

%%% HERE IS WHERE THE PH CONTROLS ARE DETERMINED!


if ph_controls(1)==1 %% first option is for beta quantiles
    PC = zeros(sum(t),1);    
    for i = 1:ph_controls(2) %% second option sets the number of quintiles
       pct = ( i./ph_controls(2) ).*100;
       PC = PC +  ( PRC(pct,beta_O,t)==1 ) ;
    end
    PH_C = dummyvar(PC);
end
if ph_controls(1)==2
    PH_C = [ones(size(CONTROL_PH,1),1) CONTROL_PH];
end



if real_data~=1
            [~,~,~,~,~,~,~,~,~,~,x_sim,~,beta_O_sim,beta_B_sim]=...
            data_prep_bg_v1(mac,tag,control_size,est_version,pollfish,BOOT,RLENGTH,  0  );
        
            sig_ep_sim  = x_sim(    1:control_id(1)  ); %%% DETERMINE CONTROLS VALUES !
            sig_nu_sim  = x_sim(   (control_id(1)+1) : (control_id(1)+control_id(2))   );
            alpha_1_sim = x_sim(   (control_id(1)+control_id(2)+1) : (control_id(1)+control_id(2)+control_id(3))   );

            [SIG_EP_sim,SIG_NU_sim,ALPHA_sim] = control_predict(sig_ep_sim,sig_nu_sim,alpha_1_sim,CA,SE,D);
            [SIG_EP_SHR_sim,~,~] = control_predict(sig_ep_sim,sig_nu_sim,alpha_1_sim,CA,SE_SHR,D);
        
            SHR_sim = [ SIG_EP_SHR_sim SIG_NU_sim ALPHA_sim (beta_O_sim + beta_B_sim) ]; 
            REG_sim = [ SIG_EP_sim SIG_NU_sim ALPHA_sim  beta_O_sim ]; 
       
            shr_ind_sim = rand(sum(t),1);
            Q_obs_shr_sim=moffitt_prep_norm_med_VAR_tune(t,k_1,k_2,k_3,p_1,p_2,p_3,p_4,...
                           SHR_sim(:,4) - SHR_sim(:,3).*PH     ,SHR_sim(:,2),SHR_sim(:,1),SHR_sim(:,3),TUNE); %% INCLUDES HASSLE COST
            Q_obs_reg_sim=moffitt_prep_norm_med_VAR_tune(t,k_1,k_2,k_3,p_1,p_2,p_3,p_4,...
                           REG_sim(:,4) ,REG_sim(:,2),REG_sim(:,1),REG_sim(:,3),TUNE);
            Q_obs = Q_obs_shr_sim.*(shr_ind_sim<=lambda) + Q_obs_reg_sim.*(shr_ind_sim>lambda);
end

       obj = @(a)est_nmid_bg_tune(a,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,SHR,REG,  lambda  ,PH_C,TUNE);
        

TRUTH = [ PH.*ones(1,size(PH_C,2)) ];


    a = 1.05.*TRUTH;
 
         tic
            x1=fminunc(obj,a);   %  options=optimoptions('fminunc','Algorithm','trust-region','GradObj','on','Hessian','on','MaxIter',10000,'TolX',1e-10, 'TolFun', 1e-10 );
         TOC=toc;
           
if x1>50        
    TRIM_COND  = Q_obs>0;
        Q_obs_T= Q_obs(TRIM_COND==1,:);
        k_1_T  = k_1(TRIM_COND==1,:);
        k_2_T  = k_2(TRIM_COND==1,:);
        k_3_T  = k_3(TRIM_COND==1,:);
        p_1_T  = p_1(TRIM_COND==1,:);
        p_2_T  = p_2(TRIM_COND==1,:);
        p_3_T  = p_3(TRIM_COND==1,:);
        p_4_T  = p_4(TRIM_COND==1,:);
        SHR_T  = SHR(TRIM_COND==1,:);
        REG_T  = REG(TRIM_COND==1,:);
        lambda_T=lambda(TRIM_COND==1,:);
        PH_C_T  =PH_C(TRIM_COND==1,:);
    obj        = @(a)est_nmid_bg_tune(a,Q_obs_T,k_1_T,k_2_T,k_3_T,p_1_T,p_2_T,p_3_T,p_4_T,SHR_T,REG_T,  lambda_T  ,PH_C_T,TUNE);
        TRUTH  = [ PH.*ones(1,ph_controls(2)) ];
    a          = 1.05.*TRUTH;
         tic
            x1=fminunc(obj,a);   %  options=optimoptions('fminunc','Algorithm','trust-region','GradObj','on','Hessian','on','MaxIter',10000,'TolX',1e-10, 'TolFun', 1e-10 );
         TOC=toc;
end
    
    
    %{
                TRUTH %%% !! DIAGNOSTICS HERE !! %%%
                a
                x1
         RR=120;
         obj_plot=zeros(RR,1);
         PHT=(1:RR)';
         for rr=1:RR
             obj_temp=obj(rr);
             obj_plot(rr,1)=obj_temp;
         end
         plot(PHT,obj_plot)
    %}
         
         
  if mac==1
      slash='/';
  else
      slash='\';
  end
                          
                %       [~,~,hess]=obj(x1);
                %        se=diag(sqrt(inv(hess)));
                            %se(1:10)
                            
    if isempty(BOOT)~=1
        csvwrite(strcat(cd_dir,'BOOT',slash,'phBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),x1)
    else
        csvwrite(strcat(cd_dir,'results',slash,'ph',num2str(est_version),'.csv'),x1);
    end
                            
if print==1                            
            vnum = length(x1);    %%% SET VNUM HERE !!!
                        TRUTHp = [TRUTH(1:vnum)];
                        x1p    = [x1(1:vnum) ];
                      
fprintf(fileID,'%s\r\n',' ');
fprintf(fileID,'%s %1.3f\r\n','Time : ',TOC);
fprintf(fileID,'%s\t %s\t \r\n','Truth','Est');

fprintf(fileID,'%1.2f\t %1.2f\t  \r\n',[TRUTHp; x1p]);
fprintf(fileID,'%s\r\n',' ');


if mac==1
    slash = '/';
else
    slash = '\';
end

dlmwrite(strcat(cd_dir,'tables',slash,'TRUTH_step2_',num2str(est_version),'.csv'),TRUTH','delimiter',',','precision',20);
dlmwrite(strcat(cd_dir,'tables',slash,'TRUTHp_step2_',num2str(est_version),'.csv'),TRUTHp,'delimiter',',','precision',20);
dlmwrite(strcat(cd_dir,'tables',slash,'ESTp_step2_',num2str(est_version),'.csv'),x1p,'delimiter',',','precision',20);
dlmwrite(strcat(cd_dir,'tables',slash,'OBS_step2_',num2str(est_version),'.csv'),length(Q_obs),'delimiter',',','precision',20);


end

