import { NextResponse } from 'next/server';
import fs from 'fs';
import path from 'path';

const CONFIG_PATH = path.resolve(process.cwd(), '..', 'scratch', 'ads_config.json');

const DEFAULT_CONFIG = {
  adsEnabled: true,
  rewardedAds: [
    {
      id: 'ad_admob_1',
      title: 'Google AdMob Rewarded Video',
      network: 'Google AdMob',
      description: 'Watch this short sponsored video to earn free game coins.',
      imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=600',
      targetUrl: 'https://admob.google.com',
      rewardCoins: 500,
      durationSeconds: 5,
      isEnabled: true,
    },
    {
      id: 'ad_unity_2',
      title: 'Unity Ads: Mega Spin Promo',
      network: 'Unity Ads',
      description: 'Check out top trending games and earn 1,000 bonus coins!',
      imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
      targetUrl: 'https://unity.com',
      rewardCoins: 1000,
      durationSeconds: 8,
      isEnabled: false,
    },
  ],
  updatedAt: new Date().toISOString(),
};

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-store, no-cache, must-revalidate',
  };
}

export async function OPTIONS() {
  return new NextResponse(null, { status: 204, headers: corsHeaders() });
}

export async function GET() {
  try {
    if (fs.existsSync(CONFIG_PATH)) {
      const raw = fs.readFileSync(CONFIG_PATH, 'utf8');
      return NextResponse.json(JSON.parse(raw), { headers: corsHeaders() });
    }
    return NextResponse.json(DEFAULT_CONFIG, { headers: corsHeaders() });
  } catch (err) {
    console.error('[api/ads-config GET]', err);
    return NextResponse.json(DEFAULT_CONFIG, { headers: corsHeaders() });
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const updated = {
      adsEnabled: Boolean(body.adsEnabled ?? true),
      rewardedAds: Array.isArray(body.rewardedAds) ? body.rewardedAds : [],
      updatedAt: new Date().toISOString(),
    };

    const dir = path.dirname(CONFIG_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(CONFIG_PATH, JSON.stringify(updated, null, 2), 'utf8');

    return NextResponse.json({ ok: true, config: updated }, { headers: corsHeaders() });
  } catch (err) {
    console.error('[api/ads-config POST]', err);
    return NextResponse.json(
      { ok: false, error: 'Failed to save ads configuration' },
      { status: 500, headers: corsHeaders() }
    );
  }
}
