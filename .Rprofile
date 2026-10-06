# renv treats a project with a DESCRIPTION file as a package and moves its
# library to the user cache (AppData/Local/R/cache/R/renv/library). Keep it
# in renv/library, where every package of the book is installed.
Sys.setenv(RENV_PATHS_LIBRARY = file.path(getwd(), "renv", "library"))
# The renv sandbox waits on a lock file in the user cache; a lock left by a
# killed R process hangs every later R start in this project. The sandbox
# only hides non-base packages in the system library, so do without it.
options(renv.config.sandbox.enabled = FALSE)
source("renv/activate.R")
