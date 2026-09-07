# Kích hoạt sao lưu Google Drive

ADay chỉ xin scope `drive.appdata`: ứng dụng chỉ ghi tệp `aday-backup.json`
trong vùng dữ liệu riêng của ứng dụng, không duyệt tệp Drive thông thường.

Trước khi phát hành Android, chủ dự án cần tạo OAuth client Android trong
Google Cloud Console cho package `com.ngduylinh.aday`, thêm SHA-1 của signing
key, bật Google Drive API và cấu hình OAuth consent screen/testers.

Nếu ADay có backend xác minh email riêng, backend phải xác minh Google ID token
qua HTTPS (chữ ký, `aud`, `iss`, `exp`) và chỉ cho phép sao lưu khi
`email_verified` là `true`. Flutter client không được tự coi claim này là đã
xác minh.
