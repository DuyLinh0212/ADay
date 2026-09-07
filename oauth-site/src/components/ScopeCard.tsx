import React, { useState } from 'react';
import { ShieldCheck, ChevronDown, ChevronUp, CheckCircle2, XCircle } from 'lucide-react';

export interface ScopeInfo {
  id: string;
  name: string;
  scopeUrl: string;
  category: string;
  purposeVi: string;
  dataAccessed: string[];
  dataNotAccessed: string[];
  userBenefit: string;
}

interface ScopeCardProps {
  scope: ScopeInfo;
}

export const ScopeCard: React.FC<ScopeCardProps> = ({ scope }) => {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="bg-white rounded-2xl border border-teal-100 shadow-sm hover:shadow-md transition-all duration-200 overflow-hidden">
      <div className="p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-teal-100 text-teal-800">
                {scope.category}
              </span>
              <span className="text-xs font-mono text-slate-500 bg-slate-100 px-2 py-0.5 rounded">
                OAuth 2.0 Scope
              </span>
            </div>
            <h3 className="text-lg font-bold text-slate-900">{scope.name}</h3>
          </div>

          <button
            type="button"
            onClick={() => setExpanded(!expanded)}
            className="inline-flex items-center gap-1.5 text-xs font-medium text-teal-700 hover:text-teal-800 bg-teal-50 hover:bg-teal-100/80 px-3 py-1.5 rounded-lg transition-colors focus:ring-2 focus:ring-teal-500 focus:outline-none"
            aria-expanded={expanded}
            aria-controls={`scope-details-${scope.id}`}
          >
            <span>{expanded ? 'Thu gọn chi tiết' : 'Xem phân tích chi tiết'}</span>
            {expanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
          </button>
        </div>

        <p className="mt-3 text-sm text-slate-600 leading-relaxed">{scope.purposeVi}</p>

        <div className="mt-4 p-3 bg-slate-50 rounded-xl border border-slate-200/60 font-mono text-xs text-slate-700 break-all select-all flex items-center justify-between gap-2">
          <span className="truncate">{scope.scopeUrl}</span>
          <span className="text-teal-600 font-sans font-medium text-[11px] shrink-0">Được bảo vệ</span>
        </div>

        {/* Collapsible section */}
        {expanded && (
          <div id={`scope-details-${scope.id}`} className="mt-6 pt-5 border-t border-slate-100 space-y-4 animate-in fade-in duration-200">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Data Accessed */}
              <div className="bg-teal-50/70 p-4 rounded-xl border border-teal-200/60 space-y-2">
                <div className="flex items-center gap-2 text-teal-900 font-semibold text-xs uppercase tracking-wider">
                  <CheckCircle2 className="w-4 h-4 text-teal-600 shrink-0" />
                  <span>Dữ liệu ADay truy cập:</span>
                </div>
                <ul className="space-y-1.5 text-xs text-teal-950">
                  {scope.dataAccessed.map((item, idx) => (
                    <li key={idx} className="flex items-start gap-1.5">
                      <span className="text-teal-600 font-bold">•</span>
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Data NOT Accessed */}
              <div className="bg-rose-50/70 p-4 rounded-xl border border-rose-200/60 space-y-2">
                <div className="flex items-center gap-2 text-rose-900 font-semibold text-xs uppercase tracking-wider">
                  <XCircle className="w-4 h-4 text-rose-600 shrink-0" />
                  <span>Cam kết TUYỆT ĐỐI KHÔNG:</span>
                </div>
                <ul className="space-y-1.5 text-xs text-rose-950">
                  {scope.dataNotAccessed.map((item, idx) => (
                    <li key={idx} className="flex items-start gap-1.5">
                      <span className="text-rose-500 font-bold">•</span>
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            <div className="bg-sky-50/60 p-3.5 rounded-xl border border-sky-200/70 text-xs text-sky-900 flex items-start gap-2.5">
              <ShieldCheck className="w-4 h-4 text-sky-600 shrink-0 mt-0.5" />
              <div>
                <strong>Lợi ích trực tiếp cho bạn: </strong>
                {scope.userBenefit}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
