  function [x1,given,moments,smm_est_option,...
                input1s,input2s,input3s,...
                errors1s,errors2s,errors3s,...
                SIG_EP_INPUTS,reps,sto,alt_error,...
                sort_condition,split_F_option,transfer_option,TUNE]=...
sim_build_normc_real_data_smm_v5_more_moments_groupings(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_max,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,BOOT,boot_max,boot_estimates,alt_sample,ESTIMATION_OPTION)

                
                
%%% CONTROLS OPTION
if length(controls)>=5
    SHH_control=controls(5);
else
    SHH_control=0;
end

%%%%%%%% BRING IN DATA
%%%
control_total=sum(controls(1:3))+SHH_control;

    [Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,x,ph,CONTROL,alt]=...
    data_prep_smm_grouping_v2(size_smp(1),mac,tag,control_max,est_version,...
    BOOT,ESTIMATION_OPTION,alt_sample,control_total,boot_max,boot_estimates);

    
%%%%%%%% CALCULATE CONTROLS
%%%

 [CA,SE,D,control_id]=generate_controls( controls , SHH_control, CONTROL , Q_obs, ones(length(p_2),1) ); 
       
sig_ep  = x(    1:control_id(1)  ); 
sig_nu  = x(   (control_id(1)+1) : (control_id(1)+control_id(2))   );
alpha_1 = x(   (control_id(1)+control_id(2)+1) : (control_id(1)+control_id(2)+control_id(3))   );

if SHH_control>0 %%% prep for proper SIG_NU projection
    SE = SE(:,1:size(SE,2)-2);
end

[~,SIG_NU,ALPHA] = control_predict(sig_ep,sig_nu,alpha_1,CA,SE,D); %% this sig_nu is only imputed from size
SIG_EP = sig_ep(1).*ones(length(SIG_NU),1);    %%% NOTE: PERSONAL SIG_EP DOES NOT TAKE INTO ACCOUNT HOUSEHOLD!!

%%%%%%%%% DETERMINE PARAMETERS:  ALPHA and VARIANCE
%%%            
            
beta_temp = x(sum(control_id)+1:sum(control_id)+size_smp(1)); %%% TAKE OLD BETAS


if SHH_control>0  %% PROJECT SIG_NU ONTO BETA TEMP!  %%% USE THIS PROJECTION LATER!
    B_index = ones(length(beta_temp),1);
    B_prc = zeros(10,1);
    for i = 1:10
       B_index = B_index + (beta_temp>prctile(beta_temp,10.*i)); 
       B_prc(i) = prctile(beta_temp,10.*i);
    end
    B_index = dummyvar(B_index);
    SR = regress(SIG_NU(alt==0),B_index);
end


if ph_controls(1)==1 %% now I plug in beta_temp !!!  %% generate predicted hassle
    PC = zeros(length(beta_temp),1);    
    for i = 1:ph_controls(2)
       pct = ( i./ph_controls(2) ).*100;
       PC = PC +  ( PRC(pct,beta_temp,ones(length(beta_temp),1))==1 ) ;
    end
    PH_C = dummyvar(PC);
    PH = zeros(length(beta_temp),1);
    for i = 1:ph_controls(2)
        PH = PH + ph(i).*PH_C(:,i);
    end
end  %% ok to use heterogeneity in the full hassle !!

%%%%%%%%%%%%%% HUGE SIMPLIFICATION TO PH
    PH = ph(end).*ones(length(alt),1);


%%%%%%%%% IMPUTE BETA FROM SPLITTING : DATA PREP
%%%

SHH = 1.*(CONTROL(:,2)>=1  & CONTROL(:,2)<=1.5)...  %% define variables
    + 2.*(CONTROL(:,2)>1.5 & CONTROL(:,2)<=2.5)...
    + 3.*(CONTROL(:,2)>2.5);

ALPHA_C     = ALPHA(alt==0);  %%% look only at standard group, to project
SHH_C       = SHH(alt==0);
PH_C        = PH(alt==0);
beta_temp_C = beta_temp(alt==0);
hhsize_C    = CONTROL(alt==0,size(CONTROL,2)-1);
sho_C       = CONTROL(alt==0,size(CONTROL,2)  );

