wt() {
  # === No args → list features ===
  if [ -z "$1" ]; then
    git worktree list --porcelain |
    awk '
      /^worktree / {
        name=$2
        sub(/^.*\//,"",name)

        if (index(name, "-") > 0) {
          print substr(name, index(name, "-") + 1)
        } else {
          print name   # fallback (e.g. main worktree)
        }
      }
    '
    return
  fi

  # === With arg → jump ===
  local feature="$1"

  local matches=$(
    git worktree list --porcelain |
    awk '
      /^worktree / {
        name=$2
        sub(/^.*\//,"",name)
        feature=substr(name, index(name, "-") + 1)
        print feature ":" $2
      }
    ' | grep "^${feature}:"
  )

  local count=$(echo "$matches" | grep -c .)

  if [ "$count" -eq 0 ]; then
    echo "No worktree for feature: $feature"
    return 1
  elif [ "$count" -gt 1 ]; then
    echo "Ambiguous feature: $feature"
    echo "$matches"
    return 1
  fi

  local path=$(echo "$matches" | cut -d: -f2)
  cd "$path"
}

