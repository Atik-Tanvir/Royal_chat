import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://wyjkmythhskebenxxblb.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'sb_publishable_U9J5Jq1Frw94Q73Uei9t5A_KtDdUf3X';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface ProfileRecord {
  id: string;
  nickname: string;
  avatar_url: string;
  country: string;
  country_flag: string;
  gender: string;
  age: number;
  level: number;
  is_vip: boolean;
  is_banned: boolean;
  coin_balance: number;
  gem_balance: number;
  friends_count: number;
  following_count: number;
  fans_count: number;
  is_online: boolean;
  created_at: string;
}

export interface RoomRecord {
  id: string;
  title: string;
  host_name: string;
  host_avatar: string;
  category: string;
  country: string;
  country_flag: string;
  online_count: number;
  status: 'live' | 'closed';
  created_at: string;
}

export interface WithdrawalRecord {
  id: string;
  user_id: string;
  user_name: string;
  user_avatar: string;
  gateway: string;
  account_number?: string;
  amount: number;
  gems: number;
  status: 'Pending' | 'Approved' | 'Rejected';
  transaction_id?: string;
  admin_note?: string;
  processed_at?: string;
  created_at: string;
}

export interface MomentRecord {
  id: string;
  user_id: string;
  user_name: string;
  user_avatar: string;
  content: string;
  media_urls: string[];
  likes_count: number;
  comments_count: number;
  category: string;
  created_at: string;
}

export interface StoryRecord {
  id: string;
  author_id: string;
  author_name: string;
  author_avatar?: string;
  country_flag?: string;
  media_url?: string;
  caption?: string;
  bg_gradient_index?: number;
  views_count?: number;
  likes_count?: number;
  created_at: string;
  expires_at?: string;
}

export interface SystemMessageRecord {
  id: string;
  title: string;
  content: string;
  type: string;
  created_at: string;
}
