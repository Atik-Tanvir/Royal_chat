import fs from 'fs';
import path from 'path';

const CONFIG_PATH = path.resolve(process.cwd(), 'r2_config.json');

export interface R2ConfigData {
  accountId: string;
  bucket: string;
  publicUrl: string;
  accessKeyId: string;
  secretAccessKey: string;
  endpoint?: string;
  corsConfigured?: boolean;
}

export function loadR2Config(): R2ConfigData {
  const defaults: R2ConfigData = {
    accountId: process.env.R2_ACCOUNT_ID || 'c6c6c97eea5025ec4aca78fa9e80c60d',
    bucket: process.env.R2_BUCKET || 'royal-chat-live',
    publicUrl: process.env.R2_PUBLIC_URL || 'https://pub-24addd4f2203427489399f391ba11669.r2.dev',
    accessKeyId: process.env.R2_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY || '',
  };

  if (fs.existsSync(CONFIG_PATH)) {
    try {
      const fileData = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf-8'));
      return { ...defaults, ...fileData };
    } catch {
      return defaults;
    }
  }
  return defaults;
}
