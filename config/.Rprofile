# Inspired by: https://www.r-bloggers.com/2014/09/fun-with-rprofile-and-customizing-r-startup/

# Custom path for R packages
.libPaths("/home/elkip/Packages/R/4.3")

options(max.print = 500)
options(scipen = 10)
options(editor = "vim")

# Function to mute package output
sshhh <- function(a.package) {
  suppressWarnings(suppressPackageStartupMessages(
      library(a.package, character.only=TRUE)))
}

auto.load <- c("base", "stats", "dplyr")
if(interactive()) {
  invisible(sapply(auto.load, sshhh))
}

message("*** R is ready***")
