'use client';

import React, { useState, useEffect } from 'react';
import { supabase, MomentRecord } from '../../shared/lib/supabase';
import { Badge } from '../../shared/components/ui/Badge';
import { formatDate } from '../../shared/lib/utils';
import {
  Compass,
  Trash2,
  Heart,
  MessageCircle,
  Pin,
  Search,
  Video,
  Image as ImageIcon,
  CheckCircle,
  AlertTriangle,
  Play,
  Film,
} from 'lucide-react';

const mockMoments: MomentRecord[] = [
  {
    id: 'moment_1',
    user_id: 'user_1001',
    user_name: 'Tania Ahmed',
    user_avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    content: 'Had an awesome voice party session today with my fans! Thanks for the Ferrari supercar gifts 🏎️💖 #party #live',
    media_urls: ['https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800'],
    likes_count: 1420,
    comments_count: 88,
    category: 'Video',
    created_at: new Date().toISOString(),
  },
  {
    id: 'moment_2',
    user_id: 'user_1002',
    user_name: 'Killer Prince',
    user_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    content: 'Ready for the PK Battle tonight! Join room #2 at 9 PM sharp! 🔥🏆 #gemgala #pk',
    media_urls: ['https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800'],
    likes_count: 3890,
    comments_count: 164,
    category: 'Video',
    created_at: new Date(Date.now() - 7200000).toISOString(),
  },
  {
    id: 'moment_3',
    user_id: 'user_1003',
    user_name: 'Zoya Khan ✨',
    user_avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    content: 'Enjoying the evening with my royal family in Dhaka 🌸 Photo from our garden!',
    media_urls: ['https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800'],
    likes_count: 640,
    comments_count: 42,
    category: 'Moments',
    created_at: new Date(Date.now() - 10800000).toISOString(),
  },
  {
    id: 'moment_4',
    user_id: 'user_1004',
    user_name: 'Rohan_Spammer',
    user_avatar: '',
    content: 'Free coins hack link click here: http://fake-coins.xyz to claim 100K coins immediately!!',
    media_urls: [],
    likes_count: 0,
    comments_count: 2,
    category: 'Spam',
    created_at: new Date(Date.now() - 14400000).toISOString(),
  },
];

