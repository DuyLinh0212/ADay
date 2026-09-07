# Deploy trang OAuth ADay lên Vercel

Site React tĩnh nằm trong thư mục `oauth-site/`. Site không có backend, không có
secret và chỉ cung cấp các trang thông tin cho Google OAuth:

- `/` — trang giới thiệu ADay
- `/privacy` — chính sách quyền riêng tư
- `/terms` — điều khoản sử dụng

## Vercel

1. Import repository ADay vào Vercel.
2. Chọn **Root Directory** là `oauth-site`.
3. Framework preset: **Vite**.
4. Build command: `npm run build`.
5. Output directory: `dist`.
6. Không cần thêm environment variable.

Sau khi deploy, dùng các URL sau trong Google Auth Platform → Branding:

```text
Application home page: https://<domain-cua-ban>/
Privacy policy:        https://<domain-cua-ban>/privacy
Terms of use:          https://<domain-cua-ban>/terms
```

Để chuyển OAuth sang production, nên gắn custom domain mà bạn sở hữu vào
Vercel rồi thêm domain đó vào **Authorized domains** của Google Cloud. Không đưa
client secret, keystore, mật khẩu hoặc token vào site.

## Kiểm tra local

```bash
cd oauth-site
npm install
npm run build
npm run dev
```
