# Załadowanie potrzebnych pakietów
library(corrplot)
library(car)  # dla scatterplotMatrix

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

# 1. Wykres macierzowy pokazujący relacje między zmiennymi
par(mfrow=c(1, 1), mar=c(2.5, 2, 1, 1), cex=0.6)
pairs(eggs_subset, panel = panel.smooth, main = "Macierzowy wykres rozproszenia - Eggs")

# 2. Bardziej zaawansowany wykres macierzowy z car package
# Używamy odpowiednich argumentów dla scatterplotMatrix, usuwając te powodujące warningi
scatterplotMatrix(~Cases+Egg.Pr+Cereal.Pr+Chicken.Pr+Beef.Pr+Pork.Pr,
                  diagonal = 'boxplot', data=Eggs)

# 3. Wizualizacja macierzy korelacji różnymi metodami
# # a. Metoda domyślna
# corrplot(cor_matrix)
# b. Metoda z liczbami
corrplot(cor_matrix, method="number")
# c. Metoda z kolorami
corrplot(cor_matrix, method="color")

# 4. Wykres pudełkowy dla zmiennych
# Przekształcenie danych do formatu długiego (long format)
variables <- c("Egg.Pr", "Beef.Pr", "Chicken.Pr", "Pork.Pr", "Cereal.Pr")
data_long <- stack(eggs_subset[, variables])
names(data_long) <- c("value", "variable")

# Zamieniamy variable na factor
data_long$variable <- as.factor(data_long$variable)

# Tworzenie wykresu pudełkowego
boxplot(value ~ variable, data = data_long,
        col="light gray", main="Zmienne wpływające na sprzedaż jajek")

# Dodatkowy wykres pudełkowy z logarytmiczną skalą
boxplot(value ~ variable, data = data_long,
        log = "y", col = "light gray",
        boxwex = 0.5, main = "Zmienne wpływające na sprzedaż jajek (skala logarytmiczna)")

# 5. Wykres słupkowy pokazujący korelacje z Cases
correlations <- cor_matrix["Cases", -1]  # Korelacje bez samej Cases
correlations_df <- data.frame(variable = names(correlations), correlation = correlations)
correlations_df <- correlations_df[order(abs(correlations_df$correlation), decreasing = TRUE), ]

# Ustawienie kolorów w zależności od znaku korelacji
colors <- ifelse(correlations > 0, "darkgreen", "darkred")

barplot(correlations_df$correlation, names.arg=correlations_df$variable,
        col=colors[match(correlations_df$variable, names(correlations))],
        main="Korelacja ze sprzedażą jajek", las=2)

# 6. Analiza trendów w czasie
plot(Eggs$Week, Eggs$Cases, type="l", col="blue",
     main="Trend sprzedaży jajek w czasie", xlab="Tydzień", ylab="Ilość sprzedanych jajek")
par(mfrow=c(1, 1), mar=c(5, 4, 4, 8), xpd=TRUE)

# Pobieramy dane o cenach artykułów spożywczych
food_prices <- Eggs[order(Eggs$Week), c("Week", "Egg.Pr", "Beef.Pr", "Chicken.Pr", "Pork.Pr", "Cereal.Pr")]

library(plotly)

mdf <- as.matrix(food_prices[, -1])
colnames(mdf) <- c("Jajka", "Wołowina", "Kurczak", "Wieprzowina", "Zboża")

# Tworzymy interaktywny wykres za pomocą plotly
# Konwertujemy dane do formatu długiego dla plotly
plot_data <- data.frame(Tydzien = food_prices$Week)
for (i in seq_len(ncol(mdf))) {
  plot_data[[colnames(mdf)[i]]] <- mdf[, i]
}

# Tworzymy wykres interaktywny
p <- plot_ly(plot_data, x = ~Tydzien) %>%
  add_trace(y = ~Jajka, name = "Jajka", type = "scatter", mode = "lines", line = list(color = "red")) %>%
  add_trace(y = ~Wołowina, name = "Wołowina", type = "scatter", mode = "lines", line = list(color = "blue")) %>%
  add_trace(y = ~Kurczak, name = "Kurczak", type = "scatter", mode = "lines", line = list(color = "green")) %>%
  add_trace(y = ~Wieprzowina, name = "Wieprzowina", type = "scatter", mode = "lines", line = list(color = "purple")) %>%
  add_trace(y = ~Zboża, name = "Zboża", type = "scatter", mode = "lines", line = list(color = "orange")) %>%
  layout(title = "Porównanie cen artykułów spożywczych w czasie",
         xaxis = list(title = "Tydzień"),
         yaxis = list(title = "Cena"),
         hovermode = "closest")
p

# Wykres liniowy z normalizacją cen (procentowa zmiana względem pierwszego tygodnia)
# Ta wersja pozwala lepiej zobaczyć względne zmiany cen
normalize_prices <- function(x) {
  return(x / x[1] * 100)  # Wartość w pierwszym tygodniu = 100%
}

