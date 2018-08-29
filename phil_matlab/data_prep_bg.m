function [t,Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,gamma,x,CONTROL,CONTROL_PH,beta_O,beta_B]=...
    data_prep_bg(mac,tag_g,control_size,est_version,pollfish,BOOT,RLENGTH,real_data,cd_dir)

%%% test
%{
 sample = [1 1 1]
 size_smp = [0 0 0]
 mac=0
 tag='v1'
%}
    if mac==1
        slash='/';
    else
        slash='\';
    end

    g          = csvread(strcat(cd_dir,'g_'     ,tag_g,'.csv'),1,0)  ;
    t          = csvread(strcat(cd_dir,'post_t_',tag_g,'.csv'),1,0)  ;
    X          = csvread(strcat(cd_dir,'post_'  ,tag_g,'.csv'),1,0, [ 1 0 sum(t) (6+control_size+4) ])  ;
    if RLENGTH>0
        R=[];
        for r=1:length(t)
            R = [R; (1:t(r))'];
        end
        condition = R<=RLENGTH;
        [X,t]=sub_sample(condition,X,t);
    end

    if isempty(BOOT)~=1
            %gindex=csvread(strcat('gBOOT',num2str(est_version),'.csv'));
            gindex=csvread(strcat(cd_dir,'BOOT',slash,'gBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
            %gindex=gindex(:,BOOT(1));
            [~,~,iB,t] = boot_testing_2(g-1,t,gindex);
            X          = csvread(strcat(cd_dir,'post_',tag_v1,'.csv'),1,0, [ 1 0 max(iB) (6+control_size) ]);
            X = X(iB,:);
            %x_pre=csvread(strcat('xBOOT',num2str(est_version),'.csv'));
            x=csvread(strcat(cd_dir,'BOOT',slash,'xBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
            %x = x_pre(:,BOOT(1));
            g = g(gindex);
    else
        if real_data==1
            x=csvread(strcat(cd_dir,'results',slash,'x',num2str(est_version),'.csv'));
        else
            if mac==1
                slash = '/';
            else
                slash = '\';
            end
            x=csvread(strcat(cd_dir,'tables',slash,'TRUTH_step1_',num2str(est_version),'.csv'));
        end
    end
    
    g1 = g-1;    
    beta_full = x(length(x)-sum(g)+1:end); %%% COMPUTE BETAS
    
    
    gB = cumsum(g);
    gO = setdiff((1:sum(g))',gB);
    
    beta = beta_full(gO);
    beta_g = beta_full(gB);

    beta_B = repelem(repelem(beta_g,g1,1),t,1); % B is buyer
    beta_O = repelem(        beta       ,t,1); % O is owner

    k_1=10.*ones(sum(t),1);
    k_2=20.*ones(sum(t),1);
    k_3=40.*ones(sum(t),1);
    
    p_1    = X(:,2) ;
    p_2    = X(:,3) ;
    p_3    = X(:,4) ;
    p_4    = X(:,5) ;
    
    Q_obs  = X(:,1) ; 
    
    gamma  = X(:,6) ;
    alt_sub= X(:,7) ;
    
    if pollfish(1)==0
        gamma = gamma.*alt_sub;
    else
        gamma = gamma.*pollfish(2);
    end
    
%    gamma = gamma.*.35;
    
    CONTROL = X(:,8:7+control_size);
    
    CONTROL_PH = [ X(:,end-1) X(:,end)];
    
  

    
    
    