-- ==============================================================================
-- Schema Module 04: Party Audio Rooms & Live Voice Seats
-- Gamegala / Royal Chat Live
-- ==============================================================================

-- 1. Party Audio Rooms Table
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

-- 2. Room Mic Seats Table (8 seats per audio room)
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

-- 3. Room Gifts Catalog
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

-- Seed Starter Gifts
INSERT INTO public.gifts (id, name, coin_price, gem_value, icon_url)
VALUES
('gift_rose', 'Royal Rose', 10, 5, '🌹'),
('gift_heart', 'Golden Heart', 100, 50, '💖'),
('gift_crown', 'Imperial Crown', 1000, 500, '👑'),
('gift_sports_car', 'Super Sports Car', 5000, 2500, '🏎️'),
('gift_rocket', 'Galaxy Rocket', 20000, 10000, '🚀')
ON CONFLICT (id) DO NOTHING;
