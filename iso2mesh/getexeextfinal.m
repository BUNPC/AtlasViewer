function exesuff = getexeextfinal(exename)

exesuff = getexeext();

exesuff = fallbackexeext(exesuff, exename);



