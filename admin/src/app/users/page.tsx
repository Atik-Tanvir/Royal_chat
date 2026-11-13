'use client';

import React, { useState, useEffect } from 'react';
import { supabase, ProfileRecord } from '../../shared/lib/supabase';
import { formatCoins, formatGems } from '../../shared/lib/utils';
import { Badge } from '../../shared/components/ui/Badge';
import { Modal } from '../../shared/components/ui/Modal';
import {
  Users,
  Search,
  ShieldAlert,
  ShieldCheck,
  Crown,
  Coins,
  Gem,
  PlusCircle,
  MinusCircle,
  Check,
  X,
  FileText,
  Clock,
  AlertTriangle,
  Flag,
  MicOff,
  AlertOctagon,
  UserX,
  MessageSquare,
  Shield,
} from 'lucide-react';

interface BanAppeal {
  id: string;
  userId: string;
  nickname: string;
  avatarUrl: string;
  country: string;
  countryFlag: string;
  level: number;
  banReason: string;
  bannedAt: string;
  appealReason: string;
  pledgeText: string;
  submittedAt: string;
  status: 'Pending' | 'Approved' | 'Rejected';
  adminDecisionNote?: string;
}

const mockProfiles: ProfileRecord[] = [
  {
    id: 'user_1001',
    nickname: 'Tania Ahmed',
    avatar_url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    country: 'Bangladesh',
    country_flag: '🇧🇩',
    gender: '♀ 21',
    age: 21,
    level: 3,
    is_vip: true,
    is_banned: false,
    coin_balance: 450000,
    gem_balance: 120000,
    friends_count: 85,
    following_count: 42,
    fans_count: 320,
    is_online: true,
    created_at: new Date().toISOString(),
  },
  {
    id: 'user_1002',
    nickname: 'Killer Prince',
    avatar_url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    country: 'Pakistan',
    country_flag: '🇵🇰',
    gender: '♂ 24',
    age: 24,
    level: 8,
    is_vip: true,
    is_banned: false,
    coin_balance: 2850000,
    gem_balance: 480000,
    friends_count: 210,
    following_count: 110,
    fans_count: 1420,
    is_online: true,
    created_at: new Date().toISOString(),
  },
  {
    id: 'user_1003',
    nickname: 'Nusrat Jahan',
    avatar_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    country: 'Bangladesh',
    country_flag: '🇧🇩',
    gender: '♀ 19',
    age: 19,
    level: 4,
    is_vip: false,
    is_banned: false,
    coin_balance: 18500,
    gem_balance: 85000,
    friends_count: 64,
    following_count: 18,
    fans_count: 190,
    is_online: false,
    created_at: new Date().toISOString(),
  },
  {
    id: 'user_1004',
    nickname: 'Rohan_Spammer',
    avatar_url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    country: 'India',
    country_flag: '🇮🇳',
    gender: '♂ 22',
    age: 22,
    level: 2,
    is_vip: false,
    is_banned: true,
    coin_balance: 200,
    gem_balance: 0,
    friends_count: 2,
    following_count: 0,
    fans_count: 5,
    is_online: false,
    created_at: new Date().toISOString(),
  },
  {
    id: 'user_1005',
    nickname: 'Bad_Actor_007',
    avatar_url: '',
    country: 'Saudi Arabia',
    country_flag: '🇸🇦',
    gender: '♂ 28',
    age: 28,
    level: 1,
    is_vip: false,
    is_banned: true,
    coin_balance: 0,
    gem_balance: 0,
    friends_count: 0,
    following_count: 0,
    fans_count: 0,
    is_online: false,
    created_at: new Date().toISOString(),
  },
];

