import React from 'react';
import * as Icons from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  change?: string;
  isPositive?: boolean;
  iconName: keyof typeof Icons;
  color?: 'emerald' | 'gold' | 'cyan' | 'purple';
}

export function StatCard({
  title,
  value,
  change,
  isPositive = true,
  iconName,
  color = 'emerald',
}: StatCardProps) {
  const IconComponent = (Icons[iconName] as React.ElementType) || Icons.Activity;

  const colorStyles = {
    emerald: {
      border: 'border-emerald-500/20',
      bg: 'bg-emerald-500/10',
      text: 'text-emerald-400',
      glow: 'hover:border-emerald-500/40',
    },
    gold: {
      border: 'border-amber-500/20',
      bg: 'bg-amber-500/10',
      text: 'text-amber-400',
      glow: 'hover:border-amber-500/40',
    },
    cyan: {
      border: 'border-cyan-500/20',
      bg: 'bg-cyan-500/10',
      text: 'text-cyan-400',
      glow: 'hover:border-cyan-500/40',
    },
    purple: {
      border: 'border-purple-500/20',
      bg: 'bg-purple-500/10',
      text: 'text-purple-400',
      glow: 'hover:border-purple-500/40',
    },
  }[color];

  return (
    <div className={`p-5 rounded-2xl glass-panel ${colorStyles.border} ${colorStyles.glow} transition-all duration-200`}>
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">
          {title}
        </span>
        <div className={`w-10 h-10 rounded-xl ${colorStyles.bg} flex items-center justify-center ${colorStyles.text}`}>
          <IconComponent className="w-5 h-5" />
        </div>
      </div>
      <div className="flex items-baseline justify-between">
        <span className="text-2xl font-black text-white tracking-tight">{value}</span>
        {change && (
          <span
            className={`text-xs font-bold px-2 py-0.5 rounded-full ${
              isPositive
                ? 'bg-emerald-500/15 text-emerald-400'
                : 'bg-rose-500/15 text-rose-400'
            }`}
          >
            {change}
          </span>
        )}
      </div>
    </div>
  );
}
