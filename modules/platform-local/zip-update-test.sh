folder=$(openssl rand -base64 12)

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

    "$REALDIR/swdc" up --app-env prod &>/dev/null
    exit 0
  )

  clear

  echo "Shopware 6 Installation is installed and accessible at: ${installName}.${DEFAULT_DOMAIN}"