const initialAppeals: BanAppeal[] = [
  {
    id: 'appeal_01',
    userId: 'user_1004',
    nickname: 'Rohan_Spammer',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    country: 'India',
    countryFlag: '🇮🇳',
    level: 2,
    banReason: 'Repeated promotional link spamming in live voice rooms',
    bannedAt: '2026-10-25',
    appealReason: 'I sincerely apologize for posting links. My cousin had access to my phone and did not understand room guidelines.',
    pledgeText: 'I promise to strictly abide by community guidelines, avoid any form of misconduct or spam, and never violate rules again.',
    submittedAt: '2026-10-28 14:30',
    status: 'Pending',
  },
  {
    id: 'appeal_02',
    userId: 'user_1005',
    nickname: 'Bad_Actor_007',
    avatarUrl: '',
    country: 'Saudi Arabia',
    countryFlag: '🇸🇦',
    level: 1,
    banReason: 'Inappropriate language in public microphone seat',
    bannedAt: '2026-10-24',
    appealReason: 'A heated argument occurred during a PK game. I regret my behavior deeply.',
    pledgeText: 'I give full assurance of respectful conduct in voice rooms without any harassment or abusive behavior in the future.',
    submittedAt: '2026-10-27 18:15',
    status: 'Pending',
  },
];


export interface UserReport {
  id: string;
  reporterId: string;
  reporterName: string;
  reportedUserId: string;
  reportedUserName: string;
  reportedUserAvatar: string;
  reportedUserFlag: string;
  reportedUserLevel: number;
  category: 'Mic Seat Abuse' | 'Harassment' | 'Inappropriate Content' | 'Spam / Scam Link';
  incidentLocation: string;
  reason: string;
  evidence: string;
  reportedAt: string;
  status: 'Pending' | 'Warned' | 'Muted' | 'Banned' | 'Dismissed';
  actionNote?: string;
}

const initialReports: UserReport[] = [
  {
    id: 'rep_101',
    reporterId: 'user_1001',
    reporterName: 'Tania Ahmed',
    reportedUserId: 'user_1005',
    reportedUserName: 'Bad_Actor_007',
    reportedUserAvatar: '',
    reportedUserFlag: '🇸🇦',
    reportedUserLevel: 1,
    category: 'Mic Seat Abuse',
    incidentLocation: 'Party Room #802 (Dubai PK)',
    reason: 'Playing disruptive loud screeching noise on Seat 4 and refusing to step down.',
    evidence: 'Audio room log: 42 participants reported audio disturbance simultaneously.',
    reportedAt: '12 mins ago',
    status: 'Pending',
  },
  {
    id: 'rep_102',
    reporterId: 'user_1003',
    reporterName: 'Nusrat Jahan',
    reportedUserId: 'user_1004',
    reportedUserName: 'SpamMaster_X',
    reportedUserAvatar: '',
    reportedUserFlag: '🇮🇳',
    reportedUserLevel: 2,
    category: 'Spam / Scam Link',
    incidentLocation: '1-on-1 Direct Message',
    reason: 'Sending phishing URLs claiming free unlimited gold coins.',
    evidence: 'Pasted link: free-gamegala-coins-gift.xyz in private chat.',
    reportedAt: '35 mins ago',
    status: 'Pending',
  },
  {
    id: 'rep_103',
    reporterId: 'user_1002',
    reporterName: 'Killer Prince',
    reportedUserId: 'user_1006',
    reportedUserName: 'TrollUser99',
    reportedUserAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    reportedUserFlag: '🇧🇩',
    reportedUserLevel: 3,
    category: 'Harassment',
    incidentLocation: 'Community Moment Comments',
    reason: 'Abusive comments under multiple host moment photos.',
    evidence: 'Repeated offensive slurs in comments section.',
    reportedAt: '2 hours ago',
    status: 'Pending',
  },
];

