function [ time ] = timeAdjust( time,startingDate,secondsHourDay )
%Adjust netcdf time to MATLAB time format
%   time is the time array extracted from netcdf file
%   startingDate is a date vector which uses the units (provided in
%   ncdisp) as the origin of the time array e.g. 'hours since ....'
%   for a starting time of: units = 'hours since 1900-01-01 00:00:00.0' 
%   use startingDate = [1900,1,1]

%   secondsHourDay is a string of either 'h' or 'd' which specifies whether the
%   time units are in hours or days

time = double(time);
if strcmp(secondsHourDay,'h')==1
    time = time./24;
elseif strcmp(secondsHourDay,'s')==1
    time = time./(60*60*24);
end
startingDate = [startingDate,0,0,0];
tadj = etime(startingDate,[0000,1,0,0,0,0])/(3600*24);
time = time+tadj;

end

