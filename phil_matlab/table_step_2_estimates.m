function h=table_step_2_estimates...
    (est_version,tag,boot_max,mac,cd_out,cd_dir)


%%% CONTROLS OPTION
if length(controls)>=5
    SHH_control=controls(5);
else
    SHH_control=0;
end
    
%%%%%%%% BRING IN DATA
%%%
control_total=sum(controls(1:3))+SHH_control;

    [~,~,~,~,~,~,~,~,~,~,~,~,PH_CONTROL]=...
    data_prep_smm_grouping_v2(size_smp(1),mac,tag,control_size,est_version,...
    [],ESTIMATION_OPTION,control_total,boot_max,boot_estimates,cd_dir);


    g          = csvread(strcat(cd_dir,'g_',tag,'.csv'),1,0)  ;
    t          = csvread(strcat(cd_dir,'post_t_',tag,'.csv'),1,0)  ;
    

if mac==1
    slash='/';
else
    slash='\';
end

ph = csvread(strcat(cd_dir,'results',slash,'ph',num2str(est_version),'.csv'));

ph_v = csvread(strcat(cd_dir,'BOOT',slash,'phBOOT',num2str(est_version),'_',num2str(1),'.csv'));
    for i = 2:boot_max
       ph_r = csvread(strcat(cd_dir,'BOOT',slash,'phBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
       ph_v   = [ph_v; ph_r]            ;
    end
    
Xmean = mean(ph,1);
Xstd  = std(ph_v,0,1);


PHT = ph(1) + ph(2).*PH_CONTROL(:,1) + ph(3).*PH_CONTROL(:,2);
dlmwrite(strcat(cd_dir,'results',slash,'ph_distribution.csv'),PHT,'precision',8); %% to make a histogram later

%hist(PHT,100);


%  std([ph_v(1:10) ph_v(1:10) ph_v(1:10) ph_v(1:10) ph_v(1:10)  ph_v(1:10) ph_v(20)])


if mac==1
    table_pre= 'tables/';
else
    table_pre= 'tables\';  
end



%%% MEAN HASSLE HASSLE COST

ph_corr = csvread(strcat(cd_dir,'results',slash,'correlation_ph_beta_.csv'));

    
    fileID = fopen(strcat(cd_out,table_pre,'correlation_hassle.tex'),'w');
    fprintf(fileID,'%s',num2str(ph_corr,'%5.2f'));
    fclose(fileID);
    
    fileID = fopen(strcat(cd_out,table_pre,'mean_hassle.tex'),'w');
    fprintf(fileID,'%s',num2str(mean(PHT),'%5.2f'));
    fclose(fileID);

    fileID = fopen(strcat(cd_out,table_pre,'hassle_percentage.tex'),'w');
    fprintf(fileID,'%s',num2str(mean(PHT)*100/25,'%5.1f'));
    fclose(fileID);
    
    fileID = fopen(strcat(cd_out,table_pre,'number_of_leakers.tex'),'w');
    fprintf(fileID,'%s',num2str(num2str(length(g)),'%10.0f'));
    fclose(fileID);
    
    
    
    
    
    
    fileID = fopen(strcat(cd_out,table_pre,'step_2_estimates.tex'),'w');


%fprintf(fileID,'%s\n','\begin{table}');
%fprintf(fileID,'%s\n','\centering');

%fprintf(fileID,'%s\n','\caption{Step 2: Hassle Cost Estimates}'); 
fprintf(fileID,'%s\n','\begin{tabular}{lccc}');
%fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','Hassle Cost (PhP/m3) & Sample Mean & Estimate & Standard Error \\');
%fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');


%%%%%%% ALPHA! (PUT MORE IN AND DESCRIBE THEM)


fprintf(fileID,'%s\n',strcat('Intercept & 1 &', ...
                    num2str(Xmean(1),'%5.2f'),' & ', num2str(Xstd(1),'%5.2f'),'\\'));
fprintf(fileID,'%s\n',strcat('\% Single Home/Apartment  &', ...
                    num2str(mean(PH_CONTROL(:,1)),'%5.2f'),'&',num2str(Xmean(2),'%5.2f'),'&', ...
                    num2str(Xstd(2),'%5.2f'),'\\'));
fprintf(fileID,'%s\n',strcat('Neighbor Distance &', ...
                    num2str(mean(PH_CONTROL(:,2)),'%5.2f'), '&', num2str(Xmean(3),'%5.2f'),'&', ...
                    num2str(Xstd(3),'%5.2f'),'\\'));
                
                
%fprintf(fileID,'%s\n','\hline');

fprintf(fileID,'%s\n','\end{tabular} '); 

%fprintf(fileID,'%s\n','\end{tabular} \\'); 

%fprintf(fileID,'%s\n','\vspace{.5cm}'); 

%fprintf(fileID,'%s\n','\label{table:step2estimates}'); 
%fprintf(fileID,'%s',' Leaking Connections:  ');
%fprintf(fileID,'%s',strcat(num2str(length(g)),','));
%fprintf(fileID,'%s','   Neighboring Connections:  ');
%fprintf(fileID,'%s',strcat(num2str(sum(g)),','));
%fprintf(fileID,'%s','   Obs:  ');
%fprintf(fileID,'%s\n',strcat(num2str(sum(t)),','));
            
%fprintf(fileID,'%s\n','\end{table}');                

fclose(fileID);


h=1;