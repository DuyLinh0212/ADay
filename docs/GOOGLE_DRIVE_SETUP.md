# Kích hoạt sao lưu Google Drive

ADay không có backend xác minh email. Luồng sao lưu chạy trực tiếp trong ứng
dụng bằng Google Sign-In: người dùng chọn tài khoản Google, cấp quyền một lần,
sau đó ADay ghi tệp sao lưu riêng của ứng dụng lên tài khoản đó.

## Quyền truy cập

Ứng dụng chỉ xin scope `drive.appdata`. Tệp `aday-backup.json` nằm trong vùng
dữ liệu riêng của ứng dụng, không duyệt hoặc đọc các tệp Drive thông thường và
không xuất hiện trong giao diện Drive như một tệp công khai.

## Cấu hình Google Cloud

1. Mở Google Cloud Console và tạo/chọn một project dành cho ADay.
2. Enable **Google Drive API**.
3. Cấu hình **OAuth consent screen** với tên ứng dụng và email hỗ trợ.
4. Nếu ứng dụng đang ở chế độ Testing, thêm các tài khoản Google sẽ dùng thử
   vào danh sách **Test users**.
5. Tạo **OAuth client ID → Android** với:
   - Package name: `com.ngduylinh.aday`
   - SHA-1: SHA-1 của keystore release cố định dùng để build APK.

SHA-1 phải khớp với keystore ký APK trên CI. Không dùng SHA-1 của debug key
nếu người dùng sẽ cài APK release từ GitHub Actions.

## Cách dùng trong app

Vào **Hồ sơ → Sao lưu Google Drive → Sao lưu ngay**. Lần đầu, Google sẽ mở hộp
thoại chọn tài khoản và cấp quyền. Những lần sau ADay dùng lại tài khoản đã cấp
quyền; có thể đổi tài khoản bằng cách thu hồi quyền Google của ADay rồi sao lưu
lại.

## Bảo mật

Không đưa OAuth client secret, access token, keystore hoặc mật khẩu keystore vào
source code. Android signing secrets chỉ lưu trong GitHub Actions Secrets. Việc
đăng nhập Google và việc cấp quyền Drive do Google xử lý; ADay không tự coi một
email là đã xác minh bằng logic phía client.
