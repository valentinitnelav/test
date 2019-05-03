# /////////////////////////////////////////////////////////////////////////
#
# R script with the model that will be run on a single available core (cpu) 
# by the job scheduler on the cluster.
#
# /////////////////////////////////////////////////////////////////////////


# Optparse section --------------------------------------------------------

library(optparse)

# Defaults

default.verbose <- FALSE

# Parsing arguments

options <- list(
  make_option(opt_str = c("-v", "--verbose"),
              action  = "store_true",
              default = default.verbose,
              help    = "Print more output on what's happening")
)

parser <- OptionParser(usage       = "Rscript %prog [options] data_path output",
                       option_list = options,
                       description = "\nan",
                       epilogue    = "With support from Christian Krause")

cli <- parse_args(parser, positional_arguments = 2)


# Assign shortcuts

verbose <- cli$options$verbose
data_path <- cli$args[1]
output  <- cli$args[2]


# The R-job section -------------------------------------------------------

library(metafor)
library(data.table)

# Load data objects for models
load(file = data_path)
setDT(dt)

# Sample with replacement the data table

# The task id from the scheduler becomes the seed:
task_id <- Sys.getenv("SGE_TASK_ID")
# Print in the log file
print(paste0("Random Number Generation using: set.seed(", task_id, ")"))
set.seed(task_id)
dt_sample <- dt[, .SD[sample(.N, replace = TRUE)], by = .(f1, f2)]

# The model
boot_rmamv <- rma.mv(y ~ f2:f1 - 1,
                     V = var_y,
                     random = list(~ 1|r1,
                                   ~ 1|r2),
                     R = list(r2 = cor_mat),
                     data = dt_sample,
                     method = "REML",
					 # Tune the convergence algorithm / optimizer
                     control = list(optimizer = "nlminb",
									iter.max = 1000,
									step.min = 0.4,
									step.max = 0.5))

coef_boot <- boot_rmamv[["beta"]]
save(coef_boot, file = output)
