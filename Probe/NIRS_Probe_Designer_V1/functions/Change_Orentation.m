function XYZnew=Change_Orentation(Orien_Curr)


%%% check for orientation
%                  'RIP' --> 
%                    Right     aligns with  x+ (thus Left      aligns with x-)
%                    Inferior  aligns with  y+ (thus Superior  aligns with y-)
%                    Posterior aligns with  z+ (thus Anterior  aligns with z-)
%                    
%                  'LAS' --> 
%                    Left      aligns with  x+ (thus Right    aligns with  x-) 
%                    Anterior  aligns with  y+ (thus Anterior aligns with  y-)
%                    Superior  aligns with  z+ (thus Anerior  aligns with  z-)

%%% chaneg the coordinate system to ALS
All_Corr{1,1}='ALS'; All_Corr{1,2}=[1 2 3]; 
All_Corr{2,1}='ALI'; All_Corr{2,2}=[1 2 -3]; 
All_Corr{3,1}='ARS'; All_Corr{3,2}=[1 -2 3]; 
All_Corr{4,1}='ARI'; All_Corr{4,2}=[1 -2 -3]; 
All_Corr{5,1}='ASL'; All_Corr{5,2}=[1 3 2]; 
All_Corr{6,1}='ASR'; All_Corr{6,2}=[1 3 -2]; 
All_Corr{7,1}='AIL'; All_Corr{7,2}=[1 -3 2]; 
All_Corr{8,1}='AIR'; All_Corr{8,2}=[1 -3 -2]; 

%%% chaneg the coordinate system to ALS
All_Corr{9,1}='PLS'; All_Corr{9,2}=[-1 2 3]; 
All_Corr{10,1}='PLI'; All_Corr{10,2}=[-1 2 -3]; 
All_Corr{11,1}='PRS'; All_Corr{11,2}=[-1 -2 3]; 
All_Corr{12,1}='PRI'; All_Corr{12,2}=[-1 -2 -3]; 
All_Corr{13,1}='PSL'; All_Corr{13,2}=[-1 3 2]; 
All_Corr{14,1}='PSR'; All_Corr{14,2}=[-1 3 -2]; 
All_Corr{15,1}='PIL'; All_Corr{15,2}=[-1 -3 2]; 
All_Corr{16,1}='PIR'; All_Corr{16,2}=[-1 -3 -2]; 

%%% chaneg the coordinate system to ALS
All_Corr{17,1}='RAS'; All_Corr{17,2}=[2 -1 3]; 
All_Corr{18,1}='RAI'; All_Corr{18,2}=[2 -1 -3]; 
All_Corr{19,1}='RPS'; All_Corr{19,2}=[-2 -1 3]; 
All_Corr{20,1}='RPI'; All_Corr{20,2}=[-2 -1 -3]; 
All_Corr{21,1}='RSA'; All_Corr{21,2}=[3 -1 2]; 
All_Corr{22,1}='RSP'; All_Corr{22,2}=[-3 -1 2]; 
All_Corr{23,1}='RIA'; All_Corr{23,2}=[3 -1 -2]; 
All_Corr{24,1}='RIP'; All_Corr{24,2}=[-3 -1 -2]; 

%%% chaneg the coordinate system to ALS
All_Corr{25,1}='LAS'; All_Corr{25,2}=[2 1 3]; 
All_Corr{26,1}='LAI'; All_Corr{26,2}=[2 1 -3]; 
All_Corr{27,1}='LPS'; All_Corr{27,2}=[-2 1 3]; 
All_Corr{28,1}='LPI'; All_Corr{28,2}=[-2 1 -3]; 
All_Corr{29,1}='LSA'; All_Corr{29,2}=[3 1 2]; 
All_Corr{30,1}='LSP'; All_Corr{30,2}=[-3 1 2]; 
%All_Corr{31,1}='LIA'; All_Corr{31,2}=[3 1 -2]; 
All_Corr{31,1}='LIA'; All_Corr{31,2}=[-3 2 1]; 
All_Corr{32,1}='LIP'; All_Corr{32,2}=[-3 1 -2]; 

%%% chaneg the coordinate system to ALS
All_Corr{33,1}='SAL'; All_Corr{33,2}=[2 3 1]; 
All_Corr{34,1}='SAR'; All_Corr{34,2}=[2 -3 1]; 
All_Corr{35,1}='SPL'; All_Corr{35,2}=[-2 3 1]; 
All_Corr{36,1}='SPR'; All_Corr{36,2}=[-2 -3 1]; 
All_Corr{37,1}='SRA'; All_Corr{37,2}=[3 -2 1]; 
All_Corr{38,1}='SRP'; All_Corr{38,2}=[-3 -2 1]; 
All_Corr{39,1}='SLA'; All_Corr{39,2}=[3 2 1]; 
All_Corr{40,1}='SLP'; All_Corr{40,2}=[-3 2 1]; 

%%% chaneg the coordinate system to ALS
All_Corr{41,1}='IAL'; All_Corr{41,2}=[2 3 -1]; 
All_Corr{42,1}='IAR'; All_Corr{42,2}=[2 -3 -1]; 
All_Corr{43,1}='IPL'; All_Corr{43,2}=[-2 3 -1]; 
All_Corr{44,1}='IPR'; All_Corr{44,2}=[-2 -3 -1]; 
All_Corr{45,1}='IRA'; All_Corr{45,2}=[3 -2 -1]; 
All_Corr{46,1}='IRP'; All_Corr{46,2}=[-3 -2 -1]; 
All_Corr{47,1}='ILA'; All_Corr{47,2}=[3 2 -1]; 
All_Corr{48,1}='ILP'; All_Corr{48,2}=[-3 2 -1]; 

for i=1:48
    if strcmp(All_Corr{i,1},Orien_Curr)
       XYZnew=All_Corr{i,2}; 
    end
end