beta_J_C = beta_temp_C + ...  %% impute beta with hassle cost
        (SHH_C==2).*   (ALPHA_C.*PH_C) + ...  
        (SHH_C==3).*2.*(ALPHA_C.*PH_C);

 %mean(beta_J_C(SHH_C==1))     %% key tests right here
 %mean(beta_J_C(SHH_C==2))./2
 %mean(beta_J_C(SHH_C==3))./3

 %mean(beta_temp_C(SHH_C==1))
 %mean(beta_temp_C(SHH_C==2))./2
 %mean(beta_temp_C(SHH_C==3))./3

%%%%%%%%% IMPUTE BETA FROM SPLITTING : DIVIDE BETA : 2 HH
%%%
split_2 = mean(beta_J_C(SHH_C==1))./mean(beta_J_C(SHH_C==2));  %% assume splitting ratio

B_2 = regress(beta_J_C(SHH_C==2),      [ ones(length(beta_J_C(SHH_C==2)),1)   hhsize_C(SHH_C==2)  sho_C(SHH_C==2) ]);           
RESIDUAL2 = beta_J_C(SHH_C==2) - (B_2'*[ ones(length(beta_J_C(SHH_C==2)),1)   hhsize_C(SHH_C==2)  sho_C(SHH_C==2) ]')';
    B1_2 = (B_2(1) + RESIDUAL2).*split_2     + B_2(2).*hhsize_C(SHH_C==2);
    B2_2 = (B_2(1) + RESIDUAL2).*(1-split_2) + B_2(3).*sho_C(SHH_C==2);

%%%%%%%%% IMPUTE BETA FROM SPLITTING : DIVIDE BETA : 3 HH
%%%
split_3 = mean(beta_J_C(SHH_C==1))./mean(beta_J_C(SHH_C==3));  %% assume splitting ratio

B_3 = regress(beta_J_C(SHH_C==3),      [ ones(length(beta_J_C(SHH_C==3)),1)   hhsize_C(SHH_C==3)  sho_C(SHH_C==3) ]);           
RESIDUAL3 = beta_J_C(SHH_C==3) - (B_3'*[ ones(length(beta_J_C(SHH_C==3)),1)   hhsize_C(SHH_C==3)  sho_C(SHH_C==3) ]')';
    B1_3 =    (B_3(1) + RESIDUAL3).*split_3     + B_3(2).*hhsize_C(SHH_C==3);
    B2_3 = (  (B_3(1) + RESIDUAL3).*(1-split_3) + B_3(3).*sho_C(SHH_C==3)  )./2;
    B3_3 = B2_3;

%%%%%%%%% EXPAND THE SAMPLE
%%%

choice=repelem(3.*ones(length(SHH_C),1),SHH_C);
    hh_first=cumsum(SHH_C);
    hh_first(SHH_C==2)=hh_first(SHH_C==2)-1; % for 2 HHs
    hh_first(SHH_C==3)=hh_first(SHH_C==3)-2; % for 3 HHs
    hh_second=cumsum(SHH_C);
    hh_second(SHH_C==3)=hh_second(SHH_C==3)-1; % for 3 HHs
        choice(hh_second) = 2;
        choice(hh_first) = 1;

SHH_F = repelem(SHH_C,SHH_C,1);
    BETA=zeros(length(choice),1);
    BETA(SHH_F==1)            =beta_J_C(SHH_C==1); % single HH
    BETA(SHH_F==2 & choice==1)=B1_2; % 2 HHs
    BETA(SHH_F==2 & choice==2)=B2_2;
    BETA(SHH_F==3 & choice==1)=B1_3; % 3 HHs
    BETA(SHH_F==3 & choice==2)=B2_3;
    BETA(SHH_F==3 & choice==3)=B3_3;

%%%%%%%%% IMPUTE ALTERNATIVE BETAs
%%%

GROUP        = [SHH_F; 4.*alt(alt==1)]; %%% add alternatives
CONTROL_FULL = repelem(CONTROL,SHH,1);    

ALT_CONTROL = alt_controls(CONTROL_FULL); %% compute control_id : NOTE : there are some key options built in here!!
    b = regress( BETA ,[ones(size(ALT_CONTROL(GROUP~=4),1),1) ALT_CONTROL(GROUP~=4,:)] ); %% project onto demographics
    b_alt = (b'*[ones(size(ALT_CONTROL(GROUP==4),1),1) ALT_CONTROL(GROUP==4,:)]')';  %% predict beta charateristics
