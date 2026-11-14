import { NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';

const CONFIG_PATH = path.resolve(process.cwd(), '../scratch/games_config.json');

interface GameConfigEntry {
  id: string;
  name: string;
  description: string;
  isActive: boolean;
  minBet: number;
  maxBet: number;
  rtp: number;
  roundSeconds: number;
  betLockSeconds: number;
  multipliers: Record<string, number>;
}

const DEFAULT_CONFIG: {
  emergencyLockdown: boolean;
  updatedAt: string;
  games: GameConfigEntry[];
} = {
  emergencyLockdown: false,
  updatedAt: '2026-11-12T10:00:00.000Z',
  games: [
    {
      id: 'game_bucket_8',
      name: 'Bucket Spin (8 Items)',
      description: '8-slot spinning cauldron prediction game (Solo & Group).',
      isActive: true,
      minBet: 100,
      maxBet: 10000,
      rtp: 94,
      roundSeconds: 35,
      betLockSeconds: 30,
      multipliers: {
        bucket: 2.0,
        mug: 2.0,
        flower: 2.0,
        star: 2.0,
        diamond: 2.0,
        crown: 2.0,
        gift: 2.0,
        heart: 2.0,
      },
    },
    {
      id: 'game_color_3',
      name: 'Color Spin (Red / Violet / Green)',
      description: '3-color cauldron prediction arena with per-color odds control.',
      isActive: true,
      minBet: 100,
      maxBet: 10000,
      rtp: 93,
      roundSeconds: 35,
      betLockSeconds: 30,
      multipliers: {
        red: 2.0,
        violet: 4.5,
        green: 2.0,
      },
    },
    {
      id: 'game_7up_7down',
      name: '7 Up 7 Down (Dice)',
      description: 'Fast 18-second dice prediction board (8~12, 7, 2~6).',
      isActive: true,
      minBet: 100,
      maxBet: 10000,
      rtp: 92,
      roundSeconds: 18,
      betLockSeconds: 15,
      multipliers: {
        up: 2.0,
        seven: 5.0,
        down: 2.0,
      },
    },
    {
      id: 'game_balloon_sky',
      name: 'Balloon Sky (Arcade)',
      description: 'Solo endless flight with Free Earn coin bubbles and 2x Double Stake mode.',
      isActive: true,
      minBet: 100,
      maxBet: 5000,
      rtp: 95,
      roundSeconds: 40,
      betLockSeconds: 40,
      multipliers: {
        targetScore: 1000,
        standardBubbleCoins: 10,
        goldBubbleCoins: 50,
        distanceBonusPer4s: 5,
        doubleTargetSeconds: 40,
        doubleStakeMultiplier: 2.0,
        speedBoostAfterSeconds: 40,
      },
    },
  ],
};

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-store',
  };
}

function sanitizeConfig(raw: Record<string, unknown>) {
  const rawGames = Array.isArray(raw.games) ? raw.games : DEFAULT_CONFIG.games;
  const normalizedGames = DEFAULT_CONFIG.games.map((fallback) => {
    const match = rawGames.find(
      (g) => typeof g === 'object' && g !== null && (g as Record<string, unknown>).id === fallback.id
    ) as Record<string, unknown> | undefined;
    if (!match) return fallback;

    const minBet = Math.max(10, Number(match.minBet ?? fallback.minBet) || fallback.minBet);
    const maxBet = Math.max(minBet, Number(match.maxBet ?? fallback.maxBet) || fallback.maxBet);
    const roundSeconds = Math.max(10, Math.min(180, Number(match.roundSeconds ?? fallback.roundSeconds) || fallback.roundSeconds));
    const betLockSeconds = Math.max(5, Math.min(roundSeconds, Number(match.betLockSeconds ?? fallback.betLockSeconds) || fallback.betLockSeconds));
    const rtp = Math.max(50, Math.min(99, Number(match.rtp ?? fallback.rtp) || fallback.rtp));

    const nextMultipliers: Record<string, number> = { ...fallback.multipliers };
    if (match.multipliers && typeof match.multipliers === 'object') {
      const mObj = match.multipliers as Record<string, unknown>;
      for (const [k, defVal] of Object.entries(fallback.multipliers)) {
        const parsed = Number(mObj[k]);
        nextMultipliers[k] = Number.isFinite(parsed) && parsed > 0 ? Math.round(parsed * 100) / 100 : defVal;
      }
    }

    return {
      ...fallback,
      name: typeof match.name === 'string' && match.name.trim() ? match.name : fallback.name,
      description: typeof match.description === 'string' ? match.description : fallback.description,
      isActive: typeof match.isActive === 'boolean' ? match.isActive : fallback.isActive,
      minBet,
      maxBet,
      rtp,
      roundSeconds,
      betLockSeconds,
      multipliers: nextMultipliers,
    };
  });

  return {
    emergencyLockdown: Boolean(raw.emergencyLockdown),
    updatedAt: new Date().toISOString(),
    games: normalizedGames,
  };
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: corsHeaders() });
}

export async function GET() {
  try {
    const raw = await fs.readFile(CONFIG_PATH, 'utf8');
    return NextResponse.json(JSON.parse(raw), { headers: corsHeaders() });
  } catch {
    return NextResponse.json(DEFAULT_CONFIG, { headers: corsHeaders() });
  }
}

export async function POST(req: Request) {
  try {
    const body = (await req.json()) as Record<string, unknown>;
    const normalized = sanitizeConfig(body);
    await fs.mkdir(path.dirname(CONFIG_PATH), { recursive: true });
    await fs.writeFile(CONFIG_PATH, JSON.stringify(normalized, null, 2), 'utf8');
    return NextResponse.json(normalized, { headers: corsHeaders() });
  } catch (err) {
    return NextResponse.json(
      { error: String(err) },
      { status: 400, headers: corsHeaders() }
    );
  }
}
