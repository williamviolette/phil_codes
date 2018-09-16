function h=table_step_1_estimates...
    (est_version,tag,tag_g,controls,sample,size_smp,boot_max,mac,cd_out,cd_dir)

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

%t = data_prepc_v4(est_version,sample,size_smp,mac,tag,control_size,0,[]);
t = data_prep(est_version,sample,size_smp,tag,tag_g,control_size,0,[],cd_dir);

OBS=sum(t);
HH=length(t);

%R_to_S=size_smp(2);

if mac==1
    slash='/';
else
    slash='\';
end

X_ORIGINAL = csvread(strcat(cd_dir,slash,'results',slash,'x',num2str(est_version),'.csv'));
X_ORIGINAL = X_ORIGINAL(1:sum(controls(1:3)+SHH_control));

X = csvread(strcat(cd_dir,'BOOT',slash,'xBOOT',num2str(est_version),'_',num2str(1),'.csv'));
X = X(1:sum(controls(1:3)+SHH_control));
for i = 2:boot_max
       x_r = csvread(strcat(cd_dir,'BOOT',slash,'xBOOT',num2str(est_version),'_',num2str(i),'.csv'))  ;
   X   = [X(1:sum(controls(1:3))+SHH_control,:) x_r(1:sum(controls(1:3))+SHH_control)]            ;
end

Xmean=mean(X_ORIGINAL,2);
Xstd=std(X,0,2);

as = 2; %%% Deals with fewer controls since the sig nu reduction

fileID = fopen(strcat(cd_out,'tables/step_1_estimates_group.tex'),'w');


fprintf(fileID,'%s\n','\begin{tabular}{lcc}');
fprintf(fileID,'%s\n','& Estimate & Standard Error \\');
fprintf(fileID,'%s\n','Price Sensitivity : $\alpha$ & \multicolumn{2}{c}{}\\');
fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');


%%%%%%% ALPHA! (PUT MORE IN AND DESCRIBE THEM)


fprintf(fileID,'%s\n',strcat('Intercept &', ...
                    num2str(Xmean(11-as),'%5.2f'),'&', num2str(Xstd(11-as),'%5.2f'),'\\'));

fprintf(fileID,'%s\n',strcat('HHsize 4 to 5 &', ...
                    num2str(Xmean(12-as),'%5.3f'),'&', num2str(Xstd(12-as),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('HHsize over 5 &', ...
                    num2str(Xmean(13-as),'%5.3f'),'&', num2str(Xstd(13-as),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('Apartment &', ...
                    num2str(Xmean(14-as),'%5.3f'),'&', num2str(Xstd(14-as),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('Single House &', ...
                    num2str(Xmean(15-as),'%5.3f'),'&', num2str(Xstd(15-as),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('Low Skill Emp. &', ...
                    num2str(Xmean(16-as),'%5.3f'),'&', num2str(Xstd(16-as),'%5.3f'),'\\'));

fprintf(fileID,'%s\n',strcat('Over 2 Empl. Members &', ...
                    num2str(Xmean(17-as),'%5.3f'),'&', num2str(Xstd(17-as),'%5.3f'),'\\'));

%%% NOTE THAT THESE ARE REVERSED ! 
    fprintf(fileID,'%s\n',strcat('$\alpha$: HH Head 36 to 52 years  &', ...
                        num2str(Xmean(19-as),'%5.3f'),'&', num2str(Xstd(19-as),'%5.3f'),'\\'));

    fprintf(fileID,'%s\n',strcat('$\alpha$: HH Head over 52 years  &', ...
                        num2str(Xmean(18-as),'%5.3f'),'&', num2str(Xstd(18-as),'%5.3f'),'\\'));

fprintf(fileID,'%s\n','\multicolumn{3}{c}{} \\');

fprintf(fileID,'%s\n','Consumption Shock : $\sigma_{\epsilon}$ & \multicolumn{2}{c}{}\\');
fprintf(fileID,'%s\n','\hline');
%fprintf(fileID,'%s\n','\hline');

%%%%% SIG EP
fprintf(fileID,'%s\n',strcat('Single HH &', ...
                    num2str(Xmean(1),'%5.2f'),'&', num2str(Xstd(1),'%5.2f'),'\\'));

fprintf(fileID,'%s\n',strcat('Two HHs &', ...
                    num2str(Xmean(2),'%5.2f'),'&', num2str(Xstd(2),'%5.2f'),'\\'));

fprintf(fileID,'%s\n',strcat('Three HHs &', ...
                    num2str(Xmean(3),'%5.2f'),'&', num2str(Xstd(3),'%5.2f'),'\\'));

fprintf(fileID,'%s\n','\multicolumn{3}{c}{} \\');

fprintf(fileID,'%s\n','Preference Shock : $\sigma_{\psi}$ & \multicolumn{2}{c}{}\\');
fprintf(fileID,'%s\n','\hline');

%%%%%%% QUINTILE OF CONSUMPTION %%%%%%%%
%    fprintf(fileID,'%s\n','\hline');

fprintf(fileID,'%s\n',strcat('Intercept &', ...
                    num2str(Xmean(6-as),'%5.2f'),'&', num2str(Xstd(6-as),'%5.2f'),'\\'));

fprintf(fileID,'%s\n',strcat('Below 1st Quintile Usage &', ...
                    num2str(Xmean(7-as),'%5.2f'),'&', num2str(Xstd(7-as),'%5.2f'),'\\'));

fprintf(fileID,'%s\n',strcat('Over 3rd Quintile Usage &', ...
                    num2str(Xmean(8-as),'%5.2f'),'&', num2str(Xstd(8-as),'%5.2f'),'\\'));

%fprintf(fileID,'%s\n',strcat('$\sigma_{\psi}$: 4th Quintile Usage &', ...
%                    num2str(Xmean(5),'%5.2f'),'&', num2str(Xstd(5),'%5.2f'),'\\'));
%fprintf(fileID,'%s\n',strcat('$\sigma_{\psi}$: 5th Quintile Usage &', ...
%                    num2str(Xmean(4),'%5.2f'),'&', num2str(Xstd(4),'%5.2f'),'\\'));

%%%%%%% SHH!
fprintf(fileID,'%s\n',strcat('Two HHs &', ...
                    num2str(Xmean(9-as),'%5.2f'),'&', num2str(Xstd(9-as),'%5.2f'),'\\'));

fprintf(fileID,'%s\n',strcat('Three HHs &', ...
                    num2str(Xmean(10-as),'%5.2f'),'&', num2str(Xstd(10-as),'%5.2f'),'\\'));
fprintf(fileID,'%s\n','\hline');

fprintf(fileID,'%s\n','\end{tabular} '); 

%fprintf(fileID,'%s\n','\vspace{.5cm}'); 

%fprintf(fileID,'%s','Total Observations:  ');
%fprintf(fileID,'%s',num2str(OBS));
%fprintf(fileID,'%s','   Total Accounts:  ');
%fprintf(fileID,'%s',num2str(HH));
%fprintf(fileID,'%s','   Rate Change Accounts:  ');
%fprintf(fileID,'%s\n',num2str(R_to_S));
            
%fprintf(fileID,'%s\n','\end{table}');                

fclose(fileID);


h=1;