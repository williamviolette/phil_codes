function  [X,t]=sub_sample(condition,X,t)

       id=repelem((1:length(t))',t,1);
       X=X(condition,:);
       id=id(condition,:);
       t=accumarray(id,ones(length(id),1));
       t=t(t~=0);