% mean(b_alt) % not much different but that's ok
% mean(BETA)


%%%%%%%%% FINAL SET OF PARAMETERS
%%%

% SHH_FULL 
% CONTROL_FULL 
BETA_FULL = [BETA; b_alt]; 
ALPHA_FULL = repelem(ALPHA,SHH,1);
SIG_EP_FULL = repelem(SIG_EP,SHH,1);

P_FULL = repelem([p_1 p_2 p_3 p_4],SHH,1);
CHOICE_FULL=[choice; 4.*alt(alt==1)];
PH_FULL = repelem(PH,SHH,1);

K_FULL = [repelem(k_1,SHH,1) ...
          repelem(k_2,SHH,1) ...
          repelem(k_3,SHH,1) ];
      
Y_FULL = CONTROL_FULL(:,10);
      
if SHH_control>0 %%% DECOMPOSE CORRELATION IN VARIABLES !!!
    B_index1 = ones(length(BETA_FULL),1);
    for i = 1:10
       B_index1 = B_index1 + (BETA_FULL>B_prc(i)); 
    end
    B_index1 = dummyvar(B_index1);
    SIG_NU_FULL = (SR'*B_index1')';
    
    SIG_NU_OLD = repelem(SIG_NU ... % what do old projections predict for joint consumption?
               + sig_nu(length(sig_nu)-1).*(SHH==2)...
               + sig_nu(length(sig_nu)  ).*(SHH==3) ,SHH,1); 
                        
    sig_nu_J_2=mean(SIG_NU_OLD(GROUP==2));
    sig_nu_O_2=mean(SIG_NU_FULL(GROUP==2 & CHOICE_FULL==1));
    sig_nu_B_2=mean(SIG_NU_FULL(GROUP==2 & CHOICE_FULL==2));
        corr_nu_O_B =  ( (sig_nu_J_2.^2) - (sig_nu_O_2.^2) - (sig_nu_B_2.^2) )./ (2.*sig_nu_O_2.*sig_nu_B_2);
    
    sig_nu_J_3  =mean(SIG_NU_OLD(GROUP==3));
    sig_nu_O_3  =mean(SIG_NU_FULL(GROUP==3 & CHOICE_FULL==1));
    sig_nu_B_3  =mean(SIG_NU_FULL(GROUP==3 & CHOICE_FULL==2)); %% same as for 3...
        corr_nu_B_B =  ( (sig_nu_J_3.^2) - (sig_nu_O_3.^2) - 2.*(sig_nu_B_3.^2) ...
            - 4.*corr_nu_O_B.*sig_nu_O_3.*sig_nu_B_3 )...
            ./ (2.*sig_nu_B_3.*sig_nu_B_3);
else 
    SIG_NU_FULL = repelem(SIG_NU,SHH,1);
end

                %%% DECOMPOSE CORRELATION FOR SIG_EP !!
    sig_ep_J_2=sig_ep(2);
    sig_ep_O_2=sig_ep(1);
    sig_ep_B_2=sig_ep(1);
    %    corr_ep_O_B =  ( sig_ep_J_2 - sig_ep_O_2 - sig_ep_B_2 )./ (2.*sqrt(sig_ep_O_2).*sqrt(sig_ep_B_2));
        corr_ep_O_B =  ( (sig_ep_J_2.^2) - (sig_ep_O_2.^2) - (sig_ep_B_2.^2) )./ (2.*sig_ep_O_2.*sig_ep_B_2);
    
        
    sig_ep_J_3  =sig_ep(3);
    sig_ep_O_3  =sig_ep(1);
    sig_ep_B_3  =sig_ep(1); %% same as for 3...
    %    corr_ep_B_B =  ( sig_ep_J_3 - sig_ep_O_3 - 2.*sig_ep_B_3 - 4.*corr_ep_O_B.*sqrt(sig_ep_O_3).*sqrt(sig_ep_B_3) )...
    %        ./ (2.*sqrt(sig_ep_B_3).*sqrt(sig_ep_B_3));
    corr_ep_B_B =  ( (sig_ep_J_3.^2) - (sig_ep_O_3.^2) - 2.*(sig_ep_B_3.^2) ...
                - 4.*corr_ep_O_B.*sig_ep_O_3.*sig_ep_B_3 )...
                ./ (2.*sig_ep_B_3.*sig_ep_B_3);    
    
            

    
    %%% EXPORT CORRELATION ESTIMATES!
    if mac==1
        slash='/';
    else
        slash='\';
    end
    if isempty(BOOT)~=1
            csvwrite(strcat('BOOT',slash,'correlation_estimatesgroup',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),...
                [corr_ep_O_B corr_ep_B_B corr_nu_O_B corr_nu_B_B]);  
    else
            csvwrite(strcat('correlation_estimatesgroup',num2str(est_version),'_.csv'),...
          [corr_ep_O_B corr_ep_B_B corr_nu_O_B corr_nu_B_B]);  
    end
            
            
            
