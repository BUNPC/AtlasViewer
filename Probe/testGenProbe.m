function SD = testGenProbe(dt)
if ~exist('dt','var')
    dt = 30;
end
setNamespace('AtlasViewerGUI');
atlasDir = getAtlasDir();
refpts = initRefpts();
refpts = getRefpts(refpts, atlasDir);
optpos = refpts.pos;
[srcpos, detpos, ml] = genProbeFromRefpts(optpos, dt);
SD.SrcPos = srcpos;
SD.DetPos = detpos;
SD.MeasList = ml;
n = NirsClass(SD);
SD = n.SD;
save('probe_try1.nirs','-mat','SD');

