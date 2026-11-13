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

export default function GiftsPage() {
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

  const [isModalOpen, setIsModalOpen] = useState(false);

  const [editingGiftId, setEditingGiftId] = useState<string | null>(null);

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

  function openCreateModal() {
    setEditingGiftId(null);
    setNewGift({
      name: '',
      icon: '🎁',
      category: 'Popular',
      priceCoins: 1000,
      animationType: 'SVGA',
      luckyMultiplier: '',
    });
    setIsModalOpen(true);
  }

  function openEditModal(gift: VirtualGift) {
    setEditingGiftId(gift.id);
    setNewGift({
      name: gift.name,
      icon: gift.icon,
      category: gift.category,
      priceCoins: gift.priceCoins,
      animationType: gift.animationType,
      luckyMultiplier: gift.luckyMultiplier || '',
    });
    setIsModalOpen(true);
  }

  function deleteGift(id: string) {
    if (!confirm('Remove this virtual gift?')) return;
    setGifts((prev) => prev.filter((g) => g.id !== id));
  }

  const [newGift, setNewGift] = useState({
    name: '',
    icon: '🎁',
    category: 'Popular' as VirtualGift['category'],
    priceCoins: 1000,
    animationType: 'SVGA' as VirtualGift['animationType'],
    luckyMultiplier: '',
  });

  
  function handleCreateGift(e: React.FormEvent) {
    e.preventDefault();
    if (!newGift.name) return;

    if (editingGiftId) {
      setGifts((prev) =>
        prev.map((g) =>
          g.id === editingGiftId
            ? {
                ...g,
                name: newGift.name,
                icon: newGift.icon,
                category: newGift.category,
                priceCoins: newGift.priceCoins,
                animationType: newGift.animationType,
                luckyMultiplier: newGift.luckyMultiplier || undefined,
              }
            : g
        )
      );
    } else {
      const gift: VirtualGift = {
        id: `gift_${Date.now()}`,
        name: newGift.name,
        icon: newGift.icon,
        category: newGift.category,
        priceCoins: newGift.priceCoins,
        animationType: newGift.animationType,
        luckyMultiplier: newGift.luckyMultiplier || undefined,
        isActive: true,
      };
      setGifts([...gifts, gift]);
    }

    setIsModalOpen(false);
    setEditingGiftId(null);
  }


  function toggleGift(id: string, checked: boolean) {
    setGifts((prev) =>
      prev.map((g) => (g.id === id ? { ...g, isActive: checked } : g))
    );
  }

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <Gift className="w-6 h-6 text-pink-400" />
          <span>Gifts Store</span>
        </h2>

        <button
          onClick={openCreateModal}
          className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-pink-500 hover:bg-pink-400 text-slate-950 font-black text-xs transition-all shadow-md"
        >
          <PlusCircle className="w-4 h-4" />
          <span>Add Gift</span>
        </button>
      </div>

      {/* Gifts Grid */}
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
                  onClick={() => openEditModal(gift)}
                  className="p-1 rounded text-slate-400 hover:text-white hover:bg-white/5"
                  title="Edit Gift"
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

      {/* Modal */}
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title={editingGiftId ? 'Edit Gift' : 'Add Gift'}>
        <form onSubmit={handleCreateGift} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Name</label>
            <input
              type="text"
              required
              value={newGift.name}
              onChange={(e) => setNewGift({ ...newGift, name: e.target.value })}
              placeholder="Gift Name"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-pink-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Icon Emoji</label>
              <input
                type="text"
                required
                value={newGift.icon}
                onChange={(e) => setNewGift({ ...newGift, icon: e.target.value })}
                placeholder="🎁"
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-center text-white focus:outline-none focus:border-pink-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Category</label>
              <select
                value={newGift.category}
                onChange={(e) =>
                  setNewGift({ ...newGift, category: e.target.value as VirtualGift['category'] })
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
                value={newGift.priceCoins}
                onChange={(e) => setNewGift({ ...newGift, priceCoins: parseInt(e.target.value) || 100 })}
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-pink-500"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Format</label>
              <select
                value={newGift.animationType}
                onChange={(e) =>
                  setNewGift({ ...newGift, animationType: e.target.value as VirtualGift['animationType'] })
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
              onClick={() => setIsModalOpen(false)}
              className="px-4 py-2 rounded-xl text-xs font-bold text-slate-400 hover:text-white"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 rounded-xl bg-pink-500 hover:bg-pink-400 text-slate-950 font-black text-xs transition-colors"
            >
              Add
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
