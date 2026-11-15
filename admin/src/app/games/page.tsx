'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { Badge } from '../../shared/components/ui/Badge';
import { Switch } from '../../shared/components/ui/Switch';
import { supabase } from '../../shared/lib/supabase';
import { formatCoins } from '../../shared/lib/utils';
import {
  Gamepad2,
  ShieldAlert,
  TrendingUp,
  Coins,
  Percent,
  Clock,
  Save,
  RotateCcw,
  Tv,
  CheckCircle2,
  Sparkles,
} from 'lucide-react';

interface OutcomeFieldMeta {
  key: string;
  label: string;
  unit: string;
  accent: string;
  step: number;
  min: number;
}

interface GameControlConfig {
  id: string;
  name: string;
  description: string;
  isActive: boolean;
  minBet: number;
  maxBet: number;
  rtp: number;
  roundSeconds: number;
  betLockSeconds: number;
  multipliers: Record<string, number>;
}

interface GameUiMeta {
  icon: string;
  totalWageredToday: number;
  houseProfitToday: number;
  activePlayers: number;
  showBucketBulkSet?: boolean;
  fields: OutcomeFieldMeta[];
}

const GAME_UI_META: Record<string, GameUiMeta> = {
  game_bucket_8: {
    icon: '🪣',
    totalWageredToday: 1450000,
    houseProfitToday: 92400,
    activePlayers: 342,
    showBucketBulkSet: true,
    fields: [
      { key: 'apple', label: '🍎 Apple', unit: 'x', accent: 'text-red-400', step: 0.5, min: 1 },
      { key: 'watermelon', label: '🍉 Watermelon', unit: 'x', accent: 'text-emerald-400', step: 0.5, min: 1 },
      { key: 'bell', label: '🔔 Bell', unit: 'x', accent: 'text-amber-300', step: 0.5, min: 1 },
      { key: 'lucky7', label: '7️⃣ Lucky 7', unit: 'x', accent: 'text-orange-400', step: 0.5, min: 1 },
      { key: 'diamond', label: '💎 Diamond', unit: 'x', accent: 'text-cyan-300', step: 0.5, min: 1 },
      { key: 'crown', label: '👑 Crown', unit: 'x', accent: 'text-yellow-300', step: 0.5, min: 1 },
      { key: 'rocket', label: '🚀 Rocket', unit: 'x', accent: 'text-purple-400', step: 0.5, min: 1 },
      { key: 'heart', label: '❤️ Heart', unit: 'x', accent: 'text-pink-400', step: 0.5, min: 1 },
    ],
  },
  game_color_3: {
    icon: '🎨',
    totalWageredToday: 2890000,
    houseProfitToday: 184200,
    activePlayers: 618,
    fields: [
      { key: 'red', label: '🔴 RED Multiplier', unit: 'x', accent: 'text-red-400', step: 0.5, min: 1 },
      { key: 'violet', label: '🟣 VIOLET Multiplier', unit: 'x', accent: 'text-purple-400', step: 0.5, min: 1 },
      { key: 'green', label: '🟢 GREEN Multiplier', unit: 'x', accent: 'text-emerald-400', step: 0.5, min: 1 },
    ],
  },
  game_7up_7down: {
    icon: '🎲',
    totalWageredToday: 1840000,
    houseProfitToday: 147200,
    activePlayers: 410,
    fields: [
      { key: 'up', label: '8 ~ 12 (Up)', unit: 'x', accent: 'text-amber-300', step: 0.5, min: 1 },
      { key: 'seven', label: '7 (Exact 7)', unit: 'x', accent: 'text-yellow-300', step: 0.5, min: 1 },
      { key: 'down', label: '2 ~ 6 (Down)', unit: 'x', accent: 'text-lime-300', step: 0.5, min: 1 },
    ],
  },
  game_balloon_sky: {
    icon: '🎈',
    totalWageredToday: 960000,
    houseProfitToday: 61500,
    activePlayers: 276,
    fields: [
      { key: 'targetScore', label: 'Minimum Target Score to Win', unit: 'pts', accent: 'text-yellow-300', step: 100, min: 200 },
      { key: 'standardBubbleCoins', label: 'White Bubble Coin', unit: 'coins', accent: 'text-sky-300', step: 5, min: 1 },
      { key: 'goldBubbleCoins', label: 'Gold Bubble Coin', unit: 'coins', accent: 'text-amber-300', step: 10, min: 5 },
      { key: 'distanceBonusPer4s', label: 'Distance Bonus / 4s', unit: 'coins', accent: 'text-emerald-300', step: 1, min: 1 },
      { key: 'doubleTargetSeconds', label: '2x Challenge Target', unit: 'sec', accent: 'text-purple-300', step: 5, min: 10 },
      { key: 'doubleStakeMultiplier', label: '2x Challenge Payout', unit: 'x', accent: 'text-rose-300', step: 0.5, min: 1.5 },
      { key: 'speedBoostAfterSeconds', label: 'Speed Boost After', unit: 'sec', accent: 'text-orange-300', step: 5, min: 10 },
    ],
  },
};

