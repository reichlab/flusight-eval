# flusight-evaluation report

This repository contains code to generate FluSight hospitalization forecast evaluations, and support for updating/publishing the reports via GitHub Pages. These reports are generated on Thursdays.

There are two ways to run the program: as a Docker container (the default, which is run on Amazon Web Services), or manually on a local machine.

## Steps to run as a Docker container

Please see [docker/README.md](docker%2FREADME.md).

## Steps to run manually on a local machine

- Clone/update your copy of https://github.com/cdcepi/FluSight-forecast-hub . Make a note of its location for the next step.
- Temporarily edit `code/score_flusight_forecasts.R`: 1/2) Uncomment the line that sets `hub_path`, setting it to the location of the repo in the previous step. E.g., `hub_path <- "../FluSight-forecast-hub"`. 2/2) Comment out the lines after that line, starting with `args <- commandArgs(trailingOnly = TRUE)` through the end of the `if` statement.
- Generate scores: Run `code/score_flusight_forecasts.R`.
- Produce reports: Knit `code/Evaluation_flu_hosp.Rmd`. This will create a new .html file in the current directory.
- Rename and move the .html file to `reports/YYYY-MM-DD_Evaluation_flu_hosp.html` (where YYYY-MM-DD is current date). E.g., `reports/2024-01-05_Evaluation_flu_hosp.html`.
- Update `reports/reports.json` by running `code/update-reports-json.py`. This file is used by `index.html` to list all reports.
- Add, commit, and push the above two files under `reports/` to this repo. This push will initiate rebuilding and publishing the website (it may take a few minutes).
- Check https://reichlab.io/flusight-eval/ to verify that it's been updated.
