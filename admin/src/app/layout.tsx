import type { Metadata } from 'next';
import './globals.css';
import { AdminLayout } from '../shared/components/layout/AdminLayout';

export const metadata: Metadata = {
  title: 'Royal Chat Live | Master Admin Console',
  description: 'Clean Architecture Central Control Center for Gamegala / Royal Chat Live',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="antialiased bg-[#08120F] text-slate-100">
        <AdminLayout>{children}</AdminLayout>
      </body>
    </html>
  );
}
