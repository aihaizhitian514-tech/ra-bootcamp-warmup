# code/clean_class.R

library(readxl)
library(dplyr)
library(stringr)
library(purrr)
library(tidyr)

# 1. データフォルダ設定
original_data_dir <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/original"
cleaned_data_dir <- "C:/Users/shiro/OneDrive/デスクトップ/bootcamp/data/cleaned"


# 2. 保存済みRDSファイルを読み込む
rds_files <- list.files(original_data_dir, pattern = "\\.rds$", full.names = TRUE)
class_list <- map(rds_files, readRDS)

# 年度を名前に設定
names(class_list) <- str_extract(basename(rds_files), "\\d{4}")

# 3. 単一データフレームをクリーニングする関数
clean_single_df <- function(df, year) {
  # 1行目を変数名に設定（学級を削除、NAや空白は自動で修正）
  new_names <- df[1, ] %>% 
    unlist() %>% 
    as.character() %>% 
    str_replace("学級", "") %>% 
    make.names(unique = TRUE)
  
  # 都道府県列は "prefecture" に固定
  new_names[1] <- "prefecture"
  
  df <- df[-1, ]
  names(df) <- new_names
  
  # 「計」列を削除
  df <- df %>% select(-matches("計"))
  
  # 年度列追加
  df <- df %>% mutate(year = as.numeric(year))
  
  return(df)
}

# 4. 全データをクリーニングして年度列追加
class_list <- imap(class_list, ~ clean_single_df(.x, .y))

# 5. 都道府県番号を付与して1つのデータフレームに結合
all_data <- bind_rows(class_list)

pref_numbers <- tibble(
  prefecture = unique(all_data$prefecture),
  prefecture_code = 1:47
)

all_data <- all_data %>% 
  left_join(pref_numbers, by = "prefecture") %>% 
  arrange(year, prefecture_code)

# 6. long型に変形前に列を数値に変換
all_data <- all_data %>%
  mutate(across(-c(prefecture, year), ~ as.numeric(as.character(.))))

# 6. long型に変形
all_data_long <- all_data %>%
  pivot_longer(
    cols = -c(prefecture, prefecture_code, year),
    names_to = "class",
    values_to = "school_count",
    values_drop_na = TRUE
  ) %>%
  mutate(
    # 学級数の範囲がある場合は平均値を取る
    class_num = str_extract(class, "\\d+") %>% as.numeric(),
    class_x_school = class_num * school_count
  )


# 7. 年・都道府県ごとの合計学級数
summary_data <- all_data_long %>%
  group_by(year, prefecture_code, prefecture) %>%
  summarise(
    total_class_x_school = sum(class_x_school, na.rm = TRUE),
    .groups = "drop"
  )

# 8. RDS形式で保存
saveRDS(all_data_long, file.path(cleaned_data_dir, "class_long_cleaned.rds"))
saveRDS(summary_data, file.path(cleaned_data_dir, "class_summary_cleaned.rds"))

#感想
#課題１と２合わせて4時間半程度かかりました。どうしても解答例のようにならない部分があり修正が難しかったです。
