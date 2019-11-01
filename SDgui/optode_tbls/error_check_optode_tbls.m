function status = error_check_optode_tbls(hObject,tbl_data1,tbl_data2,r,c)

    status=0;
    tbl_data1=tbl_data1(:,1:3);
    tbl_data2=tbl_data2(:,1:3);
    if(~isempty(tbl_data1{r,c}) & isempty(str2num(tbl_data1{r,c})))
        status = 1;
        tbl_data1{r,c}='';
        set(hObject,'data',tbl_data1);
    elseif(isempty(str2num(tbl_data1{r,c})))
        tbl_data1{r,c}='';
    else
        optpos_str = [tbl_data1; tbl_data2];
        optpos=[];
        j=1;
        for i=1:size(optpos_str,1)
            l(1)=length(optpos_str{i,1});
            l(2)=length(optpos_str{i,2}); 
            l(3)=length(optpos_str{i,3});
            if(all(l>0))
                for k=1:3
                    optpos(j,k)=str2num(optpos_str{i,k});
                end
                j=j+1;
            end
        end

        if(~isempty(optpos) & ...
            length(unique(optpos(:,1)))>1 & ...
            length(unique(optpos(:,2)))>1 & ...
            length(unique(optpos(:,3)))>1)

            status=2;
            tbl_data1{r,c}='';
            set(hObject,'data',tbl_data1);
        end
    end


