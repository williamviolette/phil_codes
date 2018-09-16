function [Q_obs,k_1,k_2,k_3,p_1,p_2,p_3,p_4,x,ph,CONTROL,alt,PH_CONTROL]=...
    data_prep_smm_grouping_v2(size_smp,mac,tag,control_size,est_version,BOOT,...
    ESTIMATION_OPTION,control_total,boot_max,boot_estimates,cd_dir)

%%% test
%{
 sample = [1 1 1]
 size_smp = [0 0 0]
 mac=0
 tag='v1'
%}


%%% FIX ALT SAMPLE!!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NOTE THAT IN THE ALT I TAKE 6.01%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAMPLE

if ESTIMATION_OPTION~=1
    BOOT=[];
end

    if mac==1
        backslash='/';
    else
        backslash='\';
    end
    
    if isempty(BOOT)~=1

        t=csvread(strcat(cd_dir,'BOOT',backslash,'tBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
        %t=t(:,BOOT(1));
    else
            t          = csvread(strcat(cd_dir,'standard_t_',tag,'.csv'),1,0)  ;
        if size_smp(1)>0
            t=t(1:size_smp(1));
        end
    end
    
    
    %X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 sum(t) (4+control_size+3+2) ]);
    
    
    if isempty(BOOT)~=1
        % i_SB=csvread(strcat('iBOOT',num2str(est_version),'.csv'));
        i_SB=csvread(strcat(cd_dir,'BOOT',backslash,'iBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
        %X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 max(i_SB) (4+control_size+3) ]);
        %%% ADD PH CONTROLS
        X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 max(i_SB) (4+control_size+3+2) ]);
        %i_SB=i_SB(:,BOOT(1));
        X=X(i_SB,:);
        %t=csvread(strcat('tBOOT',num2str(est_version),'.csv'));        
        %t=csvread(strcat('BOOT\tBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
        %t=t(:,BOOT(1));
    else
        X          = csvread(strcat(cd_dir,'standard_',tag,'.csv'),1,0, [ 1 0 sum(t) (4+control_size+3+2) ]);
    end
    
 %   xa =grpstats(X,repelem((1:length(t))',t,1));
    
    X = grpstats(X,repelem((1:length(t))',t,1)); % take averages for each individual
    X = [X zeros(size(X,1),1)]; % add alternative identifier
    

    %%%% NOW ADD ALTERNATIVE !!!!
    X_alt      = csvread(strcat(cd_dir,'alt_',tag,'.csv'),1,0); %% 6% sample
    X_alt = [X_alt ones(size(X_alt,1),1)]; % add alternative identifier here too
    
    %%% INSTEAD:  DID THIS IN STATA!
        %X_alt = [X_alt ...
        %    zeros(size(X_alt,1),size(X,2)-size(X_alt,2)-1) ... % this fills in for household size missing
        %  d  ones(size(X_alt,1),1)]; % add alternative identifier here too

    if isempty(BOOT)~=1
       i_alt = datasample((1:size(X_alt,1))',size(X_alt,1),1); 
       X_alt = X_alt(i_alt,:);
    end
    
    %%% append X's
    X = [X; X_alt];
    
    k_1    = 10.*ones(size(X,1),1);
    k_2    = 20.*ones(size(X,1),1);
    k_3    = 40.*ones(size(X,1),1);
    
    p_1    = X(:,2) ;
    p_2    = X(:,3) ;
    p_3    = X(:,4) ;
    p_4    = X(:,5) ;
    
    Q_obs  = X(:,1) ; 
    
    CONTROL = X(:,6:5+control_size+3);
    
    alt    = X(:,size(X,2));
    
    %%% SECOND AND THIRD FROM THE END ARE THE CONTROLS
    PH_CONTROL = [ X(:,size(X,2)-2) X(:,size(X,2)-1)  ];
    
    
if ESTIMATION_OPTION==1
    if isempty(BOOT)~=1
             x=csvread(strcat(cd_dir,'BOOT',backslash,'xBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
             ph=csvread(strcat(cd_dir,'BOOT',backslash,'phBOOT',num2str(est_version),'_',num2str(BOOT(1)),'.csv'));
    else
        x=csvread(strcat(cd_dir,'results',backslash,'x',num2str(est_version),'.csv'));
        ph= csvread(strcat(cd_dir,'results',backslash,'ph',num2str(est_version),'.csv'))';
    end
else
    if boot_estimates==1
        xt = csvread(strcat(cd_dir,'BOOT',backslash,'xBOOT',num2str(est_version),'_',num2str(1),'.csv'));
        pht= csvread(strcat(cd_dir,'BOOT',backslash,'phBOOT',num2str(est_version),'_',num2str(1),'.csv'));
        for i = 2:boot_max
            xr=csvread(strcat(cd_dir,'BOOT',backslash,'xBOOT',num2str(est_version),'_',num2str(i),'.csv'));
            xt=[xt(1:control_total,:) xr(1:control_total)];
            phr= csvread(strcat(cd_dir,'BOOT',backslash,'phBOOT',num2str(est_version),'_',num2str(i),'.csv'));
            pht=[pht phr];
        end

            xo=csvread(strcat(cd_dir,'results',backslash,'x',num2str(est_version),'.csv'));

            x = [mean(xt(1:control_total,:),2); xo(control_total+1:end)];
            ph = mean(pht);
    else
        x=csvread(strcat(cd_dir,'results',backslash,'x',num2str(est_version),'.csv'));
        ph= csvread(strcat(cd_dir,'results',backslash,'ph',num2str(est_version),'.csv'))';
    end
        
end
    

    

    
    
    