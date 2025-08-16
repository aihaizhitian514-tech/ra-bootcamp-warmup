library(purrr)
library(tidyverse)
library(readxl)
library(stringr)

original_path <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/original"
cleaned_path <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/cleaned"

# 不登校データ読み込み
absence_files <- list.files(original_path, pattern = "absence_.*\\.rds$", full.names = TRUE)


absence_df <- map_dfr(absence_files, function(file_path) {
  # ファイル名から年度（例: 2013）を抽出
  year_val <- as.numeric(str_extract(basename(file_path), "\\d{4}(?=\\.rds$)"))
  
  # RDSファイルを読み込み、抽出した年度を'year'列として追加
  readRDS(file_path) %>%
    mutate(year = year_val)
}) %>%
  mutate(
    都道府県 = str_trim(as.character(都道府県)),
    # カンマを削除してから数値に変換
    不登校生徒数 = as.numeric(str_replace_all(不登校生徒数, ",", ""))
  ) %>%

  select(-matches("blank"))

# 生徒数データ読み込み
student_df <- readRDS(file.path(original_path, "student_df.rds")) %>%
  mutate(
    都道府県 = str_trim(as.character(都道府県)),
    年度 = as.numeric(年度)
  )

# パネルデータ作成（左結合）

panel_df <- left_join(
  student_df,
  absence_df,
  by = c("都道府県" = "都道府県", "年度" = "year")
)

# 不登校割合を計算
panel_df <- panel_df %>%
  mutate(不登校割合 = 不登校生徒数 / 生徒数)

# rds形式で保存
saveRDS(panel_df, file = file.path(cleaned_path, "panel_absence.rds"))

# 確認
glimpse(panel_df)