export default function UsersPage() {
  const [users, setUsers] = useState<ProfileRecord[]>(mockProfiles);
  const [appeals, setAppeals] = useState<BanAppeal[]>(initialAppeals);
  const [reports, setReports] = useState<UserReport[]>(initialReports);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'all' | 'online' | 'vip' | 'banned' | 'appeals' | 'reports'>('all');

  // Modal State for adjusting balance
  const [selectedUser, setSelectedUser] = useState<ProfileRecord | null>(null);
  const [adjustAmount, setAdjustAmount] = useState('');
  const [currencyType, setCurrencyType] = useState<'coins' | 'gems'>('coins');
  const [adjustAction, setAdjustAction] = useState<'add' | 'deduct'>('add');
  const [reason, setReason] = useState('Admin compensation');

  // Modal for appeal review / decision
  const [selectedAppeal, setSelectedAppeal] = useState<BanAppeal | null>(null);
  const [appealAction, setAppealAction] = useState<'unban' | 'keep_banned'>('unban');
  const [decisionNote, setDecisionNote] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  async function fetchUsers() {
    try {
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(50);

      if (data && data.length > 0) {
        setUsers(data as ProfileRecord[]);
      }
    } catch {
      // Use fallback mock
    }
  }

  // Toggle Ban / Unban
  async function toggleBan(user: ProfileRecord) {
    const updatedStatus = !user.is_banned;
    setUsers((prev) =>
      prev.map((u) => (u.id === user.id ? { ...u, is_banned: updatedStatus } : u))
    );

    try {
      await supabase.from('profiles').update({ is_banned: updatedStatus }).eq('id', user.id);
    } catch (e) {
      console.error(e);
    }
  }

  // Toggle VIP
  async function toggleVip(user: ProfileRecord) {
    const updatedVip = !user.is_vip;
    setUsers((prev) =>
      prev.map((u) => (u.id === user.id ? { ...u, is_vip: updatedVip } : u))
    );

    try {
      await supabase.from('profiles').update({ is_vip: updatedVip }).eq('id', user.id);
    } catch (e) {
      console.error(e);
    }
  }

  // Handle balance adjustment
  async function handleAdjustBalance(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedUser || !adjustAmount) return;

    const numAmount = parseFloat(adjustAmount);
    if (isNaN(numAmount) || numAmount <= 0) return;

    const delta = adjustAction === 'add' ? numAmount : -numAmount;
    let newCoins = selectedUser.coin_balance;
    let newGems = selectedUser.gem_balance;

    if (currencyType === 'coins') {
      newCoins = Math.max(0, newCoins + delta);
    } else {
      newGems = Math.max(0, newGems + delta);
    }

    setUsers((prev) =>
      prev.map((u) =>
        u.id === selectedUser.id ? { ...u, coin_balance: newCoins, gem_balance: newGems } : u
      )
    );

    try {
      if (currencyType === 'coins') {
        await supabase.from('profiles').update({ coin_balance: newCoins }).eq('id', selectedUser.id);
      } else {
        await supabase.from('profiles').update({ gem_balance: newGems }).eq('id', selectedUser.id);
      }
    } catch (err) {
      console.error(err);
    }

    setSelectedUser(null);
    setAdjustAmount('');
  }

  // Handle Unban Appeal Decision
  async function handleAppealDecision(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedAppeal) return;

    const willUnban = appealAction === 'unban';

    // Update appeal state
    setAppeals((prev) =>
      prev.map((a) =>
        a.id === selectedAppeal.id
          ? {
              ...a,
              status: willUnban ? 'Approved' : 'Rejected',
              adminDecisionNote: decisionNote || (willUnban ? 'Appeal accepted with warning' : 'Appeal denied due to policy violation'),
            }
          : a
      )
    );

    // If unbanning, update the user status
    if (willUnban) {
      setUsers((prev) =>
        prev.map((u) => (u.id === selectedAppeal.userId ? { ...u, is_banned: false } : u))
      );

      try {
        await supabase.from('profiles').update({ is_banned: false }).eq('id', selectedAppeal.userId);
      } catch (err) {
        console.error(err);
      }
    }

    setSelectedAppeal(null);
    setDecisionNote('');
  }

  const pendingAppealsCount = appeals.filter((a) => a.status === 'Pending').length;

  async function handleReportAction(
    reportId: string,
    action: 'warn' | 'mute' | 'ban' | 'dismiss'
  ) {
    const report = reports.find((r) => r.id === reportId);
    if (!report) return;

    let newStatus: UserReport['status'] = 'Dismissed';
    let actionNote = 'Reviewed and dismissed.';

    if (action === 'warn') {
      newStatus = 'Warned';
      actionNote = 'Issued formal violation warning to user inbox.';
    } else if (action === 'mute') {
      newStatus = 'Muted';
      actionNote = 'Muted microphone permissions for 24 hours.';
    } else if (action === 'ban') {
      newStatus = 'Banned';
      actionNote = 'User account banned immediately.';
      setUsers((prev) =>
        prev.map((u) => (u.id === report.reportedUserId ? { ...u, is_banned: true } : u))
      );
      try {
        await supabase.from('profiles').update({ is_banned: true }).eq('id', report.reportedUserId);
      } catch (e) {
        console.error(e);
      }
    }

    setReports((prev) =>
      prev.map((r) =>
        r.id === reportId ? { ...r, status: newStatus, actionNote } : r
      )
    );
  }

  const pendingReportsCount = reports.filter((r) => r.status === 'Pending').length;


  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.nickname.toLowerCase().includes(search.toLowerCase()) ||
      u.id.toLowerCase().includes(search.toLowerCase()) ||
      u.country.toLowerCase().includes(search.toLowerCase());

    if (!matchesSearch) return false;
    if (filter === 'vip') return u.is_vip;
    if (filter === 'banned') return u.is_banned;
    if (filter === 'online') return u.is_online;
    return true;
  });

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <Users className="w-6 h-6 text-emerald-400" />
          <span>Users</span>
        </h2>

        {/* Filter Tabs */}
        <div className="flex items-center gap-1.5 bg-[#11221D] p-1.5 rounded-xl border border-[#1C3830] overflow-x-auto">
          {(['all', 'online', 'vip', 'banned'] as const).map((tab) => (
            <button
              key={tab}
              onClick={() => setFilter(tab)}
              className={`px-3 py-1 rounded-lg text-xs font-bold capitalize transition-colors ${
                filter === tab
                  ? 'bg-emerald-500 text-slate-950 shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              {tab === 'banned' ? 'Banned' : tab}
            </button>
          ))}


          {/* Reports Moderation Tab */}
          <button
            onClick={() => setFilter('reports')}
            className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors flex items-center gap-1.5 ${
              filter === 'reports'
                ? 'bg-rose-500 text-slate-950 shadow-sm'
                : 'text-rose-400 hover:text-rose-300'
            }`}
          >
            <Flag className="w-3.5 h-3.5" />
            <span>Reports</span>
            {pendingReportsCount > 0 && (
              <span className={`px-1.5 py-0.2 rounded-full text-[10px] font-black ${
                filter === 'reports' ? 'bg-slate-950 text-rose-300' : 'bg-rose-500/20 text-rose-400'
              }`}>
                {pendingReportsCount}
              </span>
            )}
          </button>

          {/* Appeals Tab */}
          <button
            onClick={() => setFilter('appeals')}
            className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors flex items-center gap-1.5 ${
              filter === 'appeals'
                ? 'bg-amber-500 text-slate-950 shadow-sm'
                : 'text-amber-400 hover:text-amber-300'
            }`}
          >
            <span>Unban Appeals</span>
            {pendingAppealsCount > 0 && (
              <span className={`px-1.5 py-0.2 rounded-full text-[10px] font-black ${
                filter === 'appeals' ? 'bg-slate-950 text-amber-300' : 'bg-amber-500/20 text-amber-400'
              }`}>
                {pendingAppealsCount}
              </span>
            )}
          </button>
        </div>
      </div>

      {/* Main View: Appeals Queue or Users Table */}
      
      {filter === 'reports' ? (
        /* User Reports & Incident Moderation Section */
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              <Flag className="w-4 h-4 text-rose-400" />
              <span>User Reports & Safety Moderation</span>
            </h3>
            <span className="text-xs text-slate-400">{pendingReportsCount} Pending Review</span>
          </div>

          <div className="space-y-3">
            {reports.map((rep) => (
              <div
                key={rep.id}
                className={`p-5 rounded-2xl glass-panel border transition-all ${
                  rep.status === 'Banned'
                    ? 'border-rose-500/30 bg-rose-950/15'
                    : rep.status === 'Warned' || rep.status === 'Muted'
                    ? 'border-amber-500/30 bg-amber-950/10'
                    : rep.status === 'Dismissed'
                    ? 'border-slate-800 opacity-60'
                    : 'border-[#1C3830]'
                }`}
              >
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                  <div className="flex items-start gap-3.5">
                    <div className="w-11 h-11 rounded-full bg-slate-800 overflow-hidden border border-white/10 flex items-center justify-center font-bold text-sm text-white flex-shrink-0">
                      {rep.reportedUserAvatar ? (
                        <img src={rep.reportedUserAvatar} alt={rep.reportedUserName} className="w-full h-full object-cover" />
                      ) : (
                        rep.reportedUserName.substring(0, 2).toUpperCase()
                      )}
                    </div>

                    <div>
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="font-bold text-sm text-white">{rep.reportedUserName}</span>
                        <span className="text-xs">{rep.reportedUserFlag}</span>
                        <span className="text-[10px] font-mono text-slate-500">ID: {rep.reportedUserId}</span>
                        <Badge variant={rep.status === 'Pending' ? 'rose' : rep.status === 'Banned' ? 'rose' : rep.status === 'Dismissed' ? 'slate' : 'amber'}>
                          {rep.status}
                        </Badge>
                        <span className="text-[11px] font-bold text-rose-400 px-2 py-0.5 rounded bg-rose-500/10 border border-rose-500/20">
                          {rep.category}
                        </span>
                      </div>

                      <div className="mt-1 text-xs text-slate-400 flex items-center gap-2">
                        <span>Incident: <strong className="text-slate-300">{rep.incidentLocation}</strong></span>
                        <span className="text-slate-600">·</span>
                        <span>Reported by: <strong className="text-amber-300">{rep.reporterName}</strong> ({rep.reporterId})</span>
                        <span className="text-slate-600">·</span>
                        <span className="text-slate-500">{rep.reportedAt}</span>
                      </div>

                      <div className="mt-2.5 p-3 rounded-xl bg-black/40 border border-white/5 space-y-1">
                        <p className="text-xs text-slate-200">
                          <strong className="text-rose-400">Report Reason: </strong>
                          {rep.reason}
                        </p>
                        <p className="text-[11px] text-slate-400">
                          <strong className="text-slate-300">Evidence Log: </strong>
                          {rep.evidence}
                        </p>
                      </div>

                      {rep.actionNote && (
                        <div className="mt-2 text-xs font-semibold text-emerald-400 flex items-center gap-1.5">
                          <Check className="w-3.5 h-3.5" />
                          <span>Action Note: {rep.actionNote}</span>
                        </div>
                      )}
                    </div>
                  </div>

                  {rep.status === 'Pending' ? (
                    <div className="flex flex-wrap sm:flex-col gap-1.5 self-start sm:self-auto flex-shrink-0">
                      <button
                        onClick={() => handleReportAction(rep.id, 'warn')}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 font-bold text-xs border border-amber-500/30 transition-colors"
                      >
                        <AlertTriangle className="w-3.5 h-3.5" />
                        <span>Warn User</span>
                      </button>

                      <button
                        onClick={() => handleReportAction(rep.id, 'mute')}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-cyan-500/20 hover:bg-cyan-500/30 text-cyan-300 font-bold text-xs border border-cyan-500/30 transition-colors"
                      >
                        <MicOff className="w-3.5 h-3.5" />
                        <span>Mute Mic (24h)</span>
                      </button>

                      <button
                        onClick={() => handleReportAction(rep.id, 'ban')}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-rose-500/20 hover:bg-rose-500/30 text-rose-300 font-bold text-xs border border-rose-500/30 transition-colors"
                      >
                        <UserX className="w-3.5 h-3.5" />
                        <span>Ban Account</span>
                      </button>

                      <button
                        onClick={() => handleReportAction(rep.id, 'dismiss')}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 text-slate-400 font-bold text-xs transition-colors"
                      >
                        <X className="w-3.5 h-3.5" />
                        <span>Dismiss</span>
                      </button>
                    </div>
                  ) : (
                    <span className="text-xs font-bold text-slate-500 self-start sm:self-auto">Action Taken</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : filter === 'appeals' ? (

        /* Unban Appeals Section */
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              <FileText className="w-4 h-4 text-amber-400" />
              <span>Unban Appeals & Conduct Pledges</span>
            </h3>
            <span className="text-xs text-slate-400">{pendingAppealsCount} Pending Review</span>
          </div>

          <div className="space-y-3">
            {appeals.map((appeal) => (
              <div
                key={appeal.id}
                className={`p-5 rounded-2xl glass-panel border transition-all ${
                  appeal.status === 'Approved'
                    ? 'border-emerald-500/30 bg-emerald-950/10'
                    : appeal.status === 'Rejected'
                    ? 'border-rose-500/30 bg-rose-950/10'
                    : 'border-[#1C3830]'
                }`}
              >
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                  {/* User Profile */}
                  <div className="flex items-start gap-3.5">
                    <div className="w-11 h-11 rounded-full bg-slate-800 overflow-hidden border border-white/10 flex items-center justify-center font-bold text-sm text-white flex-shrink-0">
                      {appeal.avatarUrl ? (
                        <img src={appeal.avatarUrl} alt={appeal.nickname} className="w-full h-full object-cover" />
                      ) : (
                        appeal.nickname.substring(0, 2).toUpperCase()
                      )}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-sm text-white">{appeal.nickname}</span>
                        <span className="text-xs">{appeal.countryFlag}</span>
                        <span className="text-[10px] font-mono text-slate-500">ID: {appeal.userId}</span>
                        <Badge variant={appeal.status === 'Approved' ? 'emerald' : appeal.status === 'Rejected' ? 'rose' : 'amber'}>
                          {appeal.status}
                        </Badge>
                      </div>

                      {/* Reason of original ban */}
                      <div className="mt-2 text-xs text-slate-400 flex items-center gap-1.5">
                        <span className="text-rose-400 font-bold">Ban Reason:</span>
                        <span>{appeal.banReason}</span>
                        <span className="text-slate-600">·</span>
                        <span className="text-slate-500">Banned on {appeal.bannedAt}</span>
                      </div>

                      {/* User's Appeal Statement */}
                      <div className="mt-2.5 p-3 rounded-xl bg-black/40 border border-white/5 space-y-1.5">
                        <p className="text-xs text-slate-200">
                          <strong className="text-amber-400">User's Appeal: </strong>
                          {appeal.appealReason}
                        </p>
                        <p className="text-xs text-emerald-300 flex items-start gap-1.5">
                          <Check className="w-3.5 h-3.5 text-emerald-400 mt-0.5 flex-shrink-0" />
                          <span>
                            <strong>Pledge: </strong>
                            {appeal.pledgeText}
                          </span>
                        </p>
                      </div>

                      {appeal.adminDecisionNote && (
                        <p className="mt-2 text-[11px] text-slate-400 italic">
                          Admin note: {appeal.adminDecisionNote}
                        </p>
                      )}
                    </div>
                  </div>

                  {/* Action Buttons */}
                  {appeal.status === 'Pending' ? (
                    <div className="flex sm:flex-col gap-2 flex-shrink-0">
                      <button
                        onClick={() => {
                          setSelectedAppeal(appeal);
                          setAppealAction('unban');
                        }}
                        className="px-3.5 py-1.5 rounded-xl bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/40 text-emerald-300 font-bold text-xs flex items-center gap-1.5 transition-colors"
                      >
                        <ShieldCheck className="w-3.5 h-3.5" />
                        <span>Accept & Unban</span>
                      </button>
                      <button
                        onClick={() => {
                          setSelectedAppeal(appeal);
                          setAppealAction('keep_banned');
                        }}
                        className="px-3.5 py-1.5 rounded-xl bg-rose-500/20 hover:bg-rose-500/30 border border-rose-500/40 text-rose-300 font-bold text-xs flex items-center gap-1.5 transition-colors"
                      >
                        <ShieldAlert className="w-3.5 h-3.5" />
                        <span>Keep Banned</span>
                      </button>
                    </div>
                  ) : (
                    <span className="text-xs font-bold text-slate-500 self-start sm:self-auto">Resolved</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        /* Directory Table */
        <>
          {/* Search Bar */}
          <div className="relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by ID, name, or country..."
              className="w-full pl-11 pr-4 py-3 rounded-2xl bg-[#11221D] border border-[#1C3830] text-sm text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 transition-colors"
            />
          </div>

          <div className="rounded-2xl glass-panel overflow-hidden border border-[#1C3830]">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-[#0A1814] text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-[#1C3830]">
                  <tr>
                    <th className="py-3.5 px-4">User</th>
                    <th className="py-3.5 px-4">Country</th>
                    <th className="py-3.5 px-4">Level</th>
                    <th className="py-3.5 px-4">Coins</th>
                    <th className="py-3.5 px-4">Gems</th>
                    <th className="py-3.5 px-4">Status</th>
                    <th className="py-3.5 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#1C3830] text-slate-300">
                  {filteredUsers.map((user) => (
                    <tr key={user.id} className="hover:bg-white/[0.02] transition-colors">
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-3">
                          <div className="relative w-8 h-8 rounded-full bg-slate-800 flex items-center justify-center overflow-hidden border border-white/10 flex-shrink-0">
                            {user.avatar_url ? (
                              <img src={user.avatar_url} alt={user.nickname} className="w-full h-full object-cover" />
                            ) : (
                              <span className="text-xs font-bold text-slate-300">
                                {user.nickname.substring(0, 2).toUpperCase()}
                              </span>
                            )}
                            {user.is_online && (
                              <span className="absolute bottom-0 right-0 w-2 h-2 rounded-full bg-emerald-500 border border-[#11221D]" />
                            )}
                          </div>
                          <div>
                            <div className="flex items-center gap-1.5 font-bold text-white">
                              <span>{user.nickname}</span>
                              {user.is_vip && <Crown className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />}
                            </div>
                            <span className="text-[10px] text-slate-500 font-mono">{user.id}</span>
                          </div>
                        </div>
                      </td>

                      <td className="py-3 px-4">
                        <span className="flex items-center gap-1">
                          <span>{user.country_flag}</span>
                          <span className="text-slate-300">{user.country}</span>
                        </span>
                      </td>

                      <td className="py-3 px-4">
                        <span className="px-2 py-0.5 rounded-md bg-purple-500/15 text-purple-300 border border-purple-500/30 font-bold text-[10px]">
                          LV{user.level}
                        </span>
                      </td>

                      <td className="py-3 px-4 font-bold text-amber-400">
                        {formatCoins(user.coin_balance)}
                      </td>

                      <td className="py-3 px-4 font-bold text-cyan-400">
                        {formatGems(user.gem_balance)}
                      </td>

                      <td className="py-3 px-4">
                        {user.is_banned ? (
                          <Badge variant="rose">Banned</Badge>
                        ) : user.is_online ? (
                          <Badge variant="emerald">Online</Badge>
                        ) : (
                          <Badge variant="slate">Offline</Badge>
                        )}
                      </td>

                      <td className="py-3 px-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <button
                            onClick={() => setSelectedUser(user)}
                            className="px-2.5 py-1 rounded-lg bg-emerald-500/15 hover:bg-emerald-500/25 text-emerald-300 text-xs font-bold transition-colors"
                          >
                            Adjust
                          </button>

                          <button
                            onClick={() => toggleVip(user)}
                            className={`p-1.5 rounded-lg border transition-colors ${
                              user.is_vip
                                ? 'bg-amber-500/15 border-amber-500/40 text-amber-400 hover:bg-amber-500/30'
                                : 'bg-white/5 border-white/10 text-slate-400 hover:text-white'
                            }`}
                          >
                            <Crown className="w-3.5 h-3.5" />
                          </button>

                          <button
                            onClick={() => toggleBan(user)}
                            title={user.is_banned ? 'Unban User' : 'Ban User'}
                            className={`p-1.5 rounded-lg border transition-colors ${
                              user.is_banned
                                ? 'bg-emerald-500/15 border-emerald-500/40 text-emerald-400 hover:bg-emerald-500/30'
                                : 'bg-rose-500/15 border-rose-500/40 text-rose-400 hover:bg-rose-500/30'
                            }`}
                          >
                            {user.is_banned ? (
                              <ShieldCheck className="w-3.5 h-3.5" />
                            ) : (
                              <ShieldAlert className="w-3.5 h-3.5" />
                            )}
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}

      {/* Adjust Balance Modal */}
      {selectedUser && (
        <Modal
          isOpen={true}
          onClose={() => setSelectedUser(null)}
          title={`Adjust: ${selectedUser.nickname}`}
        >
          <form onSubmit={handleAdjustBalance} className="space-y-4">
            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => setCurrencyType('coins')}
                className={`py-2 rounded-xl text-xs font-bold border transition-colors flex items-center justify-center gap-1.5 ${
                  currencyType === 'coins'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-slate-400'
                }`}
              >
                <Coins className="w-4 h-4 text-amber-400" />
                <span>Coins ({formatCoins(selectedUser.coin_balance)})</span>
              </button>
              <button
                type="button"
                onClick={() => setCurrencyType('gems')}
                className={`py-2 rounded-xl text-xs font-bold border transition-colors flex items-center justify-center gap-1.5 ${
                  currencyType === 'gems'
                    ? 'bg-cyan-500/20 border-cyan-500/50 text-cyan-300'
                    : 'bg-white/5 border-white/10 text-slate-400'
                }`}
              >
                <Gem className="w-4 h-4 text-cyan-400" />
                <span>Gems ({formatGems(selectedUser.gem_balance)})</span>
              </button>
            </div>

            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => setAdjustAction('add')}
                className={`py-2 rounded-xl text-xs font-bold border transition-colors flex items-center justify-center gap-1.5 ${
                  adjustAction === 'add'
                    ? 'bg-emerald-500/20 border-emerald-500/50 text-emerald-300'
                    : 'bg-white/5 border-white/10 text-slate-400'
                }`}
              >
                <PlusCircle className="w-4 h-4 text-emerald-400" />
                <span>Add (+)</span>
              </button>
              <button
                type="button"
                onClick={() => setAdjustAction('deduct')}
                className={`py-2 rounded-xl text-xs font-bold border transition-colors flex items-center justify-center gap-1.5 ${
                  adjustAction === 'deduct'
                    ? 'bg-rose-500/20 border-rose-500/50 text-rose-300'
                    : 'bg-white/5 border-white/10 text-slate-400'
                }`}
              >
                <MinusCircle className="w-4 h-4 text-rose-400" />
                <span>Deduct (-)</span>
              </button>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Amount</label>
              <input
                type="number"
                required
                min="1"
                value={adjustAmount}
                onChange={(e) => setAdjustAmount(e.target.value)}
                placeholder="Amount"
                className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-emerald-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Note</label>
              <input
                type="text"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="Reason"
                className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-emerald-500"
              />
            </div>

            <div className="pt-2 flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setSelectedUser(null)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs transition-colors"
              >
                Apply
              </button>
            </div>
          </form>
        </Modal>
      )}

      {/* Review Appeal Decision Modal */}
      {selectedAppeal && (
        <Modal
          isOpen={true}
          onClose={() => setSelectedAppeal(null)}
          title={`Appeal Review: ${selectedAppeal.nickname}`}
        >
          <form onSubmit={handleAppealDecision} className="space-y-4">
            <div className="p-3.5 rounded-xl bg-black/40 border border-white/5 space-y-2 text-xs">
              <p>
                <span className="text-slate-400 font-bold">Ban Reason: </span>
                <span className="text-rose-300">{selectedAppeal.banReason}</span>
              </p>
              <p>
                <span className="text-slate-400 font-bold">User Explanation: </span>
                <span className="text-slate-200">{selectedAppeal.appealReason}</span>
              </p>
              <p>
                <span className="text-slate-400 font-bold">Pledge: </span>
                <span className="text-emerald-300">{selectedAppeal.pledgeText}</span>
              </p>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Admin Decision Note</label>
              <input
                type="text"
                value={decisionNote}
                onChange={(e) => setDecisionNote(e.target.value)}
                placeholder={
                  appealAction === 'unban'
                    ? 'Accepted with strict warning'
                    : 'Denied due to severity of misconduct'
                }
                className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
              />
            </div>

            <div className="pt-2 flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setSelectedAppeal(null)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
              >
                Cancel
              </button>
              <button
                type="submit"
                className={`px-4 py-2 rounded-xl text-xs font-black transition-colors ${
                  appealAction === 'unban'
                    ? 'bg-emerald-500 hover:bg-emerald-400 text-slate-950'
                    : 'bg-rose-500 hover:bg-rose-400 text-white'
                }`}
              >
                {appealAction === 'unban' ? 'Confirm Unban' : 'Confirm Keep Banned'}
              </button>
            </div>
          </form>
        </Modal>
      )}
    </div>
  );
}
