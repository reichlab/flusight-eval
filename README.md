# flusight-eval

This repository contains code to generate FluSight evaluation reports, and to serve them on a website.

# workflow

Follow these steps to update the reports:

1. run `score_flusight_forecasts.R`, which adds a file to `reports/` named like `yyyy-mm-dd_Evaluation_flu_hosp.html`
2. run `update-reports-json.py`, which generates the file `reports/reports.json`. this file is a list of dates extracted from reports html filenames, and is used by `index.html` to serve the reports
3. add, commit, and push those files via git. push will initiate rebuilding the site via the GitHub Pages setting for the repository

# setting up python

`update-reports-json.py` requires a Python 3 configuration that includes the libraries installed via `pipenv intstall`, which installs those specified in `Pipfile` (see [Pipenv](https://pipenv.pypa.io/en/latest/)).
