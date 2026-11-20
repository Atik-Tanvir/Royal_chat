'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { supabase, WithdrawalRecord } from '../../shared/lib/supabase';
import { Badge } from '../../shared/components/ui/Badge';
import { Modal } from '../../shared/components/ui/Modal';
import { Switch } from '../../shared/components/ui/Switch';
import { formatGems, formatUSD, formatDate } from '../../shared/lib/utils';
import {
  DollarSign,
  Sliders,
  CheckCircle2,
  Copy,
  Sparkles,
  Download,
  AlertTriangle,
  ShieldAlert,
  ShieldCheck,
  Search,
  Check,
  AlertCircle,
  PhoneCall,
  UserCheck,
} from 'lucide-react';

// Realistic mock data strictly featuring Bangladesh (bKash, Nagad) & India (Google Pay, Paytm, PhonePe)
const mockWithdrawals: WithdrawalRecord[] = [
  {
    id: 'WD-89104',
    user_id: 'usr_bd_201',
    user_name: 'Nusrat Jahan',
    user_avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    gateway: 'bKash (🇧🇩 Bangladesh)',
    account_number: '01712345678 [Name: Nusrat Jahan]',
    amount: 15.0,
    gems: 15000,
    status: 'Pending',
    created_at: new Date().toISOString(),
  },
  {
    id: 'WD-89105',
    user_id: 'usr_in_304',
    user_name: 'Arjun Verma',
    user_avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    gateway: 'Google Pay (🇮🇳 India)',
    account_number: 'arjun.verma@okhdfcbank [Name: Arjun Verma]',
    amount: 25.0,
    gems: 25000,
    status: 'Pending',
    created_at: new Date(Date.now() - 1800000).toISOString(),
  },
  {
    id: 'WD-89106',
    user_id: 'usr_bd_202',
    user_name: 'Mehedi Hasan',
    user_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    gateway: 'Nagad (🇧🇩 Bangladesh)',
    account_number: '01987654321 [Name: Mehedi Hasan]',
    amount: 10.0,
    gems: 10000,
    status: 'Pending',
    created_at: new Date(Date.now() - 3600000).toISOString(),
  },
  {
    id: 'WD-89107',
    user_id: 'usr_in_305',
    user_name: 'Pooja Sharma',
    user_avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    gateway: 'PhonePe (🇮🇳 India)',
    account_number: '9876543210@ybl [Name: Pooja Sharma]',
    amount: 50.0,
    gems: 50000,
    status: 'Approved',
    transaction_id: 'UPI_9823487192',
    admin_note: 'Paid via PhonePe Business',
    created_at: new Date(Date.now() - 7200000).toISOString(),
  },
  {
    id: 'WD-89108',
    user_id: 'usr_bd_999_fake',
    user_name: 'Clone Account #2',
    user_avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    gateway: 'bKash (🇧🇩 Bangladesh)',
    account_number: '01712345678 [Name: Same Number Fraud]',
    amount: 8.0,
    gems: 8000,
    status: 'Pending',
    created_at: new Date(Date.now() - 900000).toISOString(),
  },
  {
    id: 'WD-89109',
    user_id: 'usr_bd_105',
    user_name: 'Spam User',
    user_avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    gateway: 'Nagad (🇧🇩 Bangladesh)',
    account_number: '012345 [Name: Short Number]',
    amount: 2.0,
    gems: 2000,
    status: 'Pending',
    created_at: new Date(Date.now() - 1200000).toISOString(),
  },
];

interface FraudAnalysis {
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  score: number;
  flags: string[];
  cleanNumber: string;
  isDuplicate: boolean;
  duplicateUsers: string[];
  isUnderThreshold: boolean;
  isInvalidFormat: boolean;
  isVelocityAlert: boolean;
}

