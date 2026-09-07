import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, CheckCircle2, KeyRound, ShieldCheck, Sparkles } from 'lucide-react';
import { ScopeCard, ScopeInfo } from '../components/ScopeCard';
import { DataDeletionSection } from '../components/DataDeletionSection';

const driveScope: ScopeInfo = {
  id: 'drive-appdata',
  name: 'Dữ liệu riêng của ứng dụng Google Drive',
  scopeUrl: 'https://www.googleapis.com/auth/drive.appdata',
  category: 'Sao lưu tùy chọn',
  purposeVi:
    'ADay chỉ dùng vùng appDataFolder riêng của tài khoản Google để lưu một bản sao JSON khi bạn chủ động bấm Sao lưu Google Drive.',
  dataAccessed: [
    'Tệp sao lưu ADay do chính ứng dụng tạo ra',
    'Địa chỉ email tài khoản được Google Sign-In trả về để hiển thị tài khoản đã kết nối',
  ],
  dataNotAccessed: [
    'Không đọc Gmail, Google Calendar, danh bạ hoặc tệp Drive thông thường',
    'Không biết hoặc lưu mật khẩu Google của bạn',
    'Không chia sẻ dữ liệu sao lưu cho ứng dụng hoặc bên thứ ba khác',
  ],
  userBenefit: 'Khôi phục dữ liệu ADay trên thiết bị khác mà không cần máy chủ riêng của ADay.',
};

export const Home: React.FC = () => {
  return (
    <div className="min-h-screen">
      <section className="relative overflow-hidden pt-16 pb-20 sm:pt-24 sm:pb-28 bg-gradient-to-b from-teal-950 via-sky-950 to-slate-950 text-white">
        <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-[720px] h-[360px] bg-gradient-to-t from-teal-500/20 via-sky-500/15 to-amber-400/10 blur-[100px] rounded-full pointer-events-none" />
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="max-w-3xl mx-auto text-center space-y-7">
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold bg-teal-400/10 text-teal-200 border border-teal-300/25">
              <Sparkles className="w-3.5 h-3.5 text-amber-300" aria-hidden="true" />
              <span>Trang thông tin chính thức của ADay</span>
            </div>
            <h1 className="text-4xl sm:text-6xl font-extrabold tracking-tight leading-tight">
              Lập kế hoạch nhẹ nhàng,
              <span className="block bg-gradient-to-r from-teal-300 via-sky-300 to-amber-300 bg-clip-text text-transparent">bắt đầu ngày tốt hơn.</span>
            </h1>
            <p className="text-base sm:text-lg text-slate-200/90 leading-relaxed max-w-2xl mx-auto">
              ADay là ứng dụng lập kế hoạch cá nhân. Trang này giải thích minh bạch cách ADay dùng Google OAuth cho tính năng sao lưu tùy chọn.
            </p>
            <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
              <a href="#oauth-scopes" className="inline-flex items-center gap-2 px-5 py-3 rounded-xl text-sm font-semibold bg-teal-400 hover:bg-teal-300 text-slate-950 transition-colors">
                <KeyRound className="w-4 h-4" aria-hidden="true" />
                Xem quyền Google
              </a>
              <Link to="/privacy" className="inline-flex items-center gap-2 px-5 py-3 rounded-xl text-sm font-medium bg-white/10 hover:bg-white/15 text-slate-100 border border-white/15 transition-colors">
                Chính sách riêng tư <ArrowRight className="w-4 h-4" aria-hidden="true" />
              </Link>
            </div>
          </div>
        </div>
      </section>

      <section className="py-16 sm:py-20 bg-slate-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 grid lg:grid-cols-2 gap-10 items-start">
          <div className="space-y-5">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-teal-100 text-teal-800">
              <ShieldCheck className="w-3.5 h-3.5" aria-hidden="true" />
              Minh bạch ngay từ đầu
            </div>
            <h2 className="text-3xl font-bold tracking-tight text-slate-900">Bạn luôn kiểm soát dữ liệu của mình</h2>
            <p className="text-slate-600 leading-relaxed">ADay không có backend riêng để lưu dữ liệu Google. Sao lưu chỉ diễn ra khi bạn chủ động thực hiện và được lưu trong vùng dữ liệu riêng của app trên tài khoản Google đã chọn.</p>
            <div className="space-y-3 text-sm text-slate-700">
              {['Không đọc Gmail, Calendar hoặc Drive thông thường', 'Không lưu mật khẩu Google', 'Có thể thu hồi quyền bất kỳ lúc nào'].map((item) => (
                <div key={item} className="flex items-start gap-3"><CheckCircle2 className="w-5 h-5 text-teal-600 shrink-0" aria-hidden="true" /><span>{item}</span></div>
              ))}
            </div>
          </div>
          <div className="bg-white rounded-3xl p-6 sm:p-8 border border-teal-100 shadow-sm">
            <h3 className="text-lg font-bold text-slate-900 mb-5">Luồng kết nối</h3>
            <ol className="space-y-4 text-sm text-slate-600">
              {['Bạn bấm “Sao lưu Google Drive” trong ADay.', 'Google mở màn hình chọn tài khoản và xin quyền.', 'ADay ghi aday-backup.json vào appDataFolder riêng.', 'Bạn có thể thu hồi quyền từ cài đặt tài khoản Google.'].map((item, index) => (
                <li key={item} className="flex items-start gap-3"><span className="w-7 h-7 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center shrink-0">{index + 1}</span><span className="pt-1">{item}</span></li>
              ))}
            </ol>
          </div>
        </div>
      </section>

      <section id="oauth-scopes" className="scroll-mt-20 py-16 sm:py-24 max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl space-y-3 mb-10">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-teal-100 text-teal-800"><KeyRound className="w-3.5 h-3.5" aria-hidden="true" /> Quyền OAuth</div>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight">ADay chỉ yêu cầu quyền cần thiết</h2>
          <p className="text-slate-600 leading-relaxed">Quyền dưới đây phục vụ duy nhất cho bản sao lưu riêng của ứng dụng. ADay không yêu cầu quyền đọc các tệp Drive thông thường.</p>
        </div>
        <ScopeCard scope={driveScope} />
      </section>

      <DataDeletionSection />

      <section className="py-16 sm:py-20 bg-slate-50 border-t border-slate-200">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-2xl sm:text-3xl font-bold text-slate-900 mb-8">Câu hỏi thường gặp</h2>
          <div className="space-y-4">
            <details className="bg-white p-5 rounded-2xl border border-slate-200"><summary className="font-bold cursor-pointer">ADay có đọc Gmail hoặc lịch của tôi không?</summary><p className="mt-3 text-sm text-slate-600">Không. ADay hiện chỉ dùng quyền Drive appDataFolder cho tệp sao lưu riêng.</p></details>
            <details className="bg-white p-5 rounded-2xl border border-slate-200"><summary className="font-bold cursor-pointer">Tôi có thể đổi tài khoản Google không?</summary><p className="mt-3 text-sm text-slate-600">Có. Thu hồi quyền ADay trong Google Account rồi kết nối lại bằng tài khoản khác.</p></details>
            <details className="bg-white p-5 rounded-2xl border border-slate-200"><summary className="font-bold cursor-pointer">ADay có backend không?</summary><p className="mt-3 text-sm text-slate-600">Không. Luồng đăng nhập và sao lưu được xử lý trực tiếp giữa ứng dụng, Google Sign-In và Google Drive.</p></details>
          </div>
        </div>
      </section>
    </div>
  );
};
