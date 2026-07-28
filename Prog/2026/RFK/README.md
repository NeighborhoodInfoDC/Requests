# RFK Stadium and campus residential impact analysis
Author: Katie Visalli
Date: 7/15/26

Main Output for this work is in this [Powerpoint in Box](https://urbanorg.app.box.com/file/2330661878315). All charts are linked to an excel tab. There are multiple excels sorted into subfolders of the [results box folder](https://urbanorg.app.box.com/folder/395142829696)

## Identify Analysis Area
*This step should be run first.*
The [code script in R](1.Identify RFK Adjacent Tracts.RMD) uses DC shapefiles to find the DC Square that is the RFK statdium and tracts within a mile of it. 
The script generates maps. If changed, they should also be uploaded to [the Geography & ACS Results box folder](https://urbanorg.app.box.com/folder/395144629978)
Most importantly, it makes dcdata\Libraries\Requests\Prog\2026\RFK\Result\rfk_tracts.csv which later scripts read to identify the RFK analysis area and East and West of the river.

## ACS Summary stats
The script [ACS summary stats.sas](ACS summary stats.sas) outputs large tables with demographic summary stats by geography (DC, Ward 7, RFK analysis Area, RFK-East, and RFK-West). 
Copy-Paste the output to the tab Total Summary Stats in the [ACS Summary Stats V2 Box Excel](https://urbanorg.app.box.com/file/2276965492622). 
The rest of the tabs in the sheet will automatically update, as well as the powerpoint figures which are linked to that excel. 

## Subsidized Housing
First run [Step 1](Subsidized Housing Step 1.sas) in SAS to get data to send to R in [Step 2](Subsidized Housing Step 2.Rmd)
Creates tables for subsidy types. Copy-paste changed results to [the Box Excel](https://urbanorg.app.box.com/file/2311253231300) and maps of subsidized housing in the [Subsidized Housing Folder](https://urbanorg.app.box.com/folder/395143302579)

## Parcel Data
[Ownershp Property Data.sas](Ownershp Property Data.sas) uses parcel data, rent control and geography data and produces results for:
1.Property Type
2.Owner Type
3.Homestead Exemptions
4.Rent Control
5.Length of Ownership
Copy/paste output to [property_ownership_result.xlsx](https://urbanorg.app.box.com/file/2311252974930)

## Sales
[Property Data.sas](Property Data.sas) uses residential sales and geography data to create time series for median sale price and sale volume for single-family and condos
copy/paste output to [Property Records Results.xlsx](https://urbanorg.app.box.com/file/2306604045202)

## Displacement Risk
[Displacement Risk.Rmd](Property Records Results.xlsx) uses [Yipeng's Displacement risk data](https://urbanorg.app.box.com/file/1855335661929?s=azizabexnna8hwhjshcnpaj0uvye2197) to create [maps and tables](https://urbanorg.app.box.com/file/2316524451867) Will need to copy/paste for tables if changed.
