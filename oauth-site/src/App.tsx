import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { SkipLink } from './components/SkipLink';
import { ScrollToTop } from './components/ScrollToTop';
import { Home } from './pages/Home';
import { Privacy } from './pages/Privacy';
import { Terms } from './pages/Terms';
import { NotFound } from './pages/NotFound';

export const App: React.FC = () => {
  return (
    <BrowserRouter>
      <div className="min-h-screen flex flex-col bg-slate-50 text-slate-800 font-sans selection:bg-teal-200 selection:text-teal-900">
        <SkipLink />
        <ScrollToTop />
        <Navbar />
        <main id="main-content" tabIndex={-1} className="flex-1 focus:outline-none">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/privacy" element={<Privacy />} />
            <Route path="/terms" element={<Terms />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </main>
        <Footer />
      </div>
    </BrowserRouter>
  );
};

export default App;
