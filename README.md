# Project Title : Mortality and Death Time Prediction Models using MIMIC-III


## Overview
This code repository presents a set of reproducible code for the final project of CSE6250. 
The aim of the project is to predict in-hospital mortality in the early stage of ICU stay (6-hour or 12-hour since ICU admission). If a patient is predicted dead, the model would further provide an estimate of death hours since ICU admission. Please refer to the paper for further explanation on the data source, methodology, model architecture and results. The directory structure of this repository is shown below.
```
├── README.md
├── code
│   ├── Hive
│   │   ├── input
│   │   │   ├── ADMISSIONS.csv
│   │   │   ├── CHARTEVENTS.csv
│   │   │   ├── ICUSTAYS.csv
│   │   │   ├── LABEVENTS.csv
│   │   │   ├── OUTPUTEVENTS.csv
│   │   │   ├── PATIENTS.csv
│   │   │   ├── mp_gcs.csv
│   │   │   ├── mp_hourly_cohort.csv
│   │   │   └── mp_lab.csv
│   │   ├── load_data.hql
│   │   ├── mp_cohort.hql
│   │   ├── mp_data.hql
│   │   ├── mp_data_6hr.hql
│   │   ├── mp_lab.hql
│   │   ├── mp_uo.hql
│   │   ├── mp_vital.hql
│   │   ├── output
│   │   └── output_data.hql
│   ├── Python
│   │   ├── data
│   │   │   ├── data_hive
│   │   │   └── data_psql
│   │   │       ├── mp_data.csv
│   │   │       ├── mp_data_agg_12hr.csv
│   │   │       ├── mp_data_agg_24hr.csv
│   │   │       ├── mp_data_agg_6hr.csv
│   │   │       └── regressor
│   │   │           ├── mp_data_agg_24hr_v2.csv
│   │   │           └── mp_data_agg_6hr_v2.csv
│   │   ├── img
│   │   │   ├── figure1.png
│   │   │   ├── figure2.png
│   │   │   ├── figure3.png
│   │   │   ├── figure4.png
│   │   │   └── figure5.png
│   │   ├── model
│   │   │   └── p1_RF_24hr.sav
│   │   ├── notebook1
│   │   │   ├── data_prep.ipynb
│   │   │   ├── env.template
│   │   │   └── utils.py
│   │   ├── notebook2
│   │   │   ├── Phase1_binary_classifier.ipynb
│   │   │   ├── Phase2_multiclass_classifier.ipynb
│   │   │   ├── Phase2_regressor.ipynb
│   │   │   ├── env.template
│   │   │   └── utils.py
│   │   ├── requirement.txt
│   │   └── result
│   │       ├── phase1_model_results.md
│   │       └── phase2_model_results.md
│   └── SQL
│       ├── mp_bg.sql
│       ├── mp_cohort.sql
│       ├── mp_data.sql
│       ├── mp_data_6hr.sql
│       ├── mp_gcs.sql
│       ├── mp_hourly_cohort.sql
│       ├── mp_lab.sql
│       ├── mp_uo.sql
│       └── mp_vital.sql
├── draft_modifictaion
├── paper
│   ├── AMIA2017-Submission-Word-Template.docx
│   ├── amia.cls
│   ├── amia.log
│   ├── main.aux
│   ├── main.log
│   ├── main.pdf
│   ├── main.tex
│   └── pics
│       ├── figure1.png
│       ├── figure1_.png
│       ├── figure2.png
│       ├── figure3.png
│       ├── figure4.png
│       └── figure5.png
└── slides
```

The project consists of 2 stages:

*Stage 1. Feature Engineering using Apache Hive*

*Stage 2. Machine Learning using Python*

* Stage 1 is implemented in Apache Hive 2.1.0 on Microsoft Azure remote cluster (see Environment Setup below). The relevant HQL scripts can be found in the directory `Code/Hive`. Some of the data preparation have also been made using SQL on a local Postgres database. Relevant SQL queries can be found the directory `Code/SQL`.
* Stage 2 is implemented in Python 3.6 on a local cluster (see Environment Setup below). The relevant Python notebooks can be found in the directory `Code/Python`.
* Presentation slides and paper can be found in the root directory.


## Environment Setup
**Stage 1. Feature Engineering using Apache Hive on Microsoft Azure**

