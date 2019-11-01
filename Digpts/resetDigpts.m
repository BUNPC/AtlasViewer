function digpts = resetDigpts(digpts)

if ishandles(digpts.handles.hSrcpos)
    delete(digpts.handles.hSrcpos);
end

if ishandles(digpts.handles.hDetpos)
    delete(digpts.handles.hDetpos);
end

if ishandles(digpts.handles.hOptodes)
    delete(digpts.handles.hOptodes);
end

if ishandles(digpts.handles.hPcpos)
    delete(digpts.handles.hPcpos);
end

if ishandles(digpts.handles.hRefpts)
    delete(digpts.handles.hRefpts);
end

digpts.handles.hSrcpos  = [];
digpts.handles.hDetpos  = [];
digpts.handles.hOptodes = [];
digpts.handles.hPcpos   = [];
digpts.handles.hRefpts  = [];

digpts.refpts = initRefpts();
digpts.srcpos = [];
digpts.detpos = [];
digpts.pcpos  = [];
