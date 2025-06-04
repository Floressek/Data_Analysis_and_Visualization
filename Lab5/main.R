# # Program 1
# library(lattice)
#
# xx <- c(9.20, 6.00, 6.00, 11.25, 11.00, 7.25, 9.7, 13.25, 14.00, 8.00)
#
# # Lattice equivalent of hist with specified breaks
# histogram(xx,
#           breaks = c(6, 8, 10, 12, 14),
#           include.lowest = TRUE,
#           right = FALSE,
#           xlab = "Value",
#           main = "Histogram")
#
# # Program 2
# set.seed(591)
#
# xx1 <- rnorm(20, mean = 3, sd = 3.6)
# xx2 <- rpois(40, lambda = 3.5)
# xx3 <- rchisq(31, df = 5, ncp = 0)
#
# data <- data.frame(
#   values = c(xx1, xx2, xx3),
#   groups = factor(c(rep("Group-1", length(xx1)),
#                     rep("Group-2", length(xx2)),
#                     rep("Group-3", length(xx3))),
#                   levels = c("Group-1", "Group-2", "Group-3"))
# )
#
# bwplot(values ~ groups, data = data,
#        xlab = "Group",
#        ylab = "Value",
#        scales = list(x = list(cex = 0.7)),
#        main = "Boxplot of Values by Group")

# Zasanie 2
# Załadowanie potrzebnych pakietów
library(lattice)  # używamy głównie lattice do wszystkich wykresów

# Wczytanie danych Eggs
Eggs<-read.csv("http://jolej.linuxpl.info/Eggs.csv", header=TRUE)

# Sprawdzenie danych
head(Eggs)
summary(Eggs)

# Konwersja zmiennych character na factor
Eggs$Month <- as.factor(Eggs$Month)
Eggs$First.Week <- as.factor(Eggs$First.Week)
Eggs$Easter <- as.factor(Eggs$Easter)

summary(Eggs)

# Analiza korelacji między Cases (sprzedaż jajek) a innymi zmiennymi
# Wybieramy dostępne zmienne liczbowe do analizy
main_vars <- c("Cases", "Egg.Pr", "Cereal.Pr", "Beef.Pr", "Chicken.Pr", "Pork.Pr")
eggs_subset <- Eggs[, main_vars]

# Sprawdzenie czy wszystkie zmienne są numeryczne i usunięcie ewentualnych NA
eggs_subset <- eggs_subset[complete.cases(eggs_subset), ]

# Obliczenie macierzy korelacji
cor_matrix <- cor(eggs_subset)

# Wyświetlenie macierzy korelacji
print(cor_matrix)

# 1. Wykres macierzowy pokazujący relacje między zmiennymi z lattice
splom(eggs_subset, main = "Macierzowy wykres rozproszenia - Eggs")

# 2. Wizualizacja macierzy korelacji z lattice zamiast corrplot
# Tworzymy funkcję pomocniczą do wyświetlania macierzy korelacji z lattice
panel.corr <- function(x, y, z, subscripts, at, ...) {
  panel.levelplot(x, y, z, subscripts, at, ...)
  panel.text(x, y, round(z[subscripts], 2))
}

# a. Odpowiednik metody z liczbami
levelplot(cor_matrix,
          main="Macierz korelacji",
          xlab="", ylab="",
          at=seq(-1, 1, by=0.25),
          col.regions=colorRampPalette(c("red", "white", "blue"))(100),
          panel=panel.corr)

# b. Odpowiednik metody z kolorami (bez liczb)
levelplot(cor_matrix,
          main="Macierz korelacji",
          xlab="", ylab="",
          at=seq(-1, 1, by=0.25),
          col.regions=colorRampPalette(c("red", "white", "blue"))(100))

# 4. Wykres pudełkowy dla zmiennych
# Przekształcenie danych do formatu długiego (long format)
variables <- c("Egg.Pr", "Beef.Pr", "Chicken.Pr", "Pork.Pr", "Cereal.Pr")
data_long <- stack(eggs_subset[, variables])
names(data_long) <- c("value", "variable")

# Zamieniamy variable na factor
data_long$variable <- as.factor(data_long$variable)

# Tworzenie wykresu pudełkowego z lattice
bwplot(variable ~ value, data = data_long,
       main="Zmienne wpływające na sprzedaż jajek",
       xlab="Wartość", ylab="Zmienna")

# Dodatkowy wykres pudełkowy z logarytmiczną skalą
bwplot(variable ~ value, data = data_long,
       scales=list(x=list(log=TRUE)),
       main="Zmienne wpływające na sprzedaż jajek (skala logarytmiczna)",
       xlab="Wartość (skala logarytmiczna)", ylab="Zmienna")

# 5. Wykres słupkowy pokazujący korelacje z Cases z lattice
correlations <- cor_matrix["Cases", -1]  # Korelacje bez samej Cases
correlations_df <- data.frame(variable = names(correlations), correlation = correlations)
correlations_df <- correlations_df[order(abs(correlations_df$correlation), decreasing = TRUE), ]

# Ustawienie kolorów w zależności od znaku korelacji
correlations_df$color <- ifelse(correlations_df$correlation > 0, "darkgreen", "darkred")

# Wykres słupkowy z lattice
barchart(variable ~ correlation, data = correlations_df,
         col = correlations_df$color,
         main="Korelacja ze sprzedażą jajek",
         xlab="Korelacja", ylab="Zmienna")

# 6. Analiza trendów w czasie z użyciem lattice
xyplot(Cases ~ Week, data = Eggs, type="l", col="blue",
       main="Trend sprzedaży jajek w czasie", xlab="Tydzień", ylab="Ilość sprzedanych jajek")

