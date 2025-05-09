# OmÛwiÊ rÛønice pomiÍdzy programami a i b  i c

# Program a

 par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
 xx <- c(9.20, 6.00, 6.00, 11.25, 11.00, 7.25, 9.7, 13.25, 14.00, 8.00)
 hist(xx, breaks = c(6, 8, 10, 12, 14))

# Program b
par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
xx <- c(9.20, 6.00, 6.00, 11.25, 11.00, 7.25, 9.7, 13.25, 14.00, 8.00)
hist(xx, breaks = c(6, 8, 10, 12, 14), right = F)

# Program c

par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
xx <- c(9.20, 6.00, 6.00, 11.25, 11.00, 7.25, 9.7, 13.25, 14.00, 8.00)
  br1 <-  c(6, 8, 10, 12, 14, 16)
  bw1 <- br1[2] - br1[1]
  xxh <- floor(xx/bw1) * bw1 + 0.1 * bw1
hist(xxh, breaks = br1, right = F)

# Zadanie 2
# Co przedstawia wykres generowany poniøszym kodem ? DodaÊ tytu≥ do wykresu.

 par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
 xx <- c(1.92, 4.01, 6.51, 1.40, 1.67, 5.27, 1.42, 0.36,
   3.18, 3.67, 7.48, 2.65, 7.86, 10.78, 2.30, 1.29, 0.31, 0.93,
   2.34, 2.53)

  d1 <- density(xx, bw = "Sj-ste")
  ex <- d1$x
  ey <- d1$y

  plot(ex, ey, type = "n", xlab = "x", ylab = "p(x)")
  lines(ex, ey)
  rug(xx, ticksize = 0.2, lwd = 1)
  title("Wykres gęstości prawdopodobieństwa z wektora xx (prawdopodobieństwa wylosowania wartości z osi x)")

# Zadanie 3
# Co prezentuje wykres generowany poniøszym kodem ? OmÛwiÊ znaczenie strza≥ek.
# DodaÊ tytu≥ do wykresu.

# (1)
  par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
# (2)
  set.seed(591)
  xx1 <- rnorm(20, mean = 3, sd = 3.6)
  xx2 <- rpois(40, lambda = 3.5)
  xx3 <- rchisq(31, df = 5)
# (3)
  mean1 <- c(mean(xx1), mean(xx2), mean(xx3))
  sd1 <- c(sd(xx1), sd(xx2), sd(xx3))
  data1 <- list(xx1, xx2, xx3)
# (4)
  xmin1 <- min(xx1, xx2, xx3) - 1
  xmax1 <- max(xx1, xx2, xx3) + 1
# (5)
  stripchart(data1, method = "jitter", jit = 0.3, vert = T,
   pch = 1, cex = 0.4, ylim = c(xmin1, xmax1),
   group.names = c("Group-1", "Group-2", "Group-3"))
# (6)
  arrows(1:3, mean1 + sd1, 1:3, mean1 - sd1, angle = 45,
   code = 3, length = 0.07)
  arrows(1:3, mean1 + 2 * sd1, 1:3, mean1 - 2 * sd1,
   angle = 30, code = 3, length = 0.07)
  arrows(1:3, mean1 + 0.01 * sd1, 1:3, mean1 - 0.01 * sd1,
   angle = 90, code = 3, length = 0.12)

title("Rozklad punktów z trzech rozkładów losowych (przedziały 0.001, 1, 2) oraz ich odchylenia standardowe dla każdej grupy")

# Zadanie 4
# Co prezentuje wykres generowany poniøszym kodem ?
# DodaÊ tytu≥ i oznaczenia do wykresu tak aby by≥ on bardziej czytelny.

# (1)
  par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
# (2)
  set.seed(591)
  xx1 <- rnorm(20, mean = 3, sd = 3.6)
  xx2 <- rpois(40, lambda = 3.5)
  xx3 <- rchisq(31, df = 5, ncp = 0)
# (3)
  box1 <- boxplot(xx1, xx2, xx3, names = c("Group-1", "Group-2",
   "Group-3"), cex = 0.7)
# (4)
  print("box1$stats")
  print(box1$stats)
title("Porownanie rozkładów losowych z trzech grup (Group-1, Group-2, Group-3)")

# Zadanie 5
# Co prezentuje wykres generowany poniøszym kodem ?
# DodaÊ tytu≥ i legendÍ do wykresu tak aby by≥ on bardziej czytelny.


# (1)
  par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
# (2)
  plot(c(-0.1, 2.1), c(0, 2.3), type = "n", xlab = "Wartosc x", # tytul
   ylab = "Wartosc y")
  xx <- c(0, 1,2)
  yy <- c(2, 0.8, 1.4)
  lines(xx, yy, col = "orange") # zmiana
  points(xx, yy, pch = 0)
# (3)
  text(xx, yy + 0.2, labels = as.character(yy))
# (4)
  par(new = T)
# (5)
  plot(c(-0.1, 2.1), c(100, 250), type = "n", xlab = "",
   ylab = "", axes = F)
# (6)
  axis(4)
  mtext("Wartosc y_2", side = 4, line = 2) # tytul
# (7)
  xx <- c(0, 1, 2)
  yy <- c(110, 130, 165)
  lines(xx, yy, col = "blue") # zmiana
  points(xx, yy, pch = 16)
# (8)
  text(xx, yy + 10, labels = as.character(yy))
# NOWE - legenda + title
title("Porownanie dwóch zestawow danych (x, y) oraz (x, y_2)")
legend("topright", legend = c("Pierwszy zestaw -> y", "Drugi zestaw -> y_2"), col = c("orange", "blue"),
       pch = c(0, 16), bty = "n", lwd = 0.8)

# Zadanie 6
# PrzeanalizowaÊ poniøszy program.  OpisaÊ znaczenie poszczegÛlnych sekcji.

# (1)
  par(mai = c(1, 1, 1, 1), omi = c(0, 0, 0, 0))
# (2)
  yy <- c(50,30,40)
# (3)
  name1 <- c("data-a", "data-b", "data-c")
# (4)
  pie(yy, labels = name1, col = c("red","green","skyblue"))
# (5)
  par(new = T)
# (6)
  par(mai=c(2, 2, 2, 2))
# (7)
  yy2 <- c(50, 20, 10, 20, 20)
# (8)
  name2 <- c("data-a1", "data-b1", "data-b2", "data-c1",
   "data-c2")
# (9)
  pie(yy2, labels = name2, col = c("pink", "gold", "blue",
   "gold", "blue"))



