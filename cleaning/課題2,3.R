#課題２
#Problem 1
#修正すべき点
#col1がNAである場合、TRUEを返すダミー変数を作ろうとしている。
#しかしNA==NAとなってしまうため、col1がNAのときTRUEではなくNAを返してしまう。

#修正後のコード
df <- tibble(
  col1 = sample(c(NA, 1), size = 100, replace = TRUE)
) |>
  mutate(
    is_na = if_else(is.na(col1), TRUE, FALSE)
  )

#修正内容
#is.na()関数を使うことでcol1がNAの場合TRUEを返すようにした

#Problem2
#修正すべき点
#調べたところdplyr::select_vars()は最新の関数ではないため、上手く動作しない可能性がある

#修正後のコード
df_population <- readr::read_csv(here::here("assignment23_data", "raw","population_ps2.csv"))
df_population %>%
  dplyr::select(contains("name"))

#修正内容
#dplyr::select()関数を使用

#Problem3
#修正すべき点
#change_rateは、log(population_t) - log(population_{t-20})であり成長率を指す。
#一方でchange_rateに対してさらにlm(change_rate)としているため、change_rateが負や0の場合にエラーになる。
#またn=20としているがかなり長い期間の成長率を求めていることになるためn=1に変更する。

#修正後のコード
df_population <- readr::read_csv(here::here("assignment23_data", "raw","population_ps2.csv"))
df_lm <- df_population |>
  arrange(city_name, year) |>
  mutate(
    log_population_change = (log(population) - dplyr::lag(log(population), n = 1)),
    .by = city_id
  ) |>
  dplyr::filter(year == 2015) |>
  dplyr::filter(!is.na(log_population_change))


#修正内容
#n=1に変更
#change_rateの部分はさらにlogをつけずにそのまま用いる

#Problem4
#修正すべき点
#ggplotのコードが何回も出てきてしまっている

#修正後のコード
set.seed(111)
df <- tibble(
  col_1 = seq(1, 10),
  col_2 = seq(11, 20) + rnorm(n = 10, 0, 1),
  col_3 = seq(30, 21) + rnorm(n = 10, 0, 1),
)

base_plot <- ggplot(df, aes(x = col_1)) +
  geom_point() +
  theme_minimal()

plot_col_12 <- base_plot + aes(y = col_2)
plot_col_13 <- base_plot + aes(y = col_3)

plot_col_12
plot_col_13

#修正内容
#共通のテーマをまとめる（やり方が思い浮かばずかなり調べてやりました）

#Problem5
#修正すべき点
#列名がhigherになっても反映されていない

#Problem6
#修正すべき点
#lm_robust()が重複している。

#課題３
#2
#mutateが何度もでてくるためまとめるべき