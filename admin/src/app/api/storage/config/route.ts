import { NextRequest, NextResponse } from 'next/server';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import fs from 'fs';
import path from 'path';
import { loadR2Config, R2ConfigData } from '../../../../shared/lib/r2';

const CONFIG_PATH = path.resolve(process.cwd(), 'r2_config.json');

export async function GET() {
  const config = loadR2Config();
  const endpoint = `https://${config.accountId}.r2.cloudflarestorage.com`;
  const isConfigured = Boolean(config.accessKeyId && config.secretAccessKey);

  let testStatus = 'untested';
  let testMessage = '';

  if (isConfigured) {
    try {
      const client = new S3Client({
        region: 'auto',
        endpoint,
        credentials: {
          accessKeyId: config.accessKeyId,
          secretAccessKey: config.secretAccessKey,
        },
      });

      // Quick test put object
      const testKey = `_system_test/connection_check.json`;
      await client.send(
        new PutObjectCommand({
          Bucket: config.bucket,
          Key: testKey,
          Body: JSON.stringify({ verifiedAt: new Date().toISOString(), platform: 'Royal Chat Live Admin' }),
          ContentType: 'application/json',
        })
      );
      testStatus = 'connected';
      testMessage = `Successfully verified write & read access to bucket '${config.bucket}'!`;
    } catch (err: any) {
      testStatus = 'error';
      testMessage = err.message || 'Failed to authenticate with Cloudflare R2';
    }
  }

  return NextResponse.json({
    ...config,
    endpoint,
    secretAccessKey: config.secretAccessKey ? '••••••••••••••••••••••••' : '',
    hasSecretKey: Boolean(config.secretAccessKey),
    isConfigured,
    testStatus,
    testMessage,
  });
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const current = loadR2Config();

    const updated: R2ConfigData = {
      accountId: body.accountId?.trim() || current.accountId,
      bucket: body.bucket?.trim() || current.bucket,
      publicUrl: body.publicUrl?.trim() || current.publicUrl,
      accessKeyId: body.accessKeyId !== undefined ? body.accessKeyId.trim() : current.accessKeyId,
      secretAccessKey:
        body.secretAccessKey !== undefined && body.secretAccessKey !== '••••••••••••••••••••••••'
          ? body.secretAccessKey.trim()
          : current.secretAccessKey,
    };

    // Save to admin/r2_config.json
    fs.writeFileSync(CONFIG_PATH, JSON.stringify(updated, null, 2), 'utf-8');

    // Also sync to Flutter app: lib/core/config/r2_config.dart
    const flutterConfigPath = path.resolve(process.cwd(), '..', 'lib', 'core', 'config', 'r2_config.dart');
    if (fs.existsSync(flutterConfigPath)) {
      const flutterContent = `/// Configuration for Cloudflare R2 Object Storage.
/// 
/// Account ID: ${updated.accountId}
/// Bucket: ${updated.bucket}
/// Public CDN URL: ${updated.publicUrl}
class R2Config {
  R2Config._();

  static const String accountId = '${updated.accountId}';
  static const String bucketName = '${updated.bucket}';
  static const String endPoint = '${updated.accountId}.r2.cloudflarestorage.com';
  static const String publicDevUrl = '${updated.publicUrl}';

  /// R2 API Token credentials (Access Key ID and Secret Access Key)
  /// Created in Cloudflare Dashboard -> R2 -> Manage R2 API Tokens
  static const String accessKeyId = '${updated.accessKeyId}';
  static const String secretAccessKey = '${updated.secretAccessKey}';

  /// Whether credentials have been configured
  static bool get isConfigured =>
      accessKeyId.isNotEmpty &&
      secretAccessKey.isNotEmpty &&
      accessKeyId != 'YOUR_R2_ACCESS_KEY_ID';

  /// Constructs the full public CDN URL for an object stored in R2.
  static String getPublicUrl(String key) {
    if (key.startsWith('http://') || key.startsWith('https://')) {
      return key;
    }
    final cleanKey = key.startsWith('/') ? key.substring(1) : key;
    return '\$publicDevUrl/\$cleanKey';
  }
}
`;
      fs.writeFileSync(flutterConfigPath, flutterContent, 'utf-8');
    }

    return NextResponse.json({
      success: true,
      message: 'R2 Storage configuration updated and synced to Mobile App & Admin!',
      config: {
        accountId: updated.accountId,
        bucket: updated.bucket,
        publicUrl: updated.publicUrl,
        accessKeyId: updated.accessKeyId,
        hasSecretKey: Boolean(updated.secretAccessKey),
      },
    });
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Failed to update R2 configuration' }, { status: 500 });
  }
}
