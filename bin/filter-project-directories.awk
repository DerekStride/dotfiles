#!/usr/bin/env awk -f

/[a-zA-Z]/ {
  if (!match($1, /\.\//)) {
    if (root) {
      print root  "/"  $1
    }
  }
}

/\.\// {
  sub(/^\.\//, "")
  sub(/:$/, "")
  root = $1
}

