function [headvol, fs2viewer, status] = fs2headvol(fs2viewer)

headvol = initHeadvol();
status = 1;

if isempty(fs2viewer.threshold)
	c = inputdlg('MRI IMAGE THRESHOLD FOR NOISE REDUCTION (Click CANCEL for default value):');
	if isempty(c)
	    fs2viewer.threshold = 30;
	else
	    fs2viewer.threshold = str2num(c{1});
	end
end

[fs2viewer, status] = create_hseg(fs2viewer);
if isempty(fs2viewer.hseg)
    return;
end

headvol.img = fs2viewer.hseg.volume.vol;
headvol.T_2ras = fs2viewer.hseg.volume.vox2ras;

for ii=1:length(fs2viewer.hseg.tiss_type)
    headvol.tiss_prop(ii) = get_tiss_prop(fs2viewer.hseg.tiss_type{ii});
end

