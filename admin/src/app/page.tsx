'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { StatCard } from '../shared/components/ui/StatCard';
import { Badge } from '../shared/components/ui/Badge';
import { formatCoins, formatUSD, formatGems } from '../shared/lib/utils';
import { supabase } from '../shared/lib/supabase';
import {
  Mic,
  Tv,
  ArrowRight,
  Sparkles,
} from 'lucide-react';

export default function DashboardPage() {
  const [stats, setStats] = useState({
    activeRooms: 12,
    totalUsers: 14850,
    dailyCoinVolume: 42800000,
    gemReserves: 8420000,
    adRevenueToday: 342.8,
    pendingWithdrawals: 5,
  });

  useEffect(() => {
    async function fetchLiveStats() {
      try {
        const { count: usersCount } = await supabase
          .from('profiles')
          .select('*', { count: 'exact', head: true });

        const { count: roomsCount } = await supabase
          .from('rooms')
          .select('*', { count: 'exact', head: true })
          .eq('status', 'live');

        const { count: withdrawalsCount } = await supabase
          .from('withdrawals')
          .select('*', { count: 'exact', head: true })
          .eq('status', 'Pending');

        setStats((prev) => ({
          ...prev,
          totalUsers: usersCount || prev.totalUsers,
          activeRooms: roomsCount || prev.activeRooms,
          pendingWithdrawals: withdrawalsCount || prev.pendingWithdrawals,
        }));
      } catch {
        // demo fallback
      }
    }

    fetchLiveStats();
  }, []);

  return (
    <div className="space-y-6">
      {/* Top Banner (No Subtitle) */}
      <div className="relative overflow-hidden rounded-2xl p-6 bg-gradient-to-r from-[#0C4638] via-[#105E4C] to-[#0A2E24] border border-[#1C3830]">
        <div className="relative z-10">
          <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-emerald-500/20 border border-emerald-400/30 text-emerald-300 text-[11px] font-bold mb-3">
            <Sparkles className="w-3 h-3 text-amber-300" />
            <span>Master Console</span>
          </div>
          <h2 className="text-xl sm:text-2xl font-black text-white">
            Overview
          </h2>

          <div className="mt-4 flex flex-wrap gap-2.5">
            <Link
              href="/ads"
              className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 font-black text-xs transition-all"
            >
              <Tv className="w-3.5 h-3.5" />
              <span>Ads Control</span>
            </Link>
            <Link
              href="/rooms"
              className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/40 text-emerald-300 font-bold text-xs transition-all"
            >
              <Mic className="w-3.5 h-3.5" />
              <span>Rooms</span>
            </Link>
            <Link
              href="/withdrawals"
              className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-200 font-bold text-xs transition-all"
            >
              <span>Payouts ({stats.pendingWithdrawals})</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </div>

        <div className="absolute right-0 bottom-0 translate-x-12 translate-y-12 w-64 h-64 rounded-full bg-emerald-500/10 blur-3xl pointer-events-none" />
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        <StatCard
          title="Active Rooms"
          value={stats.activeRooms}
          change="+3"
          iconName="Mic"
          color="emerald"
        />
        <StatCard
          title="Total Users"
          value={stats.totalUsers.toLocaleString()}
          change="+12%"
          iconName="Users"
          color="cyan"
        />
        <StatCard
          title="24h Coins"
          value={formatCoins(stats.dailyCoinVolume)}
          change="+8%"
          iconName="Coins"
          color="gold"
        />
        <StatCard
          title="Reserves"
          value={formatGems(stats.gemReserves)}
          iconName="Gem"
          color="purple"
        />
        <StatCard
          title="Ad Revenue"
          value={formatUSD(stats.adRevenueToday)}
          change="+24%"
          iconName="Tv"
          color="emerald"
        />
        <StatCard
          title="Payouts"
          value={stats.pendingWithdrawals}
          isPositive={false}
          iconName="DollarSign"
          color="gold"
        />
      </div>

      {/* Two Column Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Active Audio Rooms Live Preview */}
        <div className="lg:col-span-2 rounded-2xl glass-panel p-5 border border-[#1C3830]">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              <Mic className="w-4 h-4 text-emerald-400" />
              <span>Live Rooms</span>
            </h3>
            <Link
              href="/rooms"
              className="text-xs font-bold text-emerald-400 hover:text-emerald-300 flex items-center gap-1"
            >
              <span>View All</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

          <div className="space-y-2.5">
            {[
              {
                id: 'room-1',
                title: "Sadia's Royal Music",
                host: 'Sadia Islam',
                category: 'Lucky Race',
                flag: '🇧🇩',
                online: 28,
                mics: '7/8',
              },
              {
                id: 'room-2',
                title: 'Dubai PK Battle',
                host: 'Ahmad Sheikh',
                category: 'PK',
                flag: '🇦🇪',
                online: 46,
                mics: '8/8',
              },
              {
                id: 'room-3',
                title: 'Chatroom & Singing',
                host: 'Farzana Mimi',
                category: 'Chatroom',
                flag: '🇧🇩',
                online: 19,
                mics: '5/8',
              },
              {
                id: 'room-4',
                title: 'Jackpot 777 Arena',
                host: 'King Hunter',
                category: 'Lucky Number',
                flag: '🇵🇰',
                online: 34,
                mics: '8/8',
              },
            ].map((room) => (
              <div
                key={room.id}
                className="flex items-center justify-between p-3 rounded-xl bg-white/5 border border-white/5 hover:border-emerald-500/30 transition-all"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-emerald-600/30 flex items-center justify-center text-sm">
                    🎙️
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-white flex items-center gap-1">
                      <span>{room.title}</span>
                      <span className="text-xs">{room.flag}</span>
                    </h4>
                    <p className="text-[11px] text-slate-400">
                      {room.host} · <span className="text-amber-400">{room.category}</span>
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <div className="text-right">
                    <span className="text-xs font-bold text-emerald-400">{room.online} online</span>
                    <span className="text-[10px] text-slate-500 block">{room.mics} mics</span>
                  </div>
                  <Link
                    href="/rooms"
                    className="p-1 rounded-lg bg-white/10 hover:bg-emerald-500/20 text-slate-300 hover:text-emerald-300 transition-colors"
                  >
                    <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Ad Placements Status */}
        <div className="rounded-2xl glass-panel p-5 border border-[#1C3830] flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                <Tv className="w-4 h-4 text-amber-400" />
                <span>Ad Networks</span>
              </h3>
              <Badge variant="emerald">Live</Badge>
            </div>

            <div className="space-y-2.5">
              <div className="p-3 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
                <div>
                  <p className="text-xs font-bold text-white">Google AdMob</p>
                  <p className="text-[10px] text-slate-400">Banner & Interstitial</p>
                </div>
                <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
              </div>

              <div className="p-3 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
                <div>
                  <p className="text-xs font-bold text-white">Unity Ads</p>
                  <p className="text-[10px] text-slate-400">Rewarded Video</p>
                </div>
                <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
              </div>

              <div className="p-3 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
                <div>
                  <p className="text-xs font-bold text-white">In-House Campaigns</p>
                  <p className="text-[10px] text-slate-400">Banners & Promos</p>
                </div>
                <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
              </div>
            </div>

            <div className="mt-5 pt-4 border-t border-[#1C3830]">
              <div className="flex items-center justify-between text-xs text-slate-300 mb-1">
                <span>Fill Rate</span>
                <span className="font-bold text-emerald-400">98.4%</span>
              </div>
              <div className="w-full h-1.5 rounded-full bg-white/10 overflow-hidden">
                <div className="h-full bg-gradient-to-r from-emerald-500 to-teal-400 w-[98.4%]" />
              </div>
            </div>
          </div>

          <Link
            href="/ads"
            className="mt-5 w-full py-2 rounded-xl bg-white/10 hover:bg-white/15 text-center text-xs font-bold text-white transition-colors block"
          >
            Manage Ads →
          </Link>
        </div>
      </div>
    </div>
  );
}
