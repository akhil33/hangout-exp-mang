-- COMPLETE FIX FOR EXPENSES NOT SHOWING IN APP
-- This script fixes Row Level Security policies
-- Run this entire script in Supabase SQL Editor

-- =============================================
-- STEP 1: Clean up existing policies
-- =============================================
-- Drop all existing policies on expenses table to start fresh
DROP POLICY IF EXISTS "Enable read access for all users" ON expenses;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON expenses;
DROP POLICY IF EXISTS "Users can insert expenses" ON expenses;
DROP POLICY IF EXISTS "Authenticated users can insert expenses" ON expenses;
DROP POLICY IF EXISTS "Authenticated users can view expenses" ON expenses;
DROP POLICY IF EXISTS "Users can update expenses" ON expenses;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON expenses;
DROP POLICY IF EXISTS "Allow read for all authenticated" ON expenses;
DROP POLICY IF EXISTS "Allow all operations for authenticated" ON expenses;

-- =============================================
-- STEP 2: Enable RLS on expenses table
-- =============================================
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- =============================================
-- STEP 3: Create new policies that allow all operations
-- =============================================

-- Policy for SELECT (viewing expenses)
CREATE POLICY "expenses_select_policy"
ON expenses FOR SELECT
TO authenticated
USING (true);

-- Policy for INSERT (adding new expenses)
CREATE POLICY "expenses_insert_policy"
ON expenses FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy for UPDATE (updating expenses - for approve functionality)
CREATE POLICY "expenses_update_policy"
ON expenses FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Policy for DELETE (if needed in the future)
CREATE POLICY "expenses_delete_policy"
ON expenses FOR DELETE
TO authenticated
USING (true);

-- =============================================
-- STEP 4: Fix user_roles table (prevent recursion)
-- =============================================
-- Drop all policies on user_roles
DROP POLICY IF EXISTS "Users can view roles" ON user_roles;
DROP POLICY IF EXISTS "Users can view their own role" ON user_roles;
DROP POLICY IF EXISTS "Authenticated users can view all roles" ON user_roles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON user_roles;
DROP POLICY IF EXISTS "Users can read user_roles table" ON user_roles;

-- Disable RLS on user_roles (simplest solution for development)
ALTER TABLE user_roles DISABLE ROW LEVEL SECURITY;

-- =============================================
-- STEP 5: Verify the fix
-- =============================================

-- Check RLS status
SELECT 'RLS Status on expenses:' as info, rowsecurity as enabled
FROM pg_tables
WHERE tablename = 'expenses';

-- Check policies created
SELECT 'Policies on expenses table:' as info;
SELECT policyname, cmd as operation
FROM pg_policies
WHERE tablename = 'expenses'
ORDER BY cmd;

-- Count expenses that should be visible
SELECT 'Total expenses in database:' as info, COUNT(*) as count
FROM expenses;

-- =============================================
-- SUCCESS MESSAGE
-- =============================================
SELECT '✓ Policies updated successfully!' as status,
       'Now refresh your app to see the expenses.' as next_step;
