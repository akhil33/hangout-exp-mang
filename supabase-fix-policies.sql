-- Supabase RLS Policy Fix Script
-- Run this in your Supabase SQL Editor to fix all permission issues

-- =============================================
-- 1. FIX EXPENSES TABLE POLICIES
-- =============================================

-- First, drop all existing policies on expenses table
DROP POLICY IF EXISTS "Enable read access for all users" ON expenses;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON expenses;
DROP POLICY IF EXISTS "Users can insert expenses" ON expenses;
DROP POLICY IF EXISTS "Authenticated users can insert expenses" ON expenses;
DROP POLICY IF EXISTS "Authenticated users can view expenses" ON expenses;
DROP POLICY IF EXISTS "Users can update expenses" ON expenses;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON expenses;

-- Enable RLS on expenses table
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Create a permissive policy for all operations (for testing/development)
CREATE POLICY "Allow all for authenticated users"
ON expenses
TO authenticated
USING (true)
WITH CHECK (true);

-- =============================================
-- 2. FIX USER_ROLES TABLE POLICIES
-- =============================================

-- Drop all existing policies on user_roles table to prevent recursion
DROP POLICY IF EXISTS "Users can view roles" ON user_roles;
DROP POLICY IF EXISTS "Users can view their own role" ON user_roles;
DROP POLICY IF EXISTS "Authenticated users can view all roles" ON user_roles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON user_roles;
DROP POLICY IF EXISTS "Users can read user_roles table" ON user_roles;

-- OPTION 1: Disable RLS entirely on user_roles (simplest, for development)
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- OPTION 2: If you need RLS enabled, use this instead (comment out OPTION 1 above)
-- ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
--
-- -- Simple policy that doesn't cause recursion
-- CREATE POLICY "user_roles_select_policy"
-- ON user_roles FOR SELECT
-- TO authenticated
-- USING (true);

-- =============================================
-- 3. VERIFY TABLE STRUCTURE (Optional)
-- =============================================

-- Check if user_id column exists in expenses table
-- If it doesn't exist and you need it, uncomment the line below:
-- ALTER TABLE expenses ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- =============================================
-- 4. VERIFY POLICIES (Run this to check)
-- =============================================

-- Check all policies on expenses table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'expenses';

-- Check all policies on user_roles table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'user_roles';

-- =============================================
-- NOTES:
-- =============================================
-- The "Allow all for authenticated users" policy is very permissive
-- and should only be used for development/testing.
--
-- For production, you should create more restrictive policies like:
--
-- -- Only managers can insert expenses
-- CREATE POLICY "Only managers can insert expenses"
-- ON expenses FOR INSERT
-- TO authenticated
-- WITH CHECK (
--   EXISTS (
--     SELECT 1 FROM user_roles
--     WHERE user_roles.user_id = auth.uid()
--     AND user_roles.role = 'manager'
--   )
-- );
--
-- -- Users can only view their own expenses
-- CREATE POLICY "Users can view their own expenses"
-- ON expenses FOR SELECT
-- TO authenticated
-- USING (user_id = auth.uid());
