-- ==============================================================================
-- Schema Module 05: Wallet, Diamonds & Withdrawals
-- Gamegala / Royal Chat Live
-- ==============================================================================

-- 1. Wallet Withdrawals Table
CREATE TABLE IF NOT EXISTS public.withdrawals (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT DEFAULT '',
    gateway TEXT NOT NULL, -- 'bKash', 'Nagad', 'Rocket', 'USDT'
    account_number TEXT NOT NULL DEFAULT '',
    amount NUMERIC(12, 2) NOT NULL,
    gems INT NOT NULL,
    status TEXT DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
    admin_note TEXT DEFAULT '',
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_withdrawals_user_id ON public.withdrawals(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_withdrawals_status ON public.withdrawals(status);

-- 2. Diamond / Gem Conversion Logs (Gems to Coins or Payouts)
CREATE TABLE IF NOT EXISTS public.gem_conversions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    gems_spent NUMERIC(12, 2) NOT NULL,
    coins_received NUMERIC(14, 2) NOT NULL,
    conversion_rate NUMERIC(10, 4) NOT NULL DEFAULT 10.0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gem_conversions_user_id ON public.gem_conversions(user_id);
