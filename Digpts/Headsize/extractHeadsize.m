function [HC, NzCzIz, LPACzRPA] = extractHeadsize(headsize)
scalefactor = .1;

if headsize.isempty(headsize)
    HC          = headsize.default.HC;
    NzCzIz      = headsize.default.NzCzIz;
    LPACzRPA    = headsize.default.LPACzRPA;
else
    HC          = headsize.HC;
    NzCzIz      = headsize.NzCzIz;
    LPACzRPA    = headsize.LPACzRPA;
end
HC          = scalefactor*HC;
NzCzIz      = scalefactor*NzCzIz;
LPACzRPA    = scalefactor*LPACzRPA;

