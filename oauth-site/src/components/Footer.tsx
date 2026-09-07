import React from 'react';
import { Link } from 'react-router-dom';
import { Globe, ExternalLink, ShieldCheck } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer className="bg-slate-900 text-slate-300 border-t border-slate-800 relative overflow-hidden">
      {/* Subtle sunrise ambient glow */}
      <div className="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-teal-500 via-sky-500 to-amber-400" />
      <div className="absolute top-0 right-1/4 w-96 h-48 bg-teal-500/5 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 lg:gap-12">
          {/* Brand & Mission */}
          <div className="md:col-span-2 space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-lg overflow-hidden shadow">
                <img src="/logo.svg" alt="ADay Logo" className="w-full h-full object-cover" />
              </div>
              <span className="text-xl font-bold text-white tracking-tight">ADay</span>
            </div>
            <p className="text-sm text-slate-400 leading-relaxed max-w-md">
              ADay là ứng dụng lập kế hoạch cá nhân. Trang này giải thích minh bạch quyền Google Drive appData được dùng cho bản sao lưu tùy chọn.
            </p>
            <div className="flex flex-wrap items-center gap-3 pt-2">
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium bg-teal-950/80 text-teal-300 border border-teal-800">
                <ShieldCheck className="w-3 h-3 text-teal-400" aria-hidden="true" />
                Không yêu cầu mật khẩu Google
              </span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-medium bg-sky-950/80 text-sky-300 border border-sky-800">
                <ShieldCheck className="w-3 h-3 text-sky-400" aria-hidden="true" />
                Quyền Drive tối thiểu
              </span>
            </div>
          </div>

          {/* Quick Links */}
          <div className="space-y-4">
            <h3 className="text-sm font-semibold uppercase tracking-wider text-slate-200">
              Văn bản Pháp lý & Minh bạch
            </h3>
            <ul className="space-y-2.5 text-sm" aria-label="Liên kết pháp lý">
              <li>
                <Link
                  to="/"
                  className="hover:text-teal-300 transition-colors inline-flex items-center gap-1"
                >
                  Trang chủ & Minh bạch OAuth
                </Link>
              </li>
              <li>
                <Link
                  to="/privacy"
                  className="hover:text-teal-300 transition-colors inline-flex items-center gap-1"
                >
                  Chính sách Quyền riêng tư (Privacy)
                </Link>
              </li>
              <li>
                <Link
                  to="/terms"
                  className="hover:text-teal-300 transition-colors inline-flex items-center gap-1"
                >
                  Điều khoản Dịch vụ (Terms)
                </Link>
              </li>
              <li>
                <a
                  href="https://developers.google.com/terms/api-services-user-data-policy"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="hover:text-teal-300 transition-colors inline-flex items-center gap-1 text-slate-400"
                >
                  Google User Data Policy
                  <ExternalLink className="w-3 h-3" aria-hidden="true" />
                </a>
              </li>
            </ul>
          </div>

          {/* Contact & Support */}
          <div className="space-y-4">
            <h3 className="text-sm font-semibold uppercase tracking-wider text-slate-200">
              Liên hệ & Bảo vệ dữ liệu
            </h3>
            <p className="text-xs text-slate-400">
              Mọi thắc mắc về quyền riêng tư sử dụng email hỗ trợ đã khai báo trong Google Cloud OAuth.
            </p>
            <div className="space-y-2 text-sm">
              <div className="flex items-center gap-2 text-slate-400 text-xs">
                <Globe className="w-4 h-4 text-slate-500 shrink-0" aria-hidden="true" />
                <span>ADay không có backend lưu dữ liệu Google</span>
              </div>
            </div>
          </div>
        </div>

        {/* Disclaimer / Compliance Notice */}
        <div className="mt-10 pt-6 border-t border-slate-800 text-xs text-slate-400 leading-relaxed space-y-2">
          <p>
            <strong>Cam kết dữ liệu:</strong> ADay chỉ dùng Google Drive appData cho sao lưu do người dùng chủ động yêu cầu.{' '}
            <a
              href="https://developers.google.com/terms/api-services-user-data-policy#additional_requirements_for_specific_api_scopes"
              target="_blank"
              rel="noopener noreferrer"
              className="text-teal-400 hover:underline inline-flex items-center gap-0.5"
            >
              Google API Services User Data Policy
              <ExternalLink className="w-3 h-3 inline" aria-hidden="true" />
            </a>
              .
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 text-slate-400">
            <p>© {new Date().getFullYear()} ADay. Toàn bộ quyền được bảo lưu.</p>
            <p className="text-slate-400">
              Thiết kế theo phong cách ADay Sunrise Blue/Teal • Tối ưu khả năng tiếp cận WCAG 2.1
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
};
