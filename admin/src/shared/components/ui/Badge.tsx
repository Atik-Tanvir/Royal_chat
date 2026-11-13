import React from 'react';

interface BadgeProps {
  children: React.ReactNode;
  variant?: 'emerald' | 'amber' | 'cyan' | 'rose' | 'purple' | 'slate';
  size?: 'sm' | 'md';
}

export function Badge({ children, variant = 'slate', size = 'sm' }: BadgeProps) {
  const styles = {
    emerald: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30',
    amber: 'bg-amber-500/15 text-amber-400 border-amber-500/30',
    cyan: 'bg-cyan-500/15 text-cyan-400 border-cyan-500/30',
    rose: 'bg-rose-500/15 text-rose-400 border-rose-500/30',
    purple: 'bg-purple-500/15 text-purple-400 border-purple-500/30',
    slate: 'bg-slate-500/15 text-slate-300 border-slate-500/30',
  }[variant];

  const sizeClasses = size === 'sm' ? 'text-xs px-2.5 py-0.5' : 'text-sm px-3 py-1';

  return (
    <span className={`inline-flex items-center font-medium rounded-full border ${styles} ${sizeClasses}`}>
      {children}
    </span>
  );
}
