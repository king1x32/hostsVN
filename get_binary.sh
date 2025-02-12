#!/bin/bash

get_unzip(){
  curl -sSLO "$1"
  chmod +x "$2"
  if [[ "$2" == *".tar.gz"* ]]; then
    tar -xzvf "$2"
  else
    gzip -d "$2"
  fi
  chmod +x "$3"
}

singbox_url=$(curl https://api.github.com/repos/SagerNet/sing-box/releases 2>/dev/null|awk -F\" '/browser_download_url/ && /linux-amd64/ {print $4; exit}')
echo "singbox_url: $singbox_url"
singbox_namezip=$(echo "$singbox_url" | cut -d/ -f9)
singbox_name=$(echo "$singbox_namezip" | cut -c 1-$((${#singbox_namezip} - 7)))
singbox_path="./$singbox_name/sing-box"
get_unzip "$singbox_url" "$singbox_namezip" "$singbox_path"
$singbox_path rule-set compile --output option/king1x32-hostsVN-singbox-rule.srs option/king1x32-hostsVN-singbox-rule.json
$singbox_path rule-set compile --output option/king1x32-Advertising_Domain-singbox.srs option/king1x32-Advertising_Domain-singbox.json

clash_url=$(curl https://api.github.com/repos/MetaCubeX/mihomo/releases 2>/dev/null|awk -F\" '/browser_download_url/ && /linux-amd64-compatible-go/ && /.gz/ {print $4; exit}')
echo "clash_url: $clash_url"
clash_namezip=$(echo "$clash_url" | cut -d/ -f9)
clash_name=$(echo "$clash_namezip" | cut -c 1-$((${#clash_namezip} - 3)))
clash_path="./$clash_name"
get_unzip "$clash_url" "$clash_namezip" "$clash_path"
$clash_path convert-ruleset domain yaml option/king1x32-hostsVN-clash-rule.yaml option/king1x32-hostsVN-clash-rule.mrs
$clash_path convert-ruleset domain yaml option/king1x32-Advertising_Domain-clash.yaml option/king1x32-Advertising_Domain-clash.mrs
