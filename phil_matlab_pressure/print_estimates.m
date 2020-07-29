function [h]=print_estimates(cd_dir,r,rb,ver)

%     if boot==1
%         rb=zeros(size(rb,1),size(rb,2));
%     end

for i = 1:6 
    wnum(cd_dir,strcat('est_gamma_',num2str(i),'_',ver,'.tex'),r(i),'%5.2f');
        wnum(cd_dir,strcat('est_gamma_sd_',num2str(i),'_',ver,'.tex'),std(rb(i,:)),'%5.3f');
end
 
for i = 1:3
    wnum(cd_dir,strcat('est_theta_',num2str(i),'_',ver,'.tex'),r(end-6+i),'%5.2f');
        wnum(cd_dir,strcat('est_theta_sd_',num2str(i),'_',ver,'.tex'),std(rb(end-6+2,:)),'%5.2f');
end

    wnum(cd_dir,strcat('est_alpha_',ver,'.tex'),r(end-2),'%5.3f');
        wnum(cd_dir,strcat('est_alpha_sd_',ver,'.tex'),std(rb(end-2,:)),'%5.3f');
        
    wnum(cd_dir,strcat('est_sig_ep_',ver,'.tex'),r(end-1),'%5.1f');
        wnum(cd_dir,strcat('est_sig_ep_sd_',ver,'.tex'),std(rb(end-1,:)),'%5.2f');

    wnum(cd_dir,strcat('est_sig_up_',ver,'.tex'),r(end),'%5.1f');
        wnum(cd_dir,strcat('est_sig_up_sd_',ver,'.tex'),std(rb(end,:)),'%5.2f');
     
h=0;
