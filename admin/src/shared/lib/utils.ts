export function formatCoins(amount: number): string {
  if (amount >= 1_000_000_000) {
    return (amount / 1_000_000_000).toFixed(2) + 'B';
  }
  if (amount >= 1_000_000) {
    return (amount / 1_000_000).toFixed(2) + 'M';
  }
  if (amount >= 1_000) {
    return (amount / 1_000).toFixed(1) + 'K';
  }
  return amount.toLocaleString();
}

export function formatGems(gems: number): string {
  if (gems >= 1_000_000) {
    return (gems / 1_000_000).toFixed(2) + 'M 💎';
  }
  if (gems >= 1_000) {
    return (gems / 1_000).toFixed(1) + 'K 💎';
  }
  return `${gems.toLocaleString()} 💎`;
}

export function formatUSD(amount: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  }).format(amount);
}

export function formatDate(dateString: string): string {
  try {
    const d = new Date(dateString);
    return d.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch {
    return dateString;
  }
}