%%%%%%%%% DETERMINE LITTLE NEIGHBORHOODS
%%%       So far NOT grouping by BARANGAY! do that next..


J = [ GROUP CHOICE_FULL BETA_FULL ALPHA_FULL SIG_EP_FULL SIG_NU_FULL K_FULL P_FULL PH_FULL Y_FULL CONTROL_FULL ];


BAR    = J(:,size(J,2)-2) ;
BAR_id = unique(BAR)      ; 

    rng(5); %%% NEED TO RANDOMLY SORT THESE VECTORS!! %%%

    j1=[];
    j2=[];
    j3=[];
    
for b = 1:size(BAR_id,1)
    Jt = J(repelem(BAR_id(b),size(BAR,1),1)==BAR,:);
    JS = Jt(randperm(size(Jt,1)),:);
    GS = floor(size(JS,1)/3);
    j1t = JS(1:GS,:);
    j2t = JS(GS+1:2*GS,:);
    j3t = JS(2*GS+1:3*GS,:);
    j1 = [j1;j1t];
    j2 = [j2;j2t];
    j3 = [j3;j3t];
%    size(Jt,1)
end

% INPUT :   BETA_FULL ALPHA_FULL SIG_EP_FULL SIG_NU_FULL K_FULL(3) P_FULL(4) PH_FULL  Y

input1 = j1(:,3:2+13); %% ADD K and Y
input2 = j2(:,3:2+13);
input3 = j3(:,3:2+13);

CHOICE_TRUE = [j1(:,2) j2(:,2) j3(:,2)];

EP = error_sample(repelem(input1(:,3),sto*reps,1),...
                  repelem(input2(:,3),sto*reps,1),...
                  repelem(input3(:,3),sto*reps,1),...
                  corr_ep_O_B,corr_ep_B_B);
NU = error_sample(repelem(input1(:,4),sto*reps,1),...
                  repelem(input2(:,4),sto*reps,1),...
                  repelem(input3(:,4),sto*reps,1),...
                  corr_nu_O_B,corr_nu_B_B);
              
errors1 =  [  NU(:,1) EP(:,1)  ] ;
errors2 =  [  NU(:,2) EP(:,2)  ] ;
errors3 =  [  NU(:,3) EP(:,3)  ] ;

SIG_EP_INPUTS = sig_ep;


%if real_data~=1
    %[~,moments]  =  smm_shell_v3(a,given,moments,smm_est_option,...
    %                                input1,input2,input3,...
    %                                errors1,errors2,errors3,...
    %                                SIG_EP_INPUTS,reps,sto,alt_error,...
    %                                sort_condition,split_F_option,transfer_option,TUNE);
%end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    sort_condition_pre=0;
    
   [input1s,input2s,input3s,errors1s,errors2s,errors3s,CHOICE_TRUES] = pre_sort(input1,input2,input3,...
                                                                    errors1,errors2,errors3,CHOICE_TRUE,...
                                                                    sort_condition_pre,TUNE,sto,reps,...
                                                                    400 , 300 , 35) ;
                                                                
