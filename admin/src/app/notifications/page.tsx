'use client';

import React, { useState, useEffect } from 'react';
import { supabase, SystemMessageRecord } from '../../shared/lib/supabase';
import { Badge } from '../../shared/components/ui/Badge';
import { Modal } from '../../shared/components/ui/Modal';
import { formatDate } from '../../shared/lib/utils';
import {
  Bell,
  Send,
  Trash2,
  CheckCircle2,
} from 'lucide-react';

const mockAnnouncements: SystemMessageRecord[] = [
  {
    id: 'ann_1',
    title: 'Season 1 Grand Tournament',
    content: 'Grand Voice Arena Season 1 is live with $10,000 in tournament prizes.',
    type: 'system',
    created_at: new Date().toISOString(),
  },
  {
    id: 'ann_2',
    title: 'Server Optimization',
    content: 'LiveKit server optimizations completed. Ultra low-latency voice active.',
    type: 'maintenance',
    created_at: new Date(Date.now() - 86400000).toISOString(),
  },
  {
    id: 'ann_3',
    title: 'Weekend Diamond Bonus',
    content: 'Double diamond rewards on all lucky race spins this weekend.',
    type: 'event',
    created_at: new Date(Date.now() - 172800000).toISOString(),
  },
];

export default function NotificationsPage() {
  const [messages, setMessages] = useState<SystemMessageRecord[]>(mockAnnouncements);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newNotice, setNewNotice] = useState({
    title: '',
    content: '',
    type: 'system',
    target: 'all' as 'all' | 'user',
    targetUserId: '',
  });
  const [isSent, setIsSent] = useState(false);

  useEffect(() => {
    async function loadAnnouncements() {
      try {
        const { data } = await supabase
          .from('system_messages')
          .select('*')
          .order('created_at', { ascending: false });

        if (data && data.length > 0) {
          setMessages(data as SystemMessageRecord[]);
        }
      } catch {
        // mock fallback
      }
    }
    loadAnnouncements();
  }, []);

  async function handleSendBroadcast(e: React.FormEvent) {
    e.preventDefault();
    if (!newNotice.title || !newNotice.content) return;

    const created: SystemMessageRecord = {
      id: `ann_${Date.now()}`,
      title: newNotice.title,
      content: newNotice.content,
      type: newNotice.type,
      created_at: new Date().toISOString(),
    };

    setMessages([created, ...messages]);
    setIsModalOpen(false);
    setIsSent(true);
    setTimeout(() => setIsSent(false), 2500);

    try {
      await supabase.from('system_messages').insert({
        title: created.title,
        content: created.content,
        type: created.type,
      });
    } catch (err) {
      console.error(err);
    }

    setNewNotice({ title: '', content: '', type: 'system', target: 'all', targetUserId: '' });
  }

  async function deleteMessage(id: string) {
    if (!confirm('Delete message?')) return;
    setMessages((prev) => prev.filter((m) => m.id !== id));
    try {
      await supabase.from('system_messages').delete().eq('id', id);
    } catch (e) {
      console.error(e);
    }
  }

  return (
    <div className="space-y-6">
      {/* Header (No Subtitle) */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <h2 className="text-xl sm:text-2xl font-black text-white flex items-center gap-2">
          <Bell className="w-6 h-6 text-emerald-400" />
          <span>Broadcasts</span>
        </h2>

        <button
          onClick={() => setIsModalOpen(true)}
          className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs transition-all shadow-md"
        >
          <Send className="w-4 h-4" />
          <span>New Broadcast</span>
        </button>
      </div>

      {isSent && (
        <div className="p-3 rounded-xl bg-emerald-500/15 border border-emerald-500/40 text-emerald-300 text-xs font-bold flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4" />
          <span>Broadcast sent to all users.</span>
        </div>
      )}

      {/* Messages List */}
      <div className="space-y-3">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className="p-4 rounded-2xl glass-panel border border-[#1C3830] flex flex-col sm:flex-row sm:items-start justify-between gap-3"
          >
            <div className="flex items-start gap-3">
              <div
                className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 text-base ${
                  msg.type === 'maintenance'
                    ? 'bg-amber-500/20 text-amber-400'
                    : msg.type === 'event'
                    ? 'bg-purple-500/20 text-purple-400'
                    : 'bg-emerald-500/20 text-emerald-400'
                }`}
              >
                {msg.type === 'maintenance' ? '⚙️' : msg.type === 'event' ? '🎁' : '📢'}
              </div>
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="text-xs font-bold text-white">{msg.title}</h3>
                  <Badge variant={msg.type === 'maintenance' ? 'amber' : msg.type === 'event' ? 'purple' : 'emerald'}>
                    {msg.type}
                  </Badge>
                </div>
                <p className="text-xs text-slate-300 leading-relaxed max-w-3xl">{msg.content}</p>
                <span className="text-[10px] text-slate-500 mt-1.5 block font-mono" suppressHydrationWarning>
                  {formatDate(msg.created_at)}
                </span>
              </div>
            </div>

            <button
              onClick={() => deleteMessage(msg.id)}
              className="p-1.5 rounded-xl text-rose-400 hover:bg-rose-500/20 transition-colors self-end sm:self-start"
            >
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>

      {/* Modal */}
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title="New Broadcast">
        <form onSubmit={handleSendBroadcast} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Title</label>
            <input
              type="text"
              required
              value={newNotice.title}
              onChange={(e) => setNewNotice({ ...newNotice, title: e.target.value })}
              placeholder="Title"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white focus:outline-none focus:border-emerald-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Target</label>
              <select
                value={newNotice.target}
                onChange={(e) => setNewNotice({ ...newNotice, target: e.target.value as 'all' | 'user' })}
                className="w-full px-3 py-2 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
              >
                <option value="all">All Users (Broadcast)</option>
                <option value="user">Specific User ID</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Type</label>
              <select
                value={newNotice.type}
                onChange={(e) => setNewNotice({ ...newNotice, type: e.target.value })}
                className="w-full px-3 py-2 rounded-xl bg-[#0B1512] border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500"
              >
                <option value="system">Official System</option>
                <option value="maintenance">Maintenance</option>
                <option value="event">Event / Bonus</option>
                <option value="security">Security / Warning</option>
              </select>
            </div>
          </div>

          {newNotice.target === 'user' && (
            <div>
              <label className="block text-xs font-bold text-slate-300 mb-1">Recipient User ID</label>
              <input
                type="text"
                required
                value={newNotice.targetUserId}
                onChange={(e) => setNewNotice({ ...newNotice, targetUserId: e.target.value })}
                placeholder="e.g. user_1001"
                className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-sm text-white font-mono focus:outline-none focus:border-emerald-500"
              />
            </div>
          )}

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">Message</label>
            <textarea
              required
              rows={3}
              value={newNotice.content}
              onChange={(e) => setNewNotice({ ...newNotice, content: e.target.value })}
              placeholder="Message body"
              className="w-full px-3.5 py-2 rounded-xl bg-black/40 border border-[#1C3830] text-xs text-white focus:outline-none focus:border-emerald-500 leading-relaxed"
            />
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
              className="px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-xs transition-colors"
            >
              Send
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
