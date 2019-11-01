function labelssurf = getLabelssurf(labelssurf, dirname0)

if iscell(dirname0)
    for ii=1:length(dirname0)
        labelssurf = getLabelssurf(labelssurf, dirname0{ii});
        if ~labelssurf.isempty(labelssurf)
            return;
        end
    end
    return;
end

if isempty(dirname0)
    return;
end

if dirname0(end)~='/' && dirname0(end)~='\'
    dirname0(end+1)='/';
end
dirname = [dirname0 'anatomical/'];

if exist([dirname 'labelssurf.mat'],'file')
    load([dirname 'labelssurf.mat'],'-mat');
else
    return;
end
if ~isempty(labelssurf.mesh.vertices)
    return;
end

if ishandles(labelssurf.handles.surf)
    return;
end

load([dirname 'labelssurf.mat']);
if exist([dirname 'labelssurf2vol.txt'],'file')
    T_2vol = load([dirname 'labelssurf2vol.txt'],'ascii');
end

fv = struct('vertices',[],'faces',[]);
idxL = [];
for ii=1:length(aal_fv)
    if ~isempty(aal_fv{ii}.vertices)
        fv.faces    = [fv.faces; aal_fv{ii}.faces+size(fv.vertices,1)];
        aal_fv{ii}.vertices = xform_apply(aal_fv{ii}.vertices, T_2vol);
        fv.vertices = [fv.vertices; aal_fv{ii}.vertices];
        idxL = [idxL; ii*ones(size(aal_fv{ii}.faces,1),1)];
    end
end

cm(1).col = rand(length(aal_fv),3);
cm(1).name = 'rand1';
cm(2).col = jet(length(aal_fv));
cm(2).name = 'jet';
cm(3).col = cool(length(aal_fv));
cm(3).name = 'cool';
cm(4).col = repmat([.45 .75 .35],length(aal_fv),1) + 0.04*randn(length(aal_fv),3);
cm(4).name = 'single color green';
cm(5).col = repmat([.45 .35 .75],length(aal_fv),1) + 0.04*randn(length(aal_fv),3);
cm(5).name = 'single color blue';

labelssurf.mesh = fv;
labelssurf.meshes = aal_fv;
labelssurf.names = aal_ll';
labelssurf.colormaps = cm;
labelssurf.colormapsIdx = 4;
labelssurf.idxL = idxL;
labelssurf.T_2vol = T_2vol;


if ~labelssurf.isempty(labelssurf)
    labelssurf.pathname = dirname0;
end

