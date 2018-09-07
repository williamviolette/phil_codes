function [t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,CONTROL]=...
    data_prep(est_version,sample,size_smp,tag,tag_g,control_size,RLENGTH,BOOT,cd_dir)

%%% test
%{
 sample = [1 1 1]
 size_smp = [0 0 0]
 mac=0
 tag='v1_test'
%}

if isempty(BOOT)~=1
    rng(BOOT(1));
end
 
 %    xtest = grpstats(X,repelem((1:length(t))',t,1)); % take averages for each individual

 
if sample(1)==1
    t          = csvread(strcat(cd_dir,'standard_t_',tag,'.csv'),1,0)  ;
    if size_smp(1)>0
        t=t(1:size_smp(1));
    end
        X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 sum(t) (4+control_size) ]);
    if isempty(BOOT)~=1
        [i_B,t,~] = boot_testing(t);  
        X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 max(i_B) (4+control_size) ]);
        X = X(i_B,:);
        %{
                    if BOOT(1)>1
                        i_pre=csvread(strcat('BOOT/iBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
                        i_post=[i_pre i_B];
                        csvwrite(strcat('BOOT/iBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),i_post);
                        t_pre=csvread(strcat('BOOT/tBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
                        t_post=[t_pre t];
                        csvwrite(strcat('BOOT/tBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),t_post);
                    else

                        csvwrite(strcat('BOOT/iBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),i_B);    
                        csvwrite(strcat('tBOOT',num2str(est_version),'.csv'),t); 
                    end
       %}
                        dlmwrite(strcat(cd_dir,'BOOT/iBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),i_B,'precision',20);    
                        csvwrite(strcat(cd_dir,'BOOT/tBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),t);       
    end
end


if sample(2)==1
    t2          = csvread(strcat(cd_dir,'rts_t_',tag,'.csv'),1,0)  ;
    if size_smp(2)>0
        t2=t2(1:size_smp(2));
    end
    X2          = csvread(strcat(cd_dir,'rts_',tag,'.csv'),1,0, [ 1 0 sum(t2) (4+control_size) ]);
    if isempty(BOOT)~=1
        [i_B2,t2,~] = boot_testing(t2); 
        X2          = csvread(strcat(cd_dir,'rts_',tag,'.csv'),1,0, [ 1 0 max(i_B2) (4+control_size) ]);
        X2 = X2(i_B2,:);
    end
    if sample(1)==1
        X=[X;X2];
        t=[t;t2];
    else
        X=X2;
        t=t2;
    end
end

if sample(3)==1
    t3          = csvread(strcat(cd_dir,'rtc_t_',tag,'.csv'),1,0)  ;
    if size_smp(3)>0
        t3=t3(1:size_smp(3));
    end
    X3          = csvread(strcat(cd_dir,'rtc_',tag,'.csv'),1,0, [ 1 0 sum(t3) (4+control_size) ]);
    if isempty(BOOT)~=1
        [i_B3,t3,~] = boot_testing(t3);
        X3          = csvread(strcat(cd_dir,'rtc_',tag,'.csv'),1,0, [ 1 0 max(i_B3) (4+control_size) ]);
        X3 = X3(i_B3,:);
    end
    if sample(1)==1 || sample(2)==1
        X=[X;X3];
        t=[t;t3];
    else
        X=X3;
        t=t3;
    end
end


if length(size_smp)>3 %% ENSURE THAT ALL SAMPLING OCCURS BEFORE THE SECOND STAGE GROUP
    vol_smp=size_smp(4);
       if vol_smp>0
           %%% VOLUME SUBSAMPLE
           condition=    repelem((...
                   (accumarray(repelem((1:length(t))',t,1),X(:,1))./t) ...
               <= prctile((accumarray(repelem((1:length(t))',t,1),X(:,1))./t)...
               ,vol_smp) ...
               ),t,1);
           [X,t]=sub_sample(condition,X,t);
       end
end


if length(sample)>3
    if sample(4)==1
        t4      = csvread(strcat(cd_dir,'pre_t_',tag_g,'.csv'),1,0);
        X4      = csvread(strcat(cd_dir,'pre_',tag_g,'.csv'),1,0, [ 1 0 sum(t4) (4+control_size) ]);
            if isempty(BOOT)~=1
                g          = csvread(strcat(cd_dir,'g_',tag_g,'.csv'),1,0)  ;   
                [~,~,gBindex,i_GB,t4] = boot_testing(g,t4);
                X4      = csvread(strcat(cd_dir,'pre_',tag_g,'.csv'),1,0, [ 1 0 max(i_GB) (4+control_size) ]);
                X4=X4(i_GB,:); %%
                %{
                    if BOOT(1)>1
                        g_pre=csvread(strcat('gBOOT',num2str(est_version),'.csv'));
                        g_post=[g_pre gBindex];
                        csvwrite(strcat('gBOOT',num2str(est_version),'.csv'),g_post);
                    else
                        csvwrite(strcat('gBOOT',num2str(est_version),'.csv'),gBindex);            
                    end
               %}
                    csvwrite(strcat(cd_dir,'BOOT/gBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'),gBindex);
            end
        if sample(1)==1 || sample(2)==1 || sample(3)==1
            X=[X;X4];
            t=[t;t4];
        else
            X=X4;
            t=t4;
        end        
    end
end


if RLENGTH>0
    R=[];
    for r=1:length(t)
        R = [R; (1:t(r))'];
    end
    condition = R<=RLENGTH;
    [X,t]=sub_sample(condition,X,t);
end



    k_1=10.*ones(sum(t),1);
    k_2=20.*ones(sum(t),1);
    k_3=40.*ones(sum(t),1);
    
    p_1    = X(:,2) ;
    p_2    = X(:,3) ;
    p_3    = X(:,4) ;
    p_4    = X(:,5) ;
    
    Q_obs  = X(:,1) ; 
    
    
    
    CONTROL = X(:,6:5+control_size);
    
    
    
    
    
    
    