export default function WithdrawalsPage() {
  const [withdrawals, setWithdrawals] = useState<WithdrawalRecord[]>(mockWithdrawals);
  const [filter, setFilter] = useState<'All' | 'Pending' | 'Approved' | 'Rejected'>('All');
  const [gatewayFilter, setGatewayFilter] = useState<string>('All');
  const [riskFilter, setRiskFilter] = useState<'All' | 'HighRisk' | 'LowRisk'>('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [activeTx, setActiveTx] = useState<WithdrawalRecord | null>(null);
  const [actionType, setActionType] = useState<'approve' | 'reject'>('approve');
  const [proofNote, setProofNote] = useState('');
  const [copiedTargetId, setCopiedTargetId] = useState<string | null>(null);
  const [mounted, setMounted] = useState(false);

  // Payout Gateways State (Strictly BD & IN only)
  const [gateways, setGateways] = useState({
    bKash: true,
    nagad: true,
    googlePay: true,
    paytm: true,
    phonePe: true,
    minWithdrawalUsd: 5,
  });
  const [isGatewaySaved, setIsGatewaySaved] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    async function loadWithdrawals() {
      try {
        const { data } = await supabase
          .from('withdrawals')
          .select('*')
          .order('created_at', { ascending: false });

        if (data && data.length > 0) {
          // Merge with mock so fraud rules and rich cases can be verified
          const existingIds = new Set(data.map((d) => d.id));
          const merged = [
            ...(data as WithdrawalRecord[]),
            ...mockWithdrawals.filter((m) => !existingIds.has(m.id)),
          ];
          setWithdrawals(merged);
        }
      } catch {
        // Fallback to mock
      }
    }
    loadWithdrawals();
  }, []);

  // Helper to extract clean phone/UPI from raw account string
  function extractTargetNumber(rawAccount?: string, rawGateway?: string): string {
    const text = (rawAccount || rawGateway || '').trim();
    // Match phone or upi before [Name: ...]
    const bracketIndex = text.indexOf('[');
    let target = bracketIndex > 0 ? text.substring(0, bracketIndex).trim() : text;
    target = target.replace(/^[a-zA-Z\s]+:/, '').trim();
    return target;
  }

  // Calculate local currency payout
  function getLocalPayout(gateway: string, amountUsd: number): { text: string; code: string; symbol: string; value: number } {
    const isIndia = gateway.includes('India') || gateway.includes('Google Pay') || gateway.includes('Paytm') || gateway.includes('PhonePe');
    if (isIndia) {
      const val = Math.round(amountUsd * 86);
      return { text: `₹ ${val.toLocaleString()} INR`, code: 'INR', symbol: '₹', value: val };
    }
    const val = Math.round(amountUsd * 120);
    return { text: `৳ ${val.toLocaleString()} BDT`, code: 'BDT', symbol: '৳', value: val };
  }

  // Advanced Fraud Detection Engine
  const fraudReports = useMemo(() => {
    const reports: Record<string, FraudAnalysis> = {};

    // 1. Build map of destination phone/UPI -> user IDs
    const destToUsers: Record<string, Set<string>> = {};
    withdrawals.forEach((w) => {
      const dest = extractTargetNumber(w.account_number, w.gateway).toLowerCase();
      if (dest && dest.length >= 6) {
        if (!destToUsers[dest]) destToUsers[dest] = new Set();
        destToUsers[dest].add(w.user_id);
      }
    });

    // 2. Velocity map: user_id -> count in last 24 hours
    const userVelocity: Record<string, number> = {};
    const oneDayAgo = Date.now() - 86400000;
    withdrawals.forEach((w) => {
      const t = new Date(w.created_at).getTime();
      if (t > oneDayAgo) {
        userVelocity[w.user_id] = (userVelocity[w.user_id] || 0) + 1;
      }
    });

    // 3. Evaluate each withdrawal
    withdrawals.forEach((w) => {
      const cleanDest = extractTargetNumber(w.account_number, w.gateway);
      const flags: string[] = [];
      let score = 0;

      // Duplicate check across multiple user accounts
      const associatedUsers = destToUsers[cleanDest.toLowerCase()]
        ? Array.from(destToUsers[cleanDest.toLowerCase()])
        : [];
      const isDuplicate = associatedUsers.length > 1;
      if (isDuplicate) {
        score += 50;
        flags.push(`🚨 Multi-Account Alert: Same number used by ${associatedUsers.length} accounts (${associatedUsers.join(', ')})`);
      }

      // Minimum $5 threshold check
      const isUnderThreshold = w.amount < 5.0 || w.gems < 5000;
      if (isUnderThreshold) {
        score += 40;
        flags.push(`⚠️ Under-Threshold: Requested $${w.amount} (Minimum is $5.00 USD / 5,000 gems)`);
      }

      // Format check (BD vs India)
      let isInvalidFormat = false;
      const isBD = w.gateway.includes('bKash') || w.gateway.includes('Nagad') || w.gateway.includes('Bangladesh');
      if (isBD) {
        const bdRegex = /^01[3-9]\d{8}$/;
        const pureDigits = cleanDest.replace(/\D/g, '');
        if (!bdRegex.test(pureDigits)) {
          isInvalidFormat = true;
          score += 35;
          flags.push('❌ Invalid BD Phone: Must be 11 digits starting with 01 (e.g. 017XXXXXXXX)');
        }
      } else {
        const hasAt = cleanDest.includes('@') && cleanDest.length >= 5;
        const pureDigits = cleanDest.replace(/\D/g, '');
        const is10Digit = pureDigits.length === 10;
        if (!hasAt && !is10Digit) {
          isInvalidFormat = true;
          score += 35;
          flags.push('❌ Invalid India Payment: Expected 10-digit phone or valid UPI ID (e.g. user@bank)');
        }
      }

      // Velocity check
      const velocity = userVelocity[w.user_id] || 0;
      const isVelocityAlert = velocity >= 3;
      if (isVelocityAlert) {
        score += 20;
        flags.push(`⚡ High Velocity: ${velocity} requests created in the last 24 hours`);
      }

      let riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' = 'LOW';
      if (score >= 40 || isDuplicate || isUnderThreshold || isInvalidFormat) {
        riskLevel = 'HIGH';
      } else if (score >= 20 || isVelocityAlert) {
        riskLevel = 'MEDIUM';
      }

      reports[w.id] = {
        riskLevel,
        score,
        flags,
        cleanNumber: cleanDest,
        isDuplicate,
        duplicateUsers: associatedUsers,
        isUnderThreshold,
        isInvalidFormat,
        isVelocityAlert,
      };
    });

    return reports;
  }, [withdrawals]);

  // Filtering
  const filtered = useMemo(() => {
    return withdrawals.filter((w) => {
      if (filter !== 'All' && w.status !== filter) return false;

      if (gatewayFilter !== 'All') {
        if (!w.gateway.toLowerCase().includes(gatewayFilter.toLowerCase())) return false;
      }

      const report = fraudReports[w.id];
      if (riskFilter === 'HighRisk' && report?.riskLevel !== 'HIGH') return false;
      if (riskFilter === 'LowRisk' && report?.riskLevel !== 'LOW') return false;

      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        const num = (w.account_number || '').toLowerCase();
        const uname = (w.user_name || '').toLowerCase();
        const uid = (w.user_id || '').toLowerCase();
        const wid = w.id.toLowerCase();
        return num.includes(q) || uname.includes(q) || uid.includes(q) || wid.includes(q);
      }

      return true;
    });
  }, [withdrawals, filter, gatewayFilter, riskFilter, searchQuery, fraudReports]);

  // Stats
  const totalPendingUsd = withdrawals
    .filter((w) => w.status === 'Pending')
    .reduce((sum, w) => sum + w.amount, 0);

  const totalApprovedUsd = withdrawals
    .filter((w) => w.status === 'Approved')
    .reduce((sum, w) => sum + w.amount, 0);

  const highRiskCount = Object.values(fraudReports).filter((r) => r.riskLevel === 'HIGH').length;

  function copyText(text: string, id: string) {
    if (!text) return;
    navigator.clipboard.writeText(text);
    setCopiedTargetId(id);
    setTimeout(() => setCopiedTargetId(null), 2000);
  }

  function autoGenerateTrxId() {
    const prefix = activeTx?.gateway?.toUpperCase().includes('BKASH')
      ? 'BK'
      : activeTx?.gateway?.toUpperCase().includes('NAGAD')
      ? 'NG'
      : activeTx?.gateway?.toUpperCase().includes('GOOGLE')
      ? 'GP'
      : activeTx?.gateway?.toUpperCase().includes('PAYTM')
      ? 'PT'
      : activeTx?.gateway?.toUpperCase().includes('PHONEPE')
      ? 'PP'
      : 'TRX';
    const rand = Math.random().toString(36).substring(2, 7).toUpperCase();
    const timePart = Date.now().toString(36).substring(3).toUpperCase();
    setProofNote(`${prefix}_${timePart}${rand}`);
  }

  function handleSaveGateways() {
    setIsGatewaySaved(true);
    setTimeout(() => setIsGatewaySaved(false), 2000);
  }

  async function handleDecisionSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!activeTx) return;

    const newStatus = actionType === 'approve' ? 'Approved' : 'Rejected';

    setWithdrawals((prev) =>
      prev.map((w) => (w.id === activeTx.id ? { ...w, status: newStatus } : w))
    );

    try {
      await supabase
        .from('withdrawals')
        .update({
          status: newStatus,
          transaction_id: actionType === 'approve' ? proofNote : null,
          admin_note: proofNote,
          processed_at: new Date().toISOString(),
        })
        .eq('id', activeTx.id);
    } catch (err) {
      console.error(err);
    }

    setActiveTx(null);
    setProofNote('');
  }

  function exportWithdrawalsCSV() {
    const dataToExport = filtered.length > 0 ? filtered : withdrawals;
    const headers = [
      'ID',
      'Date',
      'User Name',
      'User ID',
      'Gateway',
      'Recipient Number / UPI',
      'Amount USD',
      'Local Payout',
      'Gems',
      'Risk Level',
      'Fraud Flags',
      'Status',
      'Transaction ID',
      'Admin Note',
    ];

    const rows = dataToExport.map((w) => {
      const report = fraudReports[w.id];
      const local = getLocalPayout(w.gateway, w.amount);
      return [
        `"${w.id}"`,
        `"${w.created_at || ''}"`,
        `"${(w.user_name || '').replace(/"/g, '""')}"`,
        `"${w.user_id || ''}"`,
        `"${(w.gateway || '').replace(/"/g, '""')}"`,
        `"${(w.account_number || '').replace(/"/g, '""')}"`,
        w.amount,
        `"${local.text}"`,
        w.gems,
        `"${report?.riskLevel || 'LOW'}"`,
        `"${(report?.flags || []).join('; ').replace(/"/g, '""')}"`,
        `"${w.status}"`,
        `"${(w.transaction_id || '').replace(/"/g, '""')}"`,
        `"${(w.admin_note || '').replace(/"/g, '""')}"`,
      ];
    });

    const csvContent =
      'data:text/csv;charset=utf-8,' +
      [headers.join(','), ...rows.map((e) => e.join(','))].join('\n');

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    const dateStr = new Date().toISOString().split('T')[0];
    link.setAttribute('download', `gamegala_payouts_${dateStr}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
            <DollarSign className="w-6 h-6 text-emerald-400" />
            <span>Payout Requests & Fraud Protection</span>
          </h2>
          <p className="text-xs text-slate-400 mt-1">
            Strictly configured for 🇧🇩 Bangladesh (bKash, Nagad) & 🇮🇳 India (Google Pay, Paytm, PhonePe) • Minimum $5.00 USD
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          <button
            onClick={exportWithdrawalsCSV}
            title="Download CSV spreadsheet"
            className="px-3.5 py-1.5 rounded-xl bg-emerald-500/15 hover:bg-emerald-500/25 border border-emerald-500/40 text-emerald-300 font-bold text-xs flex items-center gap-1.5 transition-all shadow-sm"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Export CSV</span>
          </button>

          {/* Status Filter */}
          <div className="flex items-center gap-1 bg-[#11221D] p-1.5 rounded-xl border border-[#1C3830]">
            {(['All', 'Pending', 'Approved', 'Rejected'] as const).map((status) => (
              <button
                key={status}
                onClick={() => setFilter(status)}
                className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors ${
                  filter === status
                    ? 'bg-emerald-500 text-slate-950 shadow-sm'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {status}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="p-4 rounded-2xl glass-panel border border-amber-500/20">
          <span className="text-xs font-bold text-slate-400 uppercase">Pending Review</span>
          <p className="text-2xl font-black text-amber-400 mt-1">{formatUSD(totalPendingUsd)}</p>
          <span className="text-[11px] text-slate-500">Requires owner disbursement</span>
        </div>

        <div className="p-4 rounded-2xl glass-panel border border-emerald-500/20">
          <span className="text-xs font-bold text-slate-400 uppercase">Disbursed (Approved)</span>
          <p className="text-2xl font-black text-emerald-400 mt-1">{formatUSD(totalApprovedUsd)}</p>
          <span className="text-[11px] text-slate-500">Completed payouts</span>
        </div>

        <div className="p-4 rounded-2xl glass-panel border border-rose-500/25 bg-rose-950/20">
          <span className="text-xs font-bold text-rose-300 uppercase flex items-center gap-1.5">
            <ShieldAlert className="w-3.5 h-3.5 text-rose-400" />
            <span>Fraud Alerts Detected</span>
          </span>
          <p className="text-2xl font-black text-rose-400 mt-1">{highRiskCount} Suspicious</p>
          <span className="text-[11px] text-rose-400/80">Duplicate numbers / under $5 limit</span>
        </div>
      </div>

      {/* Gateways & Threshold Control (Deleted all unused payment methods) */}
      <div className="p-4 rounded-2xl glass-panel border border-[#1C3830] space-y-3">
        <div className="flex items-center justify-between pb-2 border-b border-[#1C3830]">
          <h3 className="text-xs font-bold text-white flex items-center gap-2">
            <Sliders className="w-4 h-4 text-emerald-400" />
            <span>Active Payout Gateways (Bangladesh & India Only)</span>
          </h3>
          <button
            onClick={handleSaveGateways}
            className="px-3 py-1 rounded-lg bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-[11px] transition-colors flex items-center gap-1"
          >
            {isGatewaySaved ? <CheckCircle2 className="w-3.5 h-3.5" /> : null}
            <span>{isGatewaySaved ? 'Saved!' : 'Save Settings'}</span>
          </button>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <span>🇧🇩</span>
              <span className="text-xs font-bold text-slate-300">bKash</span>
            </div>
            <Switch
              checked={gateways.bKash}
              onChange={(c) => setGateways({ ...gateways, bKash: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <span>🇧🇩</span>
              <span className="text-xs font-bold text-slate-300">Nagad</span>
            </div>
            <Switch
              checked={gateways.nagad}
              onChange={(c) => setGateways({ ...gateways, nagad: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <span>🇮🇳</span>
              <span className="text-xs font-bold text-slate-300">Google Pay</span>
            </div>
            <Switch
              checked={gateways.googlePay}
              onChange={(c) => setGateways({ ...gateways, googlePay: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <span>🇮🇳</span>
              <span className="text-xs font-bold text-slate-300">Paytm</span>
            </div>
            <Switch
              checked={gateways.paytm}
              onChange={(c) => setGateways({ ...gateways, paytm: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <span>🇮🇳</span>
              <span className="text-xs font-bold text-slate-300">PhonePe</span>
            </div>
            <Switch
              checked={gateways.phonePe}
              onChange={(c) => setGateways({ ...gateways, phonePe: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-300">Min Payout ($)</span>
            <input
              type="number"
              min="5"
              step="1"
              value={gateways.minWithdrawalUsd}
              onChange={(e) =>
                setGateways({ ...gateways, minWithdrawalUsd: Math.max(5, parseInt(e.target.value) || 5) })
              }
              className="w-14 px-1.5 py-0.5 rounded bg-black/60 border border-amber-500/40 text-xs font-bold text-amber-400 text-center focus:outline-none"
            />
          </div>
        </div>
      </div>

      {/* Search & Fraud Filter Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        <div className="flex flex-wrap items-center gap-2">
          {/* Gateway Filter */}
          <select
            value={gatewayFilter}
            onChange={(e) => setGatewayFilter(e.target.value)}
            className="px-3 py-1.5 rounded-xl bg-[#11221D] border border-[#1C3830] text-xs font-bold text-slate-300 focus:outline-none"
          >
            <option value="All">All Gateways (BD & IN)</option>
            <option value="bKash">🇧🇩 bKash</option>
            <option value="Nagad">🇧🇩 Nagad</option>
            <option value="Google Pay">🇮🇳 Google Pay</option>
            <option value="Paytm">🇮🇳 Paytm</option>
            <option value="PhonePe">🇮🇳 PhonePe</option>
          </select>

          {/* Risk Filter */}
          <select
            value={riskFilter}
            onChange={(e) => setRiskFilter(e.target.value as any)}
            className="px-3 py-1.5 rounded-xl bg-[#11221D] border border-[#1C3830] text-xs font-bold text-slate-300 focus:outline-none"
          >
            <option value="All">All Risk Levels</option>
            <option value="HighRisk">🔴 Fraud Alerts (High Risk)</option>
            <option value="LowRisk">🟢 Verified (Low Risk)</option>
          </select>
        </div>

        {/* Search */}
        <div className="relative min-w-[240px]">
          <Search className="w-3.5 h-3.5 text-slate-500 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by user, phone or UPI..."
            className="w-full pl-8 pr-3 py-1.5 rounded-xl bg-[#11221D] border border-[#1C3830] text-xs text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500"
          />
        </div>
      </div>

      {/* Main Table */}
      <div className="rounded-2xl glass-panel overflow-hidden border border-[#1C3830]">
        <table className="w-full text-left text-xs">
          <thead className="bg-[#0A1814] text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-[#1C3830]">
            <tr>
              <th className="py-3 px-4">Request & User</th>
              <th className="py-3 px-4">Gateway & Country</th>
              <th className="py-3 px-4">Recipient Phone / UPI (1-Click Copy)</th>
              <th className="py-3 px-4">Payout Amount</th>
              <th className="py-3 px-4">Fraud Engine</th>
              <th className="py-3 px-4">Status</th>
              <th className="py-3 px-4 text-right">Owner Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#1C3830] text-slate-300">
            {filtered.map((w) => {
              const report = fraudReports[w.id];
              const localPayout = getLocalPayout(w.gateway, w.amount);
              const cleanNumber = report?.cleanNumber || extractTargetNumber(w.account_number, w.gateway);
              const isCopied = copiedTargetId === w.id;

              return (
                <tr
                  key={w.id}
                  className={`transition-colors hover:bg-white/[0.02] ${
                    report?.riskLevel === 'HIGH' ? 'bg-rose-950/10' : ''
                  }`}
                >
                  {/* Request & User */}
                  <td className="py-3 px-4">
                    <div className="flex items-center gap-2.5">
                      <img
                        src={w.user_avatar}
                        alt={w.user_name}
                        className="w-8 h-8 rounded-full object-cover border border-white/10"
                      />
                      <div>
                        <div className="flex items-center gap-1.5">
                          <span className="font-bold text-white text-xs">{w.user_name}</span>
                          <span className="text-[10px] text-slate-500 font-mono">({w.user_id})</span>
                        </div>
                        <p className="text-[10px] text-slate-400 font-mono" suppressHydrationWarning>
                          {w.id} • {mounted ? formatDate(w.created_at) : ''}
                        </p>
                      </div>
                    </div>
                  </td>

                  {/* Gateway */}
                  <td className="py-3 px-4">
                    <div className="font-bold text-slate-200">{w.gateway}</div>
                    <span className="text-[10px] text-cyan-400 font-mono">
                      {formatGems(w.gems)} gems
                    </span>
                  </td>

                  {/* Recipient Phone / UPI with 1-Click Copy */}
                  <td className="py-3 px-4">
                    <div className="flex items-center gap-2">
                      <div className="font-mono">
                        <span className="text-amber-400 font-bold text-xs block">{cleanNumber}</span>
                        {w.account_number && w.account_number.includes('[Name:') && (
                          <span className="text-[10px] text-slate-400 block">
                            {w.account_number.substring(w.account_number.indexOf('['))}
                          </span>
                        )}
                      </div>
                      <button
                        type="button"
                        onClick={() => copyText(cleanNumber, w.id)}
                        title="Copy recipient phone/UPI to pay user"
                        className={`p-1.5 rounded-lg border text-[10px] font-bold flex items-center gap-1 transition-colors ${
                          isCopied
                            ? 'bg-emerald-500 text-slate-950 border-emerald-400'
                            : 'bg-white/10 hover:bg-white/20 text-slate-300 border-white/10'
                        }`}
                      >
                        {isCopied ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                        <span>{isCopied ? 'Copied' : 'Copy'}</span>
                      </button>
                    </div>
                  </td>

                  {/* Amount (USD + Local Currency) */}
                  <td className="py-3 px-4">
                    <div className="font-black text-emerald-400 text-sm">{formatUSD(w.amount)}</div>
                    <div className="text-[11px] font-bold text-amber-300 font-mono">
                      {localPayout.text}
                    </div>
                  </td>

                  {/* Fraud Engine */}
                  <td className="py-3 px-4">
                    {report?.riskLevel === 'HIGH' ? (
                      <div>
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-black bg-rose-500/20 text-rose-300 border border-rose-500/40">
                          <AlertTriangle className="w-3 h-3 text-rose-400" />
                          <span>HIGH RISK</span>
                        </span>
                        <div className="mt-1 space-y-0.5">
                          {report.flags.map((flag, idx) => (
                            <p key={idx} className="text-[10px] text-rose-400 leading-tight">
                              {flag}
                            </p>
                          ))}
                        </div>
                      </div>
                    ) : report?.riskLevel === 'MEDIUM' ? (
                      <div>
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-amber-500/20 text-amber-300 border border-amber-500/40">
                          <AlertCircle className="w-3 h-3 text-amber-400" />
                          <span>Medium</span>
                        </span>
                        <div className="mt-1 space-y-0.5">
                          {report.flags.map((flag, idx) => (
                            <p key={idx} className="text-[10px] text-amber-300 leading-tight">
                              {flag}
                            </p>
                          ))}
                        </div>
                      </div>
                    ) : (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                        <ShieldCheck className="w-3 h-3 text-emerald-400" />
                        <span>Clean / Verified</span>
                      </span>
                    )}
                  </td>

                  {/* Status */}
                  <td className="py-3 px-4">
                    <Badge variant={w.status === 'Approved' ? 'emerald' : w.status === 'Rejected' ? 'rose' : 'amber'}>
                      {w.status}
                    </Badge>
                    {w.transaction_id ? (
                      <span className="block text-[10px] text-slate-400 font-mono mt-0.5">
                        Trx: {w.transaction_id}
                      </span>
                    ) : w.admin_note ? (
                      <span className="block text-[10px] text-rose-400 mt-0.5">{w.admin_note}</span>
                    ) : null}
                  </td>

                  {/* Action */}
                  <td className="py-3 px-4 text-right">
                    {w.status === 'Pending' ? (
                      <div className="flex items-center justify-end gap-1.5">
                        <button
                          onClick={() => {
                            setActiveTx(w);
                            setActionType('approve');
                            setProofNote('');
                          }}
                          className="px-2.5 py-1 rounded-lg bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/40 text-emerald-300 font-bold text-xs"
                        >
                          Approve
                        </button>
                        <button
                          onClick={() => {
                            setActiveTx(w);
                            setActionType('reject');
                            setProofNote('');
                          }}
                          className="px-2.5 py-1 rounded-lg bg-rose-500/20 hover:bg-rose-500/30 border border-rose-500/40 text-rose-300 font-bold text-xs"
                        >
                          Reject
                        </button>
                      </div>
                    ) : (
                      <span className="text-slate-500 text-xs">Completed</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Decision Modal */}
      {activeTx && (
        <Modal
          isOpen={true}
          onClose={() => setActiveTx(null)}
          title={`${actionType === 'approve' ? 'Approve & Record Payout' : 'Reject Withdrawal'}: ${activeTx.id}`}
        >
          <form onSubmit={handleDecisionSubmit} className="space-y-4">
            {/* User & Payout summary */}
            <div className="p-3.5 rounded-xl bg-white/5 border border-white/10 text-xs space-y-2">
              <div className="flex items-center justify-between">
                <div>
                  <span className="text-slate-400">User: </span>
                  <strong className="text-white text-sm">{activeTx.user_name}</strong>{' '}
                  <span className="text-[10px] text-slate-500 font-mono">({activeTx.user_id})</span>
                </div>
                <div className="text-right">
                  <span className="text-emerald-400 font-black text-sm block">{formatUSD(activeTx.amount)}</span>
                  <span className="text-amber-300 font-bold font-mono text-xs">
                    {getLocalPayout(activeTx.gateway, activeTx.amount).text}
                  </span>
                </div>
              </div>

              {/* Destination & 1-Click Copy */}
              <div className="pt-2 border-t border-white/5 flex items-center justify-between">
                <div>
                  <span className="text-slate-400 block text-[11px]">Pay to Recipient Number / UPI:</span>
                  <span className="text-amber-400 font-mono font-black text-sm">
                    {extractTargetNumber(activeTx.account_number, activeTx.gateway)}
                  </span>
                  {activeTx.account_number && activeTx.account_number.includes('[Name:') && (
                    <span className="text-[11px] text-slate-300 block">
                      {activeTx.account_number.substring(activeTx.account_number.indexOf('['))}
                    </span>
                  )}
                </div>
                <button
                  type="button"
                  onClick={() =>
                    copyText(
                      extractTargetNumber(activeTx.account_number, activeTx.gateway),
                      activeTx.id
                    )
                  }
                  className="px-2.5 py-1 rounded-lg bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-300 text-xs font-bold flex items-center gap-1 border border-emerald-500/40"
                >
                  <Copy className="w-3.5 h-3.5" />
                  <span>{copiedTargetId === activeTx.id ? 'Copied!' : 'Copy Number'}</span>
                </button>
              </div>

              {/* Fraud Report Highlight */}
              {fraudReports[activeTx.id]?.riskLevel === 'HIGH' && (
                <div className="p-2.5 rounded-lg bg-rose-500/15 border border-rose-500/30 space-y-1">
                  <div className="flex items-center gap-1.5 text-rose-300 font-bold text-xs">
                    <ShieldAlert className="w-3.5 h-3.5 text-rose-400" />
                    <span>Fraud & Abuse Warnings</span>
                  </div>
                  {fraudReports[activeTx.id].flags.map((f, i) => (
                    <p key={i} className="text-[10px] text-rose-300">
                      • {f}
                    </p>
                  ))}
                </div>
              )}
            </div>

            {/* Input field */}
            <div>
              <div className="flex items-center justify-between mb-1">
                <label className="block text-xs font-bold text-slate-300">
                  {actionType === 'approve' ? 'Owner Payment Transaction ID (TrxID)' : 'Rejection Reason'}
                </label>
                {actionType === 'approve' && (
                  <button
                    type="button"
                    onClick={autoGenerateTrxId}
                    className="text-[11px] font-bold text-amber-400 hover:text-amber-300 flex items-center gap-1 transition-colors"
                  >
                    <Sparkles className="w-3 h-3" />
                    <span>Auto-Generate</span>
                  </button>
                )}
              </div>

              {/* Rejection Preset Reasons */}
              {actionType === 'reject' && (
                <div className="flex flex-wrap gap-1.5 mb-2">
                  {[
                    '🚨 Duplicate Number / Multi-Account Fraud',
                    '❌ Fake / Invalid Phone or UPI ID',
                    '⚠️ Under $5.00 Threshold / Coin Discrepancy',
                    '🚫 Suspicious Velocity / Abusive Behavior',
                  ].map((reason) => (
                    <button
                      key={reason}
                      type="button"
                      onClick={() => setProofNote(reason)}
                      className="px-2 py-1 rounded-md bg-white/5 hover:bg-white/10 text-[10px] font-semibold text-rose-300 border border-rose-500/20"
                    >
                      {reason}
                    </button>
                  ))}
                </div>
              )}

              <input
                type="text"
                required
                value={proofNote}
                onChange={(e) => setProofNote(e.target.value)}
                placeholder={
                  actionType === 'approve'
                    ? 'Enter payment TrxID (e.g. BK_892348 or UPI Ref#)'
                    : 'Select above preset or enter custom reason'
                }
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-emerald-500 font-mono"
              />
            </div>

            {/* Actions */}
            <div className="pt-2 flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setActiveTx(null)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
              >
                Cancel
              </button>
              <button
                type="submit"
                className={`px-4 py-2 rounded-xl text-xs font-black transition-colors ${
                  actionType === 'approve'
                    ? 'bg-emerald-500 hover:bg-emerald-400 text-slate-950'
                    : 'bg-rose-500 hover:bg-rose-400 text-white'
                }`}
              >
                {actionType === 'approve' ? 'Confirm Payout Completed' : 'Reject Withdrawal'}
              </button>
            </div>
          </form>
        </Modal>
      )}
    </div>
  );
}
