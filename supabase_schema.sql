-- ============================================================
-- Royal Chat Live (Gamegala) - Complete Supabase Database Schema
-- Run this script in Supabase Dashboard -> SQL Editor
-- ============================================================

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id TEXT PRIMARY KEY,
    nickname TEXT NOT NULL,
    avatar_url TEXT DEFAULT '',
    country TEXT DEFAULT 'Bangladesh',
    country_flag TEXT DEFAULT '🇧🇩',
    gender TEXT DEFAULT '♂ 20',
    age INT DEFAULT 20,
    level INT DEFAULT 1,
    is_vip BOOLEAN DEFAULT false,
    is_banned BOOLEAN DEFAULT false,
    coin_balance NUMERIC DEFAULT 16800.0,
    gem_balance NUMERIC DEFAULT 0.0,
    friends_count INT DEFAULT 0,
    following_count INT DEFAULT 0,
    fans_count INT DEFAULT 0,
    visitors_count INT DEFAULT 0,
    is_online BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Party Audio Rooms Table
CREATE TABLE IF NOT EXISTS public.rooms (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    host_name TEXT NOT NULL,
    host_avatar TEXT DEFAULT '',
    category TEXT DEFAULT 'Lucky Number',
    country TEXT DEFAULT 'Bangladesh',
    country_flag TEXT DEFAULT '🇧🇩',
    online_count INT DEFAULT 1,
    status TEXT DEFAULT 'live',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Room Mic Seats Table (8 seats per audio room)
CREATE TABLE IF NOT EXISTS public.room_seats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id TEXT NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    seat_index INT NOT NULL,
    user_id TEXT,
    user_name TEXT,
    avatar_url TEXT,
    is_muted BOOLEAN DEFAULT false,
    is_locked BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Community Moments Posts Table
CREATE TABLE IF NOT EXISTS public.moments (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    content TEXT NOT NULL,
    media_urls JSONB DEFAULT '[]'::jsonb,
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    category TEXT DEFAULT 'Moments',
    location TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Wallet Withdrawals Table
CREATE TABLE IF NOT EXISTS public.withdrawals (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    gateway TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    gems INT NOT NULL,
    status TEXT DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. System Announcements Table
CREATE TABLE IF NOT EXISTS public.system_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'system',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Direct 1-on-1 Messages Table
CREATE TABLE IF NOT EXISTS public.direct_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id TEXT NOT NULL,
    receiver_id TEXT NOT NULL,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Leaderboards Ranking Table
CREATE TABLE IF NOT EXISTS public.leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    type TEXT NOT NULL,
    period TEXT NOT NULL,
    rank INT NOT NULL,
    score NUMERIC NOT NULL DEFAULT 0,
    country_flag TEXT DEFAULT '🇧🇩',
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Enable Row Level Security (RLS) & Grant Access to anon / authenticated
-- ============================================================
DO $$ 
DECLARE
    tbl text;
BEGIN
    FOR tbl IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS "Public access policy" ON public.%I;', tbl);
        EXECUTE format('CREATE POLICY "Public access policy" ON public.%I FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);', tbl);
    END LOOP;
END $$;

-- Enable Realtime for all tables
DO $$
BEGIN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles, public.rooms, public.room_seats, public.moments, public.withdrawals, public.system_messages, public.direct_messages;';
EXCEPTION
    WHEN duplicate_object THEN NULL;
    WHEN others THEN NULL;
END $$;

-- ============================================================
-- Initial Dynamic Data Seeding
-- ============================================================

-- Seed Rooms
INSERT INTO public.rooms (id, title, host_name, host_avatar, category, country, country_flag, online_count, status)
VALUES
('room_101', 'Zzzzzzzzzz party vibe', 'Zzzzzzzzzz...', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200', 'Lucky Number', 'Philippines', '🇵🇭', 18, 'live'),
('room_102', '💖 ANG... VIP Lounge', '💖 ANG...', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200', 'Lucky Number', 'Bangladesh', '🇧🇩', 24, 'live'),
('room_103', 'Ayesha Chill Party', 'Ayesha4357', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200', 'Lucky Number', 'Bangladesh', '🇧🇩', 31, 'live')
ON CONFLICT (id) DO NOTHING;

-- Seed Room Seats for room_101
INSERT INTO public.room_seats (room_id, seat_index, user_id, user_name, avatar_url, is_muted, is_locked)
VALUES
('room_101', 0, 'zzzzzzzzzz', 'Zzzzzzzzzz...', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200', false, false),
('room_101', 1, 'yanboyy', 'yanboyy', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200', false, false),
('room_101', 2, 'ayesha', 'Ayesha4357', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200', false, false)
ON CONFLICT DO NOTHING;

-- Seed System Announcements
INSERT INTO public.system_messages (title, content, type, is_read)
VALUES
('Welcome to Royal Chat Live', 'Welcome to Royal Chat Live! Enjoy HD live voice rooms, instant coin exchanges, and moments sharing with friends.', 'system', false),
('Daily Sign-in Reward Active', 'Claim up to 30,000 Coins every week by checking in daily in your Profile tab.', 'system', false);
