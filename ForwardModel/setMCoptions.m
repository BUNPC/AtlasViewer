function fwmodel = setMCoptions(fwmodel)


% Set MC options based on app type
switch(fwmodel.mc_appname)
    case 'tMCimg'
        fwmodel.mc_options = '';
    case 'mcx'
        fwmodel.mc_options = sprintf(' -n %g -U 0 -S 1 -f ', fwmodel.nphotons);
end