# Pobieramy dane o cenach artykułów spożywczych
food_prices <- Eggs[order(Eggs$Week), c("Week", "Egg.Pr", "Beef.Pr", "Chicken.Pr", "Pork.Pr", "Cereal.Pr")]

# Przygotowujemy dane do wykresu
mdf <- as.matrix(food_prices[, -1])
colnames(mdf) <- c("Jajka", "Wołowina", "Kurczak", "Wieprzowina", "Zboża")
mdf_df <- as.data.frame(mdf)
mdf_df$Week <- food_prices$Week

# Przekształcamy dane do formatu długiego dla lattice
mdf_long <- reshape(mdf_df,
                   idvar = "Week",
                   varying = list(colnames(mdf)),
                   times = colnames(mdf),
                   v.names = "Value",
                   timevar = "Product",
                   direction = "long")

# Rysujemy wykres za pomocą lattice
xyplot(Value ~ Week, groups = Product, data = mdf_long, type = "l",
       auto.key = list(space = "right", lines = TRUE, points = FALSE),
       main = "Porównanie cen artykułów spożywczych w czasie",
       xlab = "Tydzień", ylab = "Cena")

# Wykres liniowy z normalizacją cen z użyciem lattice
# Ta wersja pozwala lepiej zobaczyć względne zmiany cen
normalize_prices <- function(x) {
  return(x / x[1] * 100)  # Wartość w pierwszym tygodniu = 100%
}

# Normalizujemy ceny
mdf_norm <- apply(mdf, 2, normalize_prices)
mdf_norm_df <- as.data.frame(mdf_norm)
mdf_norm_df$Week <- food_prices$Week

# Przekształcamy dane do formatu długiego dla lattice
mdf_norm_long <- reshape(mdf_norm_df,
                        idvar = "Week",
                        varying = list(colnames(mdf)),
                        times = colnames(mdf),
                        v.names = "Value",
                        timevar = "Product",
                        direction = "long")

# Rysujemy wykres za pomocą lattice
xyplot(Value ~ Week, groups = Product, data = mdf_norm_long, type = "l",
       auto.key = list(space = "right", lines = TRUE, points = FALSE),
       main = "Względne zmiany cen artykułów spożywczych (pierwszy tydzień = 100%)",
       xlab = "Tydzień", ylab = "Cena (% wartości początkowej)")

# Porównanie sprzedaży jajek z ceną jajek
# Sortujemy dane według tygodnia
Eggs_sorted <- Eggs[order(Eggs$Week), ]

# Normalizujemy wartości do zakresu [0,1] dla lepszego porównania
cases_norm <- (Eggs_sorted$Cases - min(Eggs_sorted$Cases, na.rm = TRUE)) /
              (max(Eggs_sorted$Cases, na.rm = TRUE) - min(Eggs_sorted$Cases, na.rm = TRUE))
egg_price_norm <- (Eggs_sorted$Egg.Pr - min(Eggs_sorted$Egg.Pr, na.rm = TRUE)) /
                  (max(Eggs_sorted$Egg.Pr, na.rm = TRUE) - min(Eggs_sorted$Egg.Pr, na.rm = TRUE))

# Przygotowanie danych do wykresu
comparison_data <- data.frame(
  Tydzien = Eggs_sorted$Week,
  Sprzedaz_Norm = cases_norm,
  Cena_Norm = egg_price_norm,
  Sprzedaz_Org = Eggs_sorted$Cases,
  Cena_Org = Eggs_sorted$Egg.Pr
)

# Przekształcamy dane do formatu długiego dla lattice
comparison_long <- reshape(comparison_data,
                          idvar = "Tydzien",
                          varying = list(c("Sprzedaz_Norm", "Cena_Norm")),
                          v.names = "Value",
                          times = c("Sprzedaż jajek", "Cena jajek"),
                          timevar = "Typ",
                          direction = "long")

# Wykres porównawczy z lattice
xyplot(Value ~ Tydzien, groups = Typ, data = comparison_long, type = "l",
       auto.key = list(space = "right", lines = TRUE, points = FALSE),
       main = "Porównanie znormalizowanej sprzedaży jajek z ceną jajek",
       xlab = "Tydzień", ylab = "Znormalizowana wartość (0-1)")

# 7. Analiza - wpływ miesiąca na sprzedaż z lattice
month_avg <- aggregate(Cases ~ Month, data = Eggs, mean)
month_avg <- month_avg[order(month_avg$Cases, decreasing = TRUE), ]

# Wykres słupkowy z lattice
barchart(Cases ~ Month, data = month_avg,
         col = "light gray",
         main = "Średnia sprzedaż jajek według miesiąca",
         xlab = "Miesiąc", ylab = "Średnia sprzedaż")

# 8. Analiza - wpływ Easter (Wielkanocy) na sprzedaż z lattice
easter_avg <- aggregate(Cases ~ Easter, data = Eggs, mean)

# Wykres słupkowy z lattice
barchart(Cases ~ Easter, data = easter_avg,
         col = c("skyblue", "coral"),
         main = "Średnia sprzedaż jajek w zależności od Wielkanocy",
         xlab = "Wielkanocy", ylab = "Średnia sprzedaż")

# 9. Analiza - wpływ First.Week na sprzedaż z lattice
first_week_avg <- aggregate(Cases ~ First.Week, data = Eggs, mean)

# Wykres słupkowy z lattice
barchart(Cases ~ First.Week, data = first_week_avg,
         col = "lightblue",
         main = "Średnia sprzedaż jajek według First.Week",
         xlab = "First.Week", ylab = "Średnia sprzedaż")