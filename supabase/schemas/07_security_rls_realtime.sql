-- ==============================================================================
-- Schema Module 07: Security, Row-Level Security (RLS) & Realtime Publication
-- Gamegala / Royal Chat Live
-- ==============================================================================

-- 1. Enable Row-Level Security on all public tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moment_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moment_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ads_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coin_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gem_conversions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.direct_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaderboards ENABLE ROW LEVEL SECURITY;

-- 2. Clean up existing policies for idempotency
DO $$
DECLARE
    t text;
    p text;
BEGIN
    FOR t IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        FOR p IN 
            SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = t
        LOOP
            EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', p, t);
        END LOOP;
    END LOOP;
END $$;

-- 3. Public Read Policies (Allow anon and authenticated to view public game & community data)
CREATE POLICY "Public profiles are viewable by everyone" 
    ON public.profiles FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Users can update their own profile" 
    ON public.profiles FOR UPDATE 
    TO authenticated 
    USING (id = (SELECT auth.uid()::text))
    WITH CHECK (id = (SELECT auth.uid()::text));

CREATE POLICY "Users can insert their own profile" 
    ON public.profiles FOR INSERT 
    TO anon, authenticated 
    WITH CHECK (true);

-- Moments & Social Policies
CREATE POLICY "Moments are viewable by everyone" 
    ON public.moments FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Users can insert moments" 
    ON public.moments FOR INSERT 
    TO anon, authenticated 
    WITH CHECK (true);

CREATE POLICY "Authors can update their moments" 
    ON public.moments FOR UPDATE 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Authors can delete their moments" 
    ON public.moments FOR DELETE 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Moment comments are viewable by everyone" 
    ON public.moment_comments FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Users can post moment comments" 
    ON public.moment_comments FOR INSERT 
    TO anon, authenticated 
    WITH CHECK (true);

CREATE POLICY "Moment likes are viewable by everyone" 
    ON public.moment_likes FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Users can toggle likes" 
    ON public.moment_likes FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Stories are viewable by everyone" 
    ON public.moment_stories FOR SELECT 
    TO anon, authenticated 
    USING (expires_at > NOW());

CREATE POLICY "Users can publish stories" 
    ON public.moment_stories FOR INSERT 
    TO anon, authenticated 
    WITH CHECK (true);

CREATE POLICY "Authors can delete their stories" 
    ON public.moment_stories FOR DELETE 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Follows are viewable and manageable" 
    ON public.user_follows FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

-- Games & Economy Policies
CREATE POLICY "Game configs viewable by all" 
    ON public.game_configs FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Game configs manageable by admin" 
    ON public.game_configs FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Ads configs viewable by all" 
    ON public.ads_configs FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Ads configs manageable by admin" 
    ON public.ads_configs FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Game rounds viewable by all" 
    ON public.game_rounds FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Game bets manageable by players" 
    ON public.game_bets FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Coin transactions readable by owner" 
    ON public.coin_transactions FOR SELECT 
    TO anon, authenticated 
    USING (true);

-- Rooms & Party Policies
CREATE POLICY "Rooms viewable by all" 
    ON public.rooms FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Rooms manageable by host and admin" 
    ON public.rooms FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Room seats viewable by all" 
    ON public.room_seats FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Room seats manageable by participants" 
    ON public.room_seats FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Gifts catalog viewable by all" 
    ON public.gifts FOR SELECT 
    TO anon, authenticated 
    USING (true);

-- Wallet & Withdrawals Policies
CREATE POLICY "Withdrawals readable and creatable" 
    ON public.withdrawals FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Gem conversions logged" 
    ON public.gem_conversions FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

-- Messages & Notifications Policies
CREATE POLICY "System messages readable" 
    ON public.system_messages FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY "Direct messages accessible by participants" 
    ON public.direct_messages FOR ALL 
    TO anon, authenticated 
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Leaderboards viewable by all" 
    ON public.leaderboards FOR SELECT 
    TO anon, authenticated 
    USING (true);

-- 4. Enable Supabase Realtime Publication for Live Gaming & Chat
DO $$
BEGIN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE 
        public.profiles,
        public.rooms,
        public.room_seats,
        public.moments,
        public.moment_comments,
        public.moment_stories,
        public.game_configs,
        public.withdrawals,
        public.system_messages,
        public.direct_messages;';
EXCEPTION
    WHEN duplicate_object THEN NULL;
    WHEN others THEN NULL;
END $$;
