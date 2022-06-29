#!/usr/bin/env awk -f

# Start executing block when 1st pattern is matched. Stop when the 2nd block is
# matched.
/DEPENDENCIES/,/^$/ {
  cnt++
}

END {
  print cnt - 1
}
