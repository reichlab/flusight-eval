# flusight-evaluation report

This repository contains code to generate FluSight hospitalization forecast evaluations, and support for updating/publishing the reports via GitHub Pages. These reports are generated on Thursdays.

## Steps to generate evaluation reports

Step 1: Update source data
   .../FluSight-forecast-hub
forked from https://github.com/cdcepi/FluSight-forecast-hub

Step 2: Generate scores: 
Run reichlab/flusight-eval/code/score_flusight_forecasts.R

Step 3: Produce reports: 
Run reichlab/flusight-eval/code/Evaluation_flu_hosp.Rmd

Step 4: Rename html to YYYY-MM-DD_Evaluation_flu_hosp.html (where YYYY-MM-DD is date created report)

Step 5: Load YYYY-MM-DD_Evaluation_flu_hosp.html to reichlab/flusight-eval/reports

Step 6: Create copy of YYYY-MM-DD_Evaluation_flu_hosp.html called index.html and load to reichlab/flusight-eval/
