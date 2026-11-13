-- ==============================================================================
-- Schema Module 02: Moments, Stories & Social Community
-- Gamegala / Royal Chat Live
-- ==============================================================================

-- 1. Community Moments Posts Table
CREATE TABLE IF NOT EXISTS public.moments (
    id TEXT PRIMARY KEY,
    author_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_avatar TEXT DEFAULT '',
    country_flag TEXT DEFAULT '🇧🇩',
    author_level INT DEFAULT 1,
    content TEXT NOT NULL DEFAULT '',
    image_urls JSONB DEFAULT '[]'::jsonb,
    media_urls JSONB DEFAULT '[]'::jsonb, -- backward-compatibility for admin
    category TEXT DEFAULT 'Moments',
    location TEXT DEFAULT '',
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    shares_count INT DEFAULT 0,
    is_repost BOOLEAN DEFAULT false,
    reposted_from_author TEXT DEFAULT '',
    reposted_from_post_id TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_moments_author_id ON public.moments(author_id);
CREATE INDEX IF NOT EXISTS idx_moments_created_at ON public.moments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moments_category ON public.moments(category);

-- 2. Moment Comments Table
CREATE TABLE IF NOT EXISTS public.moment_comments (
    id TEXT PRIMARY KEY,
    post_id TEXT NOT NULL REFERENCES public.moments(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_moment_comments_post_id ON public.moment_comments(post_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_moment_comments_user_id ON public.moment_comments(user_id);

-- 3. Moment Likes Table
CREATE TABLE IF NOT EXISTS public.moment_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id TEXT NOT NULL REFERENCES public.moments(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_moment_likes UNIQUE (post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_moment_likes_post_id ON public.moment_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_moment_likes_user_id ON public.moment_likes(user_id);

-- 4. 24-Hour Moments Stories Table
CREATE TABLE IF NOT EXISTS public.moment_stories (
    id TEXT PRIMARY KEY,
    author_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_avatar TEXT DEFAULT '',
    country_flag TEXT DEFAULT '🇧🇩',
    media_url TEXT,
    caption TEXT NOT NULL DEFAULT '',
    bg_gradient_index INT DEFAULT 0,
    views_count INT DEFAULT 0,
    likes_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours')
);

CREATE INDEX IF NOT EXISTS idx_moment_stories_author_id ON public.moment_stories(author_id);
CREATE INDEX IF NOT EXISTS idx_moment_stories_expires_at ON public.moment_stories(expires_at DESC);

-- 5. Trigger Functions: Update Likes & Comments Count on moments
CREATE OR REPLACE FUNCTION public.fn_update_moment_likes_count()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.moments
        SET likes_count = likes_count + 1
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.moments
        SET likes_count = GREATEST(0, likes_count - 1)
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_moment_likes_count ON public.moment_likes;
CREATE TRIGGER trg_moment_likes_count
    AFTER INSERT OR DELETE ON public.moment_likes
    FOR EACH ROW EXECUTE FUNCTION public.fn_update_moment_likes_count();

CREATE OR REPLACE FUNCTION public.fn_update_moment_comments_count()
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.moments
        SET comments_count = comments_count + 1
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.moments
        SET comments_count = GREATEST(0, comments_count - 1)
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_moment_comments_count ON public.moment_comments;
CREATE TRIGGER trg_moment_comments_count
    AFTER INSERT OR DELETE ON public.moment_comments
    FOR EACH ROW EXECUTE FUNCTION public.fn_update_moment_comments_count();
