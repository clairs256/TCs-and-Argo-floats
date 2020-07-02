# TCs-and-Argo-floats
Match TCs in Australian region with Argo floats

Extracts temprature (TEMP_ADJUSTED - delayed data instead of realtime) data from Argo netcdf files and converts pressure data (PRES_ADJUSTED) to depth. 
The Argo data has been downloaded from the IMOS website. The easiest way to download the data from IMOS AODN portal is to choose the bounding box and analysis period (e.g. 2001 to 2018, argo data started on 2001 in QLD region) then download as unsubsetted netcdf and unzip the folder. The code extracts data from each D file (delayed - higher level of QC). 

Another section of code matches tropical cyclone tracks and dates to Argo locations and dates (as well as -5 to 20 days before and after to study ocean energy changes). You can change the distance of the argo from the TC location and the dates before and after the TC location.

There are also code sections which remove duplicates (the above doesn't consider if the argo match is a duplicate) and produces plots of temperature v depth data and maps of TC tracks and mooring locations.

This is pretty rough so far and the code is set up in sections (for problem solving as I go). No QC flags have been applied yet
