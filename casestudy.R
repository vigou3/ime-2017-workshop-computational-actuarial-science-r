library(actuar)
library(MASS)

lambda.A <- 0.008
lambda.F <- 0.0003
lambda.W <- 0.005

inventory <- read.csv("Inventory.csv",
                      colClasses = c(ID = "factor",
                                     Value = "numeric",
                                     DateEntry = "Date",
                                     DateExit = "Date"))
summary(inventory)

## Garder seulement les bouteilles faisant toujours partie de
## l'inventaire (c.-à-d. ayant DateHeureSortie == NA).
data <- subset(inventory, is.na(DateExit))

## Garder seulement le numéro du client et la valeur marchande
## de la bouteille.
data <- subset(data, select = c(ID, Value))

## Il y a environ 4 % de valeurs marchandes manquantes. On
## les élimine.
sum(is.na(data$Value))/nrow(data)
data <- droplevels(data[complete.cases(data), ])
data <- droplevels(data[!is.na(data$Value), ]) # same (here)

summary(data)

n <- table(data$ID)  # nombre de bouteilles par cave
plot(n)              # nombre de bouteilles par cave


## On ne conserve que les bouteilles d'une valeur marchande de
## 1000$ et moins. On ne peut supprimer
## entièrement les clients qui ont au moins une bouteille de
## plus de 1000$ car cela en toucherait un trop grand nombre.
data <- subset(data, Value <= 1000)

## Valeurs marchandes individuelles.
mv <- data$Value           # ~175 000 données
names(mv) <- data$ID

## Nombre de bouteilles par client.
nb <- by(mv, data$ID, length)  # ~250 données

## Valeurs totales des caves.
mv.tot <- by(mv, data$ID, sum) # ~250 données


plot(ecdf(mv.tot))

## Keep only cases with a total value between 5000 and 25,000.
names(mv.tot[mv.tot > 5000 & mv.tot < 25000])

mv <- mv[names(mv) %in% names(mv.tot[mv.tot > 5000 & mv.tot < 25000])]
nb <- by(mv, data$ID, length)  # ~250 données
mv.tot <- by(mv, names(mv), sum) # ~250 données

hist(nb, prob = TRUE)
plot(ecdf(mv.tot))

## Set parameter for peril: accident
par.A <- 7

## Estimation for peril: fire
start <- fitdistr(nb, "negative binomial")$estimate
r <- start[1]
p <- 1/(1 + start[2]/start[1])
(par.F <- fitdistr(nb, dztnbinom,
                   start = list(size = r, prob = p))$estimate)

hist(nb, prob = TRUE)
x <- seq(min(nb), max(nb), by = 10)
points(x, dztnbinom(x, par.F[1], par.F[2]),
       col = "orange", pch = 19)


## Estimation for peril: water damage
nb.W <- round(nb/4)
start <- fitdistr(nb.W, "negative binomial")$estimate
r <- start[1]
p <- 1/(1 + start[2]/start[1])
(par.W <- fitdistr(nb.W, dztnbinom,
                   start = list(size = r, prob = p))$estimate)

hist(nb.W, prob = TRUE)
hist(nb.W, breaks = c(0, 10, 20, 30, 40, 50, 60, 80, 100, 120))
x <- seq(min(nb.W), max(nb.W), by = 10)
points(x, dztnbinom(x, par.W[1], par.W[2]),
       col = "orange", pch = 19)

### Modeling of market values
summary(mv)
hist(mv)
hist(mv[mv < 500])
hist(mv[mv < 500],
     breaks = c(0, 20, 50, 70, 100, 150, 200, 280, 400, 500))

(par.mv <- fitdistr(mv[mv <= 500], "lognormal")$estimate)


###
### Simulation
###



model.A <- substitute(
                      list(mu = par.mv[1],
                           s = par.mv[2]))
model.F <- substitute(rcompound(rztnbinom(r, p), rlnorm(mu, s)),
                      list(r = par.F[1],
                           p = par.F[2],
                           mu = par.mv[1],
                           s = par.mv[2]))
model.W <- substitute(rcompound(rztnbinom(r, p), rlnorm(mu, s)),
                      list(r = par.W[1],
                           p = par.W[2],
                           mu = par.mv[1],
                           s = par.mv[2]))

## Number of simulations
nb.sim <- 1000

expr <- substitute(
    rmixture(n, c(lambda.A, lambda.F, lambda.W),
             expression(A = rcompound(rztpois(7), rlnorm(mu, s)),
                        F = rcompound(rztnbinom(r.F, p.F), rlnorm(mu, s)),
                        W = rcompound(rztnbinom(r.W, p.W), rlnorm(mu, s)))),
    list(n = nb.sim,
         r.F = par.F[1],
         p.F = par.F[2],
         r.W = par.W[1],
         p.W = par.W[2],
         mu = par.mv[1],
         s = par.mv[2]))

## Number of clients
nb.clients <- 100

Sk <- replicate(nb.clients, eval(expr))

Wk <- rowSums(Sk)/nb.clients

## Pure premium
mean(Wk)

## Premium with safety loading
level <- 0.9
(VaR.Wk <- quantile(Wk, level))         # VaR(W)
w <- which(Wk > VaR.Wk)                 # values Wk > var
(TVaR.Wk <- mean(Wk[w]))                # TVaR(Wk)
