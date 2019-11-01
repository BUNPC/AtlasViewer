function [pialvol, fs2viewer, status] = fs2pialvol(fs2viewer)

pialvol = initPialvol();
status = 1;

dirname = fs2viewer.mripaths.volumes;


pialmri = MRIread(fs2viewer.layers.gm.filename);
if isempty(pialmri) | isempty(pialmri.vol)
    return;
end

%%%% Write the pial volume to the pial.bin file
pialvol.img = pialmri.vol;
pialvol.tiss_prop(1) = get_tiss_prop('gm');
[pialvol.orientation, pialvol.T_2ras] = getOrientationFromMriHdr(pialmri);
c = findcenter(pialvol.img);

status = 0;

