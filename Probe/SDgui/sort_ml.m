function [ml k]=sort_ml(ml)

    k=[];
    if(isempty(ml))
        return;
    end
    ml0=ml;

    % Sort meas list by src (1st column)
    [foo i]=sort(ml(:,1));
    ml=ml(i,:);
    src_idxs = unique(ml(:,1))';

    % Sort meas list by src (1st column) and Det (2nd column) 
    for i=src_idxs
        k=find(ml(:,1)==i);
        if(~isempty(k))
            [foo j]=sort(ml(k,2));
            ml2 = ml(k,:);
            ml(k,:) = ml2(j,:);
        end
    end
  
    % Meas list is sorted. Now just set the output argument k
    % which are the previous ml indices of the in the current 
    % list. It shows how the list was rearranged so that it is 
    % sorted.
    for j=1:size(ml,1)
        i = find(ml(:,1)==ml0(j,1) & ml(:,2)==ml0(j,2));
        if(length(i)>1)
            error('Error: Measurement list in wrong format - some pairs not unique.');
        end
        k(j) = i;
    end
