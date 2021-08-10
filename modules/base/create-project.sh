#!/usr/bin/env bash

installName=$2

if [[ -z $installName ]]; then
  echo "Please enter a project name. (swdc create-project <name>)"
  exit 1
fi

if [[ -e "$CODE_DIRECTORY/$installName" ]]; then
  echo 'Project already exists'
  exit 1
fi

if ! command -v dialog &>/dev/null; then
  echo "Dialog is needed to use this command (apt install dialog)"
  exit
fi

if ! command -v jq &>/dev/null; then
  echo "jq is needed to use this command (apt install jq)"
  exit
fi

if ! command -v wget &>/dev/null; then
  echo "wget is needed to use this command (apt install wget)"
  exit
fi

dist=$(dialog --clear --backtitle "Shopware Installation" --title "Choose Distribution" --menu "Choose one of the following options:" 15 80 4 \
  development "Shopware 6 - Development Template (recommended for extension development)" \
  production "Shopware 6 - Production Template (recommended for projects)" \
  platform "Shopware 6 - Platform Repository (recommended for contribution)" \
  sw6Zip "Shopware 6 - Zip Distribution" \
  sw5Zip "Shopware 5 - Zip Distribution" 2>&1 >/dev/tty)

clear

if [[ $dist == 'development' ]]; then
  dialog --clear --backtitle "Shopware Installation" --title "Installing" --gauge "Installation..." 10 75 < <(

    cat <<EOF
XXX
0
Cloning development template
XXX
EOF

    git clone -q https://github.com/shopware/development.git --depth=1 "$CODE_DIRECTORY/$installName" >/dev/null

    cat <<EOF
XXX
20
Cloning Shopware 6 Repository
XXX
EOF

    rm -rf "$CODE_DIRECTORY/$installName/platform"
    git clone -q https://github.com/shopware/platform.git "$CODE_DIRECTORY/$installName/platform" >/dev/null

    cat <<EOF
XXX
40
Installing Shopware 6
XXX
EOF

    "$REALDIR/swdc" build "$installName" >/dev/null

    cat <<EOF
XXX
90
Configuring Nginx
XXX
EOF

    "$REALDIR/swdc" up >/dev/null

    exit 0
  )

  clear

  echo "Shopware 6 Installation is installed and accessible at: ${installName}.${DEFAULT_DOMAIN}"
fi

if [[ $dist == 'production' ]]; then
  GITHUB_RESPONSE=$(curl https://api.github.com/repos/shopware/platform/tags -s)

  NAMES=$(echo "$GITHUB_RESPONSE" | jq .[].name -r)
  VALUES=""

  for i in $NAMES; do
    VALUES="$VALUES $i $i"
  done

  # shellcheck disable=SC2086
  version=$(dialog --clear --backtitle "Shopware Installation" --title "Choose Version" --menu "Choose one of the following options:" 15 40 4 $VALUES 2>&1 >/dev/tty)

  dialog --clear --backtitle "Shopware Installation" --title "Installing" --gauge "Installation..." 10 75 < <(

    cat <<EOF
XXX
0
Cloning production template
XXX
EOF

    git clone -q https://github.com/shopware/production.git -b"$version" --depth=1 "$CODE_DIRECTORY/$installName" &>/dev/null

    cat <<EOF
XXX
20
Installing Shopware 6
XXX
EOF

    "$REALDIR/swdc" build "$installName" &>/dev/null

    cat <<EOF
XXX
90
Configuring Nginx
XXX
EOF

    "$REALDIR/swdc" up &>/dev/null
    exit 0
  )

  clear

  echo "Shopware 6 Installation is installed and accessible at: ${installName}.${DEFAULT_DOMAIN}"
fi

if [[ $dist == 'platform' ]]; then
  dialog --clear --backtitle "Shopware Installation" --title "Installing" --gauge "Installation..." 10 75 < <(

    cat <<EOF
XXX
0
Cloning platform repository
XXX
EOF

    git clone -q https://github.com/shopware/platform.git "$CODE_DIRECTORY/$installName" &>/dev/null

    cat <<EOF
XXX
20
Installing Shopware 6
XXX
EOF

    "$REALDIR/swdc" build "$installName" &>/dev/null

    cat <<EOF
XXX
90
Configuring Nginx
XXX
EOF

    "$REALDIR/swdc" up &>/dev/null
    exit 0
  )

  clear

  echo "Shopware 6 Installation is installed and accessible at: ${installName}.${DEFAULT_DOMAIN}"
fi

if [[ $dist == 'sw6Zip' ]]; then
  tags=$(curl https://update-api.shopware.com/v1/releases/install?major=6 -s | jq .[].version -r)

  VALUES=""

  for i in $tags; do
    VALUES="$VALUES $i $i"
  done

  # shellcheck disable=SC2086
  version=$(dialog --clear --backtitle "Shopware Installation" --title "Choose Version" --menu "Choose one of the following options:" 15 40 4 $VALUES 2>&1 >/dev/tty)

  installUrl=$(curl https://update-api.shopware.com/v1/releases/install?major=6 -s | jq -r ".[] | select(.version == \"$version\") | .uri")

  dialog --clear --backtitle "Shopware Installation" --title "Installing" --gauge "Installation..." 10 75 < <(

    cat <<EOF
XXX
0
Downloading and unpacking Zip
XXX
EOF

    mkdir "$CODE_DIRECTORY/$installName"
    wget "$installUrl" -q -O "$CODE_DIRECTORY/$installName/install.zip"
    cd "$CODE_DIRECTORY/$installName" || exit 0

    unzip -qq -o install.zip
    rm install.zip

    cat <<EOF
XXX
20
Installing Shopware 6
XXX
EOF

    "$REALDIR/swdc" build "$installName" &>/dev/null

    cat <<EOF
XXX
90
Configuring Nginx
XXX
EOF

    "$REALDIR/swdc" up &>/dev/null
    exit 0
  )

  clear

  echo "Shopware 6 Installation is installed and accessible at: ${installName}.${DEFAULT_DOMAIN}"
fi

if [[ $dist == 'sw5Zip' ]]; then
  tags=$(curl https://update-api.shopware.com/v1/releases/install -s | jq .[].version -r)

  VALUES=""

  for i in $tags; do
    VALUES="$VALUES $i $i"
  done

  # shellcheck disable=SC2086
  version=$(dialog --clear --backtitle "Shopware Installation" --title "Choose Version" --menu "Choose one of the following options:" 15 40 4 $VALUES 2>&1 >/dev/tty)

  installUrl=$(curl https://update-api.shopware.com/v1/releases/install -s | jq -r ".[] | select(.version == \"$version\") | .uri")

  dialog --clear --backtitle "Shopware Installation" --title "Installing" --gauge "Installation..." 10 75 < <(

    cat <<EOF
XXX
0
Downloading and unpacking Zip
XXX
EOF

    mkdir "$CODE_DIRECTORY/$installName"
    wget "$installUrl" -q -O "$CODE_DIRECTORY/$installName/install.zip"
    cd "$CODE_DIRECTORY/$installName" || exit 0

    unzip -qq -o install.zip
    rm install.zip

    cat <<EOF
XXX
20
Installing Shopware 5
XXX
EOF

    "$REALDIR/swdc" build "$installName" &>/dev/null

    cat <<EOF
XXX
90
Configuring Nginx
XXX
EOF

    "$REALDIR/swdc" up &>/dev/null
    exit 0
  )

  clear

  echo "Shopware 5 Installation is installed and accessible at: ${installName}.${DEFAULT_DOMAIN}"
fi

