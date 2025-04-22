import NextAuth from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import bcrypt from "bcrypt";

export const authOptions = {
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        username: { label: "Username", type: "text" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        // This is where you'd typically fetch user from database
        // For this example, we'll use a hardcoded user
        const user = {
          id: "1",
          name: "testuser",
          password: await bcrypt.hash("password123", 10), // Pre-hashed password
        };

        if (!credentials?.username || !credentials?.password) {
          return null;
        }

        if (credentials.username === user.name) {
          const isValid = await bcrypt.compare(
            credentials.password,
            user.password
          );
          if (isValid) {
            return { id: user.id, name: user.name };
          }
        }
        return null;
      },
    }),
  ],
  pages: {
    signIn: "/login", // We'll create this page next
  },
  session: {
    strategy: "jwt" as const,
  },
};

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
