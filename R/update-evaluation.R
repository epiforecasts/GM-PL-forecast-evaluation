# NOTE: This report relies on a version of scoringutils currently on a branch 
# called add_evaluation

# specify evaluation options ---------------------------------------------------
models <- "all" # models to evaluate
root_dir <- "../data-processed" # root directory for the submission files
load_from_server <- TRUE
locations <- c("Germany", "Poland")
forecast_dates <- c("2020-10-12", "2020-10-19", "2020-10-26", "2020-11-02",
                    "2020-11-09", "2020-11-16", "2020-11-23", "2020-11-30", 
                    "2020-12-7", "2020-12-14")
forecast_dates2 <- as.character(c((as.Date(forecast_dates) - 1)))
all_forecast_dates <- as.character(c(forecast_dates, forecast_dates2))

target_types <- c("case", "death")


# update forecast data ---------------------------------------------------------
# this assumes you have subversion installed and that the
# forecast hub data is in a folder "../../processed-data"
system("bash bin/update-forecasts-svn.sh")

# load forecast data -----------------------------------------------------------
source("R/load-data.R")

prediction_data <- load_submission_files(dates = all_forecast_dates,
                                         models = models,
                                         dir = root_dir) %>%
  dplyr::filter(target_end_date >= "2020-10-17") %>%
  dplyr::mutate(location_name = ifelse(location == "GM", 
                                       "Germany", 
                                       ifelse(location == "PL", 
                                              "Poland", 
                                              location_name))) %>%
  dplyr::select(-location) %>%
  dplyr::filter(type == "quantile") %>%
  dplyr::mutate(forecast_date = as.character(forecast_date)) %>%
  dplyr::mutate(target_type = ifelse(grepl("death", target), "death", "case")) %>%
  dplyr::rename(prediction = value) %>%
  dplyr::mutate(location = location_name)

# make forecast dates match 
for (date in 1:length(forecast_dates)) {
prediction_data <- prediction_data %>%
  dplyr::mutate(forecast_date = ifelse(forecast_date == forecast_dates2[date], 
                       forecast_dates[date], 
                       forecast_date))
}




get_data(load_from_server = load_from_server,
         country = "Germany_Poland")

obs_death <- get_data(cases = FALSE)
obs_case <- get_data()


truth_data <- dplyr::bind_rows(obs_death %>%
                                 dplyr::mutate(target_type = "death"), 
                               obs_case %>%
                                 dplyr::mutate(target_type = "case")) %>%
  dplyr::rename(true_value = value) %>%
  dplyr::filter(target_end_date > (Sys.Date() - 16 * 7)) %>%
  dplyr::mutate(location = location_name)



scoringutils::render_scoring_report(truth_data = truth_data, 
                                    prediction_data = prediction_data,
                                    params = list(locations = locations, 
                                                  forecast_dates = forecast_dates,
                                                  horizons = 1:4, 
                                                  target_types = c("case", "death")),
                                    save_dir = "docs/", 
                                    filename = "index.html")



