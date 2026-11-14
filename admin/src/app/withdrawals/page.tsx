'use client';

import React, { useState, useEffect } from 'react';
import { supabase, WithdrawalRecord } from '../../shared/lib/supabase';
import { Badge } from '../../shared/components/ui/Badge';
import { Modal } from '../../shared/components/ui/Modal';
import { Switch } from '../../shared/components/ui/Switch';
import { formatGems, formatUSD, formatDate } from '../../shared/lib/utils';
import {
  DollarSign,
  Sliders,
  CheckCircle2,
  Wallet,
  Copy,
  Sparkles,
  Download,
  FileSpreadsheet,
} from 'lucide-react';

const mockWithdrawals: WithdrawalRecord[] = [
  {
    id: 'TX_WD_901',
    user_id: 'user_1003',
    user_name: 'Nusrat Jahan',
    user_avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    gateway: 'bKash (017XXXXXXXX)',
    amount: 50.0,
    gems: 2500000,
    status: 'Pending',
    created_at: new Date().toISOString(),
  },
  {
    id: 'TX_WD_902',
    user_id: 'user_1001',
    user_name: 'Tania Ahmed',
    user_avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    gateway: 'USDT (TRC20)',
    amount: 120.0,
    gems: 6000000,
    status: 'Pending',
    created_at: new Date(Date.now() - 3600000).toISOString(),
  },
  {
    id: 'TX_WD_899',
    user_id: 'user_1002',
    user_name: 'Killer Prince',
    user_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    gateway: 'Bank Transfer',
    amount: 350.0,
    gems: 17500000,
    status: 'Approved',
    created_at: new Date(Date.now() - 86400000).toISOString(),
  },
];

