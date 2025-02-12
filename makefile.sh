#!/bin/sh

echo "Preparing files..."
# convert hosts to filters
cat hostsVN/source/hosts.txt | grep "0.0.0.0" | awk '{print $2}' >hostsVN/source/adserver-all.tmp
if [ "$(uname)" == "Darwin" ]; then
	sed -i "" "s/www\.//g" hostsVN/source/adserver-all.tmp
else
	sed -i "s/www\.//g" hostsVN/source/adserver-all.tmp
fi
sort -u -o hostsVN/source/adserver-all.tmp hostsVN/source/adserver-all.tmp

cat hostsVN/source/hosts-VN.txt | grep "0.0.0.0" | awk '{print $2}' >hostsVN/source/adserver.tmp
if [ "$(uname)" == "Darwin" ]; then
	sed -i "" "s/www\.//g" hostsVN/source/adserver.tmp
else
	sed -i "s/www\.//g" hostsVN/source/adserver.tmp
fi
sort -u -o hostsVN/source/adserver.tmp hostsVN/source/adserver.tmp

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"
DOMAIN=$(printf "%'.3d\n" $(cat hostsVN/source/hosts-group.txt hostsVN/source/hosts-VN-group.txt hostsVN/source/hosts-VN.txt hostsVN/source/hosts.txt hostsVN/source/hosts-extra.txt | grep "0.0.0.0" | wc -l))
DOMAIN_VN=$(printf "%'.3d\n" $(cat hostsVN/source/hosts-VN-group.txt hostsVN/source/hosts-VN.txt | grep "0.0.0.0" | wc -l))
RULE=$(printf "%'.3d\n" $(cat hostsVN/source/adservers.txt hostsVN/source/adservers-all.txt hostsVN/source/adserver.tmp hostsVN/source/adserver-all.tmp hostsVN/source/adservers-extra.txt hostsVN/source/exceptions.txt | grep -v '!' | wc -l))
RULE_VN=$(printf "%'.3d\n" $(cat hostsVN/source/adservers.txt hostsVN/source/adserver.tmp | grep -v '!' | wc -l))
HOSTNAME=$(cat hostsVN/source/config-hostname.txt)

echo "Creating adserver file..."
# create temp adserver files
mkdir tmp
cat hostsVN/source/adservers.txt hostsVN/source/adserver.tmp | grep -v '!' | awk '{print $1}' >>tmp/adservers.tmp
cat hostsVN/source/adservers-all.txt hostsVN/source/adserver-all.tmp | grep -v '!' | awk '{print $1}' >>tmp/adservers-all.tmp
cat hostsVN/source/adservers-extra.txt | grep -v '!' | awk '{print $1}' >>tmp/adservers-extra.tmp
cat hostsVN/source/exceptions.txt | grep -v '!' | awk '{print $1}' >>tmp/exceptions.tmp

curl -o option/king1x32-Advertising_Domain-clash.yaml -sSL https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/release/rule/Clash/Advertising/Advertising_Domain.yaml

echo 'payload:' >option/king1x32-hostsVN-clash-rule.yaml
cat tmp/exceptions.tmp | awk '{print "  - DOMAIN,"$1}' | sed -e 's///gm' >>option/king1x32-hostsVN-clash-rule.yaml
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "  - DOMAIN-SUFFIX,"$1}' | sed -e 's///gm' >>option/king1x32-hostsVN-clash-rule.yaml
cat hostsVN/source/config-rule.txt | awk '{print "  - DOMAIN-KEYWORD,"$1}' | sed -e 's///gm' >>option/king1x32-hostsVN-clash-rule.yaml
cat option/king1x32-hostsVN-clash-rule.yaml >option/king1x32-hostsVN-clash-rule-rewrite.yaml
cat hostsVN/source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "  - DOMAIN-REGEX,"$1}' | sed -e 's///gm' >>option/king1x32-hostsVN-clash-rule-rewrite.yaml
echo '{
  "version": 2,
  "rules": [
    {
      "domain": [' >option/king1x32-hostsVN-singbox-rule.json
cat tmp/exceptions.tmp | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed '$ s/,$//' >>option/king1x32-hostsVN-singbox-rule.json
echo '      ],
      "domain_suffix": [' >>option/king1x32-hostsVN-singbox-rule.json
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed '$ s/,$//' >>option/king1x32-hostsVN-singbox-rule.json
echo '      ],
      "domain_keyword": [' >>option/king1x32-hostsVN-singbox-rule.json
cat hostsVN/source/config-rule.txt | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed '$ s/,$//' >>option/king1x32-hostsVN-singbox-rule.json
echo '      ],
      "domain_regex": [' >>option/king1x32-hostsVN-singbox-rule.json
cat hostsVN/source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed -e '$ s/,$//' | sed -e 's/\\/\\\\/gm' | sed -e 's/\//\\\//gm' >>option/king1x32-hostsVN-singbox-rule.json
echo '      ]
    }
  ]
}' >>option/king1x32-hostsVN-singbox-rule.json

curl -o option/king1x32-Advertising_Domain.txt -sSL https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/release/rule/Clash/Advertising/Advertising_Domain.txt

echo '{
  "version": 2,
  "rules": [
    {
      "domain": [' >option/king1x32-Advertising_Domain-singbox.json
cat option/king1x32-Advertising_Domain.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed -e '$ s/,$//' | sed -e 's/\\/\\\\/gm' | sed -e 's/\//\\\//gm' >>option/king1x32-Advertising_Domain-singbox.json
echo '      ]
    }
  ]
}' >>option/king1x32-Advertising_Domain-singbox.json

# remove tmp file
rm -rf tmp/*.tmp
rm -rf hostsVN/source/*.tmp

# read -p "Completed! Press enter to close"
echo "Completed!"
