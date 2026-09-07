import React from 'react';

export const SkipLink: React.FC = () => {
  return (
    <a
      href="#main-content"
      className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-teal-600 focus:text-white focus:rounded-lg focus:shadow-lg focus:font-medium focus:ring-2 focus:ring-amber-400 focus:outline-none"
    >
      Chuyển đến nội dung chính (Skip to main content)
    </a>
  );
};