const DEFAULT_GAMES: GameControlConfig[] = [
  {
    id: 'game_bucket_8',
    name: 'Bucket Spin (8 Items)',
    description: '8-slot spinning cauldron prediction game (Solo & Group).',
    isActive: true,
    minBet: 100,
    maxBet: 10000,
    rtp: 94,
    roundSeconds: 35,
    betLockSeconds: 30,
    multipliers: { apple: 2, watermelon: 2, bell: 2, lucky7: 2, diamond: 2, crown: 2, rocket: 2, heart: 2 },
  },
  {
    id: 'game_color_3',
    name: 'Color Spin (Red / Violet / Green)',
    description: '3-color cauldron prediction arena with per-color odds control.',
    isActive: true,
    minBet: 100,
    maxBet: 10000,
    rtp: 93,
    roundSeconds: 35,
    betLockSeconds: 30,
    multipliers: { red: 2, violet: 4.5, green: 2 },
  },
  {
    id: 'game_7up_7down',
    name: '7 Up 7 Down (Dice)',
    description: 'Fast 18-second dice prediction board (8~12, 7, 2~6).',
    isActive: true,
    minBet: 100,
    maxBet: 10000,
    rtp: 92,
    roundSeconds: 18,
    betLockSeconds: 15,
    multipliers: { up: 2, seven: 5, down: 2 },
  },
  {
    id: 'game_balloon_sky',
    name: 'Balloon Sky (Arcade)',
    description: 'Solo endless flight with Free Earn coin bubbles and 2x Double Stake mode.',
    isActive: true,
    minBet: 100,
    maxBet: 5000,
    rtp: 95,
    roundSeconds: 40,
    betLockSeconds: 40,
    multipliers: {
      targetScore: 1000,
      standardBubbleCoins: 10,
      goldBubbleCoins: 50,
      distanceBonusPer4s: 5,
      doubleTargetSeconds: 40,
      doubleStakeMultiplier: 2,
      speedBoostAfterSeconds: 40,
    },
  },
];

