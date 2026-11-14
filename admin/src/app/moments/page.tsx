'use client';

import React, { useState, useEffect } from 'react';
import { supabase, MomentRecord, StoryRecord } from '../../shared/lib/supabase';
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
  Sparkles,
  Clock,
  Eye,
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

const mockStories: StoryRecord[] = [
  {
    id: 'story_yanboyy_1',
    author_id: 'user_yanboyy',
    author_name: 'yanboyy',
    author_avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    country_flag: '🇧🇩',
    media_url: 'royal_art://lucky_wheel',
    caption: '250K coin Lucky Wheel streak! Spin with us today 🎯',
    bg_gradient_index: 1,
    views_count: 64,
    likes_count: 29,
    created_at: new Date().toISOString(),
  },
  {
    id: 'story_sadia_1',
    author_id: 'user_sadia',
    author_name: 'SadiaQueen',
    author_avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    country_flag: '🇧🇩',
    media_url: 'royal_art://party_stage',
    caption: 'Golden Mic Acoustic Room live soon — join stage!',
    bg_gradient_index: 2,
    views_count: 112,
    likes_count: 51,
    created_at: new Date().toISOString(),
  },
  {
    id: 'story_arafat_1',
    author_id: 'user_arafat',
    author_name: 'Arafat_BD',
    author_avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
    country_flag: '🇧🇩',
    caption: 'Good evening Dhaka! Looking for 7 Up 7 Down squadmates ☕🎲',
    bg_gradient_index: 0,
    views_count: 41,
    likes_count: 17,
    created_at: new Date().toISOString(),
  },
];

