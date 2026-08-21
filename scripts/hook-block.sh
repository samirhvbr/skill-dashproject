# >>> DASHPROJECT >>>
# Records a pending review. Does not call a model.
_dp_root=$(git rev-parse --show-toplevel)
_dp_subj=$(git log -1 --pretty=%s)
case "$_dp_subj" in
  chore\(dashproject\)*) ;;
  *)
    mkdir -p "$_dp_root/.dashproject"
    date +%s > "$_dp_root/.dashproject/last-commit-ts"
    echo "pending $(git rev-parse --short HEAD) $_dp_subj" > "$_dp_root/.dashproject/pending"
    rm -f "$_dp_root/.dashproject/review-due"
    ;;
esac
unset _dp_root _dp_subj
# <<< DASHPROJECT <<<
