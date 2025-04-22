"use client";

import { signOut, useSession } from "next-auth/react";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function Home() {
  const { data: session } = useSession();
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Render a loading state or nothing during SSR to avoid mismatch
  if (!isMounted) {
    return <div className="p-8">Loading...</div>;
  }

  return (
    <div className="p-8">
      {session ? (
        <>
          <p>Welcome, {session.user?.name}!</p>
          <button
            onClick={() => signOut({ callbackUrl: "/login" })}
            className="p-2 bg-red-500 text-white rounded"
          >
            Sign Out
          </button>
          <Link href="/" className="ml-4 text-blue-500">
            Go to Protected Page
          </Link>
        </>
      ) : (
        <Link href="/login" className="text-blue-500">
          Please log in
        </Link>
      )}
    </div>
  );
}