if smm_est_option(2)~=0
    
    cc1 = corrcoef([CHOICE_TRUES(:,1)==1;CHOICE_TRUES(:,2)==1;CHOICE_TRUES(:,3)==1],[input1s(:,1);input2s(:,1);input3s(:,1)]);
    cc2 = corrcoef([(CHOICE_TRUES(:,1)==2 | CHOICE_TRUES(:,1)==3);...
                    (CHOICE_TRUES(:,2)==2 | CHOICE_TRUES(:,2)==3);...
                    (CHOICE_TRUES(:,3)==2 | CHOICE_TRUES(:,3)==3)]...
                    ,[input1s(:,1);input2s(:,1);input3s(:,1)]);
    cc3 = corrcoef([CHOICE_TRUES(:,1)==4;CHOICE_TRUES(:,2)==4;CHOICE_TRUES(:,3)==4],[input1s(:,1);input2s(:,1);input3s(:,1)]);
    
    
%    cc1 = corrcoef(CHOICE_TRUES(:,3)==1,input3s(:,1));
%    cc2 = corrcoef((CHOICE_TRUES(:,3)==2 | CHOICE_TRUES(:,3)==3),input3s(:,1));
%    cc3 = corrcoef(CHOICE_TRUES(:,3)==4 ,input3s(:,1));    

    moments = [mean(CHOICE_FULL==1) ...
               mean(CHOICE_FULL==2 | CHOICE_FULL==3) ...
               mean(CHOICE_FULL==4) ...
               cc1(1,2)  ...
               cc2(1,2)  ...
               cc3(1,2)  ...
               ]; 
else
    moments = [mean(CHOICE_FULL==1) ...
               mean(CHOICE_FULL==2 | CHOICE_FULL==3) ...
               mean(CHOICE_FULL==4)];
end



%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% HERE IS ESTIMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ESTIMATION_OPTION==1
    
  %  smm_est_option=[ 4 1 200 ];
  % smm_est_option = [4 2 50];
    
   % if smm_est_option(1)==3 || smm_est_option(1)==4
       alt_error = normrnd(0,1,size(input1s,1),3);
   % end
    
       %%%% TRY THIS %%%%
    sort_condition=99;

    if smm_est_option(2)==4
        SHR2 = max(CHOICE_TRUES==3,[],2)==1 ;
        SHR_I= max(CHOICE_TRUES==2,[],2)==1 & max(CHOICE_TRUES==4,[],2)==0 & max(CHOICE_TRUES==3,[],2)==0 ;
        SHR_A= max(CHOICE_TRUES==2,[],2)==1 & max(CHOICE_TRUES==4,[],2)==1 & max(CHOICE_TRUES==3,[],2)==0 ;
        III  = sum(CHOICE_TRUES==1,2)==3 ;
        IIA  = sum(CHOICE_TRUES==1,2)==2 &   sum(CHOICE_TRUES==4,2)==1 ;
        IAA  = sum(CHOICE_TRUES==1,2)==1 &   sum(CHOICE_TRUES==4,2)==2 ;
        AAA  = sum(CHOICE_TRUES==4,2)==3  ;   
        moments_new = mean([SHR2 SHR_I SHR_A III IIA IAA AAA]);
        moments=moments_new;
    end
                                                   
  % given = 30;
  % given = 35
                    obj = @(a1) smm_shell_v3_more_moments(a1,given,moments,smm_est_option,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,alt_error,...
                                    sort_condition,split_F_option,transfer_option,TUNE) ;
                   a = a_start ;
                                        
                     tic
                     %a     = [400 80 50 10];
                     x1 = fminsearch(obj,a); 
        x_m = x1;
        [h_m,mm]=obj(x1);
        R = [.6 .7 1.3 1.5];
        for r = 1:size(R,2)
           a1=a.*R(r);
           x1a = fminsearch(obj,a1);
           [h,moments_eqm]=obj(x1a);
           x_m(1+r,:)=x1a;
           h_m(1+r,:)=h;
           mm(1+r,:)=moments_eqm;
        end
    
        h_m
        x_m
        mm
        moments
        
        x1 = x_m(repelem(min(h_m),size(h_m,1),1)==h_m,:);
        x1 = x1(1,:);
        TOC=toc;
                     
