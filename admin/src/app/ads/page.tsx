'use client';

import React, { useState, useEffect } from 'react';
import { Badge } from '../../shared/components/ui/Badge';
import { Switch } from '../../shared/components/ui/Switch';
import { Modal } from '../../shared/components/ui/Modal';
import { ImageDropzone } from '../../shared/components/ui/ImageDropzone';
import { supabase } from '../../shared/lib/supabase';
import { formatUSD } from '../../shared/lib/utils';
import {
  Tv,
  PlusCircle,
  DollarSign,
  TrendingUp,
  MousePointerClick,
  Eye,
  Sparkles,
  Layers,
  Coins,
  Clock,
  Trash2,
  CheckCircle2,
  PlayCircle,
} from 'lucide-react';

interface RewardedAdItem {
  id: string;
  title: string;
  network: string;
  description: string;
  imageUrl: string;
  targetUrl: string;
  rewardCoins: number;
  durationSeconds: number;
  isEnabled: boolean;
}

interface AdPlacement {
  id: string;
  name: string;
  type: 'Banner' | 'Interstitial' | 'Rewarded Video' | 'App Open';
  location: string;
  network: string;
  enabled: boolean;
  frequency: string;
  dailyImpressions: number;
  ecpm: number;
  revenue: number;
}

interface InHouseCampaign {
  id: string;
  title: string;
  imageUrl: string;
  targetUrl: string;
  placement: string;
  targetCountry: string;
  targetImpressions: number;
  currentImpressions: number;
  clicks: number;
  status: 'Active' | 'Paused' | 'Completed';
  startDate: string;
}

