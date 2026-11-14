'use client';

import React, { useState, useEffect } from 'react';
import { supabase, RoomRecord } from '../../shared/lib/supabase';
import { Badge } from '../../shared/components/ui/Badge';
import { Modal } from '../../shared/components/ui/Modal';
import {
  Mic,
  MicOff,
  Lock,
  Unlock,
  Radio,
  Search,
  PowerOff,
  Megaphone,
  Send,
  AlertCircle,
  Headphones,
  Volume2,
  VolumeX,
  Activity,
} from 'lucide-react';

interface Seat {
  index: number;
  userName?: string;
  isMuted: boolean;
  isLocked: boolean;
}

const mockRooms: (RoomRecord & { seats: Seat[] })[] = [
  {
    id: 'room_bd_01',
    title: "Sadia's Royal Music & Chat",
    host_name: 'Sadia Islam',
    host_avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
    category: 'Chatroom',
    country: 'Bangladesh',
    country_flag: '🇧🇩',
    online_count: 28,
    status: 'live',
    created_at: new Date().toISOString(),
    seats: [
      { index: 1, userName: 'Tania Ahmed', isMuted: false, isLocked: false },
      { index: 2, userName: 'Ahmad_BD', isMuted: false, isLocked: false },
      { index: 3, userName: 'Nusrat Jahan', isMuted: true, isLocked: false },
      { index: 4, isMuted: false, isLocked: true },
      { index: 5, userName: 'Prince_99', isMuted: false, isLocked: false },
      { index: 6, isMuted: false, isLocked: false },
      { index: 7, isMuted: false, isLocked: false },
      { index: 8, isMuted: false, isLocked: true },
    ],
  },
  {
    id: 'room_pk_02',
    title: 'Lucky Race Turbo High Rollers 🏎️',
    host_name: 'Killer Prince',
    host_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    category: 'Lucky Race',
    country: 'Pakistan',
    country_flag: '🇵🇰',
    online_count: 54,
    status: 'live',
    created_at: new Date().toISOString(),
    seats: [
      { index: 1, userName: 'VIP_Boss', isMuted: false, isLocked: false },
      { index: 2, userName: 'LuckyRacer1', isMuted: false, isLocked: false },
      { index: 3, userName: 'GoldCoinKing', isMuted: false, isLocked: false },
      { index: 4, userName: 'SpeedDem0n', isMuted: false, isLocked: false },
      { index: 5, userName: 'Hunter_77', isMuted: false, isLocked: false },
      { index: 6, isMuted: false, isLocked: false },
      { index: 7, isMuted: false, isLocked: false },
      { index: 8, isMuted: false, isLocked: false },
    ],
  },
  {
    id: 'room_uae_03',
    title: 'Dubai PK Battle Finals 🏆',
    host_name: 'Ahmad Sheikh',
    host_avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    category: 'PK',
    country: 'United Arab Emirates',
    country_flag: '🇦🇪',
    online_count: 42,
    status: 'live',
    created_at: new Date().toISOString(),
    seats: [
      { index: 1, userName: 'Team_A_Leader', isMuted: false, isLocked: false },
      { index: 2, userName: 'Team_B_Leader', isMuted: false, isLocked: false },
      { index: 3, isMuted: false, isLocked: true },
      { index: 4, isMuted: false, isLocked: true },
      { index: 5, isMuted: false, isLocked: true },
      { index: 6, isMuted: false, isLocked: true },
      { index: 7, isMuted: false, isLocked: true },
      { index: 8, isMuted: false, isLocked: true },
    ],
  },
];

