function a = alt_controls(CONTROL)

standard_controls=9;
barangay_control =11;


barangay_id = CONTROL(:,barangay_control);
hhsize      = dummyvar(round(CONTROL(:,1)) ...
                    + round(mean(CONTROL(:,1)))...
                    .*(round(CONTROL(:,1))==0) ); %%% QUICK FIX FOR MISSING HHSIZE

                
STANDARD = [CONTROL(:,3:standard_controls) hhsize(:,2:end) ]; %% remove [+2] from [3:standard_controls+2]

full_interaction=zeros(size(STANDARD,1),1);
l=0;
for i=1:size(STANDARD,2)
    for j=1:size(STANDARD,2)
        if j>i
            l=l+1;
            full_interaction(:,l) = STANDARD(:,i).*STANDARD(:,j);
        end
    end
end

full_interaction = [STANDARD full_interaction] ;

barangay_dummies = dummyvar(grp2idx(barangay_id));

a = licols(  [full_interaction barangay_dummies(:,2:end)]  );

