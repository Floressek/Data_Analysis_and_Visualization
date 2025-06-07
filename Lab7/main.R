options(repr.plot.width = 15, repr.plot.height = 5, repr.plot.res = 200)

library(ggplot2)
library(dplyr)
library(tidyr)

# Zaladowanie zbioru danych
data <- economics

summary(data)
head(data, 10)

cat("
OPIS KOLUMN DANYCH:
+ date - Miesiąc zbierania danych
+ pce - Wydatki osobiste na konsumpcję, w miliardach dolarów
+ pop - Całkowita populacja, w tysiącach
+ psavert - Osobista stopa oszczędności
+ uempmed - Średni czas trwania bezrobocia, w tygodniach
+ unemploy - Liczba bezrobotnych, w tysiącach
")

# Wykres 1: Wydatki osobiste na konsumpcję w czasie
ggplot(data, aes(x = date)) +
  geom_line(aes(y = pce, color = "Wydatki osobiste [mld $]")) +
  geom_line(aes(y = psavert * 1000, color = "Procentowe oszczędności")) +
  scale_color_manual(values = c("Wydatki osobiste [mld $]" = "#371272", "Procentowe oszczędności" = "#20cce2")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(name = "Wydatki osobiste [mld $]", sec.axis = sec_axis(~ . * 0.001, name = "Procentowe oszczędności")) +
  labs(title = "Wykres 1. Procentowe oszczędności oraz wydatki osobiste w funkcji czasu", x = "", color = "Legenda") +
  theme(axis.title.y.left = element_text(color = "#371272"), axis.title.y.right = element_text(color = "#20cce2"),
   axis.text.x = element_text(angle = 90, hjust = 1))

# Wykres 2: Wydatki populacji w zależności od roku
qplot(data$date, (data$pce * 1000000 / data$pop), geom = "line", main = "Wykres 2. Populacja w zależności od roku", xlab = "", ylab = "Populacja [tys.]") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(breaks = seq(2500, max(data$pce * 1000000 / data$pop), by = 2000)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Wykres 3: Średni czas trwania bezrobocia oraz liczba bezrobotnych w funkcji czasu
ggplot(data, aes(x = date)) +
  geom_line(aes(y = unemploy, color = "Liczba bezrobotnych [tys.]")) +
  geom_line(aes(y = uempmed * 1000, color = "Średni czas trwania bezrobocia [tyg.]")) +
  scale_color_manual(values = c("Liczba bezrobotnych [tys.]" = "#371272", "Średni czas trwania bezrobocia [tyg.]" = "#20cce2")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(name = "Liczba bezrobotnych [tys.]", sec.axis = sec_axis(~ . * 0.001, name = "Średni czas trwania bezrobocia [tyg.]")) +
  labs(title = "Wykres 3. Śr. długość bezrobocia oraz liczba bezrobotnych w funkcji czasu", x = "", color = "Legenda") +
  theme(axis.title.y.left = element_text(color = "#371272"), axis.title.y.right = element_text(color = "#20cce2"), axis.text.x = element_text(angle = 90, hjust = 1))



# Filtrowana data danych dla wykresu babelkowego
filtered_data <- data %>%
  filter(date > as.Date("2003-01-01") & date < as.Date("2010-01-01"))

ggplot(filtered_data, aes(x = date, y = unemploy, size = uempmed, label = uempmed)) +
  geom_point(colour = "#3105f3", fill = "#f300f3", shape = 21) +
  scale_size_area(max_size = 10, name = "Średni czas bezrobocia") +
  scale_x_date(name = "", date_labels = "%Y-%m-%d", date_breaks = "1 month") +
  scale_y_continuous(name = "Liczba bezrobotnych [tys.]") +
  labs(title = "Wykres 4. Liczba bezrobotnych w latach 2002-2010") +
  geom_text(size = 3) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

