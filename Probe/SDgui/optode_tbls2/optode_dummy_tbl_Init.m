function optode_dummy_tbl_Init(handles, OptPos, noptorig)

hObject = handles.optode_dummy_tbl;

MAXTBLSIZE=100;
nopt = size(OptPos,1);
for i=1:MAXTBLSIZE
   if i<=nopt
      D{i,1} = num2str(i+noptorig);
      D{i,2} = real2str( OptPos(i,1));
      D{i,3} = real2str( OptPos(i,2));
      D{i,4} = real2str( OptPos(i,3));
      D{i,5} = '';
      D{i,6} = '';
   else
      D{i,1} = '';
      D{i,2} = '';
      D{i,3} = '';
      D{i,4} = '';
      D{i,5} = '';
      D{i,6} = '';
   end
end
userdata.tbl_size = nopt;
userdata.selection = [];
set(hObject,'data',D,'userdata',userdata);
