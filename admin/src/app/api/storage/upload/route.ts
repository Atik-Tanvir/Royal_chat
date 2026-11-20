import { NextRequest, NextResponse } from 'next/server';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { loadR2Config } from '../../../../shared/lib/r2';

function getR2Client(): { client: S3Client; bucket: string; publicUrl: string } | null {
  const config = loadR2Config();
  if (!config.accessKeyId || !config.secretAccessKey) {
    return null;
  }
  const client = new S3Client({
    region: 'auto',
    endpoint: `https://${config.accountId}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: config.accessKeyId,
      secretAccessKey: config.secretAccessKey,
    },
  });
  return { client, bucket: config.bucket, publicUrl: config.publicUrl };
}

// GET: Health & Status Check for Cloudflare R2 Connection
export async function GET() {
  const config = loadR2Config();
  const isConfigured = Boolean(config.accessKeyId && config.secretAccessKey);

  return NextResponse.json({
    storage: 'Cloudflare R2 Object Storage',
    accountId: config.accountId,
    bucket: config.bucket,
    endpoint: `https://${config.accountId}.r2.cloudflarestorage.com`,
    publicUrl: config.publicUrl,
    configured: isConfigured,
    status: isConfigured
      ? 'Ready to accept live uploads'
      : 'Awaiting R2_ACCESS_KEY_ID & R2_SECRET_ACCESS_KEY in Settings or .env.local',
  });
}

// POST: Upload a file to Cloudflare R2 Bucket
export async function POST(req: NextRequest) {
  try {
    const formData = await req.formData();
    const file = formData.get('file') as File | null;
    const folder = (formData.get('folder') as string) || 'uploads';

    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 });
    }

    const r2Setup = getR2Client();
    if (!r2Setup) {
      return NextResponse.json(
        {
          error:
            'Cloudflare R2 credentials missing. Please set R2 Access Key ID and Secret in Admin Settings -> Cloudflare R2 Storage.',
          configured: false,
        },
        { status: 503 }
      );
    }

    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    // Sanitize file name and create unique key
    const sanitizedName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
    const key = `${folder}/${Date.now()}_${sanitizedName}`;

    await r2Setup.client.send(
      new PutObjectCommand({
        Bucket: r2Setup.bucket,
        Key: key,
        Body: buffer,
        ContentType: file.type || 'application/octet-stream',
      })
    );

    const publicUrl = `${r2Setup.publicUrl}/${key}`;

    return NextResponse.json({
      success: true,
      url: publicUrl,
      key,
      size: file.size,
      contentType: file.type,
      bucket: r2Setup.bucket,
    });
  } catch (error: any) {
    console.error('[Cloudflare R2 Upload Error]:', error);
    return NextResponse.json(
      {
        error: error.message || 'Failed to upload to Cloudflare R2',
      },
      { status: 500 }
    );
  }
}