export default function MomentsPage() {
  const [moments, setMoments] = useState<MomentRecord[]>(mockMoments);
  const [stories, setStories] = useState<StoryRecord[]>(mockStories);
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState<'All' | 'Moments' | 'Video' | 'Stories' | 'Spam'>('All');
  const [pinnedIds, setPinnedIds] = useState<Set<string>>(new Set(['moment_1']));
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    async function loadData() {
      try {
        const { data: momentsData } = await supabase
          .from('moments')
          .select('*')
          .order('created_at', { ascending: false });

        if (momentsData && momentsData.length > 0) {
          const formatted = momentsData.map((m: any) => ({
            id: m.id?.toString() || '',
            user_id: m.user_id || m.author_id || 'user_unknown',
            user_name: m.user_name || m.author_name || 'Player',
            user_avatar: m.user_avatar || m.author_avatar || '',
            content: m.content || '',
            media_urls: m.media_urls || m.image_urls || [],
            likes_count: m.likes_count ?? 0,
            comments_count: m.comments_count ?? 0,
            category: m.category || 'Moments',
            created_at: m.created_at || new Date().toISOString(),
          }));
          setMoments(formatted);
        }
      } catch {
        // mock fallback
      }

      try {
        const { data: storiesData } = await supabase
          .from('stories')
          .select('*')
          .order('created_at', { ascending: false });

        if (storiesData && storiesData.length > 0) {
          const formattedStories = storiesData.map((s: any) => ({
            id: s.id?.toString() || '',
            author_id: s.author_id?.toString() || 'user_unknown',
            author_name: s.author_name || s.user_name || 'Creator',
            author_avatar: s.author_avatar || s.user_avatar || '',
            country_flag: s.country_flag || '🇧🇩',
            media_url: s.media_url || null,
            caption: s.caption || '',
            bg_gradient_index: s.bg_gradient_index ?? 0,
            views_count: s.views_count ?? 0,
            likes_count: s.likes_count ?? 0,
            created_at: s.created_at || new Date().toISOString(),
          }));
          setStories(formattedStories);
        }
      } catch {
        // mock fallback
      }
    }
    loadData();
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

  async function deleteStory(id: string) {
    if (!confirm('Are you sure you want to permanently delete this 24h story?')) return;
    setStories((prev) => prev.filter((s) => s.id !== id));
    try {
      await supabase.from('stories').delete().eq('id', id);
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

  function renderStoryMedia(story: StoryRecord) {
    const media = story.media_url || '';
    if (media.startsWith('http') || media.startsWith('data:image')) {
      return (
        <div className="relative w-full h-44 rounded-xl overflow-hidden mb-3 bg-black/40 border border-white/5">
          <img
            src={media}
            alt={story.caption || 'Story media'}
            className="w-full h-full object-cover"
          />
        </div>
      );
    }
    if (media.startsWith('royal_art://')) {
      const artName = media.replace('royal_art://', '').replace(/_/g, ' ').toUpperCase();
      return (
        <div className="w-full h-44 rounded-xl bg-gradient-to-br from-amber-600 via-emerald-800 to-slate-900 flex flex-col items-center justify-center p-3 text-center border border-amber-400/20 mb-3 shadow-inner">
          <Sparkles className="w-8 h-8 text-amber-300 mb-1.5 animate-pulse" />
          <span className="text-xs font-black text-white">{artName}</span>
          <span className="text-[10px] text-amber-200 mt-0.5">Gamegala Royal Highlight</span>
        </div>
      );
    }
    const gradients = [
      'from-emerald-700 via-teal-800 to-slate-950',
      'from-purple-700 via-indigo-800 to-slate-950',
      'from-amber-600 via-orange-700 to-rose-950',
      'from-blue-600 via-sky-700 to-indigo-950',
    ];
    const bg = gradients[(story.bg_gradient_index ?? 0) % gradients.length];
    return (
      <div className={`w-full h-44 rounded-xl bg-gradient-to-br ${bg} flex items-center justify-center p-4 text-center border border-white/10 mb-3`}>
        <p className="text-xs font-bold text-white line-clamp-4 leading-relaxed">
          {story.caption || '24h Status Story'}
        </p>
      </div>
    );
  }

  // Filter moments
  const filteredMoments = moments.filter((m) => {
    const authorName = (m.user_name || 'Player').toLowerCase();
    const postContent = (m.content || '').toLowerCase();
    const query = search.toLowerCase();
    const matchesSearch = postContent.includes(query) || authorName.includes(query);

    if (!matchesSearch) return false;
    if (activeTab === 'All') return true;
    if (activeTab === 'Video') return m.category === 'Video' || postContent.includes('#reels');
    if (activeTab === 'Moments') return m.category === 'Moments';
    if (activeTab === 'Spam') return m.category === 'Spam';
    return true;
  });

  // Filter stories
  const filteredStories = stories.filter((s) => {
    const authorName = (s.author_name || 'Creator').toLowerCase();
    const caption = (s.caption || '').toLowerCase();
    const query = search.toLowerCase();
    return caption.includes(query) || authorName.includes(query);
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
            <span>Feed, Reels & Stories Moderation</span>
          </h2>
          <p className="text-xs text-slate-400 mt-1">
            Review user-posted Moments, TikTok vertical Video Reels, 24h temporary Stories, and filter spam.
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
      <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
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
        <div className="p-4 rounded-xl glass-panel border border-amber-500/30">
          <span className="text-[11px] font-bold text-amber-400 uppercase flex items-center gap-1">
            <Sparkles className="w-3.5 h-3.5" />
            <span>24h Stories</span>
          </span>
          <p className="text-xl font-black text-amber-300 mt-1">{stories.length}</p>
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
      <div className="flex flex-wrap items-center gap-2 border-b border-[#1C3830] pb-3">
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
          onClick={() => setActiveTab('Stories')}
          className={`px-4 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-all ${
            activeTab === 'Stories'
              ? 'bg-amber-500 text-slate-950 shadow-md shadow-amber-500/20 font-black'
              : 'text-amber-400 hover:text-amber-300 hover:bg-amber-500/10'
          }`}
        >
          <Sparkles className="w-3.5 h-3.5" />
          <span>24h Stories ({stories.length})</span>
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

      {/* Main Content: Stories Grid or Moments Feed */}
      {activeTab === 'Stories' ? (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-slate-300 flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-amber-400" />
              <span>Active 24h User Stories ({filteredStories.length})</span>
            </h3>
            <span className="text-xs text-slate-500">Stories automatically disappear after 24 hours</span>
          </div>

          {filteredStories.length === 0 ? (
            <div className="p-12 text-center rounded-2xl glass-panel border border-[#1C3830]">
              <Sparkles className="w-10 h-10 text-slate-600 mx-auto mb-2" />
              <p className="text-slate-400 font-bold text-sm">No active stories found</p>
              <p className="text-slate-600 text-xs mt-1">Users have not published temporary stories recently.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredStories.map((story) => {
                const author = story.author_name || 'Creator';
                const avatar = story.author_avatar || '';
                const isRealHttpAvatar = avatar.startsWith('http') || avatar.startsWith('data:image');
                const initials = (author || 'CR').substring(0, 2).toUpperCase();

                return (
                  <div
                    key={story.id}
                    className="rounded-2xl glass-panel p-4 border border-amber-500/20 flex flex-col justify-between hover:border-amber-500/40 transition-all bg-gradient-to-b from-black/40 to-amber-950/10"
                  >
                    <div>
                      {/* Story Author Header */}
                      <div className="flex items-center justify-between mb-2.5">
                        <div className="flex items-center gap-2">
                          <div className="w-9 h-9 rounded-full bg-slate-800 overflow-hidden border border-amber-400/30 flex items-center justify-center font-bold text-xs text-amber-300">
                            {isRealHttpAvatar ? (
                              <img src={avatar} alt={author} className="w-full h-full object-cover" />
                            ) : (
                              initials
                            )}
                          </div>
                          <div>
                            <h4 className="font-bold text-xs text-white flex items-center gap-1">
                              <span>{author}</span>
                              {story.country_flag && <span>{story.country_flag}</span>}
                            </h4>
                            <span className="text-[10px] text-slate-500 font-mono">{story.author_id}</span>
                          </div>
                        </div>

                        <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-amber-500/10 border border-amber-500/30 text-[10px] font-bold text-amber-300">
                          <Clock className="w-2.5 h-2.5" />
                          <span>24h Active</span>
                        </div>
                      </div>

                      {/* Story Media Render */}
                      {renderStoryMedia(story)}

                      {/* Caption */}
                      {story.caption && (
                        <p className="text-xs text-slate-300 leading-relaxed mb-3">
                          {story.caption}
                        </p>
                      )}
                    </div>

                    {/* Story Engagement & Delete Footer */}
                    <div className="pt-2.5 border-t border-white/5 flex items-center justify-between text-xs text-slate-400">
                      <div className="flex items-center gap-3">
                        <span className="flex items-center gap-1 text-[11px] text-cyan-300 font-semibold">
                          <Eye className="w-3.5 h-3.5 text-cyan-400" />
                          {story.views_count ?? 0} views
                        </span>
                        <span className="flex items-center gap-1 text-[11px] text-rose-300 font-semibold">
                          <Heart className="w-3.5 h-3.5 text-rose-400" />
                          {story.likes_count ?? 0} likes
                        </span>
                      </div>

                      <button
                        onClick={() => deleteStory(story.id)}
                        title="Delete Story Immediately"
                        className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-rose-300 bg-rose-500/15 hover:bg-rose-500/25 border border-rose-500/30 font-bold text-xs transition-colors"
                      >
                        <Trash2 className="w-3 h-3" />
                        <span>Delete Story</span>
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      ) : (
        /* Regular Moments & Reels Posts Grid */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredMoments.map((moment) => {
            const isPinned = pinnedIds.has(moment.id);
            const isVideoReel = moment.category === 'Video' || (moment.content || '').includes('#reels');
            const author = moment.user_name || 'Player';
            const avatar = moment.user_avatar || '';
            const isRealHttpAvatar = avatar.startsWith('http') || avatar.startsWith('data:image');
            const initials = (author || 'PL').substring(0, 2).toUpperCase();
            const mediaList = moment.media_urls || [];
            const hasMedia = mediaList.length > 0;
            const firstMedia = hasMedia ? mediaList[0] : '';
            const isHttpMedia = firstMedia.startsWith('http') || firstMedia.startsWith('data:image');
            const isRoyalArtMedia = firstMedia.startsWith('royal_art://');

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
                        {isRealHttpAvatar ? (
                          <img src={avatar} alt={author} className="w-full h-full object-cover" />
                        ) : (
                          initials
                        )}
                      </div>
                      <div>
                        <h4 className="font-bold text-xs text-white flex items-center gap-1">
                          <span>{author}</span>
                          {isPinned && <span className="text-[10px] text-amber-400 font-bold">★ Pinned</span>}
                        </h4>
                        <span className="text-[10px] text-slate-500" suppressHydrationWarning>
                          {mounted ? formatDate(moment.created_at) : ''}
                        </span>
                      </div>
                    </div>

                    <Badge variant={moment.category === 'Spam' ? 'rose' : isVideoReel ? 'purple' : 'emerald'}>
                      {isVideoReel ? '🎬 Reel' : moment.category}
                    </Badge>
                  </div>

                  <p className="text-xs text-slate-300 leading-relaxed mb-3">{moment.content}</p>

                  {/* Media preview */}
                  {hasMedia && (
                    <div className="relative w-full h-44 rounded-xl overflow-hidden mb-3 bg-black/40 border border-white/5 group">
                      {isHttpMedia ? (
                        <img
                          src={firstMedia}
                          alt="Post media"
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                        />
                      ) : isRoyalArtMedia ? (
                        <div className="w-full h-full bg-gradient-to-br from-amber-600 via-emerald-800 to-slate-900 flex flex-col items-center justify-center p-3 text-center border border-amber-400/20">
                          <Sparkles className="w-7 h-7 text-amber-300 mb-1 animate-pulse" />
                          <span className="text-xs font-black text-white">
                            {firstMedia.replace('royal_art://', '').replace(/_/g, ' ').toUpperCase()}
                          </span>
                          <span className="text-[10px] text-amber-200 mt-0.5">Gamegala Royal Highlight</span>
                        </div>
                      ) : null}

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
      )}
    </div>
  );
}
