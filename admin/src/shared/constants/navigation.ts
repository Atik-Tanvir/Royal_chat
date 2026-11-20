export interface NavItem {
  name: string;
  href: string;
  iconName: string;
  badge?: string;
}

export interface NavCategory {
  title: string;
  items: NavItem[];
}

export const navigationCategories: NavCategory[] = [
  {
    title: 'Core & Overview',
    items: [
      { name: 'Dashboard', href: '/', iconName: 'LayoutDashboard' },
      { name: 'User Management', href: '/users', iconName: 'Users' },
    ],
  },
  {
    title: 'Party & Entertainment',
    items: [
      { name: 'Audio Party Rooms', href: '/rooms', iconName: 'Mic' },
      { name: 'Host Recruitment', href: '/hosts', iconName: 'Award', badge: 'New' },
      { name: 'Games Control', href: '/games', iconName: 'Gamepad2', badge: 'Live' },
      { name: 'Community Moments', href: '/moments', iconName: 'Compass' },
    ],
  },
  {
    title: 'Monetization & Ads',
    items: [
      { name: 'Ads Run & Control', href: '/ads', iconName: 'Tv', badge: 'Hot' },
      { name: 'Banner Campaigns', href: '/banners', iconName: 'Image' },
    ],
  },
  {
    title: 'Finance & Economy',
    items: [
      { name: 'Economy & Rewards', href: '/economy', iconName: 'Coins' },
      { name: 'Virtual Gift Store', href: '/gifts', iconName: 'Gift' },
      { name: 'Withdrawal Approvals', href: '/withdrawals', iconName: 'DollarSign' },
    ],
  },
  {
    title: 'System & Engagement',
    items: [
      { name: 'Leaderboards', href: '/leaderboards', iconName: 'Trophy' },
      { name: 'Broadcast Messages', href: '/notifications', iconName: 'Bell' },
      { name: 'App Settings', href: '/settings', iconName: 'Settings' },
    ],
  },
];

// Flat list for fallback / search
export const navigationItems: NavItem[] = navigationCategories.flatMap((c) => c.items);