export default function AdsManagementPage() {
  // 1. Live Game Rewarded Ads Control (synced to app via /api/ads-config + Supabase)
  const [adsEnabled, setAdsEnabled] = useState(true);
  const [rewardedAds, setRewardedAds] = useState<RewardedAdItem[]>([]);
  const [isSyncing, setIsSyncing] = useState(false);
  const [syncNotice, setSyncNotice] = useState<string | null>(null);
  const [isRewardedModalOpen, setIsRewardedModalOpen] = useState(false);
  const [newRewardedAd, setNewRewardedAd] = useState({
    title: '',
    network: 'Google AdMob',
    description: 'Watch this short sponsored video to refill your game coins.',
    imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
    targetUrl: 'https://admob.google.com',
    rewardCoins: 500,
    durationSeconds: 5,
  });

  useEffect(() => {
    async function loadRewardedConfig() {
      try {
        const res = await fetch('/api/ads-config', { cache: 'no-store' });
        if (res.ok) {
          const data = await res.json();
          setAdsEnabled(Boolean(data.adsEnabled ?? true));
          if (Array.isArray(data.rewardedAds)) {
            setRewardedAds(data.rewardedAds);
          }
        }
      } catch (err) {
        console.error('Failed to load ads config:', err);
      }
    }
    loadRewardedConfig();
  }, []);

  async function saveRewardedConfig(nextEnabled: boolean, nextAds: RewardedAdItem[]) {
    setIsSyncing(true);
    setAdsEnabled(nextEnabled);
    setRewardedAds(nextAds);
    const payload = {
      adsEnabled: nextEnabled,
      rewardedAds: nextAds,
      updatedAt: new Date().toISOString(),
    };

    try {
      await fetch('/api/ads-config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      // Best-effort sync to Supabase as well
      try {
        await supabase.from('system_messages').insert({
          title: 'rewarded_ad_config',
          content: JSON.stringify(payload),
          type: 'rewarded_ad_config',
        });
      } catch {
        // Offline / fallback handled gracefully
      }

      setSyncNotice('Saved & Synced Live to App!');
      setTimeout(() => setSyncNotice(null), 2500);
    } catch (err) {
      console.error('Failed to persist ads config:', err);
    } finally {
      setIsSyncing(false);
    }
  }

  function handleToggleMasterAds(checked: boolean) {
    saveRewardedConfig(checked, rewardedAds);
  }

  function handleToggleRewardedAd(id: string, checked: boolean) {
    const updated = rewardedAds.map((ad) =>
      ad.id === id ? { ...ad, isEnabled: checked } : ad
    );
    saveRewardedConfig(adsEnabled, updated);
  }

  function handleRewardCoinsChange(id: string, coins: number) {
    const updated = rewardedAds.map((ad) =>
      ad.id === id ? { ...ad, rewardCoins: Math.max(50, coins) } : ad
    );
    saveRewardedConfig(adsEnabled, updated);
  }

  function handleDurationChange(id: string, sec: number) {
    const updated = rewardedAds.map((ad) =>
      ad.id === id ? { ...ad, durationSeconds: Math.max(3, Math.min(60, sec)) } : ad
    );
    saveRewardedConfig(adsEnabled, updated);
  }

  function handleDeleteRewardedAd(id: string) {
    const updated = rewardedAds.filter((ad) => ad.id !== id);
    saveRewardedConfig(adsEnabled, updated);
  }

  function handleCreateRewardedAd(e: React.FormEvent) {
    e.preventDefault();
    if (!newRewardedAd.title.trim()) return;

    const created: RewardedAdItem = {
      id: `ad_${Date.now()}`,
      title: newRewardedAd.title.trim(),
      network: newRewardedAd.network,
      description: newRewardedAd.description.trim(),
      imageUrl:
        newRewardedAd.imageUrl.trim() ||
        'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
      targetUrl: newRewardedAd.targetUrl.trim() || 'https://admob.google.com',
      rewardCoins: Number(newRewardedAd.rewardCoins) || 500,
      durationSeconds: Number(newRewardedAd.durationSeconds) || 5,
      isEnabled: true,
    };

    const nextList = [created, ...rewardedAds];
    saveRewardedConfig(adsEnabled, nextList);
    setIsRewardedModalOpen(false);
    setNewRewardedAd({
      title: '',
      network: 'Google AdMob',
      description: 'Watch this short sponsored video to refill your game coins.',
      imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
      targetUrl: 'https://admob.google.com',
      rewardCoins: 500,
      durationSeconds: 5,
    });
  }

  // Legacy placements & campaigns state
  const [placements, setPlacements] = useState<AdPlacement[]>([
    {
      id: 'place_1',
      name: 'Party Tab Top Banner',
      type: 'Banner',
      location: 'PartyTabPage Top Bar',
      network: 'Google AdMob',
      enabled: true,
      frequency: 'Auto 30s',
      dailyImpressions: 48200,
      ecpm: 1.45,
      revenue: 69.89,
    },
    {
      id: 'place_2',
      name: 'Room Entrance Interstitial',
      type: 'Interstitial',
      location: 'Audio Room Entry',
      network: 'Google AdMob',
      enabled: true,
      frequency: 'Every 3 entries',
      dailyImpressions: 26400,
      ecpm: 4.8,
      revenue: 126.72,
    },
    {
      id: 'place_3',
      name: 'Bucket Spin Low-Coin Rewarded Video',
      type: 'Rewarded Video',
      location: 'Games Tab (Out of Coins)',
      network: 'Google AdMob / Unity Ads',
      enabled: true,
      frequency: 'On zero/low coins',
      dailyImpressions: 14200,
      ecpm: 8.5,
      revenue: 120.7,
    },
  ]);

  const [campaigns, setCampaigns] = useState<InHouseCampaign[]>([
    {
      id: 'camp_1',
      title: 'Host Recruitment 2026',
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500',
      targetUrl: 'app://host_recruitment',
      placement: 'Party Carousel',
      targetCountry: 'Bangladesh',
      targetImpressions: 100000,
      currentImpressions: 74200,
      clicks: 4820,
      status: 'Active',
      startDate: '2026-10-25',
    },
    {
      id: 'camp_2',
      title: 'VIP Championship - $10,000 Pool',
      imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=500',
      targetUrl: 'app://leaderboard?tab=1',
      placement: 'Room Banner',
      targetCountry: 'Global',
      targetImpressions: 50000,
      currentImpressions: 42100,
      clicks: 2980,
      status: 'Active',
      startDate: '2026-10-26',
    },
  ]);

  const [isCampaignModalOpen, setIsCampaignModalOpen] = useState(false);
  const [newCampaign, setNewCampaign] = useState({
    title: '',
    imageUrl: '',
    targetUrl: '',
    placement: 'Party Carousel',
    targetCountry: 'Global',
    targetImpressions: 50000,
  });

  function togglePlacement(id: string, checked: boolean) {
    setPlacements((prev) =>
      prev.map((p) => (p.id === id ? { ...p, enabled: checked } : p))
    );
  }

  function toggleCampaignStatus(id: string) {
    setCampaigns((prev) =>
      prev.map((c) => {
        if (c.id !== id) return c;
        const nextStatus = c.status === 'Active' ? 'Paused' : 'Active';
        return { ...c, status: nextStatus };
      })
    );
  }

  function handleCreateCampaign(e: React.FormEvent) {
    e.preventDefault();
    if (!newCampaign.title || !newCampaign.imageUrl) return;

    const created: InHouseCampaign = {
      id: `camp_${Date.now()}`,
      title: newCampaign.title,
      imageUrl: newCampaign.imageUrl,
      targetUrl: newCampaign.targetUrl || 'app://home',
      placement: newCampaign.placement,
      targetCountry: newCampaign.targetCountry,
      targetImpressions: newCampaign.targetImpressions,
      currentImpressions: 0,
      clicks: 0,
      status: 'Active',
      startDate: new Date().toISOString().substring(0, 10),
    };

    setCampaigns([created, ...campaigns]);
    setIsCampaignModalOpen(false);
    setNewCampaign({
      title: '',
      imageUrl: '',
      targetUrl: '',
      placement: 'Party Carousel',
      targetCountry: 'Global',
      targetImpressions: 50000,
    });
  }

  const totalAdRevenue = placements.reduce((sum, p) => sum + p.revenue, 0);
  const totalImpressions = placements.reduce((sum, p) => sum + p.dailyImpressions, 0);
  const activeRewardedCount = rewardedAds.filter((a) => a.isEnabled).length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
            <Tv className="w-6 h-6 text-amber-400" />
            <span>Ads Control Center</span>
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">
            Control which rewarded video ads run inside the app when players run out of coins.
          </p>
        </div>

        <div className="flex items-center gap-2">
          {syncNotice && (
            <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-emerald-500/20 border border-emerald-500/40 text-emerald-300 text-xs font-bold">
              <CheckCircle2 className="w-3.5 h-3.5" />
              <span>{syncNotice}</span>
            </span>
          )}
          <button
            onClick={() => setIsRewardedModalOpen(true)}
            className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 font-black text-xs transition-all shadow-md"
          >
            <PlusCircle className="w-4 h-4" />
            <span>Add Rewarded Ad</span>
          </button>
        </div>
      </div>

      {/* GAME REWARDED ADS LIVE CONTROLLER (User Requested Feature) */}
      <div className="rounded-2xl glass-panel p-5 border border-amber-500/35 bg-amber-500/[0.03] space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-white/10">
          <div>
            <h3 className="text-base font-black text-white flex items-center gap-2">
              <PlayCircle className="w-5 h-5 text-amber-400" />
              <span>Game Coin-Refill Rewarded Ads (Live App Control)</span>
            </h3>
            <p className="text-xs text-slate-400 mt-0.5">
              Only ads toggled ON below will play when players click &ldquo;Watch Ad&rdquo; after running out of coins.
            </p>
          </div>

          <div className="flex items-center gap-3 bg-black/40 px-4 py-2 rounded-xl border border-white/10">
            <div>
              <p className="text-xs font-bold text-white">
                {adsEnabled ? 'Rewarded Ads Active' : 'Rewarded Ads Paused'}
              </p>
              <span className="text-[10px] text-emerald-400">
                {activeRewardedCount} active ad{activeRewardedCount === 1 ? '' : 's'} running
                {isSyncing ? ' · Syncing...' : ''}
              </span>
            </div>
            <Switch checked={adsEnabled} onChange={handleToggleMasterAds} />
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3.5">
          {rewardedAds.map((ad) => (
            <div
              key={ad.id}
              className={`p-4 rounded-xl border transition-all ${
                ad.isEnabled && adsEnabled
                  ? 'bg-emerald-500/[0.07] border-emerald-500/40'
                  : 'bg-white/[0.03] border-white/10 opacity-75'
              }`}
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-14 h-12 rounded-lg overflow-hidden border border-white/15 bg-black/40 flex-shrink-0">
                    <img
                      src={ad.imageUrl}
                      alt={ad.title}
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <h4 className="text-sm font-bold text-white">{ad.title}</h4>
                      <Badge variant={ad.isEnabled ? 'emerald' : 'slate'}>
                        {ad.network}
                      </Badge>
                    </div>
                    <p className="text-[11px] text-slate-400 line-clamp-1 mt-0.5">
                      {ad.description}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <Switch
                    checked={ad.isEnabled}
                    onChange={(checked) => handleToggleRewardedAd(ad.id, checked)}
                  />
                  <button
                    onClick={() => handleDeleteRewardedAd(ad.id)}
                    title="Delete Ad"
                    className="p-1.5 rounded-lg text-rose-400 hover:bg-rose-500/20 transition-colors"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>

              <div className="mt-3 pt-3 border-t border-white/10 grid grid-cols-2 gap-3">
                <div>
                  <label className="text-[10px] font-bold text-slate-400 uppercase flex items-center gap-1 mb-1">
                    <Coins className="w-3 h-3 text-amber-400" />
                    <span>Reward Coins</span>
                  </label>
                  <input
                    type="number"
                    min={50}
                    step={50}
                    value={ad.rewardCoins}
                    onChange={(e) =>
                      handleRewardCoinsChange(ad.id, parseInt(e.target.value) || 100)
                    }
                    className="w-full px-2.5 py-1.5 rounded-lg bg-black/50 border border-white/10 text-xs font-bold text-amber-400 focus:outline-none focus:border-amber-400"
                  />
                </div>
                <div>
                  <label className="text-[10px] font-bold text-slate-400 uppercase flex items-center gap-1 mb-1">
                    <Clock className="w-3 h-3 text-cyan-400" />
                    <span>Duration (Sec)</span>
                  </label>
                  <input
                    type="number"
                    min={3}
                    max={60}
                    value={ad.durationSeconds}
                    onChange={(e) =>
                      handleDurationChange(ad.id, parseInt(e.target.value) || 5)
                    }
                    className="w-full px-2.5 py-1.5 rounded-lg bg-black/50 border border-white/10 text-xs font-bold text-cyan-400 focus:outline-none focus:border-cyan-400"
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="rounded-2xl glass-panel p-4 border border-amber-500/20">
          <div className="flex items-center justify-between mb-1">
            <span className="text-xs font-bold text-slate-400 uppercase">24h Revenue</span>
            <DollarSign className="w-4 h-4 text-amber-400" />
          </div>
          <p className="text-xl font-black text-white">{formatUSD(totalAdRevenue)}</p>
        </div>

        <div className="rounded-2xl glass-panel p-4 border border-emerald-500/20">
          <div className="flex items-center justify-between mb-1">
            <span className="text-xs font-bold text-slate-400 uppercase">Impressions</span>
            <Eye className="w-4 h-4 text-emerald-400" />
          </div>
          <p className="text-xl font-black text-white">{totalImpressions.toLocaleString()}</p>
        </div>

        <div className="rounded-2xl glass-panel p-4 border border-cyan-500/20">
          <div className="flex items-center justify-between mb-1">
            <span className="text-xs font-bold text-slate-400 uppercase">Active Game Ads</span>
            <TrendingUp className="w-4 h-4 text-cyan-400" />
          </div>
          <p className="text-xl font-black text-white">{activeRewardedCount}</p>
        </div>
      </div>

      {/* Placements Table */}
      <div className="rounded-2xl glass-panel p-5 border border-[#1C3830]">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-bold text-white flex items-center gap-2">
            <Layers className="w-4 h-4 text-emerald-400" />
            <span>Placements</span>
          </h3>
          <span className="text-xs text-slate-500 font-mono">{placements.length} Total</span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-[#0A1814] text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-[#1C3830]">
              <tr>
                <th className="py-3 px-4">Placement</th>
                <th className="py-3 px-4">Type</th>
                <th className="py-3 px-4">Network</th>
                <th className="py-3 px-4">Frequency</th>
                <th className="py-3 px-4">Impressions</th>
                <th className="py-3 px-4">Revenue</th>
                <th className="py-3 px-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#1C3830] text-slate-300">
              {placements.map((p) => (
                <tr key={p.id} className="hover:bg-white/[0.02] transition-colors">
                  <td className="py-3 px-4">
                    <p className="font-bold text-white text-xs">{p.name}</p>
                    <p className="text-[10px] text-slate-500">{p.location}</p>
                  </td>
                  <td className="py-3 px-4">
                    <Badge variant={p.type === 'Rewarded Video' ? 'amber' : p.type === 'Interstitial' ? 'purple' : 'emerald'}>
                      {p.type}
                    </Badge>
                  </td>
                  <td className="py-3 px-4 font-semibold text-slate-300">{p.network}</td>
                  <td className="py-3 px-4 text-slate-400">{p.frequency}</td>
                  <td className="py-3 px-4 font-bold text-white">{p.dailyImpressions.toLocaleString()}</td>
                  <td className="py-3 px-4 font-bold text-emerald-400">{formatUSD(p.revenue)}</td>
                  <td className="py-3 px-4 text-right">
                    <Switch
                      checked={p.enabled}
                      onChange={(checked) => togglePlacement(p.id, checked)}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* In-House Campaigns */}
      <div className="rounded-2xl glass-panel p-5 border border-[#1C3830]">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-bold text-white flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-amber-400" />
            <span>In-House Campaigns</span>
          </h3>
          <button
            onClick={() => setIsCampaignModalOpen(true)}
            className="text-xs font-bold text-amber-400 hover:text-amber-300"
          >
            + Create
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {campaigns.map((camp) => {
            const progress = Math.min(100, Math.round((camp.currentImpressions / camp.targetImpressions) * 100));

            return (
              <div
                key={camp.id}
                className="p-3.5 rounded-xl bg-white/5 border border-white/5 flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <div className="flex items-center gap-2.5">
                      <div className="w-12 h-9 rounded-lg overflow-hidden border border-white/10 flex-shrink-0">
                        <img src={camp.imageUrl} alt={camp.title} className="w-full h-full object-cover" />
                      </div>
                      <div>
                        <h4 className="text-xs font-bold text-white line-clamp-1">{camp.title}</h4>
                        <p className="text-[10px] text-slate-400">
                          {camp.targetCountry} · {camp.placement}
                        </p>
                      </div>
                    </div>
                    <Badge variant={camp.status === 'Active' ? 'emerald' : 'slate'}>{camp.status}</Badge>
                  </div>

                  <div className="mt-2">
                    <div className="flex items-center justify-between text-[10px] text-slate-400 mb-1">
                      <span>{camp.currentImpressions.toLocaleString()} imp</span>
                      <span className="font-bold text-amber-400">{progress}%</span>
                    </div>
                    <div className="w-full h-1 rounded-full bg-white/10 overflow-hidden">
                      <div className="h-full bg-gradient-to-r from-amber-500 to-emerald-400" style={{ width: `${progress}%` }} />
                    </div>
                  </div>
                </div>

                <div className="mt-3 pt-2.5 border-t border-white/5 flex items-center justify-between text-xs">
                  <span className="text-slate-400 text-[11px] flex items-center gap-1">
                    <MousePointerClick className="w-3 h-3 text-emerald-400" />
                    <strong className="text-white">{camp.clicks.toLocaleString()}</strong> clicks
                  </span>

                  <button
                    onClick={() => toggleCampaignStatus(camp.id)}
                    className="px-2 py-0.5 rounded-lg bg-white/10 hover:bg-white/15 text-[11px] font-bold text-slate-300 transition-colors"
                  >
                    {camp.status === 'Active' ? 'Pause' : 'Resume'}
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Add Rewarded Ad Modal */}
      <Modal
        isOpen={isRewardedModalOpen}
        onClose={() => setIsRewardedModalOpen(false)}
        title="Add New Rewarded Game Ad"
      >
        <form onSubmit={handleCreateRewardedAd} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Ad Title</label>
            <input
              type="text"
              required
              value={newRewardedAd.title}
              onChange={(e) => setNewRewardedAd({ ...newRewardedAd, title: e.target.value })}
              placeholder="e.g. Royal Sponsor Bonus Video"
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-amber-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Ad Network</label>
              <select
                value={newRewardedAd.network}
                onChange={(e) => setNewRewardedAd({ ...newRewardedAd, network: e.target.value })}
                className="w-full px-3 py-2.5 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-amber-500"
              >
                <option value="Google AdMob">Google AdMob</option>
                <option value="Unity Ads">Unity Ads</option>
                <option value="AppLovin MAX">AppLovin MAX</option>
                <option value="Facebook Audience">Facebook Audience</option>
                <option value="In-House Sponsor">In-House Sponsor</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Reward Coins</label>
              <input
                type="number"
                min={50}
                step={50}
                value={newRewardedAd.rewardCoins}
                onChange={(e) =>
                  setNewRewardedAd({ ...newRewardedAd, rewardCoins: parseInt(e.target.value) || 500 })
                }
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-amber-400 font-bold focus:outline-none focus:border-amber-500"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Duration (Seconds)</label>
              <input
                type="number"
                min={3}
                max={60}
                value={newRewardedAd.durationSeconds}
                onChange={(e) =>
                  setNewRewardedAd({
                    ...newRewardedAd,
                    durationSeconds: parseInt(e.target.value) || 5,
                  })
                }
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-cyan-400 font-bold focus:outline-none focus:border-amber-500"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Banner Image URL</label>
              <input
                type="text"
                value={newRewardedAd.imageUrl}
                onChange={(e) => setNewRewardedAd({ ...newRewardedAd, imageUrl: e.target.value })}
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-amber-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Description</label>
            <input
              type="text"
              value={newRewardedAd.description}
              onChange={(e) => setNewRewardedAd({ ...newRewardedAd, description: e.target.value })}
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-amber-500"
            />
          </div>

          <div className="pt-2 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setIsRewardedModalOpen(false)}
              className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-950 font-black text-xs transition-colors"
            >
              Add & Activate Ad
            </button>
          </div>
        </form>
      </Modal>

      {/* In-House Campaign Modal */}
      <Modal
        isOpen={isCampaignModalOpen}
        onClose={() => setIsCampaignModalOpen(false)}
        title="New In-House Campaign"
      >
        <form onSubmit={handleCreateCampaign} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Title</label>
            <input
              type="text"
              required
              value={newCampaign.title}
              onChange={(e) => setNewCampaign({ ...newCampaign, title: e.target.value })}
              placeholder="Campaign Title"
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-amber-500"
            />
          </div>

          <ImageDropzone
            label="Banner Image"
            value={newCampaign.imageUrl}
            onChange={(val) => setNewCampaign({ ...newCampaign, imageUrl: val })}
            aspectRatioClass="aspect-[16/7]"
            maxSizeMB={10}
          />

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Action Link</label>
            <input
              type="text"
              value={newCampaign.targetUrl}
              onChange={(e) => setNewCampaign({ ...newCampaign, targetUrl: e.target.value })}
              placeholder="app://host_recruitment"
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-amber-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Placement</label>
              <select
                value={newCampaign.placement}
                onChange={(e) => setNewCampaign({ ...newCampaign, placement: e.target.value })}
                className="w-full px-3 py-2.5 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-amber-500"
              >
                <option value="Party Carousel">Party Carousel</option>
                <option value="Room Banner">Room Banner</option>
                <option value="Leaderboard Header">Leaderboard Header</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Target Country</label>
              <select
                value={newCampaign.targetCountry}
                onChange={(e) => setNewCampaign({ ...newCampaign, targetCountry: e.target.value })}
                className="w-full px-3 py-2.5 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-amber-500"
              >
                <option value="Global">Global</option>
                <option value="Bangladesh">Bangladesh</option>
                <option value="Pakistan">Pakistan</option>
                <option value="Saudi Arabia">Saudi Arabia</option>
              </select>
            </div>
          </div>

          <div className="pt-2 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setIsCampaignModalOpen(false)}
              className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-950 font-black text-xs transition-colors"
            >
              Start
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
