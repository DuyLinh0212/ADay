import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, ExternalLink, ShieldCheck } from 'lucide-react';

export const Privacy: React.FC = () => (
  <div className="min-h-screen bg-slate-50 py-10 sm:py-16">
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <Link to="/" className="inline-flex items-center gap-2 text-sm text-teal-700 hover:text-teal-900 mb-7"><ArrowLeft className="w-4 h-4" aria-hidden="true" /> Trang chủ</Link>
      <article className="bg-white rounded-3xl p-6 sm:p-10 border border-slate-200 shadow-sm space-y-8 text-slate-700 leading-relaxed">
        <header className="space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-teal-100 text-teal-800"><ShieldCheck className="w-4 h-4" aria-hidden="true" /> Chính sách riêng tư</div>
          <h1 className="text-3xl sm:text-4xl font-extrabold text-slate-900">Chính sách quyền riêng tư ADay</h1>
          <p className="text-sm text-slate-500">Cập nhật: 07/09/2026</p>
          <p>ADay là ứng dụng lập kế hoạch cá nhân. Chính sách này mô tả dữ liệu được xử lý khi bạn tùy chọn kết nối Google Drive để sao lưu.</p>
        </header>

        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">1. Dữ liệu ADay xử lý</h2><ul className="list-disc list-inside space-y-2"><li>Dữ liệu nhiệm vụ, mục tiêu, cài đặt và avatar bạn tạo trong ứng dụng được lưu cục bộ trên thiết bị.</li><li>Khi bạn bấm sao lưu, ADay tạo tệp `aday-backup.json` từ dữ liệu ứng dụng và lưu vào vùng dữ liệu riêng của ADay trên Google Drive.</li><li>Google Sign-In có thể trả về địa chỉ email tài khoản đã chọn để ADay hiển thị tài khoản Drive đang kết nối.</li></ul></section>

        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">2. Dữ liệu ADay không truy cập</h2><p>ADay không yêu cầu hoặc đọc Gmail, Google Calendar, danh bạ, tệp Drive thông thường, mật khẩu Google hay thông tin thanh toán. ADay không bán dữ liệu và không dùng dữ liệu Google để quảng cáo hoặc huấn luyện AI.</p></section>

        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">3. Quyền Google được yêu cầu</h2><p>ADay chỉ yêu cầu scope <code className="px-1.5 py-0.5 rounded bg-slate-100 text-sm">drive.appdata</code>. Đây là vùng dữ liệu ẩn dành riêng cho ứng dụng; ứng dụng khác và giao diện Drive thông thường không duyệt được vùng này.</p><a className="inline-flex items-center gap-1 text-teal-700 underline" href="https://developers.google.com/workspace/drive/api/guides/appdata" target="_blank" rel="noopener noreferrer">Xem tài liệu Google Drive appDataFolder <ExternalLink className="w-3.5 h-3.5" aria-hidden="true" /></a></section>

        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">4. Lưu trữ và chia sẻ</h2><p>ADay không có backend riêng để lưu dữ liệu Google. Tệp sao lưu nằm trong tài khoản Google bạn chọn và chỉ ADay có thể truy cập khi bạn còn cấp quyền. ADay không chuyển dữ liệu Google cho bên thứ ba.</p></section>

        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">5. Thu hồi quyền và xóa dữ liệu</h2><p>Bạn có thể thu hồi quyền ADay tại <a className="text-teal-700 underline" href="https://myaccount.google.com/permissions" target="_blank" rel="noopener noreferrer">Google Account permissions</a>. Dữ liệu cục bộ có thể xóa bằng chức năng xóa dữ liệu của Android hoặc gỡ ứng dụng. Hãy xem <Link className="text-teal-700 underline" to="/#data-deletion">hướng dẫn xóa dữ liệu</Link> để biết thêm.</p></section>

        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">6. Liên hệ</h2><p>Để liên hệ về quyền riêng tư, sử dụng email hỗ trợ được hiển thị trong màn hình cấp quyền OAuth của Google Cloud project ADay.</p></section>
      </article>
    </div>
  </div>
);
