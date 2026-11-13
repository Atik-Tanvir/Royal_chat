export interface NavItem {
  name: string;
  href: string;
  iconName: string;
  badge?: string;
}

export const navigationItems: NavItem[] = [
  { name: 'Dashboard', href: '/', iconName: 'LayoutDashboard' },
  { name: 'User Management', href: '/users', iconName: 'Users' },
  { name: 'Audio Party Rooms', href: '/rooms', iconName: 'Mic' },
  { name: 'Host Recruitment', href: '/hosts', iconName: 'Award', badge: 'New' },
  { name: 'Games Control', href: '/games', iconName: 'Gamepad2', badge: 'Live' },
  { name: 'Ads Run & Control', href: '/ads', iconName: 'Tv', badge: 'Hot' },
  { name: 'Banner Campaigns', href: '/banners', iconName: 'Image' },
  { name: 'Economy & Rewards', href: '/economy', iconName: 'Coins' },
  { name: 'Virtual Gift Store', href: '/gifts', iconName: 'Gift' },
  { name: 'Leaderboards', href: '/leaderboards', iconName: 'Trophy' },
  { name: 'Withdrawal Approvals', href: '/withdrawals', iconName: 'DollarSign' },
  { name: 'Community Moments', href: '/moments', iconName: 'Compass' },
  { name: 'Broadcast Messages', href: '/notifications', iconName: 'Bell' },
  { name: 'App Settings', href: '/settings', iconName: 'Settings' },
];
