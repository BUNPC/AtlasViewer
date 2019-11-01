function genHelpProcStream()

procStreamRegStr = procStreamReg();
for ii=1:length(procStreamRegStr)
    procInputReg = parseProcessOpt(procStreamRegStr{ii});
    temp.funcName{ii}        = procInputReg.procFunc.funcName{1};
    temp.funcArgOut{ii}      = procInputReg.procFunc.funcArgOut{1};
    temp.funcArgIn{ii}       = procInputReg.procFunc.funcArgIn{1};
    temp.nFuncParam(ii)      = procInputReg.procFunc.nFuncParam(1);
    temp.nFuncParamVar(ii)   = procInputReg.procFunc.nFuncParamVar(1);
    temp.funcParam{ii}       = procInputReg.procFunc.funcParam{1};
    temp.funcParamFormat{ii} = procInputReg.procFunc.funcParamFormat{1};
    temp.funcParamVal{ii}    = procInputReg.procFunc.funcParamVal{1};
end
temp.nFunc = ii;
procInputReg.procFunc = temp;

% Create procStreamRegHelp.m in the same directory as the
% procStreamReg.m
procStreamRegPath = which('procStreamReg.m');
k = findstr(procStreamRegPath,'procStreamReg.m');
procStreamRegPath = procStreamRegPath(1:k-1);
fid = fopen([procStreamRegPath '/procStreamRegHelp.m'],'w');

fprintf(fid,'function helpReg = procStreamRegHelp()\n');
fprintf(fid,'helpReg = {...\n');

nFuncs = length(procInputReg.procFunc.funcName);
iFunc=1;
while 1
    C = genHelpFunc(procInputReg.procFunc.funcName{iFunc});
    funcDescr = C{1};
    fprintf(fid,'{...\n');
    iLine=1;
    while 1
        nLines = size(funcDescr,1);
        if iLine<nLines
            fprintf(fid,'''%s'',...\n',funcDescr{iLine});
        else
            fprintf(fid,'''%s''...\n',funcDescr{iLine});
            break;
        end
        iLine=iLine+1;
    end
    if iFunc < nFuncs
        fprintf(fid,'},...\n\n');
    else
        fprintf(fid,'}...\n');
        break;
    end
    iFunc=iFunc+1;
end
fprintf(fid,'};\n');
fclose(fid);
