#Script to query FluSight scores

#Set-up and load forecast data 
library(hubUtils)
library(scoringutils)
library(covidHubUtils)

library(lubridate)
library(dplyr)
library(ggplot2)
library(plotly)

library(here)
setwd(here::here())

current_ref_date <- lubridate::ceiling_date(Sys.Date(), "week") - lubridate::days(1)

hub_path <- "../FluSight-forecast-hub"

hub_con <- connect_hub(hub_path)
raw_forecasts <- hub_con |>
  dplyr::filter(
    output_type == "quantile"
  ) |>
  dplyr::collect() |>
  as_model_out_tbl()

table(raw_forecasts$model_id)

head(raw_forecasts)

#create log of forecast data
log_forecasts <- raw_forecasts |>
  dplyr::mutate(value_log=log_shift(value,offset=1))|>
  dplyr::select(-value)|>
  dplyr::rename(value=value_log) 
head(log_forecasts)

#Load raw target data
raw_truth <- readr::read_csv("https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/target-data/target-hospital-admissions.csv")
head(raw_truth)

#create log of target data
log_truth <- raw_truth |>
  dplyr::mutate(value_log=log_shift(value,offset=1))|>
  dplyr::select(-value)|>
  dplyr::rename(value=value_log) 
head(log_truth)


#merge together  raw forecast and target data
raw_data <- raw_forecasts |>
  dplyr::filter(horizon > -1) |>
  dplyr::left_join(
    raw_truth |> dplyr::select(target_end_date = date, location, location_name, true_value = value),
    by = c("location", "target_end_date")
  ) |>
  dplyr::rename(model=model_id, quantile=output_type_id, prediction=value) |>
  dplyr::mutate(quantile = as.numeric(quantile))
head(raw_data)

#confirm things set up correctly
raw_data|>
  scoringutils::check_forecasts()

#merge together  log forecast and target data
log_data <- log_forecasts |>
  dplyr::filter(horizon > -1) |>
  dplyr::left_join(
    log_truth |> dplyr::select(target_end_date = date, location,location_name, true_value = value),
    by = c("location", "target_end_date")
  ) |>
  dplyr::rename(model=model_id, quantile=output_type_id, prediction=value) |>
  dplyr::mutate(quantile = as.numeric(quantile))
head(log_data)
#confirm things set up correctly
log_data|>
  scoringutils::check_forecasts()

#score raw data
raw_scores <- raw_data |>
  scoringutils::score()
head(raw_scores)

#add interval scores
scores_raw <- raw_scores |>
  add_coverage(ranges = c(50, 80, 95), by = c("model", "reference_date")) |>
  summarise_scores(by = c("model", "reference_date"))

head(scores_raw)

#score log data
log_scores <- log_data |>
  scoringutils::score()
head(log_scores)

#add interval scores
scores_log <- log_scores |>
  add_coverage(ranges = c(50, 80, 95), by = c("model", "reference_date")) |>
  summarise_scores(by = c("model", "reference_date"))

head(scores_log)

#write rda 
setwd("~/github/flu-hosp-forecasts/reports")
save(raw_data, file = "raw_data.rda")
save(log_data, file = "log_data.rda")
save(raw_scores, file = "raw_scores.rda")
save(log_scores, file = "log_scores.rda")
save(raw_truth, file = "raw_truth.rda")
save(log_truth, file = "log_truth.rda")


