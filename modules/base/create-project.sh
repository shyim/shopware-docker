#!/usr/bin/env bash

installName=$2

if [[ -z $installName ]]; then
  echo "Please enter a project name"
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

dist=$(dialog --clear --backtitle "Shopware Installation" --title "Choose Distribution" --menu "Choose one of the following options:" 15 80 4 \
  development "Development Template (recommended for extension development)" \
  production "Production Template (recommended for projects)" 2>&1 >/dev/tty)

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
  tags=$(curl https://api.github.com/repos/shopware/platform/tags -s | jq .[].name -r)

  version=$(dialog --clear --backtitle "Shopware Installation" --title "Choose Version" --menu "Choose one of the following options:" 15 40 4 "$tags" 2>&1 >/dev/tty)

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
