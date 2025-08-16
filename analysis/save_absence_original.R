library(readxl)
library(tidyverse)
install.packages("here")
library(here)
library(purrr)

setwd("C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/raw")

folder_path <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/raw"
absence_files <- list.files(path = folder_path, pattern = "不登校生徒数.*\\.xlsx$", full.names = TRUE)
absence_list <- map(absence_files, read_excel)
names(absence_list) <- paste0("absence_", 2013:2022)

student_file <- file.path(folder_path, "生徒数.xlsx")
student_df <- read_excel(student_file)

save_path <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/original"
walk2(absence_list, names(absence_list), ~ {
  file_name <- paste0(.y, ".rds")
  saveRDS(.x, file = file.path(save_path, file_name))
})

saveRDS(student_df, file = file.path(save_path, "student_df.rds"))

