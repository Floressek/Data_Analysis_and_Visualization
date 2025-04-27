# Ustaw kodowanie
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Utwórz kopię ramki i przygotuj dane
df <- LifeCycleSavings
df$Country <- rownames(df)
df$Country <- as.factor(df$Country)
df$pop1575 <- 100 - df$pop15 - df$pop75
df$savings <- df$sr * df$dpi

# Tworzymy folder "data" jeśli nie istnieje
if (!dir.exists("data")) dir.create("data")

# Funkcja do rysowania wykresu i jednoczesnego zapisywania do pliku
plot_and_save <- function(expr, filename, width = 800, height = 600) {
  # Wykonaj wyrażenie, żeby pokazać wykres w Plots
  eval(expr)
  # Zapisz ten sam wykres do pliku
  png(paste0("data/", filename, ".png"), width = width, height = height, res = 100)
  eval(expr)
  dev.off()
}

# 1. Wykres par (dwuczynnikowy)
plot_and_save(
  quote(pairs(df[, c("sr", "pop15", "pop75", "dpi", "ddpi", "Country")], panel = panel.smooth, main = "Dependencies between variables")),
  "pairs_plot", 800, 800
)

# 2. Histogramy (jednoczynnikowe)
zmienne <- c("sr", "dpi", "pop15", "pop75", "ddpi")
etykiety <- c("Savings Rate (sr)", "Average income (dpi)",
              "% population under 15 (pop15)",
              "% population over 75 (pop75)",
              "% income growth (ddpi)")
tytuly <- c("Histogram of savings rate",
            "Histogram of average income",
            "Histogram of % population under 15",
            "Histogram of % population over 75",
            "Histogram of % income growth")

for (i in seq_along(zmienne)) {
  plot_and_save(
    bquote(hist(df[[.(zmienne[i])]], col = "blue", breaks = 12,
                main = .(tytuly[i]), xlab = .(etykiety[i]), ylab = "Number of countries")),
    paste0("histogram_", zmienne[i])
  )
}

# 3. Wykresy słupkowe w zależności od kraju (jednoczynnikowe)
plot_and_save(
  quote({
    par(mar = c(10, 4, 4, 2))
    barplot(df$sr, names.arg = df$Country, las = 2,
            main = "Savings rate by country",
            ylab = "Average savings rate", cex.names = 0.7, col = "orange")
  }),
  "barplot_sr_by_country", 1000, 700
)

plot_and_save(
  quote({
    par(mar = c(10, 4, 4, 2))
    barplot(df$savings, names.arg = df$Country, las = 2,
            main = "Savings by country",
            ylab = "Average savings", cex.names = 0.7, col = "orange")
  }),
  "barplot_savings_by_country", 1000, 700
)

# 4. Wykres udziału procentowego grup wiekowych (jednoczynnikowy)
plot_and_save(
  quote({
    par(mar = c(10, 4, 4, 2))
    colors <- c("purple", "lightblue", "blue")
    barplot(rbind(df$pop15, df$pop75, df$pop1575), col = colors,
            names.arg = df$Country, las = 2, cex.names = 0.7,
            ylab = "Part of society (%)")
    legend("topright",
           legend = c("% population under 15", "% population over 75",
                      "% population between 15-75"),
           fill = colors)
  }),
  "age_distribution_by_country", 1000, 700
)

# 5. Wykresy zależności (dwuczynnikowe)
plot_and_save(
  quote({
    plot(df$dpi, df$sr, main = "Relationship between average income and savings rate",
         xlab = "Average income (dpi)", ylab = "Savings rate (sr)",
         pch = 19, col = "blue")
    abline(lm(sr ~ dpi, data = df), col = "red", lwd = 2)
    text(df$dpi, df$sr, labels = df$Country, pos = 4, cex = 0.7)
  }),
  "scatter_sr_vs_dpi"
)

plot_and_save(
  quote({
    plot(df$pop15, df$sr, main = "Relationship between % population under 15 and savings rate",
         xlab = "% population under 15 (pop15)", ylab = "Savings rate (sr)",
         pch = 19, col = "blue")
    abline(lm(sr ~ pop15, data = df), col = "red", lwd = 2)
    text(df$pop15, df$sr, labels = df$Country, pos = 4, cex = 0.7)
  }),
  "scatter_sr_vs_pop15"
)
# Zapisanie danych do pliku CSV
write.csv(df, "data/LifeCycleSavings_with_additional_columns.csv", row.names = FALSE)

cat("Analysis completed. All charts saved in 'data' folder.\n")