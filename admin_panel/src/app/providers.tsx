"use client";

import { SessionProvider } from "next-auth/react";
import { ReactNode, useEffect, useState } from "react";

export function Providers({ children }: { children: ReactNode }) {
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Only render the SessionProvider after mounting to avoid hydration mismatches
  if (!isMounted) {
    return <>{children}</>; // Render children without provider during SSR
  }

  return <SessionProvider>{children}</SessionProvider>;
}