[~,moments_eqm] ...
                    =  smm_shell_v3_more_moments(x1,given,moments,smm_est_option,...
                                    input1s,input2s,input3s,...
                                    errors1s,errors2s,errors3s,...
                                    SIG_EP_INPUTS,reps,sto,alt_error,...
                                    sort_condition,split_F_option,transfer_option,TUNE);
                                  
   %%%%% DISPLAY RESULTS %%%%%
   %{a
   obj(x1)
   TOC
   a
   x1
   moments
   moments_eqm
   %}
   %%%%%%%%%%%%%%%%%%%%%%%%%%
                                            
                                            
    if isempty(BOOT)~=1
        %{
        if BOOT(1)>1
            x_pre=csvread(strcat('smmBOOT_',num2str(est_version),'.csv'));
            x_post=[x_pre x1];
            csvwrite(strcat('smmBOOT_',num2str(est_version),'.csv'),x_post);
        else
            csvwrite(strcat('smmBOOT_',num2str(est_version),'.csv'),x1);            
        end
        %}
        if mac==1
            csvwrite(strcat('BOOT/xsmmBOOTgroup',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),x1');
            csvwrite(strcat('BOOT/momentsBOOTgroup',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),moments);
            csvwrite(strcat('BOOT/moments_eqmBOOTgroup',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),moments_eqm);
        else
            csvwrite(strcat('BOOT\xsmmBOOTgroup',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),x1');
            csvwrite(strcat('BOOT\momentsBOOTgroup',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),moments);
            csvwrite(strcat('BOOT\moments_eqmBOOTgroup',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),moments_eqm);            
        end
    else
        csvwrite(strcat('smm_group_',num2str(est_version),'.csv'),x1');
    end
                    


            if print==1                            
                        vnum = length(x1);    %%% SET VNUM HERE !!!
                                    TRUTHp = a_start(1:vnum);
                                    x1p    =    x1(1:vnum) ;

            fprintf(fileID,'%s\r\n',' ');
            if split_F_option==1
                fprintf(fileID,'%s\r\n','Split F evenly');
            end
            if transfer_option==1
                fprintf(fileID,'%s\r\n','Include transfers');
            end
            if transfer_option==2
                fprintf(fileID,'%s\r\n','Include only positive transfers');
            end
            %if censor_negative_option==1
            %    fprintf(fileID,'%s\r\n','Prevent sharing with no consumption');
            %end
            fprintf(fileID,'%s %1.3f\r\n','Time : ',TOC);
            fprintf(fileID,'%s\t %s\t \r\n','Truth','Est');
            fprintf(fileID,'%1.2f\t %1.2f\t  \r\n',[TRUTHp; x1p]);
            fprintf(fileID,'%s\r\n',' ');
            fprintf(fileID,'%s\t %s\t %s\t \r\n','Ind','Shr','Alt');
            fprintf(fileID,'%1.2f\t %1.2f\t %1.2f\t \r\n',  [moments_eqm(1); moments_eqm(2); moments_eqm(3)]);
            fprintf(fileID,'%s\r\n','True :');
            fprintf(fileID,'%1.2f\t %1.2f\t %1.2f\t \r\n',   [moments(1);     moments(2);     moments(3)]);
            if smm_est_option(2)==1 || smm_est_option(2)==2
            fprintf(fileID,'%s\t %s\t %s\t \r\n','Ind C','Shr C','Alt C');
            fprintf(fileID,'%1.2f\t %1.2f\t %1.2f\t \r\n',...
                            [moments_eqm(4); moments_eqm(5); moments_eqm(6)]);
            fprintf(fileID,'%s\r\n','True :');
            fprintf(fileID,'%1.2f\t %1.2f\t %1.2f\t \r\n',...
                            [moments(4);     moments(5);     moments(6)]);
            end
            fprintf(fileID,'%s\r\n',' ');            
            end
else

    
%%%%%%%%%%%%% !DOWN HERE WE GET DOWN TO COUNTERFACTUALS! %%%%%%%%%%%%% 
%%%%%%%%%%%%% !DOWN HERE WE GET DOWN TO COUNTERFACTUALS! %%%%%%%%%%%%% 
%%%%%%%%%%%%% !DOWN HERE WE GET DOWN TO COUNTERFACTUALS! %%%%%%%%%%%%% 


    if smm_est_option(1)==3 || smm_est_option(1)==4
        rng(1)
       alt_error = normrnd(0,1,size(input1,1),3);
    end
        x1 = csvread(strcat('smm_group_',num2str(est_version),'.csv'));
    
end
   
end    
    

