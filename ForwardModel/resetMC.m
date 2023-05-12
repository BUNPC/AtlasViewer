function fwmodel = resetMC(fwmodel)

try 
    delete([fwmodel.pathname, 'fw/*.2pt'])
catch
end

try 
    delete([fwmodel.pathname, 'fw/*.mc2'])
catch
end

try 
    delete([fwmodel.pathname, 'fw/*.his'])
catch
end

try 
    delete([fwmodel.pathname, 'fw/Adot*'])
catch
end