export default function MomentsPage() {
  const [moments, setMoments] = useState<MomentRecord[]>(mockMoments);
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState<'All' | 'Moments' | 'Video' | 'Spam'>('All');
  const [pinnedIds, setPinnedIds] = useState<Set<String>>(new Set(['moment_1']));

  useEffect(() => {
    async function loadMoments() {
      try {
        const { data } = await supabase
          .from('moments')
          .select('*')
          .order('created_at', { ascending: false });

        if (data && data.length > 0) {
          setMoments(data as MomentRecord[]);
        }
      } catch {
        // mock fallback
      }
    }
    loadMoments();
  }, []);

  async function deletePost(id: string) {
    if (!confirm('Are you sure you want to permanently delete this post?')) return;
    setMoments((prev) => prev.filter((m) => m.id !== id));
    try {
      await supabase.from('moments').delete().eq('id', id);
    } catch (e) {
      console.error(e);
    }
  }

  function togglePin(id: string) {
    setPinnedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  // Filter based on search and tab
  const filtered = moments.filter((m) => {
    const matchesSearch =
      m.content.toLowerCase().includes(search.toLowerCase()) ||
      m.user_name.toLowerCase().includes(search.toLowerCase());

    if (!matchesSearch) return false;

    if (activeTab === 'All') return true;
    if (activeTab === 'Video') return m.category === 'Video' || m.content.includes('#reels');
    if (activeTab === 'Moments') return m.category === 'Moments';
    if (activeTab === 'Spam') return m.category === 'Spam';

    return true;
  });

  const videoCount = moments.filter((m) => m.category === 'Video').length;
  const photoCount = moments.filter((m) => m.category === 'Moments').length;
  const spamCount = moments.filter((m) => m.category === 'Spam').length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
            <Compass className="w-6 h-6 text-emerald-400" />
            <span>Feed & TikTok Reels Moderation</span>
          </h2>
          <p className="text-xs text-slate-400 mt-1">
            Review user-posted Moments, TikTok vertical Video Reels, and filter spam.
          </p>
        </div>

        <div className="w-full sm:w-72 relative">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search captions or creators..."
            className="w-full pl-9 pr-3.5 py-2.5 rounded-xl bg-[#11221D] border border-[#1C3830] text-xs text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500"
          />
        </div>
      </div>

      {/* Metric Stat Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="p-4 rounded-xl glass-panel border border-[#1C3830]">
          <span className="text-[11px] font-bold text-slate-400 uppercase">Total Posts</span>
          <p className="text-xl font-black text-white mt-1">{moments.length}</p>
        </div>
        <div className="p-4 rounded-xl glass-panel border border-[#1C3830]">
          <span className="text-[11px] font-bold text-purple-400 uppercase flex items-center gap-1">
            <Film className="w-3.5 h-3.5" />
            <span>TikTok Reels</span>
          </span>
          <p className="text-xl font-black text-purple-300 mt-1">{videoCount}</p>
        </div>
        <div className="p-4 rounded-xl glass-panel border border-[#1C3830]">
          <span className="text-[11px] font-bold text-emerald-400 uppercase flex items-center gap-1">
            <ImageIcon className="w-3.5 h-3.5" />
            <span>Photo Moments</span>
          </span>
          <p className="text-xl font-black text-emerald-300 mt-1">{photoCount}</p>
        </div>
        <div className="p-4 rounded-xl glass-panel border border-[#1C3830]">
          <span className="text-[11px] font-bold text-rose-400 uppercase flex items-center gap-1">
            <AlertTriangle className="w-3.5 h-3.5" />
            <span>Spam Flagged</span>
          </span>
          <p className="text-xl font-black text-rose-300 mt-1">{spamCount}</p>
        </div>
      </div>

      {/* Tab Filter Bar */}
      <div className="flex items-center gap-2 border-b border-[#1C3830] pb-3">
        <button
          onClick={() => setActiveTab('All')}
          className={`px-4 py-1.5 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'All'
              ? 'bg-emerald-500 text-slate-950 shadow-md shadow-emerald-500/20'
              : 'text-slate-400 hover:text-white hover:bg-white/5'
          }`}
        >
          All Feeds ({moments.length})
        </button>

        <button
          onClick={() => setActiveTab('Video')}
          className={`px-4 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-all ${
            activeTab === 'Video'
              ? 'bg-purple-500 text-white shadow-md shadow-purple-500/20'
              : 'text-slate-400 hover:text-white hover:bg-white/5'
          }`}
        >
          <Film className="w-3.5 h-3.5" />
          <span>TikTok Reels ({videoCount})</span>
        </button>

        <button
          onClick={() => setActiveTab('Moments')}
          className={`px-4 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-all ${
            activeTab === 'Moments'
              ? 'bg-emerald-500 text-slate-950 shadow-md shadow-emerald-500/20'
              : 'text-slate-400 hover:text-white hover:bg-white/5'
          }`}
        >
          <ImageIcon className="w-3.5 h-3.5" />
          <span>Photo Moments ({photoCount})</span>
        </button>

        <button
          onClick={() => setActiveTab('Spam')}
          className={`px-4 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-all ${
            activeTab === 'Spam'
              ? 'bg-rose-500 text-white shadow-md shadow-rose-500/20'
              : 'text-slate-400 hover:text-white hover:bg-white/5'
          }`}
        >
          <AlertTriangle className="w-3.5 h-3.5" />
          <span>Spam ({spamCount})</span>
        </button>
      </div>

      {/* Posts List */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filtered.map((moment) => {
          const isPinned = pinnedIds.has(moment.id);
          const isVideoReel = moment.category === 'Video' || moment.content.includes('#reels');

          return (
            <div
              key={moment.id}
              className={`rounded-2xl glass-panel p-4 border flex flex-col justify-between transition-all ${
                isPinned ? 'border-amber-400/50 bg-amber-500/[0.04]' : 'border-[#1C3830]'
              }`}
            >
              <div>
                {/* Author Info + Category Badge */}
                <div className="flex items-center justify-between mb-2.5">
                  <div className="flex items-center gap-2">
                    <div className="w-9 h-9 rounded-full bg-slate-800 overflow-hidden border border-white/10 flex items-center justify-center font-bold text-xs text-white">
                      {moment.user_avatar ? (
                        <img src={moment.user_avatar} alt={moment.user_name} className="w-full h-full object-cover" />
                      ) : (
                        moment.user_name.substring(0, 2)
                      )}
                    </div>
                    <div>
                      <h4 className="font-bold text-xs text-white flex items-center gap-1">
                        <span>{moment.user_name}</span>
                        {isPinned && <span className="text-[10px] text-amber-400 font-bold">★ Pinned</span>}
                      </h4>
                      <span className="text-[10px] text-slate-500">{formatDate(moment.created_at)}</span>
                    </div>
                  </div>

                  <Badge variant={moment.category === 'Spam' ? 'rose' : isVideoReel ? 'purple' : 'emerald'}>
                    {isVideoReel ? '🎬 Reel' : moment.category}
                  </Badge>
                </div>

                <p className="text-xs text-slate-300 leading-relaxed mb-3">{moment.content}</p>

                {/* Media preview */}
                {moment.media_urls && moment.media_urls.length > 0 && (
                  <div className="relative w-full h-44 rounded-xl overflow-hidden mb-3 bg-black/40 border border-white/5 group">
                    <img
                      src={moment.media_urls[0]}
                      alt="Post media"
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                    {isVideoReel && (
                      <div className="absolute inset-0 bg-black/30 flex items-center justify-center">
                        <div className="w-10 h-10 rounded-full bg-purple-600/90 text-white flex items-center justify-center shadow-lg">
                          <Play className="w-5 h-5 ml-0.5 fill-current" />
                        </div>
                        <span className="absolute bottom-2 left-2 px-2 py-0.5 rounded-md bg-black/70 text-[10px] font-bold text-white flex items-center gap-1">
                          <Film className="w-3 h-3 text-purple-400" />
                          <span>TikTok Reel</span>
                        </span>
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* Engagement & Controls Footer */}
              <div className="pt-2.5 border-t border-white/5 flex items-center justify-between text-xs text-slate-400">
                <div className="flex items-center gap-3">
                  <span className="flex items-center gap-1 text-[11px]">
                    <Heart className="w-3.5 h-3.5 text-rose-400" />
                    {moment.likes_count}
                  </span>
                  <span className="flex items-center gap-1 text-[11px]">
                    <MessageCircle className="w-3.5 h-3.5 text-cyan-400" />
                    {moment.comments_count}
                  </span>
                </div>

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => togglePin(moment.id)}
                    title={isPinned ? 'Unpin Post' : 'Pin to Top'}
                    className={`p-1.5 rounded-lg transition-colors ${
                      isPinned ? 'text-amber-400 bg-amber-400/10' : 'text-slate-400 hover:text-amber-400'
                    }`}
                  >
                    <Pin className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => deletePost(moment.id)}
                    title="Delete Post"
                    className="p-1.5 rounded-lg text-rose-400 hover:bg-rose-500/20 transition-colors"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
