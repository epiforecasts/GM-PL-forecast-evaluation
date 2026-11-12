# GM-PL-forecast-evaluation

> **Archived.** No longer maintained; last updated December 2020. It relied on a development branch of `scoringutils` and on checking out the German and Polish Forecast Hub submissions with Subversion, so it will not rerun as it is.

An unofficial evaluation of the COVID-19 case and death forecasts submitted to the German and Polish Forecast Hub for forecast dates between October and December 2020. The rendered report is in `docs/index.html`.

- `R/update-evaluation.R`: sets the models, locations and forecast dates, loads forecasts and truth data, and scores them.
- `R/load-data.R`: reads the hub submission files.
- `bin/update-forecasts-svn.sh`: checks out or updates `data-processed` from KITmetricslab/covid19-forecast-hub-de alongside this repository.
- `data/`: daily cumulative and incident cases and deaths for Germany and Poland.
- `docs/index.html`: the scoring report.
