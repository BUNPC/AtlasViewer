function [h1 h2]=redraw_text_many(h1,h2)

if ~exist('h2','var')
    h2=[];
end
for ii=1:length(h1)
    h1(ii)=redraw_text(h1(ii));
end
for ii=1:length(h2)
    h2(ii)=redraw_text(h2(ii));
end
