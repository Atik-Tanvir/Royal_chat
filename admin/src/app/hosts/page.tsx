'use client';

import React, { useState } from 'react';
import { Badge } from '../../shared/components/ui/Badge';
import { formatGems } from '../../shared/lib/utils';
import {
  Award,
  Check,
  X,
  FileText,
} from 'lucide-react';

interface HostApplication {
  id: string;
  userName: string;
  userId: string;
  avatarUrl: string;
  country: string;
  countryFlag: string;
  agencyCode: string;
  talentType: string;
  appliedDate: string;
  socialLink: string;
  status: 'Pending' | 'Approved' | 'Rejected';
}

interface Agency {
  id: string;
  name: string;
  code: string;
  ownerName: string;
  country: string;
  countryFlag: string;
  hostsCount: number;
  commissionRate: number;
  monthlyDiamondVolume: number;
  status: 'Active' | 'Suspended';
}

export default function HostsAgencyPage() {
  const [tab, setTab] = useState<'applications' | 'agencies'>('applications');

  const [applications, setApplications] = useState<HostApplication[]>([
    {
      id: 'app_1',
      userName: 'Nusrat Jahan',
      userId: 'user_1003',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      country: 'Bangladesh',
      countryFlag: '🇧🇩',
      agencyCode: 'ROYAL_BD_01',
      talentType: 'Singing & Audio Chat',
      appliedDate: '2026-10-28',
      socialLink: 'instagram.com/nusrat_live',
      status: 'Pending',
    },
    {
      id: 'app_2',
      userName: 'Ayesha Rahman',
      userId: 'user_1005',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
      country: 'Bangladesh',
      countryFlag: '🇧🇩',
      agencyCode: 'ROYAL_BD_01',
      talentType: 'Storytelling & Music',
      appliedDate: '2026-10-27',
      socialLink: 'facebook.com/ayesha_official',
      status: 'Pending',
    },
    {
      id: 'app_3',
      userName: 'Farzana Mimi',
      userId: 'user_1006',
      avatarUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150',
      country: 'Bangladesh',
      countryFlag: '🇧🇩',
      agencyCode: 'DIRECT_OFFICIAL',
      talentType: 'PK Battle Gamer',
      appliedDate: '2026-10-26',
      socialLink: 'tiktok.com/@farzana_mimi',
      status: 'Approved',
    },
  ]);

  const [agencies] = useState<Agency[]>([
    {
      id: 'ag_1',
      name: 'Royal Bengal Agency',
      code: 'ROYAL_BD_01',
      ownerName: 'Tanvir Hossain',
      country: 'Bangladesh',
      countryFlag: '🇧🇩',
      hostsCount: 48,
      commissionRate: 15,
      monthlyDiamondVolume: 12500000,
      status: 'Active',
    },
    {
      id: 'ag_2',
      name: 'Gulf Stars Talent Group',
      code: 'GULF_TALENT',
      ownerName: 'Ahmad Al-Mansoor',
      country: 'UAE',
      countryFlag: '🇦🇪',
      hostsCount: 65,
      commissionRate: 18,
      monthlyDiamondVolume: 42000000,
      status: 'Active',
    },
  ]);

  function handleApplicationDecision(id: string, decision: 'Approved' | 'Rejected') {
    setApplications((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: decision } : a))
    );
  }

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <Award className="w-6 h-6 text-amber-400" />
          <span>Host Recruitment</span>
        </h2>

        {/* Tab switcher */}
        <div className="flex items-center gap-1.5 bg-[#11221D] p-1.5 rounded-xl border border-[#1C3830]">
          <button
            onClick={() => setTab('applications')}
            className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors ${
              tab === 'applications'
                ? 'bg-emerald-500 text-slate-950 shadow-sm'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            Applications ({applications.filter((a) => a.status === 'Pending').length})
          </button>
          <button
            onClick={() => setTab('agencies')}
            className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors ${
              tab === 'agencies'
                ? 'bg-emerald-500 text-slate-950 shadow-sm'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            Agencies ({agencies.length})
          </button>
        </div>
      </div>

      {/* Applications List */}
      {tab === 'applications' && (
        <div className="rounded-2xl glass-panel overflow-hidden border border-[#1C3830]">
          <div className="p-4 border-b border-[#1C3830] flex items-center justify-between">
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              <FileText className="w-4 h-4 text-emerald-400" />
              <span>Applications</span>
            </h3>
            <span className="text-xs text-slate-500 font-mono">{applications.length} Total</span>
          </div>

          <div className="divide-y divide-[#1C3830]">
            {applications.map((app) => (
              <div
                key={app.id}
                className="p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3 hover:bg-white/[0.02] transition-colors"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl overflow-hidden border border-white/10 flex-shrink-0">
                    <img src={app.avatarUrl} alt={app.userName} className="w-full h-full object-cover" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="font-bold text-xs text-white">{app.userName}</h4>
                      <span className="text-xs">{app.countryFlag}</span>
                      <Badge variant={app.status === 'Approved' ? 'emerald' : app.status === 'Rejected' ? 'rose' : 'amber'}>
                        {app.status}
                      </Badge>
                    </div>
                    <p className="text-[11px] text-slate-400 mt-0.5">
                      {app.talentType} · Agency: <span className="text-amber-400 font-mono">{app.agencyCode}</span>
                    </p>
                  </div>
                </div>

                {app.status === 'Pending' ? (
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => handleApplicationDecision(app.id, 'Approved')}
                      className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl bg-emerald-500/20 hover:bg-emerald-500/30 border border-emerald-500/40 text-emerald-300 font-bold text-xs transition-colors"
                    >
                      <Check className="w-3.5 h-3.5" />
                      <span>Approve</span>
                    </button>
                    <button
                      onClick={() => handleApplicationDecision(app.id, 'Rejected')}
                      className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl bg-rose-500/20 hover:bg-rose-500/30 border border-rose-500/40 text-rose-300 font-bold text-xs transition-colors"
                    >
                      <X className="w-3.5 h-3.5" />
                      <span>Reject</span>
                    </button>
                  </div>
                ) : (
                  <span className="text-xs font-bold text-slate-500">Resolved</span>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Agencies List */}
      {tab === 'agencies' && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {agencies.map((agency) => (
            <div
              key={agency.id}
              className="p-5 rounded-2xl glass-panel border border-[#1C3830] flex flex-col justify-between"
            >
              <div>
                <div className="flex items-start justify-between gap-3 mb-3">
                  <div>
                    <h4 className="text-sm font-bold text-white flex items-center gap-1.5">
                      <span>{agency.name}</span>
                      <span>{agency.countryFlag}</span>
                    </h4>
                    <p className="text-xs text-slate-400">
                      Code: <strong className="text-amber-400 font-mono">{agency.code}</strong> · Owner: {agency.ownerName}
                    </p>
                  </div>
                  <Badge variant={agency.status === 'Active' ? 'emerald' : 'rose'}>{agency.status}</Badge>
                </div>

                <div className="grid grid-cols-2 gap-2 my-3">
                  <div className="p-2 rounded-xl bg-white/5 border border-white/5 text-center">
                    <span className="text-[10px] text-slate-400 uppercase font-bold block">Hosts</span>
                    <span className="text-xs font-black text-white">{agency.hostsCount} Verified</span>
                  </div>
                  <div className="p-2 rounded-xl bg-white/5 border border-white/5 text-center">
                    <span className="text-[10px] text-slate-400 uppercase font-bold block">Commission</span>
                    <span className="text-xs font-black text-emerald-400">{agency.commissionRate}%</span>
                  </div>
                </div>
              </div>

              <div className="pt-3 border-t border-[#1C3830] flex items-center justify-between text-xs text-slate-400">
                <span>Volume: {formatGems(agency.monthlyDiamondVolume)}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
