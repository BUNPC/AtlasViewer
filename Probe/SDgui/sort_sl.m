function [sl k]=sort_sl(sl)

    k=[];
    if isempty(sl)
        return;
    end
    sl0=sl;

    % Sort meas list by src (1st column)
    [foo i]=sort(sl(:,1));
    sl=sl(i,:);
    src_idxs = unique(sl(:,1))';

    % Sort meas list by src (1st column) and Det (2nd column) 
    for i=src_idxs
        k=find(sl(:,1)==i);
        if(~isempty(k))
            [foo j]=sort(sl(k,2));
            sl2 = sl(k,:);
            sl(k,:) = sl2(j,:);
        end
    end
  
    % Spring list is sorted. Now just set the output argument k
    % which are the previous sl indices of the in the current 
    % list. It shows how the list was rearranged so that it is 
    % sorted.
    for j=1:size(sl,1)
        i = find(sl(:,1)==sl0(j,1) & sl(:,2)==sl0(j,2));
        if length(i)>1
            error('Error: Spring list in wrong format - some pairs not unique.');
        end
        k(j) = i;
    end
