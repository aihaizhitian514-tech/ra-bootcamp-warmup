# code/save_class_original.R

# 必要なパッケージ
library(readxl)
library(dplyr)
library(purrr)
install.packages("labelled")
library(labelled)

# 1. データフォルダのパス
raw_data_dir <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/raw"
original_data_dir <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/original"

# 2. Excelファイルの取得
excel_files <- list.files(raw_data_dir, pattern = "\\.xlsx$", full.names = TRUE)

# 3. 各Excelファイルを読み込み処理
class_list <- map(excel_files, function(file_path) {
  
  # ExcelのA1セルから年度を抽出
  year <- read_excel(file_path, range = "A1", col_names = FALSE) %>% pull(1) %>% as.numeric()
  
  # データ本体を読み込む（1行目をスキップして列名は後で設定）
  df <- read_excel(file_path, skip = 1, col_names = FALSE)
  
  colnames(df) <- c("prefecture", "class", "school_count")
  
  # 年度列を追加
  df <- df %>% mutate(year = year)
  
  # 変数ラベルを付与
  var_label(df$prefecture) <- "Prefecture name"
  var_label(df$class) <- "Number of classes"
  var_label(df$school_count) <- "Number of schools"
  var_label(df$year) <- "Survey year"
  
  return(df)
})

# 4. list に年度名を付与
names(class_list) <- paste0("class_", 2013:(2013 + length(class_list) - 1))

# 5. 各データをRDS形式で保存
walk2(class_list, names(class_list), ~ {
  saveRDS(.x, file = file.path(original_data_dir, paste0(.y, ".rds")))
)
})