export default function WithdrawalsPage() {
  const [withdrawals, setWithdrawals] = useState<WithdrawalRecord[]>(mockWithdrawals);
  const [filter, setFilter] = useState<'All' | 'Pending' | 'Approved' | 'Rejected'>('All');
  const [activeTx, setActiveTx] = useState<WithdrawalRecord | null>(null);
  const [actionType, setActionType] = useState<'approve' | 'reject'>('approve');
  const [proofNote, setProofNote] = useState('');
  const [copiedTarget, setCopiedTarget] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  function exportWithdrawalsCSV() {
    const dataToExport = filtered.length > 0 ? filtered : withdrawals;
    const headers = [
      'ID',
      'Date',
      'User Name',
      'User ID',
      'Gateway',
      'Account / Phone Number',
      'Amount (USD)',
      'Gems',
      'Status',
      'Transaction ID',
      'Admin Note',
    ];

    const rows = dataToExport.map((w) => [
      `"${w.id}"`,
      `"${w.created_at || ''}"`,
      `"${(w.user_name || '').replace(/"/g, '""')}"`,
      `"${w.user_id || ''}"`,
      `"${(w.gateway || '').replace(/"/g, '""')}"`,
      `"${(w.account_number || '').replace(/"/g, '""')}"`,
      w.amount,
      w.gems,
      `"${w.status}"`,
      `"${(w.transaction_id || '').replace(/"/g, '""')}"`,
      `"${(w.admin_note || '').replace(/"/g, '""')}"`,
    ]);

    const csvContent =
      'data:text/csv;charset=utf-8,' +
      [headers.join(','), ...rows.map((e) => e.join(','))].join('\n');

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    const dateStr = new Date().toISOString().split('T')[0];
    link.setAttribute('download', `gamegala_withdrawals_${filter.toLowerCase()}_${dateStr}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  function autoGenerateTrxId() {
    const prefix = activeTx?.gateway?.toUpperCase().includes('BKASH')
      ? 'BK'
      : activeTx?.gateway?.toUpperCase().includes('NAGAD')
      ? 'NG'
      : activeTx?.gateway?.toUpperCase().includes('USDT')
      ? 'TX'
      : 'TRX';
    const rand = Math.random().toString(36).substring(2, 7).toUpperCase();
    const timePart = Date.now().toString(36).substring(3).toUpperCase();
    setProofNote(`${prefix}_${timePart}${rand}`);
  }

  function copyDestination() {
    const target = activeTx?.account_number || activeTx?.gateway || '';
    if (!target) return;
    navigator.clipboard.writeText(target);
    setCopiedTarget(true);
    setTimeout(() => setCopiedTarget(false), 2000);
  }

  const [gateways, setGateways] = useState({
    bKash: true,
    nagad: true,
    binanceUsdt: true,
    bankWire: true,
    paypal: false,
    minWithdrawalUsd: 20,
    dailyMaxPerUserUsd: 1000,
  });
  const [isGatewaySaved, setIsGatewaySaved] = useState(false);

  function handleSaveGateways() {
    setIsGatewaySaved(true);
    setTimeout(() => setIsGatewaySaved(false), 2000);
  }


  useEffect(() => {
    async function loadWithdrawals() {
      try {
        const { data } = await supabase
          .from('withdrawals')
          .select('*')
          .order('created_at', { ascending: false });

        if (data && data.length > 0) {
          setWithdrawals(data as WithdrawalRecord[]);
        }
      } catch {
        // mock fallback
      }
    }
    loadWithdrawals();
  }, []);

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
    } catch (e) {
      console.error(e);
    }

    setActiveTx(null);
    setProofNote('');
  }

  const filtered = withdrawals.filter((w) => {
    if (filter === 'All') return true;
    return w.status === filter;
  });

  const totalPendingUsd = withdrawals
    .filter((w) => w.status === 'Pending')
    .reduce((sum, w) => sum + w.amount, 0);

  const totalApprovedUsd = withdrawals
    .filter((w) => w.status === 'Approved')
    .reduce((sum, w) => sum + w.amount, 0);

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <DollarSign className="w-6 h-6 text-emerald-400" />
          <span>Withdrawals</span>
        </h2>

        <div className="flex flex-wrap items-center gap-2.5">
          <button
            onClick={exportWithdrawalsCSV}
            title="Download CSV spreadsheet of withdrawal transactions"
            className="px-3.5 py-1.5 rounded-xl bg-emerald-500/15 hover:bg-emerald-500/25 border border-emerald-500/40 text-emerald-300 font-bold text-xs flex items-center gap-1.5 transition-all shadow-sm"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Export CSV</span>
          </button>

          <div className="flex items-center gap-1.5 bg-[#11221D] p-1.5 rounded-xl border border-[#1C3830]">
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

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div className="p-4 rounded-2xl glass-panel border border-amber-500/20">
          <span className="text-xs font-bold text-slate-400 uppercase">Pending</span>
          <p className="text-xl font-black text-amber-400 mt-1">{formatUSD(totalPendingUsd)}</p>
        </div>

        <div className="p-4 rounded-2xl glass-panel border border-emerald-500/20">
          <span className="text-xs font-bold text-slate-400 uppercase">Disbursed</span>
          <p className="text-xl font-black text-emerald-400 mt-1">{formatUSD(totalApprovedUsd)}</p>
        </div>
      </div>


      {/* Payout Gateways & Threshold Controls */}
      <div className="p-4 rounded-2xl glass-panel border border-[#1C3830] space-y-3">
        <div className="flex items-center justify-between pb-2 border-b border-[#1C3830]">
          <h3 className="text-xs font-bold text-white flex items-center gap-2">
            <Sliders className="w-4 h-4 text-emerald-400" />
            <span>Payout Gateways & Minimum Thresholds</span>
          </h3>
          <button
            onClick={handleSaveGateways}
            className="px-3 py-1 rounded-lg bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-[11px] transition-colors flex items-center gap-1"
          >
            {isGatewaySaved ? <CheckCircle2 className="w-3.5 h-3.5" /> : null}
            <span>{isGatewaySaved ? 'Saved!' : 'Save Gateways'}</span>
          </button>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-300">bKash</span>
            <Switch
              checked={gateways.bKash}
              onChange={(c) => setGateways({ ...gateways, bKash: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-300">Nagad</span>
            <Switch
              checked={gateways.nagad}
              onChange={(c) => setGateways({ ...gateways, nagad: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-300">Binance</span>
            <Switch
              checked={gateways.binanceUsdt}
              onChange={(c) => setGateways({ ...gateways, binanceUsdt: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-300">Bank Wire</span>
            <Switch
              checked={gateways.bankWire}
              onChange={(c) => setGateways({ ...gateways, bankWire: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-300">PayPal</span>
            <Switch
              checked={gateways.paypal}
              onChange={(c) => setGateways({ ...gateways, paypal: c })}
            />
          </div>

          <div className="p-2.5 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-300">Min $</span>
            <input
              type="number"
              min="5"
              step="5"
              value={gateways.minWithdrawalUsd}
              onChange={(e) => setGateways({ ...gateways, minWithdrawalUsd: parseInt(e.target.value) || 20 })}
              className="w-14 px-1.5 py-0.5 rounded bg-black/60 border border-white/10 text-xs font-bold text-amber-400 text-center focus:outline-none"
            />
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="rounded-2xl glass-panel overflow-hidden border border-[#1C3830]">
        <table className="w-full text-left text-xs">
          <thead className="bg-[#0A1814] text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-[#1C3830]">
            <tr>
              <th className="py-3 px-4">ID & Date</th>
              <th className="py-3 px-4">Host</th>
              <th className="py-3 px-4">Gateway</th>
              <th className="py-3 px-4">Gems</th>
              <th className="py-3 px-4">USD</th>
              <th className="py-3 px-4">Status</th>
              <th className="py-3 px-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#1C3830] text-slate-300">
            {filtered.map((w) => (
              <tr key={w.id} className="hover:bg-white/[0.02] transition-colors">
                <td className="py-3 px-4 font-mono">
                  <p className="font-bold text-white text-xs">{w.id}</p>
                  <p className="text-[10px] text-slate-500" suppressHydrationWarning>
                    {mounted ? formatDate(w.created_at) : ''}
                  </p>
                </td>
                <td className="py-3 px-4">
                  <div className="flex items-center gap-2">
                    <img src={w.user_avatar} alt={w.user_name} className="w-7 h-7 rounded-full object-cover" />
                    <div>
                      <span className="font-bold text-white block">{w.user_name}</span>
                      <span className="text-[10px] text-slate-500 font-mono">{w.user_id}</span>
                    </div>
                  </div>
                </td>
                <td className="py-3 px-4 font-semibold text-slate-200">
                  <span>{w.gateway}</span>
                  {w.account_number ? (
                    <span className="block text-[11px] text-amber-400 font-mono">{w.account_number}</span>
                  ) : null}
                </td>
                <td className="py-3 px-4 font-bold text-cyan-400">{formatGems(w.gems)}</td>
                <td className="py-3 px-4 font-black text-emerald-400 text-sm">{formatUSD(w.amount)}</td>
                <td className="py-3 px-4">
                  <Badge variant={w.status === 'Approved' ? 'emerald' : w.status === 'Rejected' ? 'rose' : 'amber'}>
                    {w.status}
                  </Badge>
                  {w.transaction_id ? (
                    <span className="block text-[10px] text-slate-400 font-mono mt-0.5">Trx: {w.transaction_id}</span>
                  ) : w.admin_note ? (
                    <span className="block text-[10px] text-rose-400 mt-0.5">{w.admin_note}</span>
                  ) : null}
                </td>
                <td className="py-3 px-4 text-right">
                  {w.status === 'Pending' ? (
                    <div className="flex items-center justify-end gap-1.5">
                      <button
                        onClick={() => {
                          setActiveTx(w);
                          setActionType('approve');
                        }}
                        className="px-2.5 py-1 rounded-lg bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/40 text-emerald-300 font-bold text-xs"
                      >
                        Approve
                      </button>
                      <button
                        onClick={() => {
                          setActiveTx(w);
                          setActionType('reject');
                        }}
                        className="px-2.5 py-1 rounded-lg bg-rose-500/20 hover:bg-rose-500/30 border border-rose-500/40 text-rose-300 font-bold text-xs"
                      >
                        Reject
                      </button>
                    </div>
                  ) : (
                    <span className="text-slate-500 text-xs">Processed</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Modal */}
      {activeTx && (
        <Modal
          isOpen={true}
          onClose={() => setActiveTx(null)}
          title={`${actionType === 'approve' ? 'Approve' : 'Reject'}: ${activeTx.id}`}
        >
          <form onSubmit={handleDecisionSubmit} className="space-y-4">
            <div className="p-3 rounded-xl bg-white/5 border border-white/10 text-xs space-y-1.5">
              <p>User: <strong className="text-white">{activeTx.user_name}</strong> <span className="text-[10px] text-slate-500 font-mono">({activeTx.user_id})</span></p>
              <p>Amount: <strong className="text-emerald-400 font-bold">{formatUSD(activeTx.amount)}</strong> <span className="text-cyan-400">({formatGems(activeTx.gems)} gems)</span></p>
              <div className="flex items-center justify-between pt-1 border-t border-white/5">
                <p>
                  Destination:{' '}
                  <strong className="text-amber-400 font-mono">
                    {activeTx.account_number || activeTx.gateway}
                  </strong>
                </p>
                <button
                  type="button"
                  onClick={copyDestination}
                  className="px-2 py-0.5 rounded bg-white/10 hover:bg-white/20 text-slate-300 text-[10px] font-bold flex items-center gap-1 transition-colors"
                >
                  <Copy className="w-3 h-3" />
                  <span>{copiedTarget ? 'Copied!' : 'Copy'}</span>
                </button>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-1">
                <label className="block text-xs font-bold text-slate-300">
                  {actionType === 'approve' ? 'Transaction ID / Proof' : 'Rejection Reason'}
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
              <input
                type="text"
                required
                value={proofNote}
                onChange={(e) => setProofNote(e.target.value)}
                placeholder={actionType === 'approve' ? 'e.g. BLM98765432 or click Auto-Generate' : 'e.g. Invalid account details'}
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-emerald-500 font-mono"
              />
            </div>

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
                Confirm
              </button>
            </div>
          </form>
        </Modal>
      )}
    </div>
  );
}
