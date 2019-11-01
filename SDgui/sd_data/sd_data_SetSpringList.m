function [sl i]=sd_data_SetSpringList(varargin)

global SD;

if length(varargin)==1
   sl = varargin{1};
   [sl i] = sort_sl(sl);
   SD.SpringList=sl;
elseif length(varargin)==2
   tbl = varargin{1};
   tbl_size = varargin{2};
   for ii=1:tbl_size
      sl(ii,1) = str2num(tbl{ii,1});
      sl(ii,2) = str2num(tbl{ii,2});
      sl(ii,3) = str2num(tbl{ii,3});
   end
end


% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
