'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { navigationCategories } from '../../constants/navigation';
import * as Icons from 'lucide-react';

interface SidebarProps {
  isMobileOpen: boolean;
  onCloseMobile: () => void;
}

export function Sidebar({ isMobileOpen, onCloseMobile }: SidebarProps) {
  const pathname = usePathname();

  function getBadgeStyle(badge: string) {
    if (badge === 'Live') {
      return 'bg-rose-500/20 text-rose-400 border-rose-500/30';
    }
    if (badge === 'Hot') {
      return 'bg-amber-500/20 text-amber-400 border-amber-500/30';
    }
    if (badge === 'New') {
      return 'bg-cyan-500/20 text-cyan-300 border-cyan-500/30';
    }
    return 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30';
  }

  return (
    <>
      {/* Mobile backdrop */}
      {isMobileOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/70 backdrop-blur-sm lg:hidden"
          onClick={onCloseMobile}
        />
      )}

      {/* Sidebar container */}
      <aside
        className={`fixed top-0 bottom-0 left-0 z-40 w-64 bg-[#0A1814] border-r border-[#1C3830] flex flex-col transition-transform duration-300 ease-in-out lg:translate-x-0 ${
          isMobileOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {/* Brand Header */}
        <div className="h-16 flex items-center px-6 border-b border-[#1C3830] gap-3 shrink-0">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-amber-500 to-emerald-400 flex items-center justify-center shadow-lg shadow-emerald-500/20">
            <span className="text-xl">👑</span>
          </div>
          <div>
            <h1 className="font-black text-sm text-white tracking-wider uppercase">Royal Chat Live</h1>
            <p className="text-[10px] font-bold text-emerald-400 uppercase tracking-widest">Master Admin</p>
          </div>
        </div>

        {/* Categorized Navigation List */}
        <div className="flex-1 overflow-y-auto px-3 py-3 space-y-3">
          {navigationCategories.map((category, catIdx) => (
            <div key={category.title} className="space-y-1">
              {/* Category Header Label */}
              <div className="px-3 pt-1 pb-1 flex items-center justify-between">
                <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400/80 font-mono">
                  {category.title}
                </span>
                <span className="text-[9px] text-slate-500 font-mono">({category.items.length})</span>
              </div>

              {/* Items in Category */}
              <div className="space-y-0.5">
                {category.items.map((item) => {
                  const isActive = pathname === item.href;
                  const IconComponent =
                    (Icons[item.iconName as keyof typeof Icons] as React.ElementType) || Icons.Circle;

                  return (
                    <Link
                      key={item.href}
                      href={item.href}
                      onClick={onCloseMobile}
                      className={`flex items-center justify-between px-3 py-2 rounded-xl font-medium text-xs transition-all duration-150 ${
                        isActive
                          ? 'bg-emerald-500/15 text-emerald-300 font-bold border border-emerald-500/30 shadow-sm'
                          : 'text-slate-300 hover:text-white hover:bg-white/5'
                      }`}
                    >
                      <div className="flex items-center gap-2.5">
                        <IconComponent
                          className={`w-4 h-4 shrink-0 ${isActive ? 'text-emerald-400' : 'text-slate-400'}`}
                        />
                        <span className="truncate">{item.name}</span>
                      </div>
                      {item.badge && (
                        <span
                          className={`text-[9px] font-black px-1.5 py-0.5 rounded-md border tracking-wide uppercase ${getBadgeStyle(
                            item.badge
                          )}`}
                        >
                          {item.badge}
                        </span>
                      )}
                    </Link>
                  );
                })}
              </div>

              {/* Subtle divider between categories (except last) */}
              {catIdx < navigationCategories.length - 1 && (
                <div className="pt-2 border-b border-[#1C3830]/40 mx-2" />
              )}
            </div>
          ))}
        </div>

        {/* Footer Info */}
        <div className="p-4 border-t border-[#1C3830] bg-[#07130F] shrink-0">
          <div className="flex items-center justify-between text-xs text-slate-400">
            <span className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              LiveKit & Supabase
            </span>
            <span className="font-mono text-[10px] text-emerald-400 bg-emerald-500/10 px-1.5 py-0.5 rounded">
              v2.4.0
            </span>
          </div>
        </div>
      </aside>
    </>
  );
}
