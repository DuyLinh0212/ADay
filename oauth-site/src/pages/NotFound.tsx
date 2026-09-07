import React from 'react';
import { Link } from 'react-router-dom';
import { Home, AlertCircle } from 'lucide-react';

export const NotFound: React.FC = () => {
  return (
    <div className="min-h-[70vh] flex items-center justify-center px-4 py-16">
      <div className="max-w-md text-center space-y-5">
        <div className="w-16 h-16 rounded-2xl bg-teal-50 border border-teal-200 flex items-center justify-center mx-auto text-teal-600 shadow-sm">
          <AlertCircle className="w-8 h-8" />
        </div>
        <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">404 - Không tìm thấy trang</h1>
        <p className="text-sm text-slate-600 leading-relaxed">
          Trang bạn đang tìm kiếm có thể đã được đổi tên, chuyển đi hoặc không tồn tại.
        </p>
        <div>
          <Link
            to="/"
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-colors"
          >
            <Home className="w-4 h-4" />
            <span>Quay về Trang chủ</span>
          </Link>
        </div>
      </div>
    </div>
  );
};
