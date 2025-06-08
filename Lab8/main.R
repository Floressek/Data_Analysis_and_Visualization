options(repr.plot.width = 15, repr.plot.height = 5, repr.plot.res = 200)
library(ggplot2)
library(ggplot2movies)
library(dplyr)
library(tidyr)

# Usuwamy kolumny mpaa oraz r1 - r10 - nie będę ich używał
data <- movies
data <- subset(data, select = -c(r1:r10, mpaa))

# Mapujemy gatunki filmów
data <- data %>%
  gather(genre, value, Action:Short) %>%
  filter(value == 1) %>%
  select(-value)

# Konwertujemy kolumnę z gatunkiem na kategoryczny typ
data$genre <- as.factor(data$genre)

# Sprawdzamy podstawowe informacje o danych
head(data, 5)
summary(data)

# Rozkłady zmiennych numerycznych - zmieniona kolejność i kolory

# 1. Rozklad ocen (zmieniony z roku na poczatek)
ggplot(data, aes(x = rating)) +
  geom_histogram(binwidth = 0.1, fill = "#E74C3C", color = "white", alpha = 0.8) +
  scale_x_continuous(breaks = seq(1, 10, 1)) +
  labs(title = "Rozklad ocen filmow", x = "Ocena", y = "Liczba filmow") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# 2. Rozklad dlugosci filmow
ggplot(data, aes(x = length)) +
  geom_histogram(binwidth = 10, fill = "#3498DB", color = "white", alpha = 0.8) +
  scale_x_continuous(breaks = seq(0, 900, 100)) +
  labs(title = "Rozklad dlugosci filmow", x = "Dlugosc [minuty]", y = "Liczba filmow") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# 3. Rozklad rokow produkcji
ggplot(data, aes(x = year)) +
  geom_histogram(binwidth = 1, fill = "#2ECC71", color = "white", alpha = 0.8) +
  scale_x_continuous(breaks = seq(1890, 2010, 10)) +
  labs(title = "Rozklad rokow produkcji", x = "Rok", y = "Liczba filmow") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# 4. Rozklad liczby glosow
ggplot(data, aes(x = votes)) +
  geom_histogram(binwidth = 1000, fill = "#9B59B6", color = "white", alpha = 0.8) +
  scale_x_continuous(breaks = seq(0, 160000, 20000)) +
  labs(title = "Rozklad liczby glosow", x = "Liczba glosow", y = "Liczba filmow") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# 5. Rozklad budzetow
ggplot(data, aes(x = budget)) +
  geom_histogram(binwidth = 5000000, fill = "#F39C12", color = "white", alpha = 0.8, na.rm = TRUE) +
  scale_x_continuous(breaks = seq(0, 200000000, 20000000)) +
  labs(title = "Rozklad budzetow filmow", x = "Budzet [USD]", y = "Liczba filmow") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# Boxploty najwazniejszych zmiennych
ggplot(data, aes(x = genre, y = rating)) +
  geom_boxplot(fill = "#E74C3C", alpha = 0.7, color = "#C0392B") +
  labs(title = "Ocena w zaleznosci od gatunku", x = "Gatunek", y = "Ocena") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

ggplot(data, aes(x = genre, y = budget)) +
  geom_boxplot(fill = "#F39C12", alpha = 0.7, color = "#E67E22", na.rm = TRUE) +
  labs(title = "Budzet w zaleznosci od gatunku", x = "Gatunek", y = "Budzet [USD]") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# Wykres bąbelkowy dla filmów animacyjnych
animation_data <- data %>% filter(genre == "Animation")
animation_data <- animation_data %>% filter(!is.na(budget))

ggplot(animation_data, aes(x = year, y = budget, size = rating)) +
  geom_point(alpha = 0.6, color = "#E74C3C") +
  scale_size_continuous(range = c(2, 12)) +
  labs(title = "Budzet w zaleznosci od roku z ocena jako rozmiar babelkow (filmy animacyjne)",
       x = "Rok produkcji",
       y = "Budzet [USD]",
       size = "Ocena") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# Wykres babelkowy dla filmow animacyjnych
animation_data <- data %>% filter(genre == "Animation")
animation_data <- animation_data %>% filter(!is.na(budget))

ggplot(animation_data, aes(x = year, y = budget, size = rating)) +
  geom_point(alpha = 0.6, color = "#E74C3C") +
  scale_size_continuous(range = c(2, 12)) +
  labs(title = "Budzet w zaleznosci od roku z ocena jako rozmiar babelkow (filmy animacyjne)",
       x = "Rok produkcji",
       y = "Budzet [USD]",
       size = "Ocena") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

# Wykresy zaleznosci z podzialem na gatunki
ggplot(data, aes(x = year, y = budget, color = genre)) +
  geom_point(alpha = 0.6) +
  scale_color_viridis_d() +
  labs(x = "Rok produkcji", y = "Budzet [USD]", color = "Gatunek",
       title = "Zaleznosc budzetu od roku produkcji filmu") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

ggplot(data, aes(x = budget, y = rating, color = genre)) +
  geom_point(alpha = 0.6) +
  scale_color_viridis_d() +
  labs(x = "Budzet [USD]", y = "Ocena", color = "Gatunek",
       title="Zaleznosc sredniej oceny od budzetu") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))

ggplot(data, aes(x = year, y = votes, color = genre)) +
  geom_point(alpha = 0.6) +
  scale_color_viridis_d() +
  labs(x = "Rok produkcji", y = "Liczba ocen", color = "Gatunek",
       title = "Zaleznosc liczby ocen od roku produkcji") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14))


# ZADANIE: Wykres z trzema panelami pokazujacymi najwazniejsze prawidlowosci
library(gridExtra)

# Panel 1: Wzrost produkcji filmow w czasie
p1 <- ggplot(data, aes(x = year)) +
  geom_histogram(binwidth = 5, fill = "#2ECC71", color = "white", alpha = 0.8) +
  scale_x_continuous(breaks = seq(1890, 2010, 20)) +
  labs(title = "Wzrost produkcji filmow w czasie",
       x = "Rok", y = "Liczba filmow") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 12))

# Panel 2: Dominacja komedii i dramatow
genre_summary <- data %>%
  group_by(genre) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

p2 <- ggplot(genre_summary, aes(x = reorder(genre, count), y = count)) +
  geom_col(fill = "#3498DB", alpha = 0.8) +
  coord_flip() +
  labs(title = "Dominacja komedii i dramatow",
       x = "Gatunek", y = "Liczba filmow") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 12))

# Panel 3: Brak zaleznosci miedzy budzetem a ocena
budget_data <- data %>% filter(!is.na(budget))
p3 <- ggplot(budget_data, aes(x = budget/1000000, y = rating)) +
  geom_point(alpha = 0.4, color = "#E74C3C") +
  labs(title = "Brak zaleznosci: budzet vs ocena",
       x = "Budzet [miliony USD]", y = "Ocena") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 12))

# Laczenie paneli
grid.arrange(p1, p2, p3, ncol = 3,
             top = "Trzy najwazniejsze prawidlowosci w zbiorze danych movies")