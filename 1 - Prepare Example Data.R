
# PHUSE 2024 --------------------------------------------------------------

pacman::p_load(tidyverse, formatters, fs)

data(package = "formatters")

datalist <-
  lst(
    formatters::DM,
    formatters::ex_adae,
    formatters::ex_adaette,
    formatters::ex_adcm,
    formatters::ex_adlb,
    formatters::ex_admh,
    formatters::ex_adqs,
    formatters::ex_adrs,
    formatters::ex_adsl,
    formatters::ex_adtte,
    formatters::ex_advs) |>
  enframe("filename", "df") |>
  mutate(filename = str_c("data/", filename |> str_remove("formatters::"), ".rds"))

walk2(
  .x = datalist$df,
  .y = datalist$filename,
  .f = write_rds)

