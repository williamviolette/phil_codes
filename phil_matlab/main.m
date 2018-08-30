



    %{a
    

    
clear;
rng(1);
    
print                   = 1;  %%% $$$ DEFAULT OPTIONS
est_version             = 10;
tag                     = 'v1';
tag_g                   = 'v1';
only_alpha              = 0;
mac                     = 1 ;
moffitt                 = 1 ;    % 0: standard % 1: norm added
control_size             = 10;
est_title               = ' try 2000 '; 

cd '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_code/phil_matlab/';
cd_dir  = '/Users/williamviolette/Documents/Philippines/phil_analysis/phil_generated/';
%%% $$$  PERFECT VARIATION OPTIONS
perf_var                = 0;
        Q_obs_range     = [10 80];
        p_var           = 2;
        i               = 200;
        reps            = 100;

controls        = [3  5  9    9   2]; % [sig_ep sig_nu alpha other_controls(1 is hhsize, 2 is SHH)  SHH_control(0:off 2:on!)]

%%% $$$  REAL DATA OPTIONS
real_data               = 1; % first: controls data, second: controls random subsample
        sample   = [   1    0    0   1  ]; % standard rts rtc  GROUP
        size_smp = [   5000    0   0    ];
%%% $$$ STARTING VALUES
        TUNE = 1; %% set linear tuning parameter
     sig_ep  = 5.*ones(1,controls(1));            
     sigma_1 = 12.*ones(1,controls(2) + (controls(5)>0).*2); % need to keep this small?? what if it gets too big??
     alpha_1 =  .5.*ones(1,controls(3)) ;
     
%%% $$$ PH ESTIMATION OPTIONS
     PH = 5;
     ph_controls = [ 2   1 ] ; %% 1st entry: 1 is normal , 2 is with distance house_avg, 3 adds a squared term
     pollfish    = [ 1 .297 ] ;
%%% $$$ SMM ESTIMATION OPTIONS
  %  ESTIMATION_OPTION = 1;
smm_est_option  = [ 4 ... % [0 (else): F,FA ;  1: F,FA,PA ;  2: F,PA (FA=0) ;  3: F,PA,a_sigma (FA=0) ;  4: F,FA,PA,a_sigma ] ]
                    1 ... % [0 (else): simple moments; 1 : covariance moments; 2 : first covariance moments (not alterantive, can't fit, come back..) ]
                    200 ]; % (else empty) weights share moments (relative to covariance moments) high weights ensure shares are hit
                    
    sort_condition  = 0; % 0 (else): by beta;  1: by net utility (with alternative);  2: by consumption
    split_F_option  = 0; % 0 (else): no split;  1: split evenly
    transfer_option = 1; % 0 (else): no transfer;  1: transfers ; 2: only positive transfers
    censor_negative_option = 0; % 0 (else): no censoring;  1: with censoring  (prevent zero consumption with negative utility)
    given = 50; % pa mean at this point 
         reps = 10;
         sto  = 5;
    a_start =  [ 400 80 50 10 ];
    %%% $$$ COUNTERFACTUAL TIME
    ESTIMATION_OPTION = 1;
    COST_INPUTS=[ 5 225 ]; % MARGINAL COST  , CONNECTION FEE (and fixed cost)
    
        alt_sample=.0601;
        
        boot_estimates=0;  % 0 : standard, 1 : use bootstrapped average estimates for counterfactuals
        
     %   income_percentile=10;  % sets the percentile for looking at distributional effects
     group_percentile=50; % sets general percentile for looking at distributional effects
     
    boot_max = 30;

    C_FEE_DISCOUNT = 45; % used to be .05
    BOOT=[];

    appending = 0 ;    
    options=optimoptions('fminunc','Algorithm','trust-region','GradObj','on','Hessian','on','MaxIter',10000,'TolX',1e-10, 'TolFun', 1e-10 );
if appending~=1
    fileID=fopen(strcat(cd_dir,'results/','eNORM',num2str(est_version),' ',est_title,'.txt'),'w');
    fprintf(fileID,'%s\r\n',est_title);
    fprintf(fileID,'%s\r\n',' ');
end



%for i = 4:30
%   BOOT=[i];
                %{
  [~]=est1(print,tag,tag_g,mac,sample,size_smp,...
                        sig_ep,sigma_1,alpha_1,...
                        perf_var,Q_obs_range,p_var,i,reps,fileID,options,...
                        only_alpha,real_data,est_version,controls,BOOT,TUNE,cd_dir);
                %}
       
                %{
  [~]=est2(PH,print,tag_g,mac,...
                    fileID,est_version,controls,ph_controls,pollfish,real_data,BOOT,TUNE,cd_dir);
                %}  
                
                %{
[~]=est3(print,tag,mac,size_smp,...
                    fileID,est_version,controls,control_size,ph_controls,given,...
                    a_start,sto,reps,...
                    sort_condition,split_F_option,transfer_option,smm_est_option,...
                    real_data,TUNE,BOOT,boot_max,boot_estimates,ESTIMATION_OPTION,cd_dir);
                %} 
%end


%%%% DO THE COUNTERFACTUALS HERE PLEASE !




    %{a
    
   
%{
        %%% TABLES! 

        [~]=table_step_1_estimates...
            (est_version,tag,controls,sample,size_smp,boot_max,mac);

        [~]=table_step_1_elasticities...
            (est_version,tag,controls,sample,size_smp,boot_max,mac,TUNE);

        [~]=table_step_2_estimates...
            (est_version,tag,boot_max,mac);

        [~]=table_step_3_estimates...
            (est_version,tag,boot_max,mac,control_size,size_smp,alt_sample);

%} 
if appending~=1
    fclose(fileID);
end


    %}
