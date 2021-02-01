if [[ -z $EDITOR ]]; then
  echo 'Please set $EDITOR to use swdc configure'
  exit 0
fi

$EDITOR "${HOME}/.config/swdc/env"
