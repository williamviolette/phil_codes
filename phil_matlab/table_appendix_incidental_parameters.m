function h = table_appendix_incidental_parameters(mac,est_version1,est_version2)


mac=1;
est_version1=388;
est_version2=389;



if mac==1
    slash = '/';
else
    slash = '\';
end

% obs : 5000 hhs
% time periods : 38 months, around half!

Tstep1_v1=csvread(strcat('tables',slash,'TRUTHp_step1_',num2str(est_version1),'.csv'))
Estep1_v1=csvread(strcat('tables',slash,'ESTp_step1_',num2str(est_version1),'.csv'))
Estep1_v2=csvread(strcat('tables',slash,'ESTp_step1_',num2str(est_version2),'.csv'))

Tstep2_v1=csvread(strcat('tables',slash,'TRUTH_step2_',num2str(est_version1),'.csv'))
Estep2_v1=csvread(strcat('tables',slash,'ESTp_step2_',num2str(est_version1),'.csv'))
Estep2_v2=csvread(strcat('tables',slash,'ESTp_step2_',num2str(est_version2),'.csv'))

Tstep3_v1=csvread(strcat('tables',slash,'TRUTH_step3_',num2str(est_version1),'.csv'))
Estep3_v1=csvread(strcat('tables',slash,'ESTp_step3_',num2str(est_version1),'.csv'))
Estep3_v2=csvread(strcat('tables',slash,'ESTp_step3_',num2str(est_version2),'.csv'))




HLINE=0;

fileID = fopen(strcat('tables',slash,'incidental_parameters.tex'),'w');

fprintf(fileID,'%s\n','\begin{tabular}{|lccccc|}');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','Parameter & True Value & Est: Full T & (\% Diff)  & Est: 50\% T & (\% Diff) \\');
fprintf(fileID,'%s\n','\hline');
fprintf(fileID,'%s\n','\hline');


%%%%%%% ALPHA! (PUT MORE IN AND DESCRIBE THEM)

[~] = incidental_print('$\sigma_{\epsilon}$',1,Tstep1_v1,Estep1_v1,Estep1_v2,fileID);
[~] = incidental_print('$\sigma_{\eta}$',2,Tstep1_v1,Estep1_v1,Estep1_v2,fileID);
[~] = incidental_print('$\alpha$',3,Tstep1_v1,Estep1_v1,Estep1_v2,fileID);
[~] = incidental_print('$\gamma$ (avg.)',4,Tstep1_v1,Estep1_v1,Estep1_v2,fileID);
[~] = incidental_print('$p_h$',1,Tstep2_v1,Estep2_v1,Estep2_v2,fileID);
[~] = incidental_print('$F$',1,Tstep3_v1,Estep3_v1,Estep3_v2,fileID);
[~] = incidental_print('$F_v$',2,Tstep3_v1,Estep3_v1,Estep3_v2,fileID);
[~] = incidental_print('$p_v$',3,Tstep3_v1,Estep3_v1,Estep3_v2,fileID);
[~] = incidental_print('$\sigma_v$',4,Tstep3_v1,Estep3_v1,Estep3_v2,fileID);

fprintf(fileID,'%s\n','\hline');

fprintf(fileID,'%s\n','\end{tabular}'); 

fclise(fileID);



