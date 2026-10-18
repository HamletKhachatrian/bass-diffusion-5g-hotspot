# Bass model: Netgear Nighthawk M3 (5G hotspot), look-alike = 4G/LTE

# ---- Setup ----
libs <- c("ggplot2", "ggpubr", "knitr", "diffusion")
invisible(lapply(libs, library, character.only = TRUE))
theme_set(theme_grey(base_size = 9))

# Bass model functions
bass.f <- function(t, p, q) {
  ((p + q)^2 / p) * exp(-(p + q) * t) / (1 + (q / p) * exp(-(p + q) * t))^2
}
bass.F <- function(t, p, q) {
  (1 - exp(-(p + q) * t)) / (1 + (q / p) * exp(-(p + q) * t))
}

# ---- Step 3: Historical data (4G/LTE, new subscriptions per year) ----
g4 <- read.csv("data/4g_lte_global.csv")
d  <- g4[g4$year <= 2022, ]
d$t <- 1:nrow(d)
kable(d[, c("year", "subscriptions", "sales")],
      col.names = c("Year", "Subscriptions (m)", "New subscriptions (m)"),
      row.names = FALSE)

ggplot(data = d, aes(x = year, y = sales)) +
  geom_bar(stat = "identity") +
  ggtitle("4G/LTE new subscriptions per year, mln") +
  scale_x_continuous(breaks = 2012:2022)

# ---- Step 4: Bass parameters, Method 1 (nls) ----
bass_m <- nls(sales ~ m*(((p+q)^2/p)*exp(-(p+q)*t))/(1+(q/p)*exp(-(p+q)*t))^2,
              data = d,
              start = list(m = sum(d$sales), p = 0.02, q = 0.4))
summary(bass_m)

# ---- Step 4: Bass parameters, Method 2 (diffusion package) ----
diff_m <- diffusion(d$sales)
diff_m

# ---- Step 4: Compare the two methods ----
p <- unname(coef(bass_m)["p"]); q <- unname(coef(bass_m)["q"])
m <- unname(coef(bass_m)["m"])
w <- diff_m$w   # named vector: m, p, q
kable(data.frame(Method = c("1. nls()", "2. diffusion()"),
                 p = round(c(p, w[["p"]]), 4), q = round(c(q, w[["q"]]), 4),
                 m = round(c(m, w[["m"]]), 0)),
      col.names = c("Method", "p", "q", "m (millions)"))

# ---- Step 4: Fit check and peak year ----
d$pred_sales <- bass.f(d$t, p, q) * m
ggplot(data = d, aes(x = year, y = sales)) +
  geom_bar(stat = "identity") +
  geom_point(mapping = aes(x = year, y = pred_sales), color = "red") +
  ggtitle("4G/LTE new subscriptions: data (bars) and Bass fit (red), mln") +
  scale_x_continuous(breaks = 2012:2022)

data.frame(Predicted = log(q/p)/(p + q), Actual = which.max(d$sales))

# ---- Step 5: Check on 5G subscriptions (4G p and q, fit only m) ----
g5 <- read.csv("data/5g_subscriptions_global.csv")
g5$sales <- c(g5$subscriptions[1], diff(g5$subscriptions))
a5 <- g5[g5$year >= 2019 & g5$year <= 2025, ]
a5$t <- 1:nrow(a5)
fit5 <- nls(sales ~ M*bass.f(t, p, q), data = a5,
            start = list(M = 5000), algorithm = "port", lower = 0)

chk <- g5[g5$year >= 2019, ]
chk$t <- 1:nrow(chk)
chk$bass <- coef(fit5)[["M"]] * bass.f(chk$t, p, q)
chk$error <- round((chk$bass / chk$sales - 1) * 100, 1)
kable(data.frame(Year = chk$year, Data = round(chk$sales, 1),
                 Bass = round(chk$bass, 1), `Error %` = chk$error,
                 Type = ifelse(chk$forecast, "Ericsson forecast", "actual"),
                 check.names = FALSE),
      col.names = c("Year", "New 5G subs (m)", "Bass (m)", "Error %", "Type"))

ggplot(chk, aes(x = year)) +
  geom_bar(aes(y = sales, fill = forecast), stat = "identity") +
  geom_point(aes(y = bass), color = "red") +
  scale_fill_manual(values = c("grey35", "grey75"),
                    labels = c("actual", "Ericsson forecast"), name = NULL) +
  labs(y = "mln", title = "New 5G subscriptions: data (bars) and Bass with 4G p, q (red)") +
  scale_x_continuous(breaks = 2019:2030)

# ---- Step 6: Scope (share of 4G subscriptions by region, 2022) ----
reg <- read.csv("data/4g_lte_by_region.csv", check.names = FALSE)
x <- unlist(reg[reg$year == 2022, -1])
share <- sort(round(100 * x / sum(x), 1), decreasing = TRUE)
kable(data.frame(Region = names(share), Share = as.numeric(share)),
      col.names = c("Region", "Share of global 4G subscriptions, 2022 (%)"))

# ---- Step 7: Fermi estimate of the market potential m ----
subs2030 <- g5$subscriptions[g5$year == 2030]
shares <- c(Low = 0.0075, Base = 0.015, High = 0.03)
M <- shares * subs2030
kable(data.frame(Case = names(shares), `Share s` = paste0(100 * shares, "%"),
                 `m (million devices)` = round(M, 1), check.names = FALSE), row.names = FALSE)

# ---- Step 7: Adopters by year ----
years <- 2019:2035
t <- 1:length(years)
adopters <- sapply(M, function(x) x * bass.f(t, p, q))
tab <- data.frame(Year = years,
                  Cumulative_base = round(cumsum(adopters[, "Base"]), 1),
                  New_low = round(adopters[, "Low"], 1),
                  New_base = round(adopters[, "Base"], 1),
                  New_high = round(adopters[, "High"], 1))
kable(tab[tab$Year <= 2030, ],
      col.names = c("Year", "Cumulative, base (m)", "New, low (m)",
                    "New, base (m)", "New, high (m)"))

long <- data.frame(year = rep(years, 3), case = rep(names(M), each = length(years)),
                   new = as.vector(adopters),
                   cum = as.vector(apply(adopters, 2, cumsum)))
new_plot <- ggplot(long, aes(year, new, color = case)) + geom_line() +
  labs(title = "New adopters per year (mln)", y = NULL)
cum_plot <- ggplot(long, aes(year, cum, color = case)) + geom_line() +
  labs(title = "Cumulative adopters (mln)", y = NULL)
ggarrange(cum_plot, new_plot, common.legend = TRUE, legend = "bottom")

# ---- Numbers quoted in the report text ----
tstar <- log(q/p)/(p + q)                          # predicted peak (t)
peak_new <- max(adopters[, "Base"])                # peak new adopters, base case
cum2025 <- sum(adopters[years <= 2025, "Base"])    # cumulative adopters by 2025
c(tstar = tstar, peak_new = peak_new, cum2025 = cum2025)
