singbox_url=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases" | grep -o -m 1 '"browser_download_url":\s"http[^"]*-linux-amd64v3\.tar\.gz' | sed -r 's/"browser_download_url":\s"//')
singbox_url=$(echo -e "${singbox_url}" | tr -d '[:space:]')
echo "singbox_url: $singbox_url"
singbox_namezip=$(echo "$singbox_url" | cut -d/ -f9)
singbox_name=$(echo "$singbox_namezip" | cut -c 1-$((${#singbox_namezip} - 7)))
singbox_path="./$singbox_name/sing-box"
curl -sSLO $singbox_url
chmod +x $singbox_namezip
tar -xzvf $singbox_namezip
chmod +x $singbox_path
$singbox_path rule-set compile --output option/king1x32-hostsVN-singbox-rule.srs option/king1x32-hostsVN-singbox-rule.json

$singbox_path rule-set compile --output option/king1x32-Advertising_Domain.srs option/king1x32-Advertising_Domain.json

clash_url=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases" | grep -o -m 1 '"browser_download_url":\s"http[^"]*mihomo-linux-amd64-compatible-go.*-alpha-.*\.gz' | sed -r 's/"browser_download_url":\s"//')
clash_url=$(echo -e "${clash_url}" | tr -d '[:space:]')
echo "clash_url: $clash_url"
clash_namezip=$(echo "$clash_url" | cut -d/ -f9)
clash_name=$(echo "$clash_namezip" | cut -c 1-$((${#clash_namezip} - 3)))
clash_path="./$clash_name"
curl -sSLO $clash_url
chmod +x $clash_namezip
gzip -d $clash_namezip
chmod +x $clash_path
$clash_path convert-ruleset domain yaml option/king1x32-hostsVN-clash-rule.yaml option/king1x32-hostsVN-clash-rule.mrs

$clash_path convert-ruleset domain yaml option/king1x32-Advertising_Domain.yaml option/king1x32-Advertising_Domain.mrs
