'use client';

import React from 'react';
import { Menu, Bell, Shield, Sparkles, RefreshCw } from 'lucide-react';
import Link from 'next/link';

interface HeaderProps {
  onToggleMobileMenu: () => void;
}

export function Header({ onToggleMobileMenu }: HeaderProps) {
  return (
    <header className="sticky top-0 z-30 h-16 bg-[#0B1512]/90 backdrop-blur-md border-b border-[#1C3830] flex items-center justify-between px-4 lg:px-8">
      {/* Left: Mobile Menu Toggle & Title */}
      <div className="flex items-center gap-3">
        <button
          onClick={onToggleMobileMenu}
          className="lg:hidden p-2 text-slate-300 hover:text-white hover:bg-white/5 rounded-xl"
        >
          <Menu className="w-5 h-5" />
        </button>
        <div className="hidden sm:flex items-center gap-2">
          <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-ping"></span>
          <span className="text-xs font-semibold text-emerald-400">System Live</span>
          <span className="text-xs text-slate-500">|</span>
          <span className="text-xs text-slate-400">Server Ping: 24ms</span>
        </div>
      </div>

      {/* Right: Quick actions, notifications, Admin Profile */}
      <div className="flex items-center gap-3">
        {/* Quick Run Ads shortcut */}
        <Link
          href="/ads"
          className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-gradient-to-r from-amber-500/20 to-emerald-500/20 border border-amber-500/30 text-amber-300 hover:border-amber-400 text-xs font-bold transition-colors"
        >
          <Sparkles className="w-3.5 h-3.5 text-amber-400" />
          <span>Run Ads Campaign</span>
        </Link>

        {/* Sync button */}
        <button
          onClick={() => window.location.reload()}
          title="Refresh Data"
          className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-white/5 transition-colors"
        >
          <RefreshCw className="w-4 h-4" />
        </button>

        {/* Notifications */}
        <Link
          href="/notifications"
          className="relative p-2 rounded-xl text-slate-400 hover:text-white hover:bg-white/5 transition-colors"
        >
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-rose-500"></span>
        </Link>

        {/* Admin User Chip */}
        <div className="flex items-center gap-2 pl-2 border-l border-[#1C3830]">
          <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-emerald-600 to-teal-400 flex items-center justify-center font-bold text-xs text-white shadow-md">
            AD
          </div>
          <div className="hidden sm:block text-left">
            <p className="text-xs font-bold text-white leading-tight">Super Admin</p>
            <p className="text-[10px] text-emerald-400 flex items-center gap-1">
              <Shield className="w-2.5 h-2.5" /> Full Root Access
            </p>
          </div>
        </div>
      </div>
    </header>
  );
}
