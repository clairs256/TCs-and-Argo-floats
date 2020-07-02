%% set up folders and files
dataDir = 'C:\Users\z3523352\OneDrive - UNSW\Postdoc-C1068\ocean\';
argoDir = [dataDir,'data files\argo\'];

%if there are both D and R files, D=delayed, R=real time. D has more QC
argofiles = dir([dataDir,'data files\argo\D*.nc']);

%% read each argo .nc file into a structure. commented out the save command at the bottom
for d=1:length(argofiles)

    time = ncread([argoDir,argofiles(d).name],'JULD');
    time = timeAdjust(time,[1950,1,1],'d');
    lat = ncread([argoDir,argofiles(d).name],'LATITUDE');
    lon = ncread([argoDir,argofiles(d).name],'LONGITUDE');
    temp = ncread([argoDir,argofiles(d).name],'TEMP_ADJUSTED');
    tempFlag = ncread([argoDir,argofiles(d).name],'TEMP_ADJUSTED_QC');
    pres = ncread([argoDir,argofiles(d).name],'PRES_ADJUSTED');

    depth = -1.*gsw_z_from_p(pres(:,1),lat(1));

    argoData(d).date = time(1);
    argoData(d).lat = lat(1);
    argoData(d).lon = lon(1);
    argoData(d).temp = temp(:,1);
    argoData(d).tempFlag = tempFlag(:,1);
    argoData(d).depth = depth(:,1);
%
end

% save([dataDir,'argoDataAllTCs'],'argoData')
%% this section tries to match argo data to tc location. Start with a close match (same day, within 200 km box)

%set up folders and data
dataDir = 'C:\Users\z3523352\OneDrive - UNSW\Postdoc-C1068\ocean\';
% dataDir = 'C:\Users\clair\OneDrive - UNSW\Postdoc-C1068\ocean\';

load([dataDir,'BOMregionalDataUpdated.mat'],'BOM_QLDdata')
clear argoMatchTC

%
tcs = unique(BOM_QLDdata(:,2)); %each TC identifier

%Numeric arrays of argo data, easier to search
argoDates = [argoData.date]';
argoLat = [argoData.lat]';
argoLon = [argoData.lon]';
%% match to tc data
boundingdistance = 1;     %distance between argo and TC in degrees

d0=0;

%the first available argo year for QLD region is 2001 so start at that tc
for t=38:length(tcs)
    clear tcrows tcdata
    tcrows = find(strcmp(BOM_QLDdata(:,2),tcs(t)));
    tcdata = cell2mat(BOM_QLDdata(tcrows,3:5));
    
    for tt=1:length(tcdata)
        
        for d=-5:20 %also look for argo from -5 days to +20 days in vicinity of TC location
            fdate = find(fix(argoDates)==fix(tcdata(tt,1)+d));
        
        if isempty(fdate)
            continue
        else
            for f=1:length(fdate)
                
                if abs(argoLat(fdate(f))-tcdata(tt,2))<=boundingdistance  && abs(argoLon(fdate(f))-tcdata(tt,3))<=boundingdistance
                    d0=d0+1;
                    argoMatchTC(d0).tcdate = datestr(tcdata(tt,1));
                    argoMatchTC(d0).argoDate = datestr(argoDates(fdate(f)));
                    argoMatchTC(d0).argoInfo = [argoDates(fdate(f)),argoLat(fdate(f)),argoLon(fdate(f))];
                    argoMatchTC(d0).tcinfo = tcdata(tt,:);
                    argoMatchTC(d0).tcname = BOM_QLDdata(tcrows(tt),1);
                    argoMatchTC(d0).tcid = BOM_QLDdata(tcrows(tt),2);
                    argoMatchTC(d0).temp = argoData(fdate(f)).temp;
                    argoMatchTC(d0).tempFlag = argoData(fdate(f)).tempFlag;
                    argoMatchTC(d0).depth = argoData(fdate(f)).depth;


                end
            end
        end
        end
    end
end

% save([dataDir,'argoMatchTC'],'argoMatchTC')


%% temp v depth plots and argo locations
dataDir = 'C:\Users\z3523352\OneDrive - UNSW\Postdoc-C1068\ocean\';

load([dataDir,'argoMatchTC.mat'])
load([dataDir,'BOMregionalDataUpdated.mat'],'BOM_QLDdata')


tcnames = cellstr([argoMatchTC.tcname]');

tcs = unique(tcnames);
argoinfo = {argoMatchTC.argoInfo}';
argoinfo = cell2mat(argoinfo);

tcinfo = {argoMatchTC.tcinfo}';
tcinfo = cell2mat(tcinfo);

%%

for t=1:length(tcs)
    tcrows = find(strcmp(tcnames,tcs(t)));
    bomrows = find(strcmp(BOM_QLDdata(:,1),tcs(t)));
%     [~,urows] = unique(argoinfo(tcrows,:),'rows');

    f=figure('Position',get(0,'Screensize'));
    f.Color = 'w';
    
    for r=1:length(tcrows)
        plot(argoMatchTC(tcrows(r)).temp,argoMatchTC(tcrows(r)).depth,'LineWidth',1.5)
        hold on
    end
set(gca,'YDir','reverse','XAxisLocation','top')
title(tcs{t})
ylabel('Depth (m)')
% saveas(f,[dataDir,'figures\ARGO\',tcs{t},'_tempVdepth']);
% saveas(f,[dataDir,'figures\ARGO\',tcs{t},'_tempVdepth.png']);


f=figure('Position',get(0,'Screensize'));
f.Color = 'w';
axesm('eqdcylin','MapLatLim',[-30 0],'MapLonLim',[135 180])
geoshow('landareas.shp','FaceColor','none','LineWidth',0.5);
plotm(argoinfo(tcrows,2),argoinfo(tcrows,3),'^k','MarkerSize',6,'LineWidth',2);
hold on
plotm(cell2mat(BOM_QLDdata(bomrows,4)),cell2mat(BOM_QLDdata(bomrows,5)),'.r','MarkerSize',14);
title({tcs{t};['TC dates: from ',datestr(min(cell2mat(BOM_QLDdata(bomrows,3))),'dd mmm yy'),' to ',datestr(max(cell2mat(BOM_QLDdata(bomrows,3))),'dd mmm yy')];['ARGO dates: from ',datestr(min(argoinfo(tcrows,1)),'dd mmm yy'),' to ',datestr(max(argoinfo(tcrows,1)),'dd mmm yy')]},'FontWeight','normal');

% saveas(f,[dataDir,'figures\ARGO\',tcs{t},'_ARGOlocations']);
% saveas(f,[dataDir,'figures\ARGO\',tcs{t},'_ARGOlocations.png']);

end
%% export data to table to save as excel. add in to calculate distance between argo and TC track
haversin = @(lat1,lat2,lon1,lon2) 2*6371*asin(sqrt(sin((lat2*pi/180-lat1*pi/180)/2).^2+cos(lat2*pi/180)*cos(lat1*pi/180)*sin((lon2*pi/180-lon1*pi/180)/2).^2));

for r=1:length(argoMatchTC)
% argoMatchTCforExcel(r).tcdate = argoMatchTC(r).tcdate;
% argoMatchTCforExcel(r).argodate = argoMatchTC(r).argoDate;
% argoMatchTCforExcel(r).tcLat = argoMatchTC(r).tcinfo(2);
% argoMatchTCforExcel(r).tcLon = argoMatchTC(r).tcinfo(3);
% argoMatchTCforExcel(r).argoLat = argoMatchTC(r).argoInfo(2);
% argoMatchTCforExcel(r).argoLon = argoMatchTC(r).argoInfo(3);
% argoMatchTCforExcel(r).tcname = argoMatchTC(r).tcname;
% argoMatchTCforExcel(r).tcid = argoMatchTC(r).tcid;
argoMatchTCforExcel(r).distance = haversin(argoMatchTC(r).tcinfo(2),argoMatchTC(r).argoInfo(2),argoMatchTC(r).tcinfo(3),argoMatchTC(r).argoInfo(3));
end
argoMatchTCTable = struct2table(argoMatchTCforExcel);
filename = 'argoMatchTCdistance.xlsx';
writetable(argoMatchTCTable,filename);
    
%% find and remove duplicates of argoMatchTC by using the table
tcid = [argoMatchTCforExcel.tcid]';
argoinfo = {argoMatchTC.argoInfo}';
argoinfo = cell2mat(argoinfo);

tcs = unique(tcid);
%% REMOVE DUPLICATES!! 
removeRowsAll =[];
for t=1:length(tcs)
    tcrows = find(strcmp(tcid,tcs(t)));
    tcRowLength = 1:length(tcrows);
    tcRowLength = tcRowLength';
    
    [urows,ui,uj] = unique(argoinfo(tcrows,:),'rows');
    
    removeRows = setdiff(tcRowLength',ui);
    if isempty(removeRows)==0
        removeRowsAll = [removeRowsAll;tcrows(removeRows)];
    end
end

argoMatchTC(removeRowsAll,:)=[];
argoMatchTCforExcel(removeRowsAll,:)=[];
argoMatchTCTable(removeRowsAll,:)=[];