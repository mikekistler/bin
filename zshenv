# Since .zshenv is always sourced, it often contains exported variables
# that should be available to other programs. For example, $PATH, $EDITOR,
# and $PAGER are often set in .zshenv.

# set $PATH

export PATH=$HOME/bin:$PATH

git_url() {
    BRANCH=$(git branch --show-current 2>/dev/null || echo main)
    REMOTE=$(git config branch.${BRANCH}.remote || echo origin)
    git config remote.${REMOTE}.url | sed -e 's|git@\([^:]*\):\(.*\).git|https://\1/\2|'
}
