# nanwakolas-time-series-v1_2018-2023

Nanwakolas-focal-watersheds-data

Welcome to the Nanwakolas Focal Watersheds time-series data repository. This repository corresponds to the metadata record located at [insert DOI here]

The complete data files that are ready for analysis area as follows:
	fulmore-timeseries.csv
	glendale-timeseries.csv
	heydon-timeseries.csv
	lull-timeseries.csv
	tuna-timeseries.csv
 

CHANGELOG

Here we track what changes between different versions of the dataset. Different versions of the data set will be tagged on github with a release tag showing the version (eg. v1.2.0) that should be cited when using these data to be clear which version of the data you used for an analysis.

Data dictionary

In the data dictionary we aim to provide definitions of all the core tables. 

License

This repository is public and so the data and code are licensed under the Creative Commons By Attribution 4.0 (CC BY4) license. Download the data files you'd like or clone this Git repository and copy the data to your computer but you must attribute the work to the authors. To cite this work please see [insert here] Please collaborate with the authors of this dataset if you plan to analyze it. They represent a significant public resource, and time investment.

What's in the supplemental material?

Data folders

raw_data

In the raw_data folder you will find the raw sensor data downloaded from the Hakai Sensor Network. 


Reports

These are qc summary reports generated with each data package release.

Scripts

The data_cleaning-nanwakolas script performs various data wrangling tasks and changes the format from the sensor network into a more workable format. The qc-summary script generates an .html file which summarizes the latest qaqc findings. The figs script pulls in the hourly data file and summarizes into annual time-series html plots per variable. 

