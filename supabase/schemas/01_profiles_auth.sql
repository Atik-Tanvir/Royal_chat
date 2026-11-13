-- ==============================================================================
-- Schema Module 01: User Authentication & Profiles
-- Gamegala / Royal Chat Live
-- ==============================================================================

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id TEXT PRIMARY KEY,
    email TEXT,
    username_handle TEXT UNIQUE,
    nickname TEXT NOT NULL DEFAULT 'Royal Player',
    avatar_url TEXT DEFAULT '',
    cover_image_url TEXT DEFAULT '',
    cover_gradient_index INT DEFAULT 0,
    bio TEXT DEFAULT '',
    country TEXT DEFAULT 'Bangladesh',
    country_flag TEXT DEFAULT '🇧🇩',
    gender TEXT DEFAULT '♂ 20',
    age INT DEFAULT 20,
    level INT DEFAULT 1,
    is_vip BOOLEAN DEFAULT false,
    is_banned BOOLEAN DEFAULT false,
    coin_balance NUMERIC(14, 2) DEFAULT 16800.00,
    gem_balance NUMERIC(14, 2) DEFAULT 0.00,
    friends_count INT DEFAULT 0,
    following_count INT DEFAULT 0,
    fans_count INT DEFAULT 0,
    visitors_count INT DEFAULT 0,
    is_online BOOLEAN DEFAULT true,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for username lookups and leaderboards
CREATE INDEX IF NOT EXISTS idx_profiles_username_handle ON public.profiles(username_handle);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON public.profiles(level DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_coin_balance ON public.profiles(coin_balance DESC);

-- 2. User Follows Table
CREATE TABLE IF NOT EXISTS public.user_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    following_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_user_follows UNIQUE (follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON public.user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON public.user_follows(following_id);

-- 3. Trigger Function: Sync auth.users to public.profiles automatically
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        email,
        username_handle,
        nickname,
        avatar_url,
        country,
        country_flag,
        coin_balance
    )
    VALUES (
        NEW.id::text,
        NEW.email,
        COALESCE('@' || LOWER(REGEXP_REPLACE(SPLIT_PART(NEW.email, '@', 1), '[^a-zA-Z0-9_]', '', 'g')), '@player'),
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1), 'Royal Player'),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture', ''),
        'Bangladesh',
        '🇧🇩',
        16800.00
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Safe trigger creation for auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
