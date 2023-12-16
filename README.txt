# nanwakolas-time-series-v1_2018-2023

Nanwakolas-focal-watersheds-data

Welcome to the Nanwakolas Focal Watersheds time-series data repository. This repository corresponds to the metadata record located at [insert DOI here]

The complete data files that are ready for analysis area as follows:
	fulmore-2023-cleaned.csv
	glendale-2023-cleaned.csv
	heydon-2023-cleaned.csv
	lull-2023-cleaned.csv
	tuna-2023-cleaned.csv
 

CHANGELOG

Here we track what changes between different versions of the dataset. Different versions of the data set will be tagged on github with a release tag showing the version (eg. v1.2.0) that should be cited when using these data to be clear which version of the data you used for an analysis.

Data dictionary

In the data dictionary we aim to provide definitions of all the core tables. Definitions of variables in sample result data may have there own separate data dictionary or readme file in the raw_data folder and sub folders.
License

This repository is public and so the data and code are licensed under the Creative Commons By Attribution 4.0 (CC BY4) license. Download the data files you'd like or clone this Git repository and copy the data to your computer but you must attribute the work to the authors. To cite this work please see http://dx.doi.org/10.21966/1.566666 Please collaborate with the authors of this dataset if you plan to analyze it. They represent a significant public resource, and time investment.

What's in the supplemental material?
Data folders

raw_data

In the raw_data folder you will find the raw sensor data downloaded from the Hakai Sensor Network. 

tidy_data

Data in the tidy_data folder are cleaned and converted into a more workable format. 

Reports

These are qc reports generated annually.

Scripts

The data_cleaning script performs various data wrangling tasks and changes the format from the sensor network into a more workable format. The qc-summary script generates an .html file which summarizes the latest qaqc findings. The figs script pulls in the hourly data file and summarizes into annual time-series plots per variable. 

