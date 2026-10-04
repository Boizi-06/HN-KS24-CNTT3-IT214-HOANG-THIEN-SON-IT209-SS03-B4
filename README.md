# Bài 4: Chạy song song nhiều cổng dịch vụ (Nginx Virtual Hosts)

## 📌 Tổng quan
Bài tập cấu hình Nginx chạy song song hai trang web tĩnh độc lập trên cùng một địa chỉ IP thông qua hai cổng:
- **Cổng 8080**: Trỏ về thư mục `/var/www/beta-app/html/` (Beta App)
- **Cổng 8090**: Trỏ về thư mục `/var/www/internal-app/html/` (Internal App)

---

## 📂 Danh sách các file trong thư mục bài nộp
- `multi-port.conf`: File cấu hình Nginx cho 2 Server Block (cổng 8080 & 8090).
- `beta-app/index.html`: Mã nguồn giao diện trang web Beta App.
- `internal-app/index.html`: Mã nguồn giao diện trang web Internal App.
- `setup.sh`: Script tự động cài đặt toàn bộ lên VPS chỉ với một lệnh.https://127.0.0.1:49950/static/artifacts/f239461f-4726-4546-97a2-9b2376d34c2e/.user_uploaded/media_1791153736864.png?csrf=cd3ae34a-4558-4c27-8c20-83f188988a30

---

## 🚀 Hướng dẫn triển khai trên VPS

### Cách 1: Chạy tự động bằng script `setup.sh` (Nhanh nhất)
1. Tải hoặc đẩy thư mục `ex4` lên VPS.
2. Di chuyển vào thư mục `ex4` và chạy:
```bash
chmod +x setup.sh
./setup.sh
```

---

### Cách 2: Thực hiện thủ công từng bước

#### Bước 1: Tạo thư mục lưu trữ mã nguồn
```bash
sudo mkdir -p /var/www/beta-app/html
sudo mkdir -p /var/www/internal-app/html
```

#### Bước 2: Tạo nội dung file `index.html` cho từng trang
- **Beta App** (`/var/www/beta-app/html/index.html`):
```bash
sudo cp beta-app/index.html /var/www/beta-app/html/index.html
```
- **Internal App** (`/var/www/internal-app/html/index.html`):
```bash
sudo cp internal-app/index.html /var/www/internal-app/html/index.html
```

Phân quyền truy cập cho Nginx:
```bash
sudo chown -R www-data:www-data /var/www/beta-app /var/www/internal-app
sudo chmod -R 755 /var/www/beta-app /var/www/internal-app
```

#### Bước 3: Cấu hình Virtual Hosts Nginx
Sao chép file cấu hình `multi-port.conf` vào `/etc/nginx/sites-available/` và kích hoạt:
```bash
sudo cp multi-port.conf /etc/nginx/sites-available/multi-port.conf
sudo ln -sf /etc/nginx/sites-available/multi-port.conf /etc/nginx/sites-enabled/multi-port.conf
```

Kiểm tra cú pháp và khởi động lại Nginx:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

#### Bước 4: Mở cổng trên tường lửa UFW (trên VPS)
```bash
sudo ufw allow 8080/tcp
sudo ufw allow 8090/tcp
sudo ufw reload
sudo ufw status
```

#### Bước 5: Mở cổng trên DigitalOcean Cloud Firewall (trên Web Dashboard)
Nếu Droplet của bạn được quản lý bởi **DigitalOcean Cloud Firewall**:
1. Vào **Networking** -> **Firewalls** -> Chọn Firewall gán với Droplet của bạn.
2. Tại mục **Inbound Rules**, thêm 2 luật mới:
   - **Type**: Custom | **Protocol**: TCP | **Port Range**: `8080` | **Sources**: `All IPv4`, `All IPv6`
   - **Type**: Custom | **Protocol**: TCP | **Port Range**: `8090` | **Sources**: `All IPv4`, `All IPv6`
3. Bấm **Save**.

---

## 🧪 Kiểm tra kết quả

### 1. Kiểm tra bằng `curl`
```bash
# Kiểm tra cổng 8080 (Beta App)
curl http://<IP_ADDRESS_DROPLET>:8080

# Kiểm tra cổng 8090 (Internal App)
curl http://<IP_ADDRESS_DROPLET>:8090
```

### 2. Kiểm tra trên trình duyệt
- `http://<IP_ADDRESS_DROPLET>:8080` hiển thị giao diện màu tím/xanh đậm: **Beta App**.
- `http://<IP_ADDRESS_DROPLET>:8090` hiển thị giao diện màu xanh lá/ngọc lục bảo: **Internal App**.
