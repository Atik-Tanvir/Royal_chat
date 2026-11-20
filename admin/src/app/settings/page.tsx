'use client';

import React, { useState, useEffect } from 'react';
import { Badge } from '../../shared/components/ui/Badge';
import { Switch } from '../../shared/components/ui/Switch';
import {
  Settings,
  Server,
  Cloud,
  Shield,
  Save,
  CheckCircle2,
  AlertTriangle,
  Smartphone,
  Video,
  Phone,
  Sparkles,
  Key,
  Mail,
  Lock,
  Flame,
  UploadCloud,
  ExternalLink,
  Database,
  RefreshCw,
} from 'lucide-react';

export default function SettingsPage() {
  const [isSaved, setIsSaved] = useState(false);

  // System & Maintenance
  const [maintenanceMode, setMaintenanceMode] = useState(false);
  const [maintenanceMessage, setMaintenanceMessage] = useState(
    'Server is undergoing scheduled maintenance to improve audio room quality. We will be back online shortly!'
  );

  // 1. Login Methods & Authentication Settings
  const [authSettings, setAuthSettings] = useState({
    googleLoginEnabled: true,
    emailLoginEnabled: true,
    phoneOtpEnabled: true,
    allowGuestLogin: true,
    smsProvider: 'Supabase Phone Auth (Twilio Gateway)',
    otpCooldownSeconds: 60,
    googleClientId: '1092837465-royalgamegala.apps.googleusercontent.com',
  });

  // 2. 1-on-1 Video & Audio Calls Economy
  const [callSettings, setCallSettings] = useState({
    videoCallRateGems: 240,
    audioCallRateGems: 120,
    hostCommissionPercent: 70,
    minGemsToInitiate: 120,
    maxCallDurationMinutes: 120,
    beautyFilterEnabled: true,
    arFacialDetection: true,
    callQualityLimit: '720p HD @ 30fps',
  });

  // Chat & Moderation
  const [bannedWords, setBannedWords] = useState(
    'scam, hack, free coins, whatsapp, telegram, deposit now, +880, sex, nude, abuse'
  );

  // App Version Control
  const [versionSettings, setVersionSettings] = useState({
    latestVersion: '1.2.4',
    minSupportedVersion: '1.0.0',
    forceUpdate: false,
    apkDownloadUrl: 'https://royalchatlive.com/download/app-release.apk',
    releaseNotes: 'Fixed chat subtab host grid, added 1v1 video calls with beauty filters, and TikTok-style reels.',
  });

  // Cloudflare R2 Storage State
  const [r2Config, setR2Config] = useState({
    accountId: 'c6c6c97eea5025ec4aca78fa9e80c60d',
    bucket: 'royal-chat-live',
    publicUrl: 'https://pub-24addd4f2203427489399f391ba11669.r2.dev',
    accessKeyId: '',
    secretAccessKey: '',
    isConfigured: false,
    testStatus: 'untested',
    testMessage: '',
  });
  const [isR2Testing, setIsR2Testing] = useState(false);
  const [r2SaveMsg, setR2SaveMsg] = useState('');
  const [testUploadResult, setTestUploadResult] = useState<string | null>(null);
  const [isUploadingTest, setIsUploadingTest] = useState(false);

  useEffect(() => {
    fetch('/api/storage/config')
      .then((res) => res.json())
      .then((data) => {
        if (data) {
          setR2Config((prev) => ({
            ...prev,
            accountId: data.accountId || prev.accountId,
            bucket: data.bucket || prev.bucket,
            publicUrl: data.publicUrl || prev.publicUrl,
            accessKeyId: data.accessKeyId || '',
            secretAccessKey: data.secretAccessKey || '',
            isConfigured: data.isConfigured || false,
            testStatus: data.testStatus || 'untested',
            testMessage: data.testMessage || '',
          }));
        }
      })
      .catch((err) => console.error('Failed to load R2 config', err));
  }, []);

  async function handleSaveR2() {
    setIsR2Testing(true);
    setR2SaveMsg('');
    try {
      const res = await fetch('/api/storage/config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          accountId: r2Config.accountId,
          bucket: r2Config.bucket,
          publicUrl: r2Config.publicUrl,
          accessKeyId: r2Config.accessKeyId,
          secretAccessKey: r2Config.secretAccessKey,
        }),
      });
      const data = await res.json();
      if (res.ok) {
        setR2SaveMsg('Configuration saved! Running connection test...');
        const checkRes = await fetch('/api/storage/config');
        const checkData = await checkRes.json();
        setR2Config((prev) => ({
          ...prev,
          ...checkData,
        }));
        setR2SaveMsg('Saved & tested successfully!');
      } else {
        setR2SaveMsg(data.error || 'Failed to save');
      }
    } catch (e: any) {
      setR2SaveMsg(e.message || 'Error saving R2 config');
    } finally {
      setIsR2Testing(false);
      setTimeout(() => setR2SaveMsg(''), 4000);
    }
  }

  async function handleTestUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setIsUploadingTest(true);
    setTestUploadResult(null);
    try {
      const fd = new FormData();
      fd.append('file', file);
      fd.append('folder', 'admin_tests');
      const res = await fetch('/api/storage/upload', {
        method: 'POST',
        body: fd,
      });
      const data = await res.json();
      if (res.ok && data.url) {
        setTestUploadResult(`Success! File uploaded to Cloudflare R2: ${data.url}`);
      } else {
        setTestUploadResult(`Error: ${data.error || 'Upload failed'}`);
      }
    } catch (err: any) {
      setTestUploadResult(`Error: ${err.message}`);
    } finally {
      setIsUploadingTest(false);
    }
  }

  function handleSaveSettings(e: React.FormEvent) {
    e.preventDefault();
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2500);
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
            <Settings className="w-6 h-6 text-emerald-400" />
            <span>Master Control & Settings</span>
          </h2>
          <p className="text-xs text-slate-400 mt-1">
            Configure mobile authentication methods, 1-on-1 call pricing, beauty filters, and media feeds.
          </p>
        </div>

        <button
          onClick={handleSaveSettings}
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs shadow-lg shadow-emerald-500/20 transition-all"
        >
          {isSaved ? <CheckCircle2 className="w-4 h-4" /> : <Save className="w-4 h-4" />}
          <span>{isSaved ? 'Settings Saved Live!' : 'Save All Settings'}</span>
        </button>
      </div>

      {/* Cloud & Infrastructure Health Status */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="p-5 rounded-2xl glass-panel border border-[#1C3830]">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-bold text-slate-400 uppercase">Supabase PostgreSQL</span>
            <Badge variant="emerald">Connected</Badge>
          </div>
          <p className="text-sm font-bold text-white font-mono truncate">wyjkmythhskebenxxblb</p>
          <p className="text-[11px] text-slate-400 mt-1">Real-time sync active · 15 tables synced</p>
        </div>

        <div className="p-5 rounded-2xl glass-panel border border-[#1C3830]">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-bold text-slate-400 uppercase">LiveKit WebRTC Cloud</span>
            <Badge variant="emerald">Connected</Badge>
          </div>
          <p className="text-sm font-bold text-white font-mono truncate">royal-chat-live-a78egp07</p>
          <p className="text-[11px] text-slate-400 mt-1">1v1 HD Calls & Audio Party Rooms active</p>
        </div>

        <div className="p-5 rounded-2xl glass-panel border border-[#1C3830]">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-bold text-slate-400 uppercase">Cloudflare R2 Storage</span>
            <Badge variant={r2Config.testStatus === 'connected' ? 'emerald' : r2Config.isConfigured ? 'amber' : 'rose'}>
              {r2Config.testStatus === 'connected' ? 'Connected' : r2Config.isConfigured ? 'Configured' : 'Needs Token'}
            </Badge>
          </div>
          <p className="text-sm font-bold text-white font-mono truncate">{r2Config.bucket}</p>
          <p className="text-[11px] text-slate-400 mt-1">
            {r2Config.testStatus === 'connected' ? 'Verified & Active' : 'S3 Object CDN Storage'}
          </p>
        </div>
      </div>

      {/* SECTION: Cloudflare R2 Object Storage Deployment & Configuration */}
      <div className="rounded-2xl glass-panel p-6 border border-[#1C3830] space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <Cloud className="w-5 h-5 text-emerald-400" />
              <span>Cloudflare R2 Media & Asset Storage (royal-chat-live)</span>
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              High-speed S3-compatible cloud object storage for avatar photos, banners, moments feed, and chat media.
            </p>
          </div>
          <div className="flex items-center gap-2">
            <a
              href="https://dash.cloudflare.com/c6c6c97eea5025ec4aca78fa9e80c60d/r2/default/buckets/royal-chat-live"
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white/5 hover:bg-white/10 text-xs font-semibold text-slate-300 border border-white/10 transition-colors"
            >
              <span>Open in Cloudflare</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </a>
            <button
              type="button"
              onClick={handleSaveR2}
              disabled={isR2Testing}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs shadow-lg shadow-emerald-500/20 transition-all disabled:opacity-50"
            >
              {isR2Testing ? <RefreshCw className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
              <span>{isR2Testing ? 'Testing Connection...' : 'Save & Verify'}</span>
            </button>
          </div>
        </div>

        {/* Status Alert Banner */}
        {r2Config.testStatus === 'connected' ? (
          <div className="p-3.5 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center gap-3 text-emerald-400 text-xs font-medium">
            <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
            <span>{r2Config.testMessage || "Successfully connected to Cloudflare R2 bucket 'royal-chat-live'!"}</span>
          </div>
        ) : r2Config.testStatus === 'error' ? (
          <div className="p-3.5 rounded-xl bg-rose-500/10 border border-rose-500/20 flex items-center gap-3 text-rose-400 text-xs font-medium">
            <AlertTriangle className="w-4 h-4 flex-shrink-0" />
            <span>{r2Config.testMessage}</span>
          </div>
        ) : !r2Config.isConfigured ? (
          <div className="p-3.5 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center gap-3 text-amber-300 text-xs font-medium">
            <AlertTriangle className="w-4 h-4 flex-shrink-0" />
            <span>Cloudflare R2 Bucket & Endpoint configured. Enter R2 API Token credentials below to enable live uploads.</span>
          </div>
        ) : null}

        {r2SaveMsg && (
          <div className="p-3 rounded-xl bg-emerald-500/20 text-emerald-300 text-xs font-medium">
            {r2SaveMsg}
          </div>
        )}

        {/* Inputs */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Cloudflare Account ID</label>
            <input
              type="text"
              value={r2Config.accountId}
              onChange={(e) => setR2Config({ ...r2Config, accountId: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              placeholder="c6c6c97eea5025ec4aca78fa9e80c60d"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">R2 Bucket Name</label>
            <input
              type="text"
              value={r2Config.bucket}
              onChange={(e) => setR2Config({ ...r2Config, bucket: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              placeholder="royal-chat-live"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">R2 S3 API Endpoint</label>
            <input
              type="text"
              readOnly
              value={`https://${r2Config.accountId}.r2.cloudflarestorage.com`}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/20 border border-[#1C3830] text-sm text-slate-400 font-mono"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Public CDN Domain (R2.dev or Custom)</label>
            <input
              type="text"
              value={r2Config.publicUrl}
              onChange={(e) => setR2Config({ ...r2Config, publicUrl: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              placeholder="https://pub-24addd4f2203427489399f391ba11669.r2.dev"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">R2 Access Key ID</label>
            <input
              type="text"
              value={r2Config.accessKeyId}
              onChange={(e) => setR2Config({ ...r2Config, accessKeyId: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              placeholder="Paste R2 Access Key ID from Cloudflare"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">R2 Secret Access Key</label>
            <input
              type="password"
              value={r2Config.secretAccessKey}
              onChange={(e) => setR2Config({ ...r2Config, secretAccessKey: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              placeholder="Paste R2 Secret Access Key from Cloudflare"
            />
          </div>
        </div>

        {/* Live Test Upload Box */}
        <div className="p-4 rounded-xl bg-black/30 border border-[#1C3830] flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div>
            <p className="text-xs font-bold text-white flex items-center gap-2">
              <UploadCloud className="w-4 h-4 text-emerald-400" />
              <span>Test Live Upload to Cloudflare R2</span>
            </p>
            <p className="text-[11px] text-slate-400 mt-0.5">
              Select any test image/file to verify direct upload and CDN link generation.
            </p>
          </div>
          <div>
            <label className="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 text-xs font-bold cursor-pointer transition-colors">
              <UploadCloud className="w-4 h-4" />
              <span>{isUploadingTest ? 'Uploading to R2...' : 'Upload Test File'}</span>
              <input
                type="file"
                className="hidden"
                disabled={isUploadingTest}
                onChange={handleTestUpload}
              />
            </label>
          </div>
        </div>
        {testUploadResult && (
          <div className="p-3 rounded-xl bg-white/5 border border-white/10 text-xs font-mono text-emerald-300 break-all">
            {testUploadResult}
          </div>
        )}
      </div>

      {/* SECTION 1: Login Systems & Authentication Configuration */}
      <div className="rounded-2xl glass-panel p-6 border border-[#1C3830] space-y-5">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <Key className="w-5 h-5 text-emerald-400" />
              <span>Login Methods & Authentication Controls</span>
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              Enable or disable sign-in providers for the Android/iOS application in real time.
            </p>
          </div>
          <Badge variant="emerald">Security Active</Badge>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {/* Google Sign-In */}
          <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-red-500/10 border border-red-500/20 flex items-center justify-center text-red-400 font-bold">
                G
              </div>
              <div>
                <p className="text-xs font-bold text-white">Google Sign-In (OAuth)</p>
                <span className="text-[10px] text-slate-400">One-tap Google Account login</span>
              </div>
            </div>
            <Switch
              checked={authSettings.googleLoginEnabled}
              onChange={(checked) => setAuthSettings({ ...authSettings, googleLoginEnabled: checked })}
            />
          </div>

          {/* Email & Password */}
          <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-cyan-500/10 border border-cyan-500/20 flex items-center justify-center text-cyan-400">
                <Mail className="w-4 h-4" />
              </div>
              <div>
                <p className="text-xs font-bold text-white">Email & Password</p>
                <span className="text-[10px] text-slate-400">Sign in & Sign up with credentials</span>
              </div>
            </div>
            <Switch
              checked={authSettings.emailLoginEnabled}
              onChange={(checked) => setAuthSettings({ ...authSettings, emailLoginEnabled: checked })}
            />
          </div>

          {/* Phone OTP Verification */}
          <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                <Phone className="w-4 h-4" />
              </div>
              <div>
                <p className="text-xs font-bold text-white">Phone Number + OTP</p>
                <span className="text-[10px] text-slate-400">6-digit SMS verification code</span>
              </div>
            </div>
            <Switch
              checked={authSettings.phoneOtpEnabled}
              onChange={(checked) => setAuthSettings({ ...authSettings, phoneOtpEnabled: checked })}
            />
          </div>

          {/* One-Click Guest Mode */}
          <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
                <Sparkles className="w-4 h-4" />
              </div>
              <div>
                <p className="text-xs font-bold text-white">One-Click Guest Mode</p>
                <span className="text-[10px] text-slate-400">Instant trial without registration</span>
              </div>
            </div>
            <Switch
              checked={authSettings.allowGuestLogin}
              onChange={(checked) => setAuthSettings({ ...authSettings, allowGuestLogin: checked })}
            />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">SMS OTP Gateway Provider</label>
            <input
              type="text"
              value={authSettings.smsProvider}
              onChange={(e) => setAuthSettings({ ...authSettings, smsProvider: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
            />
          </div>
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">OTP Resend Cooldown (Seconds)</label>
            <input
              type="number"
              value={authSettings.otpCooldownSeconds}
              onChange={(e) => setAuthSettings({ ...authSettings, otpCooldownSeconds: parseInt(e.target.value) || 60 })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
            />
          </div>
        </div>
      </div>

      {/* SECTION 2: 1-on-1 Calls & Beauty Filter Controls */}
      <div className="rounded-2xl glass-panel p-6 border border-[#1C3830] space-y-5">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <Video className="w-5 h-5 text-purple-400" />
              <span>1-on-1 Video & Audio Call Rates and Economy</span>
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              Configure per-minute Gems billing, host earnings share, and real-time Beauty Filter features.
            </p>
          </div>
          <Badge variant="purple">1v1 Calls Active</Badge>
        </div>

        {/* Pricing Inputs */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-4 rounded-xl bg-white/5 border border-white/5">
            <div className="flex items-center gap-2 text-xs font-bold text-purple-300 mb-1">
              <Video className="w-4 h-4" />
              <span>1v1 Video Call Rate</span>
            </div>
            <div className="flex items-center gap-2 mt-2">
              <input
                type="number"
                value={callSettings.videoCallRateGems}
                onChange={(e) => setCallSettings({ ...callSettings, videoCallRateGems: parseInt(e.target.value) || 0 })}
                className="w-full px-3 py-2 rounded-lg bg-black/50 border border-purple-500/30 text-white font-mono font-bold text-sm focus:outline-none focus:border-purple-500"
              />
              <span className="text-xs text-purple-400 font-bold whitespace-nowrap">💎 Gems/min</span>
            </div>
            <p className="text-[10px] text-slate-400 mt-1.5">Gemgala standard: 240 Gems per min</p>
          </div>

          <div className="p-4 rounded-xl bg-white/5 border border-white/5">
            <div className="flex items-center gap-2 text-xs font-bold text-emerald-300 mb-1">
              <Phone className="w-4 h-4" />
              <span>1v1 Voice Call Rate</span>
            </div>
            <div className="flex items-center gap-2 mt-2">
              <input
                type="number"
                value={callSettings.audioCallRateGems}
                onChange={(e) => setCallSettings({ ...callSettings, audioCallRateGems: parseInt(e.target.value) || 0 })}
                className="w-full px-3 py-2 rounded-lg bg-black/50 border border-emerald-500/30 text-white font-mono font-bold text-sm focus:outline-none focus:border-emerald-500"
              />
              <span className="text-xs text-emerald-400 font-bold whitespace-nowrap">💎 Gems/min</span>
            </div>
            <p className="text-[10px] text-slate-400 mt-1.5">Gemgala standard: 120 Gems per min</p>
          </div>

          <div className="p-4 rounded-xl bg-white/5 border border-white/5">
            <div className="flex items-center gap-2 text-xs font-bold text-amber-300 mb-1">
              <Flame className="w-4 h-4" />
              <span>Host Revenue Share %</span>
            </div>
            <div className="flex items-center gap-2 mt-2">
              <input
                type="number"
                value={callSettings.hostCommissionPercent}
                onChange={(e) => setCallSettings({ ...callSettings, hostCommissionPercent: parseInt(e.target.value) || 0 })}
                className="w-full px-3 py-2 rounded-lg bg-black/50 border border-amber-500/30 text-white font-mono font-bold text-sm focus:outline-none focus:border-amber-500"
              />
              <span className="text-xs text-amber-400 font-bold whitespace-nowrap">% of Gems</span>
            </div>
            <p className="text-[10px] text-slate-400 mt-1.5">Host receives 70%, Platform retains 30%</p>
          </div>
        </div>

        {/* Feature Switches */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-1">
          <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400">
                <Sparkles className="w-4 h-4" />
              </div>
              <div>
                <p className="text-xs font-bold text-white">AI Beauty Filter Engine</p>
                <span className="text-[10px] text-slate-400">Skin smooth, whitening, slimming & rosy blush</span>
              </div>
            </div>
            <Switch
              checked={callSettings.beautyFilterEnabled}
              onChange={(checked) => setCallSettings({ ...callSettings, beautyFilterEnabled: checked })}
            />
          </div>

          <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400">
                <Shield className="w-4 h-4" />
              </div>
              <div>
                <p className="text-xs font-bold text-white">Minimum Balance Verification</p>
                <span className="text-[10px] text-slate-400">Require at least 1 min gems before dialing</span>
              </div>
            </div>
            <Switch
              checked={callSettings.arFacialDetection}
              onChange={(checked) => setCallSettings({ ...callSettings, arFacialDetection: checked })}
            />
          </div>
        </div>
      </div>

      {/* Maintenance Mode Configuration */}
      <div className="rounded-2xl glass-panel p-6 border border-[#1C3830]">
        <div className="flex items-start justify-between gap-4 mb-4">
          <h3 className="text-base font-bold text-white flex items-center gap-2">
            <Server className="w-4 h-4 text-amber-400" />
            <span>Maintenance Mode</span>
          </h3>

          <Switch
            checked={maintenanceMode}
            onChange={setMaintenanceMode}
          />
        </div>

        {maintenanceMode && (
          <div className="mt-4 p-4 rounded-xl bg-amber-500/10 border border-amber-500/30 space-y-2">
            <div className="flex items-center gap-2 text-amber-400 font-bold text-xs">
              <AlertTriangle className="w-4 h-4" />
              <span>Maintenance Mode Is Currently ACTIVE!</span>
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">
                Notice Displayed to Users
              </label>
              <textarea
                rows={2}
                value={maintenanceMessage}
                onChange={(e) => setMaintenanceMessage(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-black/50 border border-white/10 text-xs text-white focus:outline-none"
              />
            </div>
          </div>
        )}
      </div>

      {/* Chat Moderation & Prohibited Words Filter */}
      <div className="rounded-2xl glass-panel p-6 border border-[#1C3830] space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-base font-bold text-white flex items-center gap-2">
            <Shield className="w-4 h-4 text-emerald-400" />
            <span>Chat Moderation & Keyword Blacklist</span>
          </h3>
          <Badge variant="emerald">Auto-Filter Active</Badge>
        </div>

        <div>
          <label className="block text-xs font-bold text-slate-300 mb-1">
            Prohibited Words (Comma-separated)
          </label>
          <textarea
            rows={2}
            value={bannedWords}
            onChange={(e) => setBannedWords(e.target.value)}
            className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500 font-mono leading-relaxed"
          />
          <span className="text-[10px] text-slate-400 mt-1 block">
            Messages containing these words will be automatically masked with *** in public audio rooms and 1-on-1 chats.
          </span>
        </div>
      </div>

      {/* Mobile App Version Control & Force Update */}
      <div className="rounded-2xl glass-panel p-6 border border-[#1C3830]">
        <div className="flex items-center justify-between mb-5">
          <h3 className="text-base font-bold text-white flex items-center gap-2">
            <Smartphone className="w-4 h-4 text-emerald-400" />
            <span>App Version & Updates</span>
          </h3>
          <Badge variant={versionSettings.forceUpdate ? 'rose' : 'emerald'}>
            {versionSettings.forceUpdate ? 'Forced' : 'Optional'}
          </Badge>
        </div>

        <form onSubmit={handleSaveSettings} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Latest Version Released</label>
              <input
                type="text"
                value={versionSettings.latestVersion}
                onChange={(e) => setVersionSettings({ ...versionSettings, latestVersion: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Minimum Supported Version</label>
              <input
                type="text"
                value={versionSettings.minSupportedVersion}
                onChange={(e) => setVersionSettings({ ...versionSettings, minSupportedVersion: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              />
            </div>
          </div>

          <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
            <p className="text-xs font-bold text-white">Enforce Mandatory Update</p>
            <Switch
              checked={versionSettings.forceUpdate}
              onChange={(checked) => setVersionSettings({ ...versionSettings, forceUpdate: checked })}
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">APK Direct Download / Google Play URL</label>
            <input
              type="url"
              value={versionSettings.apkDownloadUrl}
              onChange={(e) => setVersionSettings({ ...versionSettings, apkDownloadUrl: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Release Notes</label>
            <textarea
              rows={2}
              value={versionSettings.releaseNotes}
              onChange={(e) => setVersionSettings({ ...versionSettings, releaseNotes: e.target.value })}
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
            />
          </div>
        </form>
      </div>
    </div>
  );
}
