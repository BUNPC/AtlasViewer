function d = getFileDateStruct(file)

if ~isstruct(file) & ischar(file)
    file = dir(file);
end

d = struct('filename',file.name,'str','','year',[],'month',[],'day',[],'hour',[],'min',[],'sec',[],'num',[]);

START_YEAR     = 1970;
MONTHS         = {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};
NUMDAYSINMONTH = [  31    29    31    30    31    30    31    31    30    31    30    31 ];
base_yr  = 32140800;   % 12*31*24*60*60
base_mo  = 2678400;    % 31*24*60*60;
base_day = 86400;      % 24*60*60;
base_hr  = 3600;       % 60*60;
base_min = 60;

date_curr = date;
year_curr = str2num(date_curr(8:11))-START_YEAR;

% Translate string from whatever language and format the OS environment 
% is set to, to standard matlab date format. Do NOT use the 'date' field as it 
% is reported differently depending on language settings of the OS and is 
% thus not portable. Use the 'datenum' field instead. It's a number rather 
% than a string which guarantees the same result regardless of language/region 
% settings
date_standard_fmt = datestr(datevec(file.datenum));
if isempty(date_standard_fmt)
    d = [];
end

year    = str2num(date_standard_fmt(8:11))-START_YEAR;
month   = find(strcmpi(MONTHS, date_standard_fmt(4:6)));
day     = str2num(date_standard_fmt(1:2));
hour    = str2num(date_standard_fmt(13:14));
min     = str2num(date_standard_fmt(16:17));
sec     = str2num(date_standard_fmt(19:20));


% Now that we have a numberic date, check it for errors
if year<0 || year>year_curr
    return;
end
if isempty(month) || month<1 || month>12
    return;
end
if day<1 || day>NUMDAYSINMONTH(month)
    return;
end
if hour<0 || hour>23
    return;
end
if min<0 || min>59
    return;
end
if sec<0 || sec>59
    return;
end

d.str     = file.date;
d.year    = year;
d.month   = month;
d.day     = day;
d.hour    = hour;
d.min     = min;
d.sec     = sec;
d.num     = year*base_yr + month*base_mo + day*base_day + hour*base_hr + min*base_min + sec;


