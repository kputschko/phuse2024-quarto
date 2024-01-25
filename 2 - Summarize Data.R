
# PHUSE 2024 --------------------------------------------------------------


# Setup -------------------------------------------------------------------

library(fs)
library(labelled)
library(tidyverse)
library(vctrs)


# Read Data ---------------------------------------------------------------

data_list <-
  dir_ls("data") |>
  map(read_rds) |>
  enframe(
    name = "filepath",
    value = "data") |>
  mutate()

data_summary <-
  list(
    var_type  =
      data_list$data[[2]] |>
      map(class) |>
      enframe("variable", "type") |>
      unnest(type) |>
      summarize(.by = variable, type = str_flatten_comma(type)),
    var_label = data_list$data[[2]] |> labelled::generate_dictionary(details = "none"),
    var_date  =
      data_list$data[[2]] |>
      summarize(across(
        .cols = where(\(x) is.Date(x) || is.POSIXt(x)),
        .fns  = \(x) x |> range(na.rm = T) |> str_flatten(" -- "))) |>
      pivot_longer(everything(), names_to = "variable", values_to = "values_d"),
    var_category  =
      data_list$data[[2]] |>
      summarize(across(where(is.factor), \(x) x |> unique() |> str_flatten_comma())) |>
      pivot_longer(everything(), names_to = "variable", values_to = "values_c"),
    var_numeric =
      data_list$data[[2]] |>
      summarize(across(where(is.numeric), \(x) str_glue("mean:{a}; sd:{b}; range:{c})",
                                                        a = mean(x, na.rm = T) |> round(2),
                                                        b = sd(x, na.rm = T) |> round(2),
                                                        c = range(x, na.rm = T) |> round(2) |> str_flatten("-")))) |>
      pivot_longer(everything(), names_to = "variable", values_to = "values_n")) |>
  reduce(.f = \(x, y) left_join(x, y, join_by(variable))) |>
  rename(variable_order = pos) |>
  mutate(summary_values = coalesce(values_c, values_n, values_d)) |>
  select(-starts_with("values_"))
