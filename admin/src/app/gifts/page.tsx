'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../../shared/lib/supabase';
import { Badge } from '../../shared/components/ui/Badge';
import { Modal } from '../../shared/components/ui/Modal';
import { Switch } from '../../shared/components/ui/Switch';
import { formatCoins } from '../../shared/lib/utils';
import {
  Gift,
  PlusCircle,
  Coins,
  Edit2,
  Trash2,
  Store,
  Sparkles,
  Car,
  MessageSquare,
  Crown,
} from 'lucide-react';

interface VirtualGift {
  id: string;
  name: string;
  icon: string;
  category: 'Popular' | 'Romance' | 'Luxury' | 'Special';
  priceCoins: number;
  animationType: 'SVGA' | 'Lottie' | 'Static PNG';
  luckyMultiplier?: string;
  isActive: boolean;
}

interface MallStoreItem {
  id: string;
  name: string;
  category: 'Avatar Frame' | 'Entrance Ride' | 'Chat Bubble';
  icon: string;
  priceCoins: number;
  duration: string;
  description: string;
  isActive: boolean;
}

export default function GiftsAndMallPage() {
  const [activeTab, setActiveTab] = useState<'gifts' | 'mall'>('gifts');

  // Room Gifts State
  const [gifts, setGifts] = useState<VirtualGift[]>([
    {
      id: 'gift_1',
      name: 'Rose',
      icon: '🌹',
      category: 'Popular',
      priceCoins: 100,
      animationType: 'Static PNG',
      isActive: true,
    },
    {
      id: 'gift_2',
      name: 'Diamond Ring',
      icon: '💍',
      category: 'Romance',
      priceCoins: 5000,
      animationType: 'Lottie',
      isActive: true,
    },
    {
      id: 'gift_3',
      name: 'Supercar',
      icon: '🏎️',
      category: 'Luxury',
      priceCoins: 25000,
      animationType: 'SVGA',
      luckyMultiplier: '50x',
      isActive: true,
    },
    {
      id: 'gift_4',
      name: 'Rocket',
      icon: '🚀',
      category: 'Special',
      priceCoins: 100000,
      animationType: 'SVGA',
      luckyMultiplier: '500x',
      isActive: true,
    },
    {
      id: 'gift_5',
      name: 'Royal Crown',
      icon: '👑',
      category: 'Luxury',
      priceCoins: 50000,
      animationType: 'SVGA',
      isActive: true,
    },
    {
      id: 'gift_6',
      name: 'Fairy Castle',
      icon: '🏰',
      category: 'Special',
      priceCoins: 250000,
      animationType: 'SVGA',
      luckyMultiplier: '1000x',
      isActive: true,
    },
  ]);

  // Mall Store Items (Avatar Frames, Entrance Rides, Chat Bubbles)
  const [mallItems, setMallItems] = useState<MallStoreItem[]>([
    {
      id: 'frame_dragon',
      name: 'Imperial Dragon Frame',
      category: 'Avatar Frame',
      icon: '🐉',
      priceCoins: 5000,
      duration: '30 Days',
      description: 'Golden Imperial Dragon halo with animated embers',
      isActive: true,
    },
    {
      id: 'frame_cyber',
      name: 'Cyber Neon Frame',
      category: 'Avatar Frame',
      icon: '⚡',
      priceCoins: 3500,
      duration: '30 Days',
      description: 'Futuristic glowing cyberpunk neon ring',
      isActive: true,
    },
    {
      id: 'frame_royalty',
      name: 'Diamond Royalty Crown',
      category: 'Avatar Frame',
      icon: '👑',
      priceCoins: 8000,
      duration: '30 Days',
      description: 'Crown of royal gemstones for prestigious hosts',
      isActive: true,
    },
    {
      id: 'frame_phoenix',
      name: 'Phoenix Flame Frame',
      category: 'Avatar Frame',
      icon: '🔥',
      priceCoins: 12000,
      duration: '30 Days',
      description: 'Blazing eternal fire frame of supreme glory',
      isActive: true,
    },
    {
      id: 'ride_supercar',
      name: 'Royal Supercar Entrance',
      category: 'Entrance Ride',
      icon: '🏎️',
      priceCoins: 15000,
      duration: '30 Days',
      description: 'Roaring sports car grand arrival banner in voice rooms',
      isActive: true,
    },
    {
      id: 'ride_dragon',
      name: 'Flying Dragon Entrance',
      category: 'Entrance Ride',
      icon: '🐲',
      priceCoins: 25000,
      duration: '30 Days',
      description: 'Mythical dragon descending with storm flashes on join',
      isActive: true,
    },
    {
      id: 'ride_rocket',
      name: 'Space Shuttle Ride',
      category: 'Entrance Ride',
      icon: '🚀',
      priceCoins: 10000,
      duration: '30 Days',
      description: 'Galactic rocket blastoff room entrance banner',
      isActive: true,
    },
    {
      id: 'ride_pegasus',
      name: 'Golden Pegasus Ride',
      category: 'Entrance Ride',
      icon: '🦄',
      priceCoins: 30000,
      duration: '30 Days',
      description: 'Celestial winged steed lighting up the whole room',
      isActive: true,
    },
    {
      id: 'bubble_luxury',
      name: 'Golden Luxury Bubble',
      category: 'Chat Bubble',
      icon: '💬',
      priceCoins: 2000,
      duration: '30 Days',
      description: 'Exclusive golden border for room chat messages',
      isActive: true,
    },
    {
      id: 'bubble_cyber',
      name: 'Neon Cyber Bubble',
      category: 'Chat Bubble',
      icon: '💭',
      priceCoins: 3500,
      duration: '30 Days',
      description: 'Cyberpunk animated speech bubble style',
      isActive: true,
    },
  ]);

  const [mallFilter, setMallFilter] = useState<'All' | 'Avatar Frame' | 'Entrance Ride' | 'Chat Bubble'>('All');

  // Gift Modal
  const [isGiftModalOpen, setIsGiftModalOpen] = useState(false);
  const [editingGiftId, setEditingGiftId] = useState<string | null>(null);
  const [giftForm, setGiftForm] = useState({
    name: '',
    icon: '🎁',
    category: 'Popular' as VirtualGift['category'],
    priceCoins: 1000,
    animationType: 'SVGA' as VirtualGift['animationType'],
    luckyMultiplier: '',
  });

  // Mall Item Modal
  const [isMallModalOpen, setIsMallModalOpen] = useState(false);
  const [editingMallId, setEditingMallId] = useState<string | null>(null);
  const [mallForm, setMallForm] = useState({
    name: '',
    category: 'Avatar Frame' as MallStoreItem['category'],
    icon: '👑',
    priceCoins: 5000,
    duration: '30 Days',
    description: '',
  });

  useEffect(() => {
    async function loadGifts() {
      try {
        const { data } = await supabase
          .from('gifts')
          .select('*')
          .order('price_coins', { ascending: true });
        if (data && data.length > 0) {
          setGifts(
            data.map((g: any) => ({
              id: g.id,
              name: g.name,
              icon: g.icon,
              category: g.category || 'Popular',
              priceCoins: g.price_coins,
              animationType: g.animation_type || 'Static PNG',
              luckyMultiplier: g.lucky_multiplier || undefined,
              isActive: g.is_active ?? true,
            }))
          );
        }
      } catch (err) {
        console.error('Error fetching gifts:', err);
      }
    }
    loadGifts();
  }, []);

  // Gift Handlers
  function openCreateGiftModal() {
    setEditingGiftId(null);
    setGiftForm({
      name: '',
      icon: '🎁',
      category: 'Popular',
      priceCoins: 1000,
      animationType: 'SVGA',
      luckyMultiplier: '',
    });
    setIsGiftModalOpen(true);
  }

  function openEditGiftModal(gift: VirtualGift) {
    setEditingGiftId(gift.id);
    setGiftForm({
      name: gift.name,
      icon: gift.icon,
      category: gift.category,
      priceCoins: gift.priceCoins,
      animationType: gift.animationType,
      luckyMultiplier: gift.luckyMultiplier || '',
    });
    setIsGiftModalOpen(true);
  }

  function handleSaveGift(e: React.FormEvent) {
    e.preventDefault();
    if (!giftForm.name) return;

    if (editingGiftId) {
      setGifts((prev) =>
        prev.map((g) =>
          g.id === editingGiftId
            ? {
                ...g,
                name: giftForm.name,
                icon: giftForm.icon,
                category: giftForm.category,
                priceCoins: giftForm.priceCoins,
                animationType: giftForm.animationType,
                luckyMultiplier: giftForm.luckyMultiplier || undefined,
              }
            : g
        )
      );
    } else {
      const newG: VirtualGift = {
        id: `gift_${Date.now()}`,
        name: giftForm.name,
        icon: giftForm.icon,
        category: giftForm.category,
        priceCoins: giftForm.priceCoins,
        animationType: giftForm.animationType,
        luckyMultiplier: giftForm.luckyMultiplier || undefined,
        isActive: true,
      };
      setGifts([...gifts, newG]);
    }

    setIsGiftModalOpen(false);
    setEditingGiftId(null);
  }

  function toggleGift(id: string, checked: boolean) {
    setGifts((prev) =>
      prev.map((g) => (g.id === id ? { ...g, isActive: checked } : g))
    );
  }

  function deleteGift(id: string) {
    if (!confirm('Remove this virtual gift?')) return;
    setGifts((prev) => prev.filter((g) => g.id !== id));
  }

  // Mall Item Handlers
  function openCreateMallModal() {
    setEditingMallId(null);
    setMallForm({
      name: '',
      category: 'Avatar Frame',
      icon: '👑',
      priceCoins: 5000,
      duration: '30 Days',
      description: '',
    });
    setIsMallModalOpen(true);
  }

  function openEditMallModal(item: MallStoreItem) {
    setEditingMallId(item.id);
    setMallForm({
      name: item.name,
      category: item.category,
      icon: item.icon,
      priceCoins: item.priceCoins,
      duration: item.duration,
      description: item.description,
    });
    setIsMallModalOpen(true);
  }

  function handleSaveMallItem(e: React.FormEvent) {
    e.preventDefault();
    if (!mallForm.name) return;

    if (editingMallId) {
      setMallItems((prev) =>
        prev.map((m) =>
          m.id === editingMallId
            ? {
                ...m,
                name: mallForm.name,
                category: mallForm.category,
                icon: mallForm.icon,
                priceCoins: mallForm.priceCoins,
                duration: mallForm.duration,
                description: mallForm.description,
              }
            : m
        )
      );
    } else {
      const newItem: MallStoreItem = {
        id: `mall_${Date.now()}`,
        name: mallForm.name,
        category: mallForm.category,
        icon: mallForm.icon,
        priceCoins: mallForm.priceCoins,
        duration: mallForm.duration,
        description: mallForm.description,
        isActive: true,
      };
      setMallItems([...mallItems, newItem]);
    }

    setIsMallModalOpen(false);
    setEditingMallId(null);
  }

  function toggleMallItem(id: string, checked: boolean) {
    setMallItems((prev) =>
      prev.map((m) => (m.id === id ? { ...m, isActive: checked } : m))
    );
  }

  function deleteMallItem(id: string) {
    if (!confirm('Remove this item from Mall store?')) return;
    setMallItems((prev) => prev.filter((m) => m.id !== id));
  }

  const filteredMallItems = mallItems.filter((item) => {
    if (mallFilter === 'All') return true;
    return item.category === mallFilter;
  });

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
            <Gift className="w-6 h-6 text-pink-400" />
            <span>Virtual Gift Store & Mall Pricing</span>
          </h2>
          <p className="text-xs text-slate-400 mt-1">
            Manage live room virtual gifts, avatar frames, entrance rides, and customize user coin pricing.
          </p>
        </div>

        <div className="flex items-center gap-2">
          {activeTab === 'gifts' ? (
            <button
              onClick={openCreateGiftModal}
              className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-pink-500 hover:bg-pink-400 text-slate-950 font-black text-xs transition-all shadow-md"
            >
              <PlusCircle className="w-4 h-4" />
              <span>Add Virtual Gift</span>
            </button>
          ) : (
            <button
              onClick={openCreateMallModal}
              className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-purple-500 hover:bg-purple-400 text-slate-950 font-black text-xs transition-all shadow-md"
            >
              <PlusCircle className="w-4 h-4" />
              <span>Add Mall Item / Frame</span>
            </button>
          )}
        </div>
      </div>

      {/* Main Tabs: Room Gifts vs Mall & Backpack Items */}
      <div className="flex items-center gap-2 p-1.5 rounded-2xl bg-[#0B1512] border border-[#1C3830] w-fit">
        <button
          onClick={() => setActiveTab('gifts')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'gifts'
              ? 'bg-pink-500/20 text-pink-300 border border-pink-500/40 shadow-sm'
              : 'text-slate-400 hover:text-white'
          }`}
        >
          <Gift className="w-4 h-4 text-pink-400" />
          <span>Room Virtual Gifts ({gifts.length})</span>
        </button>

        <button
          onClick={() => setActiveTab('mall')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold transition-all ${
            activeTab === 'mall'
              ? 'bg-purple-500/20 text-purple-300 border border-purple-500/40 shadow-sm'
              : 'text-slate-400 hover:text-white'
          }`}
        >
          <Store className="w-4 h-4 text-purple-400" />
          <span>Mall Store (Avatar Frames, Rides & Bubbles) ({mallItems.length})</span>
        </button>
      </div>

      {/* TAB 1: Room Gifts */}
      {activeTab === 'gifts' && (
        <div className="space-y-4">
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
            {gifts.map((gift) => (
              <div
                key={gift.id}
                className={`p-3.5 rounded-2xl glass-panel border flex flex-col justify-between transition-all ${
                  gift.isActive ? 'border-[#1C3830]' : 'border-rose-500/30 opacity-60'
                }`}
              >
                <div>
                  <div className="flex items-center justify-between mb-1.5">
                    <Badge variant={gift.category === 'Luxury' ? 'amber' : gift.category === 'Special' ? 'purple' : 'cyan'}>
                      {gift.category}
                    </Badge>
                    <span className="text-[9px] font-bold text-slate-400 font-mono">{gift.animationType}</span>
                  </div>

                  <div className="w-14 h-14 mx-auto my-2 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-2xl shadow-inner">
                    {gift.icon}
                  </div>

                  <h3 className="text-xs font-bold text-white text-center truncate">{gift.name}</h3>

                  <div className="mt-1.5 text-center">
                    <span className="inline-flex items-center gap-1 font-black text-amber-400 text-xs">
                      <Coins className="w-3 h-3" />
                      {formatCoins(gift.priceCoins)}
                    </span>
                    {gift.luckyMultiplier && (
                      <p className="text-[10px] font-bold text-pink-400">{gift.luckyMultiplier}</p>
                    )}
                  </div>
                </div>

                <div className="mt-3 pt-2 border-t border-white/5 flex items-center justify-between">
                  <div className="flex items-center gap-1.5">
                    <Switch
                      checked={gift.isActive}
                      onChange={(checked) => toggleGift(gift.id, checked)}
                    />
                    <span className="text-[10px] text-slate-500">{gift.isActive ? 'Live' : 'Off'}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => openEditGiftModal(gift)}
                      className="p-1 rounded text-slate-400 hover:text-white hover:bg-white/5"
                      title="Edit Price & Details"
                    >
                      <Edit2 className="w-3 h-3" />
                    </button>
                    <button
                      onClick={() => deleteGift(gift.id)}
                      className="p-1 rounded text-rose-400 hover:bg-rose-500/20"
                      title="Delete Gift"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* TAB 2: Mall Store Items (Avatar Frames, Rides, Bubbles) */}
      {activeTab === 'mall' && (
        <div className="space-y-4">
          {/* Sub-filter chips */}
          <div className="flex flex-wrap items-center gap-2">
            {(['All', 'Avatar Frame', 'Entrance Ride', 'Chat Bubble'] as const).map((cat) => (
              <button
                key={cat}
                onClick={() => setMallFilter(cat)}
                className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                  mallFilter === cat
                    ? 'bg-purple-500 text-slate-950 shadow-sm'
                    : 'bg-[#11221D] text-slate-400 hover:text-white border border-[#1C3830]'
                }`}
              >
                {cat === 'All' ? 'All Items' : cat}
              </button>
            ))}
          </div>

          {/* Mall Items Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            {filteredMallItems.map((item) => (
              <div
                key={item.id}
                className={`p-4 rounded-2xl glass-panel border flex flex-col justify-between transition-all ${
                  item.isActive ? 'border-[#1C3830]' : 'border-rose-500/30 opacity-60'
                }`}
              >
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span
                      className={`text-[10px] font-black px-2 py-0.5 rounded-md border ${
                        item.category === 'Avatar Frame'
                          ? 'bg-cyan-500/15 text-cyan-300 border-cyan-500/30'
                          : item.category === 'Entrance Ride'
                          ? 'bg-rose-500/15 text-rose-300 border-rose-500/30'
                          : 'bg-emerald-500/15 text-emerald-300 border-emerald-500/30'
                      }`}
                    >
                      {item.category}
                    </span>
                    <span className="text-[10px] text-amber-400 font-mono font-bold bg-amber-500/10 px-1.5 py-0.5 rounded">
                      {item.duration}
                    </span>
                  </div>

                  <div className="flex items-center gap-3 my-2">
                    <div className="w-12 h-12 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-2xl shadow-inner shrink-0">
                      {item.icon}
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-xs font-bold text-white truncate">{item.name}</h3>
                      <p className="text-[10px] text-slate-400 line-clamp-1 mt-0.5">{item.description}</p>
                    </div>
                  </div>

                  <div className="p-2 rounded-xl bg-black/40 border border-white/5 flex items-center justify-between mt-2">
                    <span className="text-[10px] text-slate-400">Buyer Coin Price:</span>
                    <span className="inline-flex items-center gap-1 font-black text-amber-400 text-xs">
                      <Coins className="w-3.5 h-3.5" />
                      {formatCoins(item.priceCoins)} Coins
                    </span>
                  </div>
                </div>

                <div className="mt-3 pt-2 border-t border-white/5 flex items-center justify-between">
                  <div className="flex items-center gap-1.5">
                    <Switch
                      checked={item.isActive}
                      onChange={(checked) => toggleMallItem(item.id, checked)}
                    />
                    <span className="text-[10px] text-slate-500">{item.isActive ? 'Active in Mall' : 'Disabled'}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => openEditMallModal(item)}
                      className="px-2 py-1 rounded bg-white/5 hover:bg-white/10 text-slate-300 text-[10px] font-bold flex items-center gap-1"
                      title="Edit Price"
                    >
                      <Edit2 className="w-3 h-3 text-purple-400" />
                      <span>Edit Price</span>
                    </button>
                    <button
                      onClick={() => deleteMallItem(item.id)}
                      className="p-1 rounded text-rose-400 hover:bg-rose-500/20"
                      title="Delete Item"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Gift Modal */}
      <Modal isOpen={isGiftModalOpen} onClose={() => setIsGiftModalOpen(false)} title={editingGiftId ? 'Edit Virtual Gift' : 'Add Virtual Gift'}>
        <form onSubmit={handleSaveGift} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Gift Name</label>
            <input
              type="text"
              required
              value={giftForm.name}
              onChange={(e) => setGiftForm({ ...giftForm, name: e.target.value })}
              placeholder="e.g. Royal Crown"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-pink-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Icon / Emoji</label>
              <input
                type="text"
                required
                value={giftForm.icon}
                onChange={(e) => setGiftForm({ ...giftForm, icon: e.target.value })}
                placeholder="🎁"
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-center text-white focus:outline-none focus:border-pink-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Category</label>
              <select
                value={giftForm.category}
                onChange={(e) =>
                  setGiftForm({ ...giftForm, category: e.target.value as VirtualGift['category'] })
                }
                className="w-full px-3 py-2 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-pink-500"
              >
                <option value="Popular">Popular</option>
                <option value="Romance">Romance</option>
                <option value="Luxury">Luxury</option>
                <option value="Special">Special</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Price (Coins)</label>
              <input
                type="number"
                min="10"
                step="100"
                value={giftForm.priceCoins}
                onChange={(e) => setGiftForm({ ...giftForm, priceCoins: parseInt(e.target.value) || 100 })}
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-pink-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Animation Format</label>
              <select
                value={giftForm.animationType}
                onChange={(e) =>
                  setGiftForm({ ...giftForm, animationType: e.target.value as VirtualGift['animationType'] })
                }
                className="w-full px-3 py-2 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-pink-500"
              >
                <option value="SVGA">SVGA</option>
                <option value="Lottie">Lottie</option>
                <option value="Static PNG">PNG</option>
              </select>
            </div>
          </div>

          <div className="pt-2 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setIsGiftModalOpen(false)}
              className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-xl bg-pink-500 hover:bg-pink-400 text-slate-950 font-black text-xs transition-colors"
            >
              {editingGiftId ? 'Save Changes' : 'Add Gift'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Mall Item Modal */}
      <Modal
        isOpen={isMallModalOpen}
        onClose={() => setIsMallModalOpen(false)}
        title={editingMallId ? 'Edit Mall Item & Coin Price' : 'Add Mall Item (Frame / Ride / Bubble)'}
      >
        <form onSubmit={handleSaveMallItem} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Item Title</label>
            <input
              type="text"
              required
              value={mallForm.name}
              onChange={(e) => setMallForm({ ...mallForm, name: e.target.value })}
              placeholder="e.g. Golden Phoenix Frame"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-purple-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Category</label>
              <select
                value={mallForm.category}
                onChange={(e) =>
                  setMallForm({ ...mallForm, category: e.target.value as MallStoreItem['category'] })
                }
                className="w-full px-3 py-2 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-purple-500"
              >
                <option value="Avatar Frame">Avatar Frame</option>
                <option value="Entrance Ride">Entrance Ride</option>
                <option value="Chat Bubble">Chat Bubble</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Icon / Emoji</label>
              <input
                type="text"
                required
                value={mallForm.icon}
                onChange={(e) => setMallForm({ ...mallForm, icon: e.target.value })}
                placeholder="👑"
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-center text-white focus:outline-none focus:border-purple-500"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Buyer Coin Price</label>
              <input
                type="number"
                min="100"
                step="500"
                value={mallForm.priceCoins}
                onChange={(e) => setMallForm({ ...mallForm, priceCoins: parseInt(e.target.value) || 1000 })}
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-purple-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Duration</label>
              <select
                value={mallForm.duration}
                onChange={(e) => setMallForm({ ...mallForm, duration: e.target.value })}
                className="w-full px-3 py-2 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-purple-500"
              >
                <option value="7 Days">7 Days</option>
                <option value="30 Days">30 Days</option>
                <option value="90 Days">90 Days</option>
                <option value="Permanent">Permanent</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Description / Effects Note</label>
            <input
              type="text"
              value={mallForm.description}
              onChange={(e) => setMallForm({ ...mallForm, description: e.target.value })}
              placeholder="e.g. Glowing halo effect around avatar in voice rooms"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-purple-500"
            />
          </div>

          <div className="pt-2 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setIsMallModalOpen(false)}
              className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-xl bg-purple-500 hover:bg-purple-400 text-slate-950 font-black text-xs transition-colors"
            >
              {editingMallId ? 'Save Price & Item' : 'Add to Mall'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