export default function RoomsPage() {
  const [rooms, setRooms] = useState(mockRooms);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [activeMonitorRoomId, setActiveMonitorRoomId] = useState<string | null>(null);
  const [isListeningMuted, setIsListeningMuted] = useState(false);
  const [listenerVolume, setListenerVolume] = useState(80);

  function toggleListenIn(roomId: string) {
    if (activeMonitorRoomId === roomId) {
      setActiveMonitorRoomId(null);
    } else {
      setActiveMonitorRoomId(roomId);
    }
  }

  useEffect(() => {
    async function loadRooms() {
      try {
        const { data } = await supabase
          .from('rooms')
          .select('*')
          .order('created_at', { ascending: false });
        if (data && data.length > 0) {
          const formatted = data.map((r: any) => ({
            ...r,
            seats: r.seats || [
              { index: 1, userName: r.host_name, isMuted: false, isLocked: false },
              { index: 2, isMuted: false, isLocked: false },
              { index: 3, isMuted: false, isLocked: false },
              { index: 4, isMuted: false, isLocked: false },
              { index: 5, isMuted: false, isLocked: false },
              { index: 6, isMuted: false, isLocked: false },
              { index: 7, isMuted: false, isLocked: false },
              { index: 8, isMuted: false, isLocked: false },
            ],
          }));
          setRooms(formatted);
        }
      } catch (err) {
        console.error('Error fetching rooms:', err);
      }
    }
    loadRooms();
  }, []);

  const [isAlertModalOpen, setIsAlertModalOpen] = useState(false);
  const [activeRoomAlert, setActiveRoomAlert] = useState<string | null>(
    '✨ Royal Audio Carnival is live! Send gifts to climb the Charm Leaderboard.'
  );
  const [alertText, setAlertText] = useState('');

  function handleSendRoomAlert(e: React.FormEvent) {
    e.preventDefault();
    if (!alertText) return;
    setActiveRoomAlert(alertText);
    setAlertText('');
    setIsAlertModalOpen(false);
  }


  async function terminateRoom(roomId: string) {
    if (!confirm('Close this live room?')) return;
    setRooms((prev) => prev.filter((r) => r.id !== roomId));
    try {
      await supabase.from('rooms').update({ status: 'closed' }).eq('id', roomId);
    } catch (e) {
      console.error(e);
    }
  }

  function toggleSeatMute(roomId: string, seatIndex: number) {
    setRooms((prev) =>
      prev.map((room) => {
        if (room.id !== roomId) return room;
        return {
          ...room,
          seats: room.seats.map((s) => (s.index === seatIndex ? { ...s, isMuted: !s.isMuted } : s)),
        };
      })
    );
  }

  function toggleSeatLock(roomId: string, seatIndex: number) {
    setRooms((prev) =>
      prev.map((room) => {
        if (room.id !== roomId) return room;
        return {
          ...room,
          seats: room.seats.map((s) => (s.index === seatIndex ? { ...s, isLocked: !s.isLocked } : s)),
        };
      })
    );
  }

  const filteredRooms = rooms.filter((r) => {
    const matchesSearch =
      r.title.toLowerCase().includes(search.toLowerCase()) ||
      r.host_name.toLowerCase().includes(search.toLowerCase());
    if (!matchesSearch) return false;
    if (categoryFilter !== 'All') return r.category === categoryFilter;
    return true;
  });

  const monitoredRoom = rooms.find((r) => r.id === activeMonitorRoomId);

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <Radio className="w-6 h-6 text-emerald-400" />
          <span>Audio Rooms</span>
        </h2>


        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsAlertModalOpen(true)}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-amber-500/15 hover:bg-amber-500/25 text-amber-300 font-bold text-xs border border-amber-500/30 transition-all"
          >
            <Megaphone className="w-3.5 h-3.5" />
            <span>Room Alert</span>
          </button>
        </div>

        {/* Category Filter */}
        <div className="flex items-center gap-1.5 bg-[#11221D] p-1.5 rounded-xl border border-[#1C3830]">
          {['All', 'Lucky Race', 'Lucky Number', 'Chatroom', 'PK'].map((cat) => (
            <button
              key={cat}
              onClick={() => setCategoryFilter(cat)}
              className={`px-3 py-1 rounded-lg text-xs font-bold transition-colors ${
                categoryFilter === cat
                  ? 'bg-emerald-500 text-slate-950 shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Live Audio Room Web Monitor (Listen-In Panel) */}
      {monitoredRoom && (
        <div className="p-4 rounded-2xl glass-panel border border-emerald-500/40 bg-gradient-to-r from-emerald-950/40 via-black/60 to-slate-950/80 shadow-lg shadow-emerald-950/30">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center text-emerald-400">
                <Headphones className="w-5 h-5 animate-pulse" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 text-[10px] font-bold border border-emerald-500/30">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping" />
                    LIVE AUDIO STREAM (SILENT ADMIN)
                  </span>
                  <span className="text-xs font-mono text-slate-400">{monitoredRoom.id}</span>
                </div>
                <h4 className="text-sm font-black text-white mt-0.5 flex items-center gap-1.5">
                  <span>{monitoredRoom.title}</span>
                  <span className="text-xs font-normal text-slate-400">({monitoredRoom.host_name})</span>
                </h4>
              </div>
            </div>

            {/* Audio Visualizer & Controls */}
            <div className="flex items-center gap-4 bg-black/40 px-3.5 py-2 rounded-xl border border-white/5">
              {/* Equalizer Wave simulation */}
              <div className="flex items-end gap-1 h-5 w-16">
                {[40, 90, 60, 100, 75, 45].map((h, i) => (
                  <span
                    key={i}
                    style={{ height: isListeningMuted ? '4px' : `${h}%` }}
                    className={`w-1.5 rounded-full transition-all duration-300 ${
                      isListeningMuted ? 'bg-slate-600' : 'bg-emerald-400 animate-pulse'
                    }`}
                  />
                ))}
              </div>

              {/* Volume Slider */}
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setIsListeningMuted(!isListeningMuted)}
                  className="text-slate-400 hover:text-white"
                  title={isListeningMuted ? 'Unmute' : 'Mute'}
                >
                  {isListeningMuted ? (
                    <VolumeX className="w-4 h-4 text-rose-400" />
                  ) : (
                    <Volume2 className="w-4 h-4 text-emerald-400" />
                  )}
                </button>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={isListeningMuted ? 0 : listenerVolume}
                  onChange={(e) => {
                    setListenerVolume(Number(e.target.value));
                    if (isListeningMuted) setIsListeningMuted(false);
                  }}
                  className="w-20 accent-emerald-400 h-1.5 cursor-pointer bg-slate-800 rounded-lg"
                />
                <span className="text-[11px] font-mono text-slate-300 w-7 text-right">
                  {isListeningMuted ? '0%' : `${listenerVolume}%`}
                </span>
              </div>

              {/* Stop Button */}
              <button
                onClick={() => setActiveMonitorRoomId(null)}
                className="px-2.5 py-1 rounded-lg bg-white/10 hover:bg-rose-500/20 hover:text-rose-300 text-xs font-bold text-slate-300 transition-colors"
              >
                Stop
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Search Bar */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search by room title or host name..."
          className="w-full pl-11 pr-4 py-3 rounded-2xl bg-[#11221D] border border-[#1C3830] text-sm text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500"
        />
      </div>

      {/* Rooms Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredRooms.map((room) => (
          <div
            key={room.id}
            className={`rounded-2xl glass-panel p-5 border flex flex-col justify-between transition-all duration-200 ${
              activeMonitorRoomId === room.id
                ? 'border-emerald-500 ring-2 ring-emerald-500/30 bg-emerald-950/20 shadow-lg shadow-emerald-950/40'
                : 'border-[#1C3830] hover:border-emerald-500/40'
            }`}
          >
            <div>
              <div className="flex items-start justify-between gap-3 mb-3">
                <div className="flex items-center gap-2.5">
                  <div className="w-10 h-10 rounded-xl overflow-hidden border border-emerald-500/30 flex-shrink-0">
                    <img src={room.host_avatar} alt={room.host_name} className="w-full h-full object-cover" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-white line-clamp-1">{room.title}</h3>
                    <p className="text-[11px] text-slate-400 flex items-center gap-1">
                      <span>{room.country_flag}</span>
                      <span>{room.host_name}</span>
                    </p>
                  </div>
                </div>
                <Badge variant={room.category === 'PK' ? 'rose' : room.category === 'Lucky Race' ? 'amber' : 'emerald'}>
                  {room.category}
                </Badge>
              </div>

              {/* Status bar */}
              <div className="flex items-center justify-between py-2 px-3 rounded-xl bg-white/5 text-xs text-slate-300 mb-4">
                <span className="flex items-center gap-1.5 font-bold text-emerald-400">
                  <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                  {room.online_count} Online
                </span>
                <span className="text-[10px] text-slate-500">ID: {room.id}</span>
              </div>

              {/* 8-Seat Mic Matrix */}
              <div className="mb-4">
                <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2">
                  Microphones (8 Mics)
                </p>
                <div className="grid grid-cols-4 gap-2">
                  {room.seats.map((seat) => (
                    <div
                      key={seat.index}
                      className={`p-2 rounded-xl text-center border transition-all ${
                        seat.isLocked
                          ? 'bg-rose-950/20 border-rose-500/30 text-rose-400'
                          : seat.userName
                          ? 'bg-emerald-950/30 border-emerald-500/40 text-emerald-300'
                          : 'bg-white/5 border-white/5 text-slate-500'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-[9px] font-bold">#{seat.index}</span>
                        <div className="flex gap-1">
                          <button
                            onClick={() => toggleSeatMute(room.id, seat.index)}
                            title={seat.isMuted ? 'Unmute' : 'Mute'}
                            className="text-slate-400 hover:text-white"
                          >
                            {seat.isMuted ? (
                              <MicOff className="w-2.5 h-2.5 text-rose-400" />
                            ) : (
                              <Mic className="w-2.5 h-2.5 text-emerald-400" />
                            )}
                          </button>
                          <button
                            onClick={() => toggleSeatLock(room.id, seat.index)}
                            title={seat.isLocked ? 'Unlock' : 'Lock'}
                            className="text-slate-400 hover:text-white"
                          >
                            {seat.isLocked ? (
                              <Lock className="w-2.5 h-2.5 text-rose-400" />
                            ) : (
                              <Unlock className="w-2.5 h-2.5 text-slate-400" />
                            )}
                          </button>
                        </div>
                      </div>
                      <p className="text-[10px] font-bold truncate">
                        {seat.isLocked ? 'Locked' : seat.userName || 'Open'}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Room Footer Actions */}
            <div className="pt-3 border-t border-[#1C3830] flex items-center justify-between">
              <button
                onClick={() => toggleListenIn(room.id)}
                className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl border text-xs font-bold transition-all ${
                  activeMonitorRoomId === room.id
                    ? 'bg-emerald-500 text-slate-950 border-emerald-400 shadow-md shadow-emerald-500/30 font-black'
                    : 'bg-emerald-500/15 hover:bg-emerald-500/25 border-emerald-500/30 text-emerald-300'
                }`}
              >
                <Headphones className="w-3.5 h-3.5" />
                <span>{activeMonitorRoomId === room.id ? 'Listening...' : 'Listen In'}</span>
              </button>

              <button
                onClick={() => terminateRoom(room.id)}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-rose-500/15 hover:bg-rose-500/25 border border-rose-500/30 text-rose-300 text-xs font-bold transition-colors"
              >
                <PowerOff className="w-3.5 h-3.5" />
                <span>Close Room</span>
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Active Pinned Announcement in Rooms */}
      {activeRoomAlert && (
        <div className="p-3.5 rounded-2xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-between text-xs text-amber-200">
          <div className="flex items-center gap-2">
            <Megaphone className="w-4 h-4 text-amber-400 flex-shrink-0" />
            <span>Pinned In-Room Notice: <strong className="text-white">{activeRoomAlert}</strong></span>
          </div>
          <button
            onClick={() => setActiveRoomAlert(null)}
            className="text-[11px] font-bold text-amber-400 hover:text-white px-2 py-0.5 rounded bg-amber-500/20"
          >
            Clear
          </button>
        </div>
      )}

      {/* Room Alert Modal */}
      <Modal isOpen={isAlertModalOpen} onClose={() => setIsAlertModalOpen(false)} title="Broadcast In-Room Banner Alert">
        <form onSubmit={handleSendRoomAlert} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Alert Message</label>
            <textarea
              required
              rows={3}
              value={alertText}
              onChange={(e) => setAlertText(e.target.value)}
              placeholder="e.g. Warning: Keep discussions respectful. Abusive microphone behavior results in a 24h ban."
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-amber-500 leading-relaxed"
            />
            <span className="text-[10px] text-slate-400 mt-1 block">
              This message will be pinned across all active 8-mic audio rooms in the mobile app.
            </span>
          </div>

          <div className="pt-2 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setIsAlertModalOpen(false)}
              className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-950 font-black text-xs transition-colors"
            >
              Broadcast to Rooms
            </button>
          </div>
        </form>
      </Modal>

    </div>
  );
}
