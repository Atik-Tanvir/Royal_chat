'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../../shared/lib/supabase';
import { Badge } from '../../shared/components/ui/Badge';
import { Modal } from '../../shared/components/ui/Modal';
import { Switch } from '../../shared/components/ui/Switch';
import { ImageDropzone } from '../../shared/components/ui/ImageDropzone';
import {
  Image as ImageIcon,
  PlusCircle,
  Trash2,
  Edit2,
  Sparkles,
} from 'lucide-react';

interface PromotionBanner {
  id: string;
  title: string;
  subtitle: string;
  imageUrl: string;
  targetTab: 'Party' | 'Follow' | 'Chat' | 'Top' | 'All';
  actionUrl: string;
  isActive: boolean;
  order: number;
}

export default function BannersPage() {
  const [banners, setBanners] = useState<PromotionBanner[]>([
    {
      id: 'banner_1',
      title: 'BlockMe Ranking',
      subtitle: 'Monthly $8,360',
      imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
      targetTab: 'Top',
      actionUrl: 'app://leaderboard?tab=1',
      isActive: true,
      order: 1,
    },
    {
      id: 'banner_2',
      title: 'Host Recruitment',
      subtitle: 'Monetize your talent',
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
      targetTab: 'All',
      actionUrl: 'app://host_recruitment',
      isActive: true,
      order: 2,
    },
    {
      id: 'banner_3',
      title: 'Royal Voice Arena',
      subtitle: 'Season 1 Pool $10,000',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600',
      targetTab: 'Party',
      actionUrl: 'app://leaderboard?tab=0',
      isActive: true,
      order: 3,
    },
  ]);

  useEffect(() => {
    async function loadBanners() {
      try {
        const { data } = await supabase
          .from('banners')
          .select('*')
          .order('sort_order', { ascending: true });
        if (data && data.length > 0) {
          setBanners(
            data.map((b: any) => ({
              id: b.id,
              title: b.title,
              subtitle: b.subtitle || '',
              imageUrl: b.image_url,
              targetTab: b.target_tab || 'All',
              actionUrl: b.action_url || '',
              isActive: b.is_active ?? true,
              order: b.sort_order || 1,
            }))
          );
        }
      } catch (err) {
        console.error('Error fetching banners:', err);
      }
    }
    loadBanners();
  }, []);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBannerId, setEditingBannerId] = useState<string | null>(null);

  const [bannerForm, setBannerForm] = useState({
    title: '',
    subtitle: '',
    imageUrl: '',
    targetTab: 'All' as PromotionBanner['targetTab'],
    actionUrl: '',
  });

  function openCreateModal() {
    setEditingBannerId(null);
    setBannerForm({
      title: '',
      subtitle: '',
      imageUrl: '',
      targetTab: 'All',
      actionUrl: '',
    });
    setIsModalOpen(true);
  }

  function openEditModal(banner: PromotionBanner) {
    setEditingBannerId(banner.id);
    setBannerForm({
      title: banner.title,
      subtitle: banner.subtitle,
      imageUrl: banner.imageUrl,
      targetTab: banner.targetTab,
      actionUrl: banner.actionUrl,
    });
    setIsModalOpen(true);
  }

  function handleSaveBanner(e: React.FormEvent) {
    e.preventDefault();
    if (!bannerForm.title || !bannerForm.imageUrl) return;

    if (editingBannerId) {
      // Update existing banner
      setBanners((prev) =>
        prev.map((b) =>
          b.id === editingBannerId
            ? {
                ...b,
                title: bannerForm.title,
                subtitle: bannerForm.subtitle,
                imageUrl: bannerForm.imageUrl,
                targetTab: bannerForm.targetTab,
                actionUrl: bannerForm.actionUrl || 'app://home',
              }
            : b
        )
      );
    } else {
      // Create new banner
      const newBanner: PromotionBanner = {
        id: `banner_${Date.now()}`,
        title: bannerForm.title,
        subtitle: bannerForm.subtitle,
        imageUrl: bannerForm.imageUrl,
        targetTab: bannerForm.targetTab,
        actionUrl: bannerForm.actionUrl || 'app://home',
        isActive: true,
        order: banners.length + 1,
      };
      setBanners([...banners, newBanner]);
    }

    setIsModalOpen(false);
    setEditingBannerId(null);
    setBannerForm({
      title: '',
      subtitle: '',
      imageUrl: '',
      targetTab: 'All',
      actionUrl: '',
    });
  }

  function toggleBanner(id: string, checked: boolean) {
    setBanners((prev) =>
      prev.map((b) => (b.id === id ? { ...b, isActive: checked } : b))
    );
  }

  function deleteBanner(id: string) {
    if (!confirm('Remove banner?')) return;
    setBanners((prev) => prev.filter((b) => b.id !== id));
  }

  return (
    <div className="space-y-6">
      {/* Header (Minimal, No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <ImageIcon className="w-6 h-6 text-emerald-400" />
          <span>Banners</span>
        </h2>

        <button
          onClick={openCreateModal}
          className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs transition-all shadow-md shadow-emerald-500/20"
        >
          <PlusCircle className="w-4 h-4" />
          <span>Add Banner</span>
        </button>
      </div>

      {/* Banners Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {banners.map((banner) => (
          <div
            key={banner.id}
            className="rounded-2xl glass-panel overflow-hidden border border-[#1C3830] flex flex-col justify-between group hover:border-emerald-500/30 transition-all"
          >
            <div className="relative h-36 w-full bg-slate-900 overflow-hidden">
              <img
                src={banner.imageUrl}
                alt={banner.title}
                className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-black/25 to-transparent" />
              <div className="absolute top-2.5 right-2.5 flex items-center gap-1.5">
                <Badge variant={banner.isActive ? 'emerald' : 'slate'}>
                  {banner.isActive ? 'Active' : 'Off'}
                </Badge>
              </div>
              <div className="absolute bottom-2.5 left-3 right-3">
                <h3 className="text-xs font-black text-white truncate">{banner.title}</h3>
                <p className="text-[10px] text-amber-300 font-semibold truncate">{banner.subtitle}</p>
              </div>
            </div>

            <div className="p-3.5 space-y-2.5">
              <div className="flex items-center justify-between text-[11px] text-slate-400">
                <span>Tab: <strong className="text-white">{banner.targetTab}</strong></span>
                <span className="font-mono text-[10px] text-slate-500 truncate max-w-[150px]">{banner.actionUrl}</span>
              </div>

              <div className="pt-2 border-t border-[#1C3830] flex items-center justify-between">
                <Switch
                  checked={banner.isActive}
                  onChange={(checked) => toggleBanner(banner.id, checked)}
                  label="Display"
                />
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => openEditModal(banner)}
                    className="p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-white/5 transition-colors"
                    title="Edit Banner"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => deleteBanner(banner.id)}
                    className="p-1.5 rounded-lg text-rose-400 hover:bg-rose-500/20 transition-colors"
                    title="Delete Banner"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Add / Edit Banner Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingBannerId ? 'Edit Banner' : 'Add Banner'}
      >
        <form onSubmit={handleSaveBanner} className="space-y-4">
          <ImageDropzone
            label="Banner Image"
            value={bannerForm.imageUrl}
            onChange={(val) => setBannerForm({ ...bannerForm, imageUrl: val })}
            aspectRatioClass="aspect-[16/7]"
            maxSizeMB={10}
          />

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Title</label>
            <input
              type="text"
              required
              value={bannerForm.title}
              onChange={(e) => setBannerForm({ ...bannerForm, title: e.target.value })}
              placeholder="Title"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-emerald-500"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Subtitle</label>
            <input
              type="text"
              value={bannerForm.subtitle}
              onChange={(e) => setBannerForm({ ...bannerForm, subtitle: e.target.value })}
              placeholder="Subtitle"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-emerald-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Target Tab</label>
              <select
                value={bannerForm.targetTab}
                onChange={(e) =>
                  setBannerForm({ ...bannerForm, targetTab: e.target.value as PromotionBanner['targetTab'] })
                }
                className="w-full px-3 py-2 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
              >
                <option value="All">All</option>
                <option value="Party">Party</option>
                <option value="Chat">Chat</option>
                <option value="Top">Top</option>
                <option value="Follow">Follow</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Action Link</label>
              <input
                type="text"
                value={bannerForm.actionUrl}
                onChange={(e) => setBannerForm({ ...bannerForm, actionUrl: e.target.value })}
                placeholder="app://..."
                className="w-full px-3 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
              />
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
              disabled={!bannerForm.imageUrl}
              className="px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 disabled:opacity-50 disabled:cursor-not-allowed text-slate-950 font-black text-xs transition-colors shadow-md"
            >
              {editingBannerId ? 'Update Banner' : 'Publish Banner'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
