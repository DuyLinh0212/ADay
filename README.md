# ADay

ADay là ứng dụng lập kế hoạch cá nhân cho người dùng Việt Nam: tập trung vào
việc cần làm hôm nay, mục tiêu dài hạn, lịch theo mốc thời gian và tiến độ nhẹ
nhàng không tạo áp lực.

## Tính năng chính

- Tạo, cập nhật và hoàn thành nhiệm vụ trong ngày.
- Phân biệt mục tiêu trong ngày với mục tiêu dài hạn; mục tiêu dài hạn không tự
  lặp lại theo ngày.
- Lịch tháng và chế độ xem theo mốc thời gian.
- Chọn một trong các template giao diện, màu trạng thái và logo tương ứng.
- Avatar người dùng, câu nhắc hằng ngày và tiện ích Android ngoài màn hình app.
- Sao lưu dữ liệu riêng của ứng dụng lên Google Drive khi tài khoản đã được
  xác minh.

## Công nghệ

- Flutter/Dart.
- SQLite và SharedPreferences cho dữ liệu cục bộ.
- Google Sign-In/Drive App Data cho sao lưu tùy chọn.
- Android App Widget cho tiện ích ngoài giao diện ứng dụng.

## Chạy dự án

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Build Android release:

```bash
flutter build apk --release
```

## Tài nguyên giao diện

- `Template_theme/`: ảnh preview cho 5 template giao diện.
- `Template_TienIch/`: ảnh preview cho tiện ích theo template.
- `Logo_template/`: logo tương ứng từng template.
- `assets/`: tài nguyên dùng trực tiếp trong ứng dụng.

Các thư mục template là mã nguồn của sản phẩm và được theo dõi bởi Git; không
xóa chúng khỏi commit hoặc thêm lại quy tắc ignore cho các file ảnh bên trong.

## Tài liệu

- [Thiết kế giao diện](docs/DESIGN.md)
- [Định hướng sản phẩm](docs/PRODUCT.md)
- [Cấu hình Google Drive](docs/GOOGLE_DRIVE_SETUP.md)
- [Ký APK Android cho cập nhật](docs/ANDROID_SIGNING_SETUP.md)
- [Tài nguyên thương hiệu](docs/BRAND_ASSETS.md)
- [Tùy biến màn hình khởi động iOS](docs/IOS_LAUNCH_SCREEN.md)

## Bảo mật

Không commit keystore, `key.properties`, OAuth secret, access token hoặc dữ liệu
người dùng. Thông tin ký APK chỉ được lưu trong GitHub Actions Secrets; xem tài
liệu Android signing để biết tên biến cần cấu hình, không ghi giá trị bí mật vào
README hay source code.
