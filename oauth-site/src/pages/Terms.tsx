import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, Scale } from 'lucide-react';

export const Terms: React.FC = () => (
  <div className="min-h-screen bg-slate-50 py-10 sm:py-16">
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <Link to="/" className="inline-flex items-center gap-2 text-sm text-teal-700 hover:text-teal-900 mb-7"><ArrowLeft className="w-4 h-4" aria-hidden="true" /> Trang chủ</Link>
      <article className="bg-white rounded-3xl p-6 sm:p-10 border border-slate-200 shadow-sm space-y-8 text-slate-700 leading-relaxed">
        <header className="space-y-4"><div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-sky-100 text-sky-800"><Scale className="w-4 h-4" aria-hidden="true" /> Điều khoản sử dụng</div><h1 className="text-3xl sm:text-4xl font-extrabold text-slate-900">Điều khoản dịch vụ ADay</h1><p className="text-sm text-slate-500">Cập nhật: 07/09/2026</p><p>Bằng việc sử dụng ADay, bạn đồng ý với các điều khoản dưới đây và <Link className="text-teal-700 underline" to="/privacy">Chính sách quyền riêng tư</Link>.</p></header>
        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">1. Dịch vụ</h2><p>ADay cung cấp công cụ lập kế hoạch cá nhân, quản lý nhiệm vụ, mục tiêu, lịch và sao lưu tùy chọn. Tính năng Google Drive chỉ hoạt động sau khi bạn tự chọn tài khoản và cấp quyền qua Google.</p></section>
        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">2. Tài khoản Google</h2><p>Bạn chỉ kết nối tài khoản Google mà bạn sở hữu hoặc có quyền sử dụng. Bạn có thể thu hồi quyền ADay bất cứ lúc nào tại <a className="text-teal-700 underline" href="https://myaccount.google.com/permissions" target="_blank" rel="noopener noreferrer">Google Account permissions</a>.</p></section>
        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">3. Dữ liệu và sao lưu</h2><p>Dữ liệu trong ứng dụng thuộc về bạn. ADay không cam kết bản sao lưu thay thế cho việc bảo vệ dữ liệu của thiết bị; hãy kiểm tra sao lưu đã hoàn tất trước khi đổi hoặc xóa thiết bị.</p></section>
        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">4. Sử dụng hợp lệ</h2><p>Không sử dụng ADay để phá hoại, can thiệp trái phép, phát tán mã độc hoặc vi phạm pháp luật. Bạn chịu trách nhiệm về nội dung và dữ liệu do mình tạo.</p></section>
        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">5. Tính khả dụng</h2><p>ADay được cung cấp trên cơ sở “như hiện có”. Dịch vụ có thể bị gián đoạn do thiết bị, mạng hoặc Google API. ADay không chịu trách nhiệm cho việc mất dữ liệu do lỗi ngoài khả năng kiểm soát hợp lý.</p></section>
        <section className="space-y-3"><h2 className="text-xl font-bold text-slate-900">6. Thay đổi</h2><p>Điều khoản có thể được cập nhật khi tính năng hoặc yêu cầu pháp lý thay đổi. Phiên bản mới sẽ được đăng tại trang này.</p></section>
        <p className="pt-5 border-t border-slate-200 text-sm text-slate-500">Nếu có câu hỏi, hãy dùng email hỗ trợ được khai báo trong màn hình OAuth của Google Cloud project ADay.</p>
      </article>
    </div>
  </div>
);
