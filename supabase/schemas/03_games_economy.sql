-- ==============================================================================
-- Schema Module 03: Games, Economy & Admin Controls
-- Gamegala / Royal Chat Live
-- ==============================================================================

-- 1. Games Configuration Table (Live sync with Admin Panel)
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

-- Seed default games configuration
INSERT INTO public.game_configs (id, name, description, is_active, min_bet, max_bet, rtp, round_seconds, bet_lock_seconds, multipliers)
VALUES
(
    'game_bucket_8',
    'Bucket Spin (8 Items)',
    '8-slot spinning cauldron prediction game (Solo & Group).',
    true,
    100.00,
    10000.00,
    94,
    35,
    30,
    '{"bucket": 2.0, "mug": 2.0, "flower": 2.0, "star": 2.0, "diamond": 2.0, "crown": 2.0, "gift": 2.0, "heart": 2.0}'::jsonb
),
(
    'game_color_3',
    'Color Spin (Red / Violet / Green)',
    '3-color cauldron prediction arena with per-color odds control.',
    true,
    100.00,
    10000.00,
    93,
    35,
    30,
    '{"red": 2.0, "violet": 4.5, "green": 2.0}'::jsonb
),
(
    'game_7up_7down',
    '7 Up 7 Down (Dice)',
    'Fast 18-second dice prediction board (8~12, 7, 2~6).',
    true,
    100.00,
    10000.00,
    92,
    18,
    15,
    '{"up": 2.0, "seven": 5.0, "down": 2.0}'::jsonb
),
(
    'game_balloon_sky',
    'Balloon Sky (Arcade)',
    'Solo endless flight with Free Earn coin bubbles and 2x Double Stake mode.',
    true,
    100.00,
    5000.00,
    95,
    40,
    40,
    '{"standardBubbleCoins": 10, "goldBubbleCoins": 50, "distanceBonusPer4s": 5, "doubleTargetSeconds": 40, "doubleStakeMultiplier": 2.0, "speedBoostAfterSeconds": 40}'::jsonb
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    multipliers = EXCLUDED.multipliers;

-- 2. Rewarded Ads Configuration Table (Admin Panel control for free coin rewards)
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
(
    'ad_admob_1',
    'Google AdMob Rewarded Video',
    'Google AdMob',
    'Watch this short sponsored video to earn free game coins.',
    'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
    'https://admob.google.com',
    500,
    5,
    true
),
(
    'ad_unity_2',
    'Unity Ads: Mega Spin Promo',
    'Unity Ads',
    'Check out top trending games and earn 1,000 bonus coins!',
    'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
    'https://unity.com',
    1000,
    8,
    true
)
ON CONFLICT (id) DO NOTHING;

-- 3. Live Game Rounds History
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

-- 4. User Game Bets Ledger
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

-- 5. Coin Transactions History (Earnings, Ads, Bets, Transfers)
CREATE TABLE IF NOT EXISTS public.coin_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- 'game_win', 'game_bet', 'ad_reward', 'daily_checkin', 'admin_adjustment'
    amount NUMERIC(14, 2) NOT NULL,
    balance_after NUMERIC(14, 2) NOT NULL,
    reference_id TEXT DEFAULT '',
    note TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coin_transactions_user_id ON public.coin_transactions(user_id, created_at DESC);
