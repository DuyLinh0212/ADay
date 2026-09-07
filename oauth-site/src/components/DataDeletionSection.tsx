import React from 'react';
import { ExternalLink, ShieldAlert, Trash2 } from 'lucide-react';

export const DataDeletionSection: React.FC = () => (
  <section id="data-deletion" className="scroll-mt-24 py-12 max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <div className="bg-gradient-to-br from-slate-900 via-teal-950 to-slate-900 rounded-3xl p-6 sm:p-10 text-white shadow-xl border border-teal-800/40">
      <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-amber-400/20 text-amber-300 border border-amber-400/30">
        <Trash2 className="w-3.5 h-3.5" aria-hidden="true" />
        Kiểm soát dữ liệu
      </div>
      <h2 className="mt-5 text-2xl sm:text-3xl font-bold tracking-tight">Thu hồi quyền và xóa dữ liệu</h2>
      <p className="mt-3 max-w-3xl text-slate-300 text-sm sm:text-base leading-relaxed">ADay không có máy chủ riêng lưu dữ liệu Google. Bạn có thể dừng quyền truy cập trực tiếp từ tài khoản Google của mình.</p>
      <div className="mt-7 grid md:grid-cols-2 gap-5">
        <div className="bg-slate-800/80 rounded-2xl p-5 border border-slate-700/70 space-y-3">
          <h3 className="font-bold">1. Thu hồi quyền Google</h3>
          <p className="text-sm text-slate-300 leading-relaxed">Mở trang quản lý quyền Google, tìm ADay và chọn Remove Access. Sau đó ADay không thể truy cập vùng appDataFolder nữa.</p>
          <a href="https://myaccount.google.com/permissions" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-2 w-full justify-center py-2.5 px-4 rounded-xl text-xs font-semibold bg-teal-600 hover:bg-teal-500 transition-colors">Mở cài đặt quyền Google <ExternalLink className="w-3.5 h-3.5" aria-hidden="true" /></a>
        </div>
        <div className="bg-slate-800/80 rounded-2xl p-5 border border-slate-700/70 space-y-3">
          <h3 className="font-bold">2. Xóa dữ liệu trên thiết bị</h3>
          <p className="text-sm text-slate-300 leading-relaxed">Dữ liệu nhiệm vụ và cài đặt cục bộ có thể xóa bằng chức năng xóa dữ liệu của Android hoặc gỡ ứng dụng. Google appDataFolder do ADay tạo sẽ được Google quản lý theo quyền của ứng dụng.</p>
          <div className="flex items-start gap-2 text-xs text-amber-200 bg-amber-400/10 border border-amber-400/20 rounded-xl p-3"><ShieldAlert className="w-4 h-4 shrink-0" aria-hidden="true" /><span>Hãy sao lưu trước khi xóa nếu bạn còn cần khôi phục dữ liệu.</span></div>
        </div>
      </div>
    </div>
  </section>
);