export default function GamesControlPage() {
  const [games, setGames] = useState<GameControlConfig[]>(DEFAULT_GAMES);
  const [emergencyLockdown, setEmergencyLockdown] = useState(false);
  const [bulkBucketMultiplier, setBulkBucketMultiplier] = useState('2');
  const [isSaving, setIsSaving] = useState(false);
  const [syncMessage, setSyncMessage] = useState<string | null>(null);
  const [lastSyncedAt, setLastSyncedAt] = useState<string | null>(null);

  useEffect(() => {
    async function loadConfig() {
      try {
        const res = await fetch('/api/games-config', { cache: 'no-store' });
        if (!res.ok) return;
        const data = await res.json();
        setEmergencyLockdown(Boolean(data.emergencyLockdown));
        if (Array.isArray(data.games) && data.games.length > 0) {
          setGames(data.games);
        }
        if (typeof data.updatedAt === 'string') {
          setLastSyncedAt(data.updatedAt);
        }
      } catch (err) {
        console.error('Failed to load games config:', err);
      }
    }
    loadConfig();
  }, []);

  async function persistConfig(nextLockdown: boolean, nextGames: GameControlConfig[], notice: string) {
    setIsSaving(true);
    try {
      const res = await fetch('/api/games-config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          emergencyLockdown: nextLockdown,
          games: nextGames,
        }),
      });
      if (res.ok) {
        const saved = await res.json();
        setEmergencyLockdown(Boolean(saved.emergencyLockdown));
        if (Array.isArray(saved.games)) setGames(saved.games);
        setLastSyncedAt(saved.updatedAt ?? new Date().toISOString());
      }
      try {
        await supabase.from('system_messages').insert({
          title: 'games_control_config',
          body: JSON.stringify({ emergencyLockdown: nextLockdown, games: nextGames }),
        });
      } catch {
        // Offline / local mode fallback already succeeded via /api/games-config
      }
      setSyncMessage(notice);
    } catch (err) {
      console.error('Failed to save games config:', err);
      setSyncMessage('Error syncing configuration.');
    } finally {
      setIsSaving(false);
    }
  }

  function updateGameField<K extends keyof GameControlConfig>(
    id: string,
    field: K,
    value: GameControlConfig[K]
  ) {
    setGames((prev) => prev.map((g) => (g.id === id ? { ...g, [field]: value } : g)));
  }

  function updateMultiplier(gameId: string, key: string, rawValue: string) {
    const num = Number(rawValue);
    setGames((prev) =>
      prev.map((g) =>
        g.id === gameId
          ? {
              ...g,
              multipliers: {
                ...g.multipliers,
                [key]: Number.isFinite(num) && num > 0 ? num : 1,
              },
            }
          : g
      )
    );
  }

  function applyBulkBucketMultiplier() {
    const parsed = Number(bulkBucketMultiplier);
    if (!Number.isFinite(parsed) || parsed < 1) return;
    setGames((prev) =>
      prev.map((g) => {
        if (g.id !== 'game_bucket_8') return g;
        const updated: Record<string, number> = {};
        for (const k of Object.keys(g.multipliers)) {
          updated[k] = parsed;
        }
        return { ...g, multipliers: updated };
      })
    );
  }

  const totalWagered = Object.values(GAME_UI_META).reduce((s, m) => s + m.totalWageredToday, 0);
  const totalProfit = Object.values(GAME_UI_META).reduce((s, m) => s + m.houseProfitToday, 0);
  const totalPlayers = Object.values(GAME_UI_META).reduce((s, m) => s + m.activePlayers, 0);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-amber-400 text-xs font-bold uppercase tracking-widest mb-1">
            <Gamepad2 className="w-4 h-4" />
            <span>Games Control Center</span>
          </div>
          <h1 className="text-2xl font-black text-white">All Games, Payout Odds &amp; Bet Limits</h1>
          <p className="text-xs text-slate-400 mt-1">
            Configure exact per-outcome coin multipliers (e.g., Red/Violet/Green, 8~12/7/2~6, Bucket items, Balloon coins), round timers, min/max stakes, and freeze switches synced live to the mobile app.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <Link
            href="/ads"
            className="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl bg-[#0D211B] border border-[#1C3830] hover:border-amber-500/40 text-xs font-bold text-slate-200 transition"
          >
            <Tv className="w-4 h-4 text-amber-400" />
            <span>Rewarded Ads Control</span>
          </Link>

          <button
            onClick={() => persistConfig(false, DEFAULT_GAMES, 'Restored default payouts & synced live!')}
            disabled={isSaving}
            className="inline-flex items-center gap-2 px-3.5 py-2.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs font-bold text-slate-200 transition disabled:opacity-50"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Reset Defaults</span>
          </button>

          <button
            onClick={() => persistConfig(emergencyLockdown, games, 'All game payouts, limits & switches synced live to Flutter app!')}
            disabled={isSaving}
            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 text-xs font-black shadow-lg shadow-emerald-500/20 transition disabled:opacity-50"
          >
            <Save className="w-4 h-4" />
            <span>{isSaving ? 'Syncing...' : 'Save & Sync All Live'}</span>
          </button>
        </div>
      </div>

      {/* Emergency Lockdown + Sync Toast */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 flex items-center justify-between gap-4 px-4 py-3.5 rounded-2xl bg-red-500/10 border border-red-500/30">
          <div className="flex items-center gap-3">
            <ShieldAlert className="w-5 h-5 text-red-400 shrink-0" />
            <div>
              <p className="text-xs font-bold text-red-300 uppercase tracking-wider">Master Emergency Freeze All Games</p>
              <p className="text-[11px] text-slate-400">Immediately locks betting &amp; new rounds across every game in the app.</p>
            </div>
          </div>
          <Switch
            checked={emergencyLockdown}
            onChange={(checked) => {
              const nextGames = games.map((g) => ({ ...g, isActive: !checked }));
              setEmergencyLockdown(checked);
              setGames(nextGames);
              persistConfig(
                checked,
                nextGames,
                checked ? 'Emergency freeze activated across all games!' : 'Emergency freeze lifted — games resumed!'
              );
            }}
          />
        </div>

        <div className="flex items-center justify-between px-4 py-3.5 rounded-2xl bg-[#0D211B] border border-[#1C3830]">
          <div className="flex items-center gap-2.5">
            <CheckCircle2 className={`w-4 h-4 ${syncMessage ? 'text-emerald-400' : 'text-slate-400'}`} />
            <div>
              <p className="text-xs font-bold text-white">{syncMessage ?? 'Live Config Active'}</p>
              <p className="text-[10px] text-slate-400">
                {lastSyncedAt ? `Updated ${new Date(lastSyncedAt).toLocaleTimeString()}` : 'Endpoint: /api/games-config'}
              </p>
            </div>
          </div>
          <Badge variant={emergencyLockdown ? 'rose' : 'emerald'}>
            {emergencyLockdown ? 'FROZEN' : 'LIVE'}
          </Badge>
        </div>
      </div>

      {/* Overview Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-[#0D211B] border border-[#1C3830] rounded-2xl p-4 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
            <Coins className="w-5 h-5" />
          </div>
          <div>
            <p className="text-[11px] text-slate-400 uppercase font-bold">Total Wagered Today</p>
            <p className="text-xl font-black text-white">{formatCoins(totalWagered)} Coins</p>
          </div>
        </div>
        <div className="bg-[#0D211B] border border-[#1C3830] rounded-2xl p-4 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
            <TrendingUp className="w-5 h-5" />
          </div>
          <div>
            <p className="text-[11px] text-slate-400 uppercase font-bold">House Net Profit (Today)</p>
            <p className="text-xl font-black text-emerald-400">+{formatCoins(totalProfit)} Coins</p>
          </div>
        </div>
        <div className="bg-[#0D211B] border border-[#1C3830] rounded-2xl p-4 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400">
            <Gamepad2 className="w-5 h-5" />
          </div>
          <div>
            <p className="text-[11px] text-slate-400 uppercase font-bold">Active Players</p>
            <p className="text-xl font-black text-white">{totalPlayers.toLocaleString()} Playing</p>
          </div>
        </div>
      </div>

      {/* Per-Game Controls */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {games.map((game) => {
          const meta = GAME_UI_META[game.id];
          const isEffectiveActive = !emergencyLockdown && game.isActive;
          const isArcade = game.id === 'game_balloon_sky';

          return (
            <div
              key={game.id}
              className="bg-[#0D211B] border border-[#1C3830] rounded-2xl p-5 flex flex-col justify-between gap-4 hover:border-emerald-500/30 transition"
            >
              {/* Card Header */}
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-3.5">
                  <div className="w-12 h-12 rounded-2xl bg-[#07130F] border border-[#1C3830] flex items-center justify-center text-2xl">
                    {meta?.icon ?? '🎮'}
                  </div>
                  <div>
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="text-base font-black text-white">{game.name}</h3>
                      <Badge variant={isEffectiveActive ? 'emerald' : 'rose'}>
                        {isEffectiveActive ? 'Running' : 'Disabled'}
                      </Badge>
                    </div>
                    <p className="text-xs text-slate-400 mt-0.5">{game.description}</p>
                  </div>
                </div>
                <Switch
                  checked={game.isActive}
                  onChange={(checked) => updateGameField(game.id, 'isActive', checked)}
                />
              </div>

              {/* Stakes, Timing & RTP */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                <label className="p-2.5 rounded-xl bg-[#07130F] border border-[#1C3830] block">
                  <span className="text-[10px] text-slate-400 uppercase font-bold block mb-1">Min Bet</span>
                  <input
                    type="number"
                    min={10}
                    step={50}
                    value={game.minBet}
                    onChange={(e) => updateGameField(game.id, 'minBet', Math.max(10, Number(e.target.value) || 10))}
                    className="w-full bg-transparent text-sm font-black text-white outline-none"
                  />
                </label>

                <label className="p-2.5 rounded-xl bg-[#07130F] border border-[#1C3830] block">
                  <span className="text-[10px] text-slate-400 uppercase font-bold block mb-1">Max Bet</span>
                  <input
                    type="number"
                    min={game.minBet}
                    step={100}
                    value={game.maxBet}
                    onChange={(e) => updateGameField(game.id, 'maxBet', Math.max(game.minBet, Number(e.target.value) || game.minBet))}
                    className="w-full bg-transparent text-sm font-black text-white outline-none"
                  />
                </label>

                <label className="p-2.5 rounded-xl bg-[#07130F] border border-[#1C3830] block">
                  <span className="text-[10px] text-slate-400 uppercase font-bold flex items-center gap-1 mb-1">
                    <Clock className="w-3 h-3 text-cyan-400" />
                    {isArcade ? 'Ref Time (s)' : 'Round (s)'}
                  </span>
                  <input
                    type="number"
                    min={10}
                    max={180}
                    value={game.roundSeconds}
                    onChange={(e) => {
                      const nextRound = Math.max(10, Math.min(180, Number(e.target.value) || 18));
                      setGames((prev) =>
                        prev.map((g) =>
                          g.id === game.id
                            ? {
                                ...g,
                                roundSeconds: nextRound,
                                betLockSeconds: Math.min(g.betLockSeconds, Math.max(5, nextRound - 2)),
                              }
                            : g
                        )
                      );
                    }}
                    className="w-full bg-transparent text-sm font-black text-cyan-300 outline-none"
                  />
                </label>

                <label className="p-2.5 rounded-xl bg-[#07130F] border border-[#1C3830] block">
                  <span className="text-[10px] text-slate-400 uppercase font-bold flex items-center gap-1 mb-1">
                    <Clock className="w-3 h-3 text-amber-400" />
                    {isArcade ? 'Lock / Target' : 'Bet Lock (s)'}
                  </span>
                  <input
                    type="number"
                    min={5}
                    max={game.roundSeconds}
                    value={game.betLockSeconds}
                    onChange={(e) =>
                      updateGameField(
                        game.id,
                        'betLockSeconds',
                        Math.max(5, Math.min(game.roundSeconds, Number(e.target.value) || 15))
                      )
                    }
                    className="w-full bg-transparent text-sm font-black text-amber-300 outline-none"
                  />
                </label>
              </div>

              {/* Outcome Payout Multipliers / Arcade Rewards */}
              <div className="p-3.5 rounded-xl bg-[#07130F] border border-[#1C3830] space-y-2.5">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <div className="flex items-center gap-1.5 text-[11px] font-black text-amber-300 uppercase tracking-wider">
                    <Sparkles className="w-3.5 h-3.5" />
                    <span>
                      {isArcade
                        ? 'Coin Rewards & 2x Challenge Tuning'
                        : 'Win Payout Multipliers (Bet x Multiplier = Coins)'}
                    </span>
                  </div>

                  {meta?.showBucketBulkSet && (
                    <div className="flex items-center gap-1.5">
                      <input
                        type="number"
                        step={0.5}
                        min={1}
                        value={bulkBucketMultiplier}
                        onChange={(e) => setBulkBucketMultiplier(e.target.value)}
                        className="w-14 px-2 py-1 rounded-lg bg-[#0D211B] border border-[#1C3830] text-xs font-bold text-white outline-none"
                      />
                      <button
                        type="button"
                        onClick={applyBulkBucketMultiplier}
                        className="px-2.5 py-1 rounded-lg bg-amber-500/20 hover:bg-amber-500/30 border border-amber-500/40 text-[10px] font-black text-amber-300"
                      >
                        Set All 8
                      </button>
                    </div>
                  )}
                </div>

                <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                  {(meta?.fields ?? []).map((f) => (
                    <label
                      key={f.key}
                      className="flex items-center justify-between gap-2 px-2.5 py-2 rounded-xl bg-[#0D211B] border border-[#1C3830]"
                    >
                      <span className={`text-[11px] font-bold truncate ${f.accent}`}>{f.label}</span>
                      <div className="flex items-center gap-1 shrink-0">
                        <input
                          type="number"
                          step={f.step}
                          min={f.min}
                          value={game.multipliers[f.key] ?? f.min}
                          onChange={(e) => updateMultiplier(game.id, f.key, e.target.value)}
                          className="w-14 text-right bg-transparent text-xs font-black text-white outline-none"
                        />
                        <span className="text-[10px] font-bold text-slate-400">{f.unit}</span>
                      </div>
                    </label>
                  ))}
                </div>
              </div>

              {/* RTP Slider */}
              <div className="p-3 rounded-xl bg-[#07130F] border border-[#1C3830] space-y-1.5">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-1.5 text-xs font-bold text-slate-300">
                    <Percent className="w-3.5 h-3.5 text-emerald-400" />
                    <span>Return to Player (RTP %)</span>
                  </div>
                  <span className="text-sm font-black text-emerald-400">{game.rtp}%</span>
                </div>
                <input
                  type="range"
                  min={60}
                  max={98}
                  value={game.rtp}
                  onChange={(e) => updateGameField(game.id, 'rtp', Number(e.target.value))}
                  className="w-full accent-emerald-500 cursor-pointer h-1.5 bg-[#1C3830] rounded-lg"
                />
                <div className="flex justify-between text-[10px] text-slate-500">
                  <span>High Profit (60%)</span>
                  <span>Balanced (90-95%)</span>
                  <span>Generous (98%)</span>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
