'use client';

import React, { useState } from 'react';
import { formatCoins, formatUSD } from '../../shared/lib/utils';
import {
  Trophy,
} from 'lucide-react';

interface LeaderboardUser {
  rank: number;
  userId: string;
  username: string;
  avatarUrl: string;
  flag: string;
  country: string;
  gender: string;
  level: number;
  score: number;
  usdEquivalent: number;
  type: 'Wealth' | 'Game' | 'Charm' | 'Invitation';
  isAnonymous: boolean;
}

export default function LeaderboardsPage() {
  const [activeType, setActiveType] = useState<'Wealth' | 'Game' | 'Charm' | 'Invitation'>('Wealth');
  const [period, setPeriod] = useState<'Daily' | 'Monthly'>('Daily');
  const [country, setCountry] = useState('All');

  const [rankings, setRankings] = useState<LeaderboardUser[]>([
    {
      rank: 1,
      userId: 'user_ahmad',
      username: 'A H M A D',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      flag: '🇸🇦',
      country: 'Saudi Arabia',
      gender: '♂ 27',
      level: 9,
      score: 280810000,
      usdEquivalent: 561,
      type: 'Wealth',
      isAnonymous: false,
    },
    {
      rank: 2,
      userId: 'user_killer',
      username: 'K I L L E R',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      flag: '🇵🇰',
      country: 'Pakistan',
      gender: '♂ 20',
      level: 3,
      score: 189650000,
      usdEquivalent: 379,
      type: 'Wealth',
      isAnonymous: false,
    },
    {
      rank: 3,
      userId: 'user_queen',
      username: 'Dark Queen',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      flag: '🇵🇰',
      country: 'Pakistan',
      gender: '♀ 19',
      level: 3,
      score: 186480000,
      usdEquivalent: 372,
      type: 'Wealth',
      isAnonymous: false,
    },
    {
      rank: 4,
      userId: 'user_hunter',
      username: 'H U N T E R',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
      flag: '🇺🇸',
      country: 'United States',
      gender: '♂ 19',
      level: 3,
      score: 184070000,
      usdEquivalent: 368,
      type: 'Wealth',
      isAnonymous: false,
    },
    {
      rank: 5,
      userId: 'user_ang',
      username: 'ANGELINA 💖',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      flag: '🇧🇩',
      country: 'Bangladesh',
      gender: '♀ 21',
      level: 6,
      score: 1450000,
      usdEquivalent: 290,
      type: 'Invitation',
      isAnonymous: false,
    },
  ]);

  function disqualifyUser(userId: string) {
    if (!confirm('Disqualify user?')) return;
    setRankings((prev) => prev.filter((r) => r.userId !== userId));
  }

  const filteredRankings = rankings.filter((r) => {
    if (country !== 'All' && r.country !== country) return false;
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <Trophy className="w-6 h-6 text-amber-400" />
          <span>Leaderboards</span>
        </h2>

        {/* Filters */}
        <div className="flex items-center gap-2">
          <select
            value={country}
            onChange={(e) => setCountry(e.target.value)}
            className="px-3 py-1.5 rounded-xl bg-[#11221D] border border-[#1C3830] text-xs text-white focus:outline-none"
          >
            <option value="All">All Regions</option>
            <option value="Bangladesh">🇧🇩 Bangladesh</option>
            <option value="Pakistan">🇵🇰 Pakistan</option>
            <option value="Saudi Arabia">🇸🇦 Saudi Arabia</option>
            <option value="United States">🇺🇸 United States</option>
          </select>

          <div className="flex items-center gap-1 bg-[#11221D] p-1 rounded-xl border border-[#1C3830]">
            {(['Daily', 'Monthly'] as const).map((p) => (
              <button
                key={p}
                onClick={() => setPeriod(p)}
                className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors ${
                  period === p ? 'bg-emerald-500 text-slate-950 shadow-sm' : 'text-slate-400 hover:text-white'
                }`}
              >
                {p}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-1.5 border-b border-[#1C3830] pb-2">
        {(['Wealth', 'Game', 'Charm', 'Invitation'] as const).map((type) => (
          <button
            key={type}
            onClick={() => setActiveType(type)}
            className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
              activeType === type
                ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                : 'text-slate-400 hover:text-white hover:bg-white/5'
            }`}
          >
            {type}
          </button>
        ))}
      </div>

      {/* Table */}
      <div className="rounded-2xl glass-panel overflow-hidden border border-[#1C3830]">
        <table className="w-full text-left text-xs">
          <thead className="bg-[#0A1814] text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-[#1C3830]">
            <tr>
              <th className="py-3 px-4">Rank</th>
              <th className="py-3 px-4">User</th>
              <th className="py-3 px-4">Country</th>
              <th className="py-3 px-4">Level</th>
              <th className="py-3 px-4">Score</th>
              <th className="py-3 px-4">USD</th>
              <th className="py-3 px-4 text-right">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#1C3830] text-slate-300">
            {filteredRankings.map((user) => (
              <tr key={user.userId} className="hover:bg-white/[0.02] transition-colors">
                <td className="py-3 px-4 font-black">
                  {user.rank === 1 ? (
                    <span className="text-lg">👑</span>
                  ) : user.rank === 2 ? (
                    <span className="text-lg">🥈</span>
                  ) : user.rank === 3 ? (
                    <span className="text-lg">🥉</span>
                  ) : (
                    <span className="text-slate-400">{user.rank}</span>
                  )}
                </td>
                <td className="py-3 px-4">
                  <div className="flex items-center gap-2.5">
                    <img src={user.avatarUrl} alt={user.username} className="w-7 h-7 rounded-full object-cover" />
                    <div>
                      <p className="font-bold text-white text-xs">{user.username}</p>
                      <p className="text-[10px] text-slate-500 font-mono">{user.userId}</p>
                    </div>
                  </div>
                </td>
                <td className="py-3 px-4">
                  <span className="flex items-center gap-1">
                    <span>{user.flag}</span>
                    <span>{user.country}</span>
                  </span>
                </td>
                <td className="py-3 px-4">
                  <span className="px-2 py-0.5 rounded-md bg-purple-500/15 text-purple-300 border border-purple-500/30 font-bold text-[10px]">
                    LV{user.level}
                  </span>
                </td>
                <td className="py-3 px-4 font-black text-amber-400">
                  {formatCoins(user.score)}
                </td>
                <td className="py-3 px-4 text-slate-400 font-bold">
                  ≈{formatUSD(user.usdEquivalent)}
                </td>
                <td className="py-3 px-4 text-right">
                  <button
                    onClick={() => disqualifyUser(user.userId)}
                    className="px-2 py-1 rounded-lg bg-rose-500/15 hover:bg-rose-500/25 border border-rose-500/30 text-rose-300 text-xs font-bold transition-colors"
                  >
                    Disqualify
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
