#!/bin/bash

#
# A wrapper script to run the sarix model, messaging slack with progress and results.
#
# Environment variables (see README.md for details):
# - `SLACK_API_TOKEN`, `CHANNEL_ID` (required): used by slack.sh
# - `GH_TOKEN`, `GIT_USER_NAME`, `GIT_USER_EMAIL`, `GIT_CREDENTIALS` (required): used by load-env-vars.sh
# - `DRY_RUN` (optional): when set (to anything), stops git commit actions from happening (default is to do commits)
#

#
# load environment variables and then slack functions
#

echo "sourcing: load-env-vars.sh"
source "/app/container-utils/scripts/load-env-vars.sh"

echo "sourcing: slack.sh"
source "/app/container-utils/scripts/slack.sh"

#
# start
#

slack_message "starting. id='$(id -u -n)', HOME='${HOME}', PWD='${PWD}', DRY_RUN='${DRY_RUN+x}'"

#
# clone this repo's most recent reports
#

slack_message "cloning flusight-eval"
git -C "/app" clone https://github.com/reichlab/flusight-eval.git
FLUSIGHT_EVAL_DIR="/app/flusight-eval"

#
# create the report .html file
#

OUT_FILE=/tmp/run-make-eval-reports-out.txt

# update the FluSight-forecast-hub repo
git -C /data/FluSight-forecast-hub/ pull

# run score_flusight_forecasts.R (creates a handful of `*.rda` files in current dir), passing `hub_path`. we run in
# `code/` so that `Evaluation_flu_hosp.Rmd` can find them
slack_message "running score_flusight_forecasts.R"
cd /app/code/
Rscript --vanilla "score_flusight_forecasts.R" /data/FluSight-forecast-hub/ >${OUT_FILE} 2>&1

# knit Evaluation_flu_hosp.Rmd (creates `code/Evaluation_flu_hosp.html`)
slack_message "knitting the file"
Rscript -e "library(knitr); rmarkdown::render('Evaluation_flu_hosp.Rmd')" >>${OUT_FILE} 2>&1

# move and rename the output html file to `${FLUSIGHT_EVAL_DIR}/reports/<yyyy-mm-dd>_Evaluation_flu_hosp.html`
TODAY_DATE=$(date +'%Y-%m-%d') # e.g., 2022-02-17
mv "Evaluation_flu_hosp.html" "${FLUSIGHT_EVAL_DIR}/reports/${TODAY_DATE}_Evaluation_flu_hosp.html"

# run update-reports-json.py (creates/updates `reports/reports.json`). must be done after the file has been copied to
# `/data/FluSight-forecast-hub/reports/`
slack_message "updating reports.json"
python3 update-reports-json.py "${FLUSIGHT_EVAL_DIR}/reports/" >>${OUT_FILE} 2>&1

if [ -n "${DRY_RUN+x}" ]; then # yes DRY_RUN
  slack_message "DRY_RUN set, exiting"
  exit 0 # success
fi

#
# commit and save new .html and updated reports.json . do this on the `main` branch with no PR
#

if ! cd ${FLUSIGHT_EVAL_DIR}; then
  slack_message "cd failed: ${FLUSIGHT_EVAL_DIR}"
  exit 1 # fail
fi

git add reports/\*
git commit -m "latest flusight-eval report, ${TODAY_DATE}"
git push
slack_message "push done. The updated file will be at https://reichlab.io/flusight-eval/ after GitHub Pages and Netlify run."

# done
slack_message "done"
exit 0 # success