Stage 1 has been deployed using Apache Hive 2.1.0 on Microsoft Azure HDInsight 3.6 ([Reference](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-component-versioning)). The remote cluster consists of 2 head nodes and 1 worker node. Each node has the following specification ([Reference](https://azure.microsoft.com/en-us/pricing/details/cloud-services/)). 

| Component                     |  Spec   |
| :-----------------------------|:--------|
| Instance                      | D3 v2   |
| Core                          | 4       |
| RAM                           | 14 GB   |
| Storage                       | 200 GB  |


**Stage 2. Machine Learning using Python on Local Machine**

Stage 2 has been deployed on a local machine with the following specification. Python 3.6 and relevant packages have been used (see `Code/Python/requirement.txt`). 

| Component                     |  Spec   |
| :-----------------------------|:--------|
| Core                          | 4       |
| RAM                           | 16 GB   |
| GPU                           | 4 GB     |
| Storage                       | 500 GB  |



## Stage 1. Feature Engineering using Apache Hive

In Stage 1, we have extracted features for the first 6 hours, 12 hours or 24 hours since ICU admission for each ICU stay from MIMIC-III database. Specifically, we have selected the following dataset from MIMIC-III as input data, created intermediate tables and extracted useful features as shown in the table below. Data output in Stage 1 is then used as feature input for Stage 2 model prediction. 

| Input data from MIMIC-III   | Intermediate tables         | Output data from Stage 1    |
|:----------------------------|:----------------------------|:----------------------------|
|ICUSTAYS.csv                 | mp_cohort                   | mp_data_6hr.csv             |
|ADMISSIONS.csv               | mp_hourly_cohort            | mp_data_12hr.csv            |
|PATIENTS.csv                 | mp_gcs                      | mp_data_24hr.csv            |
|CHARTEVENTS.csv              | mp_bg, mp_bg_art            |                             |
|LABEVENTS.csv                | mp_lab                      |                             | 
|OUTPUTEVENTS.csv             | mp_uo                       |                             |
|                             | mp_vital                    |                             |
|                             | mp_data                     |                             |

In the proof-of-concept stage, we have done data preprocessing and feature engineering on a local Postgres MIMIC-III database (see this [Official Repo](https://github.com/MIT-LCP/mimic-code/tree/master/buildmimic/postgres) for setting up a local Postgres MIMIC-III database). The set of SQL scripts shown in the table below should produce all tables needed in this project. Note that reference has been made to the SQL queries provided in this [Repo](https://github.com/alistairewj/mortality-prediction/tree/master/queries) when constructing relevant features.

We then reproduced the code in Hive on Microsoft Azure. The decompressed dataset is around 40 GB. First, we loaded the csv files to the remote cluster on Microsoft Azure. Then, we ran the following HQL scripts to create tables. Note that `mp_hourly_cohort`, `mp_gcs` and `mp_bg` were generated in SQL and directly loaded to Hive due to time constraint, since these tables require sequence generation and complex non-equality left join conditions which are not supported by Hive and too tedious to be implemented in MapReduce. 

| HQL scripts           | SQL scripts       | Description                 |
|:----------------------|:----------------------|:----------------------------|
| load_data.hql     | --                    | Load tables from csv files  |
| mp_cohort.hql         | mp_cohort.sql         | Create table for patient cohort|
| --          | mp_hourly_cohort.sql  | Generate sequence of ICU hours per patient|
| --              | mp_gcs.sql        | Extract patients' Glasgow Coma Scale|
| --          | mp_bg.sql           | Extract patients' blood gas and chemistry values|
| mp_lab.hql          | mp_lab.sql        | Extract patients' lab results|  
| mp_uo.hql             | mp_uo.sql             | Extract patients' urine output|
| mp_vital.hql        | mp_vital.sql          | Extract patients' vital signs, eg. heart rate|
| mp_data.hql           | mp_data.sql         | Combine all tables created above to get all features at every ICU hour for each patient |
| mp_data_6hr.hql       | mp_data_6hr.sql     | Aggregate features extracted from mp_data table during the first 6 hours of ICU stay (similarly for 12-hour and 24-hour)|
| output_data.hql       | --                    |Output final tables to csv files|


## Stage 2. Machine Learning using Python
Stage 2 consists two phases of model training. In Phase 1, a binary classifier has been trained using the extracted features in Stage 1 to predict in-hospital mortality. In Phase 2, a multiclass classifier has been trained  to predict the death hours since ICU admission for those predicted dead patients in Phase 1. 

| Notebook                |  Description   |
| :-----------------------|:---------------|
| `EDA.ipynb`             | Exploratory data analysis on the study population |
| `Phase1_model.ipynb`    | Model training and evaluation using Random Forest Classifier to predict in-hospital mortality|
| `Phase2_model.ipynb`    |Model training and evaluation using Random Forest Multiclass Classifier to predict death hours since ICU admission|

This 2-phase model has been trained on 5-fold cross validation and tested on a separate test set using the aggregated features in 6-hour, 12-hour and 24-hour timeframe respectively. We have then compared the model performance between these timeframe to determine whether an early stage (6-hour or 12-hour) prediction model is competitive to those trained on a more common timeframe of 24-hour. Please refer to the paper for further discussion on the model architecture and the model results.

