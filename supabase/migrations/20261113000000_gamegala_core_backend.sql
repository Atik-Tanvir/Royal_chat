-- ==============================================================================
-- Gamegala / Royal Chat Live - Complete Master Database Migration
-- Version: 20261113000000
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Profiles & Follows
-- ------------------------------------------------------------------------------
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

CREATE INDEX IF NOT EXISTS idx_profiles_username_handle ON public.profiles(username_handle);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON public.profiles(level DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_coin_balance ON public.profiles(coin_balance DESC);

CREATE TABLE IF NOT EXISTS public.user_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    following_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_user_follows UNIQUE (follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON public.user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON public.user_follows(following_id);

-- ------------------------------------------------------------------------------
-- 2. Moments, Comments, Likes & Stories
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.moments (
    id TEXT PRIMARY KEY,
    author_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_avatar TEXT DEFAULT '',
    country_flag TEXT DEFAULT '🇧🇩',
    author_level INT DEFAULT 1,
    content TEXT NOT NULL DEFAULT '',
    image_urls JSONB DEFAULT '[]'::jsonb,
    media_urls JSONB DEFAULT '[]'::jsonb,
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

CREATE TABLE IF NOT EXISTS public.moment_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id TEXT NOT NULL REFERENCES public.moments(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_moment_likes UNIQUE (post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_moment_likes_post_id ON public.moment_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_moment_likes_user_id ON public.moment_likes(user_id);

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

-- ------------------------------------------------------------------------------
-- 3. Games, Configurations & Economy
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.game_configs (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    is_active BOOLEAN DEFAULT true,
    min_bet NUMERIC(10, 2) DEFAULT 100.00,
    max_bet NUMERIC(10, 2) DEFAULT 10000.00,
    rtp INT DEFAULT 94,
    round_seconds INT DEFAULT 35,
    bet_lock_seconds INT DEFAULT 30,
    multipliers JSONB NOT NULL DEFAULT '{}'::jsonb,
    emergency_lockdown BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.game_configs (id, name, description, is_active, min_bet, max_bet, rtp, round_seconds, bet_lock_seconds, multipliers)
VALUES
('game_bucket_8', 'Bucket Spin (8 Items)', '8-slot spinning cauldron prediction game (Solo & Group).', true, 100.00, 10000.00, 94, 35, 30, '{"bucket": 2.0, "mug": 2.0, "flower": 2.0, "star": 2.0, "diamond": 2.0, "crown": 2.0, "gift": 2.0, "heart": 2.0}'::jsonb),
('game_color_3', 'Color Spin (Red / Violet / Green)', '3-color cauldron prediction arena with per-color odds control.', true, 100.00, 10000.00, 93, 35, 30, '{"red": 2.0, "violet": 4.5, "green": 2.0}'::jsonb),
('game_7up_7down', '7 Up 7 Down (Dice)', 'Fast 18-second dice prediction board (8~12, 7, 2~6).', true, 100.00, 10000.00, 92, 18, 15, '{"up": 2.0, "seven": 5.0, "down": 2.0}'::jsonb),
('game_balloon_sky', 'Balloon Sky (Arcade)', 'Solo endless flight with Free Earn coin bubbles and 2x Double Stake mode.', true, 100.00, 5000.00, 95, 40, 40, '{"standardBubbleCoins": 10, "goldBubbleCoins": 50, "distanceBonusPer4s": 5, "doubleTargetSeconds": 40, "doubleStakeMultiplier": 2.0, "speedBoostAfterSeconds": 40}'::jsonb)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    multipliers = EXCLUDED.multipliers;

CREATE TABLE IF NOT EXISTS public.ads_configs (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    network TEXT NOT NULL DEFAULT 'Google AdMob',
    description TEXT DEFAULT '',
    image_url TEXT DEFAULT '',
    target_url TEXT DEFAULT '',
    reward_coins INT DEFAULT 500,
    duration_seconds INT DEFAULT 5,
    is_enabled BOOLEAN DEFAULT true,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.ads_configs (id, title, network, description, image_url, target_url, reward_coins, duration_seconds, is_enabled)
VALUES
('ad_admob_1', 'Google AdMob Rewarded Video', 'Google AdMob', 'Watch this short sponsored video to earn free game coins.', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600', 'https://admob.google.com', 500, 5, true),
('ad_unity_2', 'Unity Ads: Mega Spin Promo', 'Unity Ads', 'Check out top trending games and earn 1,000 bonus coins!', 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600', 'https://unity.com', 1000, 8, true)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.game_rounds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id TEXT NOT NULL REFERENCES public.game_configs(id),
    round_number BIGINT NOT NULL,
    winning_target TEXT NOT NULL,
    total_bets_count INT DEFAULT 0,
    total_bet_coins NUMERIC(14, 2) DEFAULT 0.00,
    total_payout_coins NUMERIC(14, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_game_rounds_game_id ON public.game_rounds(game_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.game_bets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    round_id UUID REFERENCES public.game_rounds(id) ON DELETE SET NULL,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    game_id TEXT NOT NULL REFERENCES public.game_configs(id),
    bet_target TEXT NOT NULL,
    bet_amount NUMERIC(12, 2) NOT NULL,
    multiplier NUMERIC(6, 2) NOT NULL DEFAULT 1.00,
    is_win BOOLEAN DEFAULT false,
    payout_amount NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_game_bets_user_id ON public.game_bets(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_bets_round_id ON public.game_bets(round_id);

CREATE TABLE IF NOT EXISTS public.coin_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    amount NUMERIC(14, 2) NOT NULL,
    balance_after NUMERIC(14, 2) NOT NULL,
    reference_id TEXT DEFAULT '',
    note TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coin_transactions_user_id ON public.coin_transactions(user_id, created_at DESC);

-- ------------------------------------------------------------------------------
-- 4. Rooms, Seats & Gifts
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.rooms (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    host_id TEXT REFERENCES public.profiles(id) ON DELETE SET NULL,
    host_name TEXT NOT NULL,
    host_avatar TEXT DEFAULT '',
    category TEXT DEFAULT 'Lucky Number',
    country TEXT DEFAULT 'Bangladesh',
    country_flag TEXT DEFAULT '🇧🇩',
    online_count INT DEFAULT 1,
    status TEXT DEFAULT 'live',
    is_locked BOOLEAN DEFAULT false,
    lock_pin TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rooms_status ON public.rooms(status);
CREATE INDEX IF NOT EXISTS idx_rooms_category ON public.rooms(category);

CREATE TABLE IF NOT EXISTS public.room_seats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id TEXT NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    seat_index INT NOT NULL,
    user_id TEXT REFERENCES public.profiles(id) ON DELETE SET NULL,
    user_name TEXT,
    avatar_url TEXT,
    is_muted BOOLEAN DEFAULT false,
    is_locked BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_room_seat UNIQUE (room_id, seat_index)
);

CREATE INDEX IF NOT EXISTS idx_room_seats_room_id ON public.room_seats(room_id);

CREATE TABLE IF NOT EXISTS public.gifts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    coin_price INT NOT NULL DEFAULT 100,
    gem_value INT NOT NULL DEFAULT 50,
    animation_url TEXT DEFAULT '',
    icon_url TEXT DEFAULT '',
    category TEXT DEFAULT 'Popular',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.gifts (id, name, coin_price, gem_value, icon_url)
VALUES
('gift_rose', 'Royal Rose', 10, 5, '🌹'),
('gift_heart', 'Golden Heart', 100, 50, '💖'),
('gift_crown', 'Imperial Crown', 1000, 500, '👑'),
('gift_sports_car', 'Super Sports Car', 5000, 2500, '🏎️'),
('gift_rocket', 'Galaxy Rocket', 20000, 10000, '🚀')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 5. Wallet Withdrawals & Conversions
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.withdrawals (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    gateway TEXT NOT NULL,
    account_number TEXT NOT NULL DEFAULT '',
    amount NUMERIC(12, 2) NOT NULL,
    gems INT NOT NULL,
    status TEXT DEFAULT 'Pending',
    transaction_id TEXT DEFAULT '',
    admin_note TEXT DEFAULT '',
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_withdrawals_user_id ON public.withdrawals(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_withdrawals_status ON public.withdrawals(status);

CREATE TABLE IF NOT EXISTS public.gem_conversions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    gems_spent NUMERIC(12, 2) NOT NULL,
    coins_received NUMERIC(14, 2) NOT NULL,
    conversion_rate NUMERIC(10, 4) NOT NULL DEFAULT 10.0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gem_conversions_user_id ON public.gem_conversions(user_id);

-- ------------------------------------------------------------------------------
-- 6. Messages & Leaderboards
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.system_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'system',
    target_user_id TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_system_messages_target ON public.system_messages(target_user_id, created_at DESC);

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

CREATE TABLE IF NOT EXISTS public.leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    type TEXT NOT NULL,
    period TEXT NOT NULL,
    rank INT NOT NULL,
    score NUMERIC NOT NULL DEFAULT 0,
    country_flag TEXT DEFAULT '🇧🇩',
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_leaderboard_entry UNIQUE (type, period, rank)
);

CREATE INDEX IF NOT EXISTS idx_leaderboards_lookup ON public.leaderboards(type, period, rank ASC);

-- ------------------------------------------------------------------------------
-- 7. Seed Initial Community Data & Rooms
-- ------------------------------------------------------------------------------
INSERT INTO public.profiles (id, nickname, username_handle, avatar_url, country_flag, level, coin_balance, bio, location)
VALUES
('user_yanboyy', 'yanboyy', '@yanboyy_ctg', 'royal_avatar://YB:E65100', '🇧🇩', 24, 250000.00, 'Lucky Wheel hunter • Chittagong vibes • Always up for group Color Spin!', 'Chittagong, Bangladesh'),
('user_sadia', 'SadiaQueen', '@sadia_queen', 'royal_avatar://SQ:8E24AA', '🇧🇩', 31, 85000.00, 'Voice Party host 🎤 Music, PK nights, and daily coin giveaways!', 'Dhaka, Bangladesh'),
('user_arafat', 'Arafat_BD', '@arafat_bd', 'royal_avatar://AB:00897B', '🇧🇩', 19, 42000.00, 'Balloon Sky top pilot 🎈 & evening chai enthusiast.', 'Sylhet, Bangladesh'),
('user_farhan', 'FarhanPK', '@farhan_pk', 'royal_avatar://FP:C2185B', '🇧🇩', 28, 98000.00, 'PK Arena regular 👑 Love competing in Color Spin & Bucket Spin.', 'Dhaka, Bangladesh')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.moments (id, author_id, author_name, author_avatar, country_flag, author_level, content, image_urls, media_urls, category, location, likes_count, comments_count, shares_count)
VALUES
('starter_yanboyy', 'user_yanboyy', 'yanboyy', 'royal_avatar://YB:E65100', '🇧🇩', 24, 'Just won 250,000 coins on the Lucky Wheel! 🔥 Luck is definitely on my side today!', '["royal_art://lucky_wheel"]'::jsonb, '["royal_art://lucky_wheel"]'::jsonb, 'Moments', 'Chittagong', 216, 2, 18),
('starter_sadia', 'user_sadia', 'SadiaQueen', 'royal_avatar://SQ:8E24AA', '🇧🇩', 31, 'Hosting Golden Mic Voice Party tonight at 9 PM! Drop by for PK battles and coin rain 🎤✨', '["royal_art://party_stage"]'::jsonb, '["royal_art://party_stage"]'::jsonb, 'Moments', 'Dhaka', 148, 0, 9),
('starter_arafat', 'user_arafat', 'Arafat_BD', 'royal_avatar://AB:00897B', '🇧🇩', 19, 'Evening chai & Balloon Sky high score run! Who can beat 42 seconds on fast speed mode? 🎈🚀', '["royal_art://balloon_sky"]'::jsonb, '["royal_art://balloon_sky"]'::jsonb, 'Moments', 'Sylhet', 96, 0, 7),
('starter_farhan', 'user_farhan', 'FarhanPK', 'royal_avatar://FP:C2185B', '🇧🇩', 28, 'Clean sweep in Color Spin Royale! Red & Gold hit back-to-back in group room 👑💛', '["royal_art://pk_trophy"]'::jsonb, '["royal_art://pk_trophy"]'::jsonb, 'Moments', 'Dhaka', 183, 0, 14)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.moment_comments (id, post_id, user_id, user_name, user_avatar, text)
VALUES
('c_yan_1', 'starter_yanboyy', 'user_sadia', 'SadiaQueen', 'royal_avatar://SQ:8E24AA', 'Congratulations bro! 250K jackpot is massive!'),
('c_yan_2', 'starter_yanboyy', 'user_arafat', 'Arafat_BD', 'royal_avatar://AB:00897B', 'Save some luck for tonight party room!')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.moment_stories (id, author_id, author_name, author_avatar, country_flag, media_url, caption, bg_gradient_index, views_count, likes_count)
VALUES
('story_yanboyy_1', 'user_yanboyy', 'yanboyy', 'royal_avatar://YB:E65100', '🇧🇩', 'royal_art://lucky_wheel', '250K coin Lucky Wheel streak! Spin with us today 🎯', 1, 64, 29),
('story_sadia_1', 'user_sadia', 'SadiaQueen', 'royal_avatar://SQ:8E24AA', '🇧🇩', 'royal_art://party_stage', 'Golden Mic Acoustic Room live soon — join stage!', 2, 112, 51),
('story_arafat_1', 'user_arafat', 'Arafat_BD', 'royal_avatar://AB:00897B', '🇧🇩', NULL, 'Good evening Dhaka! Looking for 7 Up 7 Down squadmates ☕🎲', 0, 41, 17)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.rooms (id, title, host_id, host_name, host_avatar, category, country, country_flag, online_count, status)
VALUES
-- Lucky Number (🎰)
('room_101', 'Zzzzzzzzzz party vibe', 'user_yanboyy', 'Zzzzzzzzzz...', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200', 'Lucky Number', 'Philippines', '🇵🇭', 18, 'live'),
('room_102', '💖 ANG... VIP Lounge', 'user_sadia', '💖 ANG...', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200', 'Lucky Number', 'Bangladesh', '🇧🇩', 24, 'live'),
('room_103', 'Ayesha Chill Party', 'user_arafat', 'Ayesha4357', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200', 'Lucky Number', 'Bangladesh', '🇧🇩', 31, 'live'),
('room_104', 'Mega Jackpot 777 🎰', 'user_yanboyy', 'Tanvir_Pro', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200', 'Lucky Number', 'Bangladesh', '🇧🇩', 45, 'live'),
('room_105', 'High Rollers Dice Club 🎲', 'user_farhan', 'Ali_Khan_PK', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200', 'Lucky Number', 'Pakistan', '🇵🇰', 38, 'live'),
('room_106', 'Fortune Wheel VIP 💎', 'user_sadia', 'Priya_Royal', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200', 'Lucky Number', 'India', '🇮🇳', 52, 'live'),

-- Lucky Race (🟨 sports_motorsports / helmet)
('race_201', 'Dhaka Nitro Drift 🏎️', 'user_arafat', 'Racer_Shanto', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200', 'Lucky Race', 'Bangladesh', '🇧🇩', 28, 'live'),
('race_202', 'Formula Royal GP 🏁', 'user_farhan', 'Hamza_Speed', 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200', 'Lucky Race', 'Pakistan', '🇵🇰', 42, 'live'),
('race_203', 'Turbo Speed Challenge ⚡', 'developer_demo_user', 'Vikram_Rider', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200', 'Lucky Race', 'India', '🇮🇳', 35, 'live'),
('race_204', 'Night Highway Racers 🌙', 'user_yanboyy', 'Fahim_Turbo', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200', 'Lucky Race', 'Bangladesh', '🇧🇩', 19, 'live'),
('race_205', 'Supercar Apex Club 🏎️', 'user_farhan', 'Zeeshan_Apex', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200', 'Lucky Race', 'Pakistan', '🇵🇰', 61, 'live'),
('race_206', 'Speedway Champions 🏆', 'developer_demo_user', 'Rohit_Racer', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200', 'Lucky Race', 'India', '🇮🇳', 33, 'live'),

-- Chatroom (🟥 forum / chat bubbles)
('chat_301', 'Night Adda & Acoustic 🎸', 'user_sadia', 'Nabila_Sings', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200', 'Chatroom', 'Bangladesh', '🇧🇩', 64, 'live'),
('chat_302', 'Late Night Melody ☕', 'user_farhan', 'Bilal_Acoustic', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200', 'Chatroom', 'Pakistan', '🇵🇰', 48, 'live'),
('chat_303', 'Bollywood Chai & Talks 🎶', 'developer_demo_user', 'Ananya_Voice', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200', 'Chatroom', 'India', '🇮🇳', 75, 'live'),
('chat_304', 'Friendship Hub Dhaka ☕', 'user_arafat', 'Sabbir_Host', 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=200', 'Chatroom', 'Bangladesh', '🇧🇩', 29, 'live'),
('chat_305', 'Sufi Soul Nights 🌙', 'user_farhan', 'Zahra_Sufi', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200', 'Chatroom', 'Pakistan', '🇵🇰', 53, 'live'),
('chat_306', 'Desi Music & Chill 🎧', 'developer_demo_user', 'Arjun_Radio', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200', 'Chatroom', 'India', '🇮🇳', 41, 'live'),

-- PK (⚡ offline_bolt / lightning)
('pk_401', 'Mega PK: Dhaka vs Lahore ⚡', 'user_yanboyy', 'Rifat_Boss', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200', 'PK', 'Bangladesh', '🇧🇩', 88, 'live'),
('pk_402', '1v1 Crown War: Gift Rush 👑', 'user_farhan', 'Faizan_King', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200', 'PK', 'Pakistan', '🇵🇰', 95, 'live'),
('pk_403', 'Royal Gladiator PK Arena ⚔️', 'user_sadia', 'Rhea_Warrior', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200', 'PK', 'India', '🇮🇳', 67, 'live'),
('pk_404', 'Star Battle Live PK 💥', 'user_arafat', 'Mehedi_Host', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200', 'PK', 'Bangladesh', '🇧🇩', 54, 'live'),
('pk_405', 'Ultimate Rivalry Showdown 🔥', 'user_farhan', 'Tariq_Pro', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200', 'PK', 'Pakistan', '🇵🇰', 73, 'live'),
('pk_406', 'Champion Belt PK Clash 🏆', 'developer_demo_user', 'Simran_Star', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200', 'PK', 'India', '🇮🇳', 62, 'live')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.room_seats (room_id, seat_index, user_id, user_name, avatar_url, is_muted, is_locked)
VALUES
('room_101', 0, 'user_yanboyy', 'yanboyy', 'royal_avatar://YB:E65100', false, false),
('room_101', 1, 'user_sadia', 'SadiaQueen', 'royal_avatar://SQ:8E24AA', false, false),
('room_101', 2, 'user_arafat', 'Arafat_BD', 'royal_avatar://AB:00897B', false, false)
ON CONFLICT DO NOTHING;

INSERT INTO public.system_messages (title, content, type, is_read)
VALUES
('Welcome to Royal Chat Live', 'Welcome to Royal Chat Live! Enjoy HD live voice rooms, instant coin exchanges, and moments sharing with friends.', 'system', false),
('Daily Sign-in Reward Active', 'Claim up to 30,000 Coins every week by checking in daily in your Profile tab.', 'system', false)
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------------------------
-- 8. Row-Level Security (RLS) & Realtime Publication
-- ------------------------------------------------------------------------------
DO $$ 
DECLARE
    tbl text;
BEGIN
    FOR tbl IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS "Public access policy" ON public.%I;', tbl);
        EXECUTE format('CREATE POLICY "Public access policy" ON public.%I FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);', tbl);
    END LOOP;
END $$;

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
