-- ==============================================================================
-- Schema Module 06: Messages, Announcements & Leaderboards
-- Gamegala / Royal Chat Live
-- ==============================================================================

-- 1. System Announcements & Global Notifications
CREATE TABLE IF NOT EXISTS public.system_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'system', -- 'system', 'reward', 'security', 'game'
    target_user_id TEXT, -- NULL for broadcast to all users
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_system_messages_target ON public.system_messages(target_user_id, created_at DESC);

-- 2. Direct 1-on-1 Messages Table
CREATE TABLE IF NOT EXISTS public.direct_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    receiver_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    media_url TEXT DEFAULT '',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_direct_messages_participants ON public.direct_messages(sender_id, receiver_id, created_at DESC);

-- 3. Leaderboards Ranking Table
CREATE TABLE IF NOT EXISTS public.leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    type TEXT NOT NULL, -- 'hourly', 'daily', 'weekly', 'invites'
    period TEXT NOT NULL,
    rank INT NOT NULL,
    score NUMERIC NOT NULL DEFAULT 0,
    country_flag TEXT DEFAULT '🇧🇩',
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_leaderboard_entry UNIQUE (type, period, rank)
);

CREATE INDEX IF NOT EXISTS idx_leaderboards_lookup ON public.leaderboards(type, period, rank ASC);
