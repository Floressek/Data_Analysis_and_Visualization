# Załadowanie potrzebnych pakietów
library(latticeExtra)
library(lattice)
library(sandwich)

# Wczytanie danych Investment z pakietu sandwich
data(Investment, package = "sandwich")
Investment <- as.data.frame(Investment)
summary(Investment)

# Dodajemy kolumnę z latami
Investment$Year <- seq(1963, 1982)
Investment <- Investment[2:20,]  # Usunięcie pierwszego wiersza
summary(Investment)

# 1. Szereg czasowy inwestycji i wartości dodanej
xyplot(RealInv + RealGNP ~ Year, data = Investment,
       type = "l", col = c("darkblue", "darkred"), lwd = 2,
       auto.key = list(space = "right", lines = TRUE, points = FALSE),
       main = "Inwestycje i GNP w czasie",
       xlab = "Rok", ylab = "Wartość")

# 2. Wykres rozproszenia między inwestycjami a GNP
xyplot(RealInv ~ RealGNP, data = Investment,
       type = c("p", "r"), col = "darkblue", pch = 16,
       main = "Zależność między inwestycjami a GNP",
       xlab = "Realne GNP", ylab = "Realne inwestycje")


# 3. Panel szeregów czasowych dla kilku zmiennych z indywidualnymi skalami
Investment_long <- reshape(Investment,
                         idvar = "Year",
                         varying = list(c("RealInv", "RealGNP", "RealInt")),
                         v.names = "Value",
                         times = c("Inwestycje", "GNP", "Stopa procentowa"),
                         timevar = "Variable",
                         direction = "long")

# Ustawienie indywidualnych skal dla każdej zmiennej
xyplot(Value ~ Year | Variable, data = Investment_long,
      type = "l", layout = c(1, 3), col = "darkblue", lwd = 2,
      main = "Zmienne ekonomiczne w czasie",
      xlab = "Rok", ylab = "Wartość",
      scales = list(y = list(relation = "free")),
      par.settings = list(strip.background = list(col = "lightgray")),
      strip = function(...) strip.default(..., strip.names = TRUE))

# 4. Wykres rozproszenia z kolorami według stopy procentowej
levelplot(RealInv ~ Year * RealGNP, data = Investment,
col.regions = colorRampPalette(c("blue", "white", "red"))(100),
main = "Inwestycje w zależności od roku i GNP",
xlab = "Rok", ylab = "Realne GNP")

# 6. Wykres pudełkowy dla zmiennych ekonomicznych
variables <- c("RealInv", "RealGNP", "RealInt")
data_long <- stack(Investment[, variables])
names(data_long) <- c("value", "variable")

bwplot(variable ~ value, data = data_long,
main = "Rozkład zmiennych ekonomicznych",
xlab = "Wartość", ylab = "Zmienna",
fill = "lightblue", pch = "|")

# 8. Analiza relacji między wszystkimi zmiennymi - wykres macierzowy
splom(~Investment[, c("RealInv", "RealGNP", "RealInt", "Year")],
main = "Macierz wykresów rozproszenia",
pscales = 0,
col = "darkblue",
varnames = c("Inwestycje", "GNP", "Stopa %", "Rok"))

##### Dodatkowe wykresy
# A. Porównanie wskaźników nominalnych i realnych na jednym wykresie
gnp_plot <- xyplot(GNP ~ Year, data = Investment, type = "l", col = "darkblue", lwd = 2,
                  main = "GNP nominalny vs realny", ylab = "GNP nominalny [mld USD]")
real_gnp_plot <- xyplot(RealGNP ~ Year, data = Investment, type = "l", col = "darkred", lwd = 2)
combined_gnp <- doubleYScale(gnp_plot, real_gnp_plot, add.ylab2 = TRUE)
print(combined_gnp)

# B. Podobne porównanie dla inwestycji
inv_plot <- xyplot(Investment ~ Year, data = Investment, type = "l", col = "darkblue", lwd = 2,
                  main = "Inwestycje nominalne vs realne", ylab = "Inwestycje nominalne [mld USD]")
real_inv_plot <- xyplot(RealInv ~ Year, data = Investment, type = "l", col = "darkred", lwd = 2)
combined_inv <- doubleYScale(inv_plot, real_inv_plot, add.ylab2 = TRUE)
print(combined_inv)

# D. Wskaźnik deflatora w czasie (podobnie jak w przykładzie)
xyplot(Price ~ Year, data = Investment, type = "l", col = "darkgreen", lwd = 2,
       main = "Zmiana deflatora cen w czasie",
       xlab = "Rok", ylab = "Deflator cen")

# F. Wykorzystanie funkcji z latticeExtra - wykres bąbelkowy
xyplot(RealInv ~ RealGNP, data = Investment,
       type = "p",
       cex = (Investment$RealInt - min(Investment$RealInt)) * 2 + 1,  # Rozmiar punktów zależny od stopy procentowej
       col = trellis.par.get("superpose.symbol")$col[1],
       main = "Inwestycje vs GNP z uwzględnieniem stopy procentowej",
       xlab = "Realne GNP", ylab = "Realne inwestycje",
       key = list(
         space = "top", points = list(col = "black", cex = c(1, 2, 3)),
         text = list(c("Niska stopa", "Średnia stopa", "Wysoka stopa")),
         columns = 3
       ))