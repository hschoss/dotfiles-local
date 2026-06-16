## ~/.Rprofile

## ANSI helper
ansi <- function(code) paste0("\033[", code, "m")

elflord <- list(
  reset   = ansi("0"),
  cyan    = ansi("38;5;51"),
  cyan2   = ansi("38;5;87"),
  yellow  = ansi("38;5;226"),
  magenta = ansi("38;5;201"),
  green   = ansi("38;5;83;1"),
  red     = ansi("38;5;196;1"),
  blue    = ansi("38;5;44"),
  white   = ansi("38;5;231"),
  grey    = ansi("38;5;145")
)


reset <- ansi("0")
cyan  <- ansi("38;5;51")
grey  <- ansi("38;5;145")

options(
  prompt = paste0(cyan, "R", grey, "> ", reset),
  continue = paste0(cyan, "+ ", reset),
  crayon.enabled = TRUE,
  cli.num_colors = 256
)

Sys.setenv(R_CLI_NUM_COLORS = "256")