# Normalizujemy ceny
mdf_norm <- apply(mdf, 2, normalize_prices)

# Rysujemy wykres
par(mfrow=c(1, 1))
matplot(food_prices$Week, mdf_norm, type="l", col=c("red", "blue", "green", "purple", "orange"),
        lty=1, main="Względne zmiany cen artykułów spożywczych (pierwszy tydzień = 100%)",
        xlab="Tydzień", ylab="Cena (% wartości początkowej)")
legend("topright", legend=colnames(mdf), col=c("red", "blue", "green", "purple", "orange"),
       lty=1, cex=0.8)

# Porównanie sprzedaży jajek z ceną jajek
# Sortujemy dane według tygodnia
Eggs_sorted <- Eggs[order(Eggs$Week), ]

# Normalizujemy wartości do zakresu [0,1] dla lepszego porównania
cases_norm <- (Eggs_sorted$Cases - min(Eggs_sorted$Cases, na.rm = TRUE)) /
              (max(Eggs_sorted$Cases, na.rm = TRUE) - min(Eggs_sorted$Cases, na.rm = TRUE))
egg_price_norm <- (Eggs_sorted$Egg.Pr - min(Eggs_sorted$Egg.Pr, na.rm = TRUE)) /
                  (max(Eggs_sorted$Egg.Pr, na.rm = TRUE) - min(Eggs_sorted$Egg.Pr, na.rm = TRUE))

# Przygotowanie danych do wykresu interaktywnego
comparison_data <- data.frame(
  Tydzien = Eggs_sorted$Week,
  Sprzedaz_Norm = cases_norm,
  Cena_Norm = egg_price_norm,
  Sprzedaz_Org = Eggs_sorted$Cases,   # Dodajemy oryginalne wartości do hovera
  Cena_Org = Eggs_sorted$Egg.Pr       # Dodajemy oryginalne wartości do hovera
)

# Tworzymy wykres interaktywny
p_comparison <- plot_ly(comparison_data) %>%
  add_trace(x = ~Tydzien, y = ~Sprzedaz_Norm,
            name = "Sprzedaż jajek (znorm.)",
            type = "scatter", mode = "lines+markers", line = list(color = "blue", width = 3),
            marker = list(color = "blue", size = 6),
            text = ~paste("Tydzień:", Tydzien,
                         "<br>Sprzedaż znorm.:", round(Sprzedaz_Norm, 3),
                         "<br>Sprzedaż oryg.:", Sprzedaz_Org),
            hoverinfo = "text") %>%
  add_trace(x = ~Tydzien, y = ~Cena_Norm,
            name = "Cena jajek (znorm.)",
            type = "scatter", mode = "lines+markers", line = list(color = "red", width = 3),
            marker = list(color = "red", size = 6),
            text = ~paste("Tydzień:", Tydzien,
                         "<br>Cena znorm.:", round(Cena_Norm, 3),
                         "<br>Cena oryg.:", Cena_Org),
            hoverinfo = "text") %>%
  layout(title = list(text = "Porównanie znormalizowanej sprzedaży jajek z ceną jajek", font = list(size = 18)),
         xaxis = list(title = "Tydzień",
                      tickfont = list(size = 12),
                      titlefont = list(size = 14)),
         yaxis = list(title = "Znormalizowana wartość (0-1)",
                      tickfont = list(size = 12),
                      titlefont = list(size = 14),
                      range = c(0, 1)),
         hovermode = "closest",
         legend = list(x = 0.05, y = 0.95),
         hoverlabel = list(bgcolor = "white", font = list(size = 12)))

# Wyświetlenie wykresu
p_comparison

# 7. Analiza - wpływ miesiąca na sprzedaż (barplot)
month_avg <- aggregate(Cases ~ Month, data = Eggs, mean)
month_avg <- month_avg[order(month_avg$Cases, decreasing = TRUE), ]
barplot(month_avg$Cases, names.arg = month_avg$Month,
        col = "light gray", las = 2,
        main = "Średnia sprzedaż jajek według miesiąca")

# 8. Analiza - wpływ Easter (Wielkanocy) na sprzedaż
easter_avg <- aggregate(Cases ~ Easter, data = Eggs, mean)
barplot(easter_avg$Cases, names.arg = easter_avg$Easter,
        col = c("skyblue", "coral"),
        main = "Średnia sprzedaż jajek w zależności od Wielkanocy")

# 9.Analiza - wpływ First.Week na sprzedaż
first_week_avg <- aggregate(Cases ~ First.Week, data = Eggs, mean)
barplot(first_week_avg$Cases, names.arg = first_week_avg$First.Week,
        col = "lightblue", main = "Średnia sprzedaż jajek według First.Week")

