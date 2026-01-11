-- QUICK FIX FOR INFINITE RECURSION ERROR
-- Copy and paste this entire script into Supabase SQL Editor and run it

-- =============================================
-- STEP 1: Fix user_roles table (STOP THE RECURSION)
-- =============================================

-- Drop ALL policies on user_roles to stop recursion
DROP POLICY IF EXISTS "Users can view roles" ON user_roles;
DROP POLICY IF EXISTS "Users can view their own role" ON user_roles;
DROP POLICY IF EXISTS "Authenticated users can view all roles" ON user_roles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON user_roles;
DROP POLICY IF EXISTS "Users can read user_roles table" ON user_roles;

-- Disable RLS on user_roles (this stops the recursion)
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- =============================================
-- STEP 2: Fix expenses table policies
-- =============================================

-- Drop all existing policies on expenses
DROP POLICY IF EXISTS "Enable read access for all users" ON expenses;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON expenses;
DROP POLICY IF EXISTS "Users can insert expenses" ON expenses;
DROP POLICY IF EXISTS "Authenticated users can insert expenses" ON expenses;
DROP POLICY IF EXISTS "Authenticated users can view expenses" ON expenses;
DROP POLICY IF EXISTS "Users can update expenses" ON expenses;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON expenses;

-- Enable RLS on expenses
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Create permissive policy for all operations
CREATE POLICY "Allow all for authenticated users"
ON expenses
TO authenticated
USING (true)
WITH CHECK (true);

-- =============================================
-- STEP 3: Verify it worked
-- =============================================

-- Check user_roles policies (should be empty or disabled)
SELECT tablename, policyname
FROM pg_policies
WHERE tablename = 'user_roles';

-- Check expenses policies (should have one policy)
SELECT tablename, policyname
FROM pg_policies
WHERE tablename = 'expenses';

-- =============================================
-- DONE! Now try adding an expense in your app
-- =============================================
