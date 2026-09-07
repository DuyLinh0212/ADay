import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, ShieldCheck, Sun, ExternalLink } from 'lucide-react';

export const Navbar: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();

  // Close mobile menu on route navigation
  useEffect(() => {
    setIsOpen(false);
  }, [location.pathname]);

  const navLinks = [
    { to: '/', label: 'Trang chủ (Tổng quan)' },
    { to: '/privacy', label: 'Chính sách Bảo mật' },
    { to: '/terms', label: 'Điều khoản Dịch vụ' },
  ];

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  return (
    <header className="sticky top-0 z-40 w-full border-b border-teal-900/10 bg-white/90 backdrop-blur-md transition-all shadow-sm">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-18 py-3">
          {/* Brand Logo & Name */}
          <Link
            to="/"
            className="flex items-center gap-3 group rounded-xl p-1 focus:ring-2 focus:ring-teal-500 focus:outline-none"
            aria-label="ADay - Trang chủ thông tin OAuth và Quyền riêng tư"
          >
            <div className="relative w-10 h-10 rounded-xl overflow-hidden shadow-md group-hover:scale-105 transition-transform duration-200">
              <img src="/logo.svg" alt="ADay Logo" className="w-full h-full object-cover" />
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <span className="text-xl font-bold tracking-tight bg-gradient-to-r from-teal-700 via-sky-700 to-amber-600 bg-clip-text text-transparent">
                  ADay
                </span>
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-teal-50 text-teal-700 border border-teal-200/60">
                  <ShieldCheck className="w-3 h-3 text-teal-600" aria-hidden="true" />
                  OAuth Verified
                </span>
              </div>
              <p className="text-xs text-slate-500 hidden sm:block">
                Trung tâm Minh bạch & Quyền riêng tư
              </p>
            </div>
          </Link>

          {/* Desktop Nav Links */}
          <nav className="hidden md:flex items-center gap-1" aria-label="Điều hướng chính">
            {navLinks.map((link) => {
              const active = isActive(link.to);
              return (
                <Link
                  key={link.to}
                  to={link.to}
                  className={`px-4 py-2 rounded-lg text-sm font-medium transition-all duration-150 ${
                    active
                      ? 'bg-teal-50 text-teal-900 font-semibold shadow-xs border border-teal-200/80'
                      : 'text-slate-600 hover:text-teal-700 hover:bg-slate-100/70'
                  }`}
                  aria-current={active ? 'page' : undefined}
                >
                  {link.label}
                </Link>
              );
            })}
          </nav>

          {/* CTA / Quick Access */}
          <div className="hidden lg:flex items-center gap-3">
            <a
              href="https://myaccount.google.com/permissions"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 text-xs font-medium px-3.5 py-2 rounded-lg text-slate-700 bg-slate-100 hover:bg-slate-200/80 hover:text-slate-900 border border-slate-200/70 transition-colors"
              title="Mở cài đặt quản lý quyền tài khoản Google của bạn"
            >
              <span>Quản lý quyền Google</span>
              <ExternalLink className="w-3.5 h-3.5 text-slate-400" aria-hidden="true" />
            </a>
            <Link
              to="/#data-deletion"
              className="inline-flex items-center gap-1.5 text-xs font-semibold px-4 py-2 rounded-lg bg-gradient-to-r from-teal-600 to-sky-600 text-white shadow-sm hover:from-teal-700 hover:to-sky-700 transition-all focus:ring-2 focus:ring-teal-500 focus:ring-offset-2"
            >
              <Sun className="w-3.5 h-3.5 text-amber-300" aria-hidden="true" />
              <span>Yêu cầu xóa dữ liệu</span>
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <div className="flex md:hidden">
            <button
              type="button"
              onClick={() => setIsOpen(!isOpen)}
              className="p-2 rounded-lg text-slate-600 hover:text-teal-700 hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-teal-500"
              aria-controls="mobile-menu"
              aria-expanded={isOpen}
              aria-label={isOpen ? 'Đóng bảng điều hướng' : 'Mở bảng điều hướng'}
            >
              {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu Dropdown */}
      {isOpen && (
        <div id="mobile-menu" className="md:hidden border-t border-slate-200 bg-white/95 px-4 pt-3 pb-5 shadow-lg">
          <nav className="flex flex-col gap-1.5" aria-label="Điều hướng trên thiết bị di động">
            {navLinks.map((link) => {
              const active = isActive(link.to);
              return (
                <Link
                  key={link.to}
                  to={link.to}
                  className={`px-4 py-3 rounded-lg text-base font-medium transition-colors ${
                    active
                      ? 'bg-teal-50 text-teal-900 font-semibold border-l-4 border-teal-600'
                      : 'text-slate-700 hover:bg-slate-50 hover:text-teal-700'
                  }`}
                  aria-current={active ? 'page' : undefined}
                >
                  {link.label}
                </Link>
              );
            })}
            <div className="mt-4 pt-4 border-t border-slate-100 flex flex-col gap-2">
              <a
                href="https://myaccount.google.com/permissions"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center justify-center gap-2 py-2.5 px-4 rounded-lg text-sm font-medium text-slate-700 bg-slate-100"
              >
                <span>Quản lý quyền Google</span>
                <ExternalLink className="w-4 h-4 text-slate-400" aria-hidden="true" />
              </a>
              <Link
                to="/#data-deletion"
                className="inline-flex items-center justify-center gap-2 py-2.5 px-4 rounded-lg text-sm font-semibold bg-teal-600 text-white shadow-sm"
              >
                <Sun className="w-4 h-4 text-amber-300" aria-hidden="true" />
                <span>Yêu cầu xóa dữ liệu</span>
              </Link>
            </div>
          </nav>
        </div>
      )}
    </header>
  );
};
