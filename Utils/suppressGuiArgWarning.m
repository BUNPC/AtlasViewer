function suppressGuiArgWarning(onoff)

if onoff
    warning('off', 'MATLAB:str2func:invalidFunctionName')
else
    warning('on', 'MATLAB:str2func:invalidFunctionName')
end