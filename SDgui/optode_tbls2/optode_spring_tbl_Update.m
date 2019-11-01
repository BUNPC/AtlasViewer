function optode_spring_tbl_Update(handles,val,idxcell,action)

hObject = handles.optode_spring_tbl;
userdata = get(hObject,'userdata');
tbl_size = userdata.tbl_size;

if exist('idxcell','var') && ~isempty(idxcell) && length(idxcell)==2
   r = idxcell(1);
   c = idxcell(2);
   ncols = 3;
   D = get(hObject,'data');
   D{r,c}=num2str(val);
   for i=1:ncols
       l(i)=length(D{r,i});
   end
   if r>tbl_size && all(l>0)
      tbl_size=tbl_size+1;
   end
   
   sd_data_AddEditSpring(r,[str2num(D{r,1}) str2num(D{r,2}) str2num(D{r,3})]);
   
elseif exist('idxcell','var') && ~isempty(idxcell) && length(idxcell)==1
   if strcmp(action,'delete')
      r = idxcell(1);
      D = get(hObject,'data');
      D(r,:)=[];
      D(end+1,:)={'','',''};
      tbl_size=tbl_size-1;   

      % Update SD
      sd_data_DeleteSpring(r);
      
   elseif strcmp(action,'add')
      r = idxcell(1);
      D = get(hObject,'data');
      tbl_size=tbl_size+1;
      for i=tbl_size:-1:r+1
          D(i,:)=D(i-1,:);
      end
      D{r,1}=num2str(val(r,1));
      D{r,2}=num2str(val(r,2));
      D{r,3}=num2str(val(r,3));

      % Update SD
      sd_data_AddEditSpring(r,[str2num(D{r,1}) str2num(D{r,2}) str2num(D{r,3})]);
   end
else
   sl = val;
   D=repmat({'' '' ''},300,1);
   tbl_size = size(sl,1);
   for i=1:tbl_size
       D{i,1}=num2str(sl(i,1));
       D{i,2}=num2str(sl(i,2));
       D{i,3}=num2str(sl(i,3));
   end
   
   % Update SD
   sd_data_SetSpringList(D,tbl_size);

end

userdata.tbl_size = tbl_size;
set(hObject,'data',D,'userdata',userdata);

