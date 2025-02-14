#!/bin/bash

get_url() {
  url=$(curl -sS "$1" 2>/dev/null | awk -F\" '/browser_download_url/ && /linux-amd64/ && /.gz/ {print $4; exit}')

  if [[ -z "$url" ]]; then
    echo "❌ Không tìm thấy URL tải về từ $1"
    return 1
  fi

  echo "🔗 Tải về từ: $url"

  namezip=$(basename "$url")

  if [[ "$namezip" == *".tar.gz" ]]; then
      cut_length=7
  elif [[ "$namezip" == *".gz" ]]; then
      cut_length=3
  else
      echo "❌ Không hỗ trợ định dạng file: $namezip"
      return 1
  fi

  name="${namezip:0:$((${#namezip} - cut_length))}"

  # Xác định đường dẫn chính xác trước khi tải
  if [[ "$namezip" == *".tar.gz" ]]; then
    path="./$name/sing-box"
  else
    path="./$name"
  fi

  # Tải file
  curl -sSLO "$url" || { echo "❌ Tải thất bại: $url"; return 1; }

  # Giải nén file
  if [[ "$namezip" == *".tar.gz" ]]; then
    tar -xzvf "$namezip" || { echo "❌ Giải nén thất bại: $namezip"; return 1; }
  elif [[ "$namezip" == *".gz" ]]; then
    gzip -d "$namezip" || { echo "❌ Giải nén thất bại: $namezip"; return 1; }
  fi

  # Kiểm tra và cấp quyền thực thi
  if [[ -e "$path" ]]; then
    chmod +x "$path"
    echo "✅ Đã cấp quyền thực thi cho: $path"
  else
    echo "❌ Không tìm thấy file thực thi: $path"
    return 1
  fi
}

# Chạy cho Sing-box
get_url "https://api.github.com/repos/SagerNet/sing-box/releases" && {
  $path rule-set compile --output option/king1x32-hostsVN-singbox-rule.srs option/king1x32-hostsVN-singbox-rule.json
  $path rule-set compile --output option/king1x32-Advertising_Domain-singbox.srs option/king1x32-Advertising_Domain-singbox.json
}

# Chạy cho Mihomo
get_url "https://api.github.com/repos/MetaCubeX/mihomo/releases" && {
  $path convert-ruleset domain yaml option/king1x32-hostsVN-clash-rule.yaml option/king1x32-hostsVN-clash-rule.mrs
  $path convert-ruleset domain yaml option/king1x32-Advertising_Domain-clash.yaml option/king1x32-Advertising_Domain-clash.mrs
}
