'use client';

import React, { useState } from 'react';
import { Switch } from '../../shared/components/ui/Switch';
import { Badge } from '../../shared/components/ui/Badge';
import { formatCoins, formatUSD } from '../../shared/lib/utils';
import {
  Coins,
  Calendar,
  Gem,
  Save,
  CheckCircle2,
  Gift,
  UserPlus,
  Sparkles,
} from 'lucide-react';

interface DailyRewardDay {
  dayNumber: number;
  label: string;
  coins: number;
  isSpecial: boolean;
}

interface CoinPackage {
  id: string;
  name: string;
  coins: number;
  bonusCoins: number;
  priceUsd: number;
  badge?: string;
  isActive: boolean;
}

export default function EconomyPage() {
  const [dailyDays, setDailyDays] = useState<DailyRewardDay[]>([
    { dayNumber: 1, label: 'Day 1', coins: 2000, isSpecial: false },
    { dayNumber: 2, label: 'Day 2', coins: 2500, isSpecial: false },
    { dayNumber: 3, label: 'Day 3', coins: 3000, isSpecial: false },
    { dayNumber: 4, label: 'Day 4', coins: 3500, isSpecial: false },
    { dayNumber: 5, label: 'Day 5', coins: 4000, isSpecial: false },
    { dayNumber: 6, label: 'Day 6', coins: 4500, isSpecial: false },
    { dayNumber: 7, label: 'Day 7+', coins: 5000, isSpecial: true },
  ]);

  const [enableDoubleRewardAd, setEnableDoubleRewardAd] = useState(true);

  // Promotional Incentives & Referral Multipliers
  const [promoConfig, setPromoConfig] = useState({
    firstRechargeBonusPct: 75,
    referralDiamondReward: 10000,
    newRegistrationCoins: 2000,
    rewardedAdCoins: 500,
  });

  const [exchangeRate, setExchangeRate] = useState(50000);
  const [isSaved, setIsSaved] = useState(false);

  const [packages, setPackages] = useState<CoinPackage[]>([
    {
      id: 'pkg_1',
      name: 'Starter Pile',
      coins: 10000,
      bonusCoins: 1000,
      priceUsd: 0.99,
      badge: 'Popular',
      isActive: true,
    },
    {
      id: 'pkg_2',
      name: 'Special Sack',
      coins: 55000,
      bonusCoins: 10000,
      priceUsd: 4.99,
      badge: '+20%',
      isActive: true,
    },
    {
      id: 'pkg_3',
      name: 'Royal Chest',
      coins: 120000,
      bonusCoins: 30000,
      priceUsd: 9.99,
      badge: 'Best Value',
      isActive: true,
    },
    {
      id: 'pkg_4',
      name: 'Whale Vault',
      coins: 700000,
      bonusCoins: 250000,
      priceUsd: 49.99,
      badge: 'VIP',
      isActive: true,
    },
  ]);

  function handleDayCoinsChange(dayNumber: number, value: number) {
    setDailyDays((prev) =>
      prev.map((d) => (d.dayNumber === dayNumber ? { ...d, coins: value } : d))
    );
  }

  function handleSaveEconomySettings() {
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2500);
  }

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <Coins className="w-6 h-6 text-amber-400" />
          <span>Economy & Rewards</span>
        </h2>

        <button
          onClick={handleSaveEconomySettings}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs transition-all shadow-md"
        >
          {isSaved ? <CheckCircle2 className="w-4 h-4" /> : <Save className="w-4 h-4" />}
          <span>{isSaved ? 'Saved!' : 'Save & Deploy'}</span>
        </button>
      </div>

      {/* Daily Sign-in Reward Configuration */}
      <div className="rounded-2xl glass-panel p-5 border border-[#1C3830]">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-5 pb-3 border-b border-[#1C3830]">
          <h3 className="text-sm font-bold text-white flex items-center gap-2">
            <Calendar className="w-4 h-4 text-emerald-400" />
            <span>Daily Streak Rewards (Day 1 - 7+)</span>
          </h3>

          <Switch
            checked={enableDoubleRewardAd}
            onChange={setEnableDoubleRewardAd}
            label="2x Coins via Video Ad"
          />
        </div>

        {/* 7-Days Cards */}
        <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-2.5">
          {dailyDays.map((day) => (
            <div
              key={day.dayNumber}
              className={`p-3 rounded-xl border text-center transition-all ${
                day.isSpecial
                  ? 'bg-amber-500/10 border-amber-500/40'
                  : 'bg-white/5 border-white/10'
              }`}
            >
              <span
                className={`text-xs font-bold block mb-1 ${
                  day.isSpecial ? 'text-amber-400' : 'text-emerald-400'
                }`}
              >
                {day.label}
              </span>
              <div className="w-7 h-7 rounded-full bg-amber-500/20 mx-auto flex items-center justify-center text-amber-400 text-xs mb-2">
                🪙
              </div>
              <input
                type="number"
                step="500"
                min="500"
                value={day.coins}
                onChange={(e) =>
                  handleDayCoinsChange(day.dayNumber, parseInt(e.target.value) || 0)
                }
                className="w-full text-center px-1.5 py-1 rounded-lg bg-black/50 border border-white/10 text-xs font-bold text-white focus:outline-none focus:border-emerald-500"
              />
            </div>
          ))}
        </div>
      </div>

      {/* Gem Exchange Rate & Packages */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-1 rounded-2xl glass-panel p-5 border border-[#1C3830]">
          <h3 className="text-sm font-bold text-white flex items-center gap-2 mb-4">
            <Gem className="w-4 h-4 text-cyan-400" />
            <span>Gem Exchange Rate</span>
          </h3>

          <div className="space-y-3">
            <div>
              <label className="block text-[11px] font-bold text-slate-400 mb-1">
                Gems Per $1.00 USD
              </label>
              <div className="relative">
                <input
                  type="number"
                  step="1000"
                  value={exchangeRate}
                  onChange={(e) => setExchangeRate(parseInt(e.target.value) || 50000)}
                  className="w-full px-3 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm font-bold text-cyan-300 focus:outline-none"
                />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-500 font-bold">
                  = $1.00
                </span>
              </div>
            </div>

            <p className="text-xs text-slate-400">
              1,000,000 Diamonds = <strong className="text-emerald-400">$20.00</strong>
            </p>
          </div>
        </div>

        {/* Coin Store Packages */}
        <div className="md:col-span-2 rounded-2xl glass-panel p-5 border border-[#1C3830]">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              <Coins className="w-4 h-4 text-amber-400" />
              <span>Coin Packages</span>
            </h3>
            <span className="text-xs text-slate-500 font-mono">{packages.length} Total</span>
          </div>

          <div className="space-y-2">
            {packages.map((pkg) => (
              <div
                key={pkg.id}
                className="flex items-center justify-between p-3 rounded-xl bg-white/5 border border-white/5 hover:border-amber-500/30 transition-all"
              >
                <div className="flex items-center gap-2.5">
                  <div className="w-8 h-8 rounded-lg bg-amber-600/30 flex items-center justify-center text-sm">
                    🪙
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-white flex items-center gap-2">
                      <span>{pkg.name}</span>
                      {pkg.badge && <Badge variant="amber">{pkg.badge}</Badge>}
                    </h4>
                    <p className="text-[11px] text-slate-400">
                      {formatCoins(pkg.coins)} + <span className="text-emerald-400 font-bold">+{formatCoins(pkg.bonusCoins)}</span>
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <span className="text-xs font-black text-amber-400">{formatUSD(pkg.priceUsd)}</span>
                  <Switch
                    checked={pkg.isActive}
                    onChange={(checked) =>
                      setPackages((prev) =>
                        prev.map((p) => (p.id === pkg.id ? { ...p, isActive: checked } : p))
                      )
                    }
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
