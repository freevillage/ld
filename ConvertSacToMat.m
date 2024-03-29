function sac = ConvertSacToMat( sacFilename, matFilename )

sacFieldNames = { 'B','E','O','A',...
	'T0',	'T1',	'T2',	'T3',	'T4',...
	'T5',	'T6',	'T7',	'T8',	'T9',...
	'F'	'RESP0'	'RESP1'	'RESP2'	'RESP3',...
	'RESP4',	'RESP5',	'RESP6',	'RESP7',	'RESP8',...
	'RESP9',	'STLA'	'STLO'	'STEL',	'STDP',...
	'EVLA',	'EVLO',	'EVEL',	'EVDP',	'MAG',...
	'USER0',	'USER1',	'USER2',	'USER3',	'USER4',...
	'USER5',	'USER6',	'USER7',	'USER8',	'USER9',...
	'DIST',	'AZ'	'BAZ',	'GCARC',	...
		'DEPMEN',	'CMPAZ',	'CMPINC',	'XMINIMUM',...
	'XMAXIMUM',	'YMINIMUM',	'YMAXIMUM',		...
					...
	'NZYEAR',	'NZJDAY',	'NZHOUR',	'NZMIN',	'NZSEC',...
	'NZMSEC',	'NVHDR',	'NORID',	'NEVID',	'NPTS',...
		'NWFID',	'NXSIZE',	'NYSIZE',	...
	'IFTYPE',	'IDEP',	'IZTYPE',		'IINST',...
	'ISTREG',	'IEVREG',	'IEVTYP',	'IQUAL',	'ISYNTH',...
	'IMAGTYP',	'IMAGSRC',			...
					...
	'LEVEN'	'LPSPOL'	'LOVROK',	'LCALDA',	...
	'KSTNM',	...	 	 	 
	'KHOLE',	'KO',	'KA',...	 	 
	'KT0',	'KT1',	'KT2',...	 	 
	'KT3',	'KT4',	'KT5',...	 	 
	'KT6',	'KT7',	'KT8',...	 	 
	'KT9',	'KF',	'KUSER0',...
	'KUSER1',	'KUSER2',	'KCMPNM',...	 	 
	'KNETWK',	'KDATRD',	'KINST' };


sacFileContents = rsac( sacFilename );
sac.time = sacFileContents(:,1);
sac.amplitude = sacFileContents(:,2);

totalFieldNames = length( sacFieldNames );

for iFieldName = 1 : totalFieldNames
    thisFieldName = sacFieldNames{iFieldName};
    sac.(thisFieldName) = lh( sacFileContents, thisFieldName );
end

if nargin == 2
    save( matFilename, 'sac' );
end

end

