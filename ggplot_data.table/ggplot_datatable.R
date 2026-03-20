library(ggplot2); library(data.table)

# --- PRECIPITATION ANALYSIS ---

dta <- readRDS(file = "~/Desktop/DMaVR-assignments/assignment_01/data/prec_data.rds")
dta <- as.data.table(x = dta)[1:100000]

## clear the data - leave only station id, date, and totals in the dataset,
## aggregate the prec to various time steps (day, week, and month)
## plot (in base R) at least 5 stations in all time steps in one plot
## (each variable has its own panel)

dta[, let(VALUE_DAY = frollsum(x = VALUE,
                               n = 24),
          VALUE_WEK = frollsum(x = VALUE,
                               n = 24 * 7),
          VALUE_MNT = frollsum(x = VALUE,
                               n = 24 * 30)),
    by = .(STATION)]

dta_m <- melt(data = dta[, .(STATION, DT, VALUE, VALUE_DAY, VALUE_WEK, VALUE_MNT)],
              id.vars = c("STATION", "DT"))

ggplot(data = dta_m[STATION %in% unique(x = STATION)[1:5]],
       mapping = aes(x = DT,
                     y = value,
                     colour = variable)) +
  geom_line() +
  facet_grid(variable ~ STATION) +
  theme(legend.position = "bottom")

# --- GGPLOT DEMO ---

demo_dta <- data.frame(x = rnorm(n = 1000),
                       y = rnorm(n = 1000))
demo_dta

ggplot(data = demo_dta) ## data

ggplot(data = demo_dta,
       mapping = aes(x = x,   ## aesthetics (mapping)
                     y = y))

ggplot(data = demo_dta) +
  geom_point(mapping = aes(x = x,
                           y = y,
                           size = y),
             shape = "*",
             size = 5,
             colour = "grey50")

ggplot(data = demo_dta[1:10, ]) +
  geom_point(mapping = aes(x = x,
                           y = y,
                           colour = factor(x = round(y, 1))),
             shape = "*",
             size = 5) +
  scale_color_manual(values = c("steelblue4", "red4", "pink", "darkorange4",
                                "cadetblue1", "brown2", "chocolate2", "darkred",
                                "yellow4", "deepskyblue3"))

ggplot(data = demo_dta) +
  geom_point(mapping = aes(x = x,
                           y = y,
                           colour = y),
             shape = "*",
             size = 5) +
  scale_color_gradient2(low = "royalblue4",
                        mid = "white",
                        high = "red4",
                        midpoint = 0)

ggplot(data = demo_dta) +
  geom_point(mapping = aes(x = x,
                           y = y,
                           colour = y),
             shape = "*",
             size = 5) +
  scale_color_gradient2(low = "royalblue4",
                        mid = "white",
                        high = "red4",
                        midpoint = 0) +
  scale_y_log10()

## create distribution function for each of the 5 stations for each variable
ggplot(data = dta_m[STATION %in% unique(STATION)[1:5]],
       mapping = aes(x = value, colour = STATION)) +
  geom_histogram() +
  facet_wrap(variable ~ STATION) +
  theme(legend.position = "bottom")

## create boxplot function for each of the 5 stations for each variable
ggplot(data = dta_m[STATION %in% unique(STATION)[1:5]],
       mapping = aes(x = as.factor(month(x = DT)), 
                     y = value, 
                     group = month(x = DT), 
                     fill = variable)) +
  geom_boxplot() +
  facet_grid(variable ~ STATION) +
  theme(legend.position = "bottom")
