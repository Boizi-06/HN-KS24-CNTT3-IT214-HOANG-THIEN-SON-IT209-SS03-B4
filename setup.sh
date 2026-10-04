#!/usr/bin/env bash
# ==============================================================================
# Script tự động triển khai Bài 4: Nginx Virtual Hosts đa cổng (8080 & 8090)
# ==============================================================================
set -e

echo "=== [1/6] Kiểm tra và cài đặt Nginx ==="
if ! command -v nginx > /dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y nginx
else
    echo "Nginx đã được cài đặt sẵn."
fi

echo "=== [2/6] Tạo thư mục lưu trữ mã nguồn ==="
sudo mkdir -p /var/www/beta-app/html
sudo mkdir -p /var/www/internal-app/html

echo "=== [3/6] Sao chép file giao diện index.html ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo cp "$SCRIPT_DIR/beta-app/index.html" /var/www/beta-app/html/index.html
sudo cp "$SCRIPT_DIR/internal-app/index.html" /var/www/internal-app/html/index.html

# Phân quyền thư mục cho user www-data của Nginx
sudo chown -R www-data:www-data /var/www/beta-app /var/www/internal-app
sudo chmod -R 755 /var/www/beta-app /var/www/internal-app

echo "=== [4/6] Cấu hình Server Blocks Nginx ==="
sudo cp "$SCRIPT_DIR/multi-port.conf" /etc/nginx/sites-available/multi-port.conf
sudo ln -sf /etc/nginx/sites-available/multi-port.conf /etc/nginx/sites-enabled/multi-port.conf

echo "=== [5/6] Kiểm tra cú pháp và khởi động lại Nginx ==="
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "=== [6/6] Cấu hình tường lửa UFW ==="
sudo ufw allow 8080/tcp
sudo ufw allow 8090/tcp
sudo ufw reload

echo "======================================================"
echo "🎉 TRIỂN KHAI HOÀN TẤT THÀNH CÔNG!"
echo "Kiểm tra bằng lệnh:"
echo "  curl http://localhost:8080"
echo "  curl http://localhost:8090"
echo "======================================================"
