function [ext, loadMCFuncPtr] = getMCoutputExt(mc_appname)

ext = '';
loadMCFuncPtr = [];
switch(mc_appname)
    case 'tMCimg'
        ext = '2pt';
        loadMCFuncPtr = @load_tMCimg_2pt;
    case 'mcx'
        ext = 'inp.mc2';
        loadMCFuncPtr = @loadmc2;
end

