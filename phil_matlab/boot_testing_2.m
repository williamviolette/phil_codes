function [next_level_index,boot_sample,next_level_index_2,boot_sample_2] = boot_testing_2(index,index_2,boot_sample_index)

% rng(2)
% index = [  3 3 4 4  ]
% index_2=ones(sum(index),1);
% index_2(10:end)=8

%{
index = g-1;
index_2 = t;
boot_sample_index=gindex;
%}

index_id_start_values=cumsum(index)-index+1;

    boot_sample         = index(boot_sample_index);
    boot_sample_start_values = index_id_start_values(boot_sample_index);

boot_sample_start_values_rep = ...
    repelem(boot_sample_start_values,boot_sample,1);

ones_ind=ones(sum(boot_sample),1);

boot_sample_index_expanded=repelem((1:length(boot_sample))',boot_sample,1);

result = accumarray(boot_sample_index_expanded, ones_ind, [], @(x) {cumsum(x)});
result = vertcat(result{:});

next_level_index=boot_sample_start_values_rep+result-1;

if nargin>1
    index_id_start_values_2=cumsum(index_2)-index_2+1 ;
    
    boot_sample_2 = index_2(next_level_index);
    boot_sample_start_values_2 = index_id_start_values_2(next_level_index);

    boot_sample_start_values_rep_2 = ...
    repelem(boot_sample_start_values_2,boot_sample_2,1);
    
    ones_ind_2=ones(sum(boot_sample_2),1);

    boot_sample_index_expanded_2=repelem((1:length(boot_sample_2))',boot_sample_2,1);

    result_2 = accumarray(boot_sample_index_expanded_2, ones_ind_2, [], @(x) {cumsum(x)});
    result_2 = vertcat(result_2{:});

    next_level_index_2=boot_sample_start_values_rep_2+result_2-1;
end
    
    
end