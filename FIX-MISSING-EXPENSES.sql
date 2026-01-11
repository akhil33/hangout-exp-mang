-- FIX FOR MISSING EXPENSES IN UI
-- This script ensures all expenses are visible regardless of user_id

-- =============================================
-- PROBLEM DIAGNOSIS
-- =============================================
-- If you see fewer expenses in the app than in the database,
-- it's likely due to RLS policies filtering rows based on user_id.

-- Check which expenses exist in the database
SELECT
    id,
    name,
    user_id,
    due_date,
    status,
    CASE
        WHEN user_id IS NULL THEN '⚠️ No user_id (might be filtered)'
        ELSE '✓ Has user_id'
    END as note
FROM expenses
ORDER BY id;

-- =============================================
-- SOLUTION 1: Remove RLS entirely (Development Only)
-- =============================================
-- This is the quickest fix for development/testing
-- WARNING: Only use this if you're in development mode

ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;

-- =============================================
-- SOLUTION 2: Update RLS policy to allow all
-- =============================================
-- If you want to keep RLS enabled but allow all access

-- Drop existing policies
DROP POLICY IF EXISTS "expenses_select_policy" ON expenses;
DROP POLICY IF EXISTS "expenses_insert_policy" ON expenses;
DROP POLICY IF EXISTS "expenses_update_policy" ON expenses;
DROP POLICY IF EXISTS "expenses_delete_policy" ON expenses;
DROP POLICY IF EXISTS "Allow all for authenticated users" ON expenses;

-- Enable RLS
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Create permissive SELECT policy (no user_id check)
CREATE POLICY "expenses_select_all"
ON expenses FOR SELECT
TO authenticated
USING (true);  -- Allow all authenticated users to see all expenses

-- Create permissive INSERT policy
CREATE POLICY "expenses_insert_all"
ON expenses FOR INSERT
TO authenticated
WITH CHECK (true);  -- Allow all authenticated users to insert

-- Create permissive UPDATE policy
CREATE POLICY "expenses_update_all"
ON expenses FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);  -- Allow all authenticated users to update

-- Create permissive DELETE policy
CREATE POLICY "expenses_delete_all"
ON expenses FOR DELETE
TO authenticated
USING (true);  -- Allow all authenticated users to delete

-- =============================================
-- SOLUTION 3: Update existing expenses to have user_id
-- =============================================
-- If you want expenses to be tied to specific users

-- First, get your user ID
SELECT
    'Your user ID is: ' || id as message,
    email
FROM auth.users
WHERE email = 'YOUR_EMAIL_HERE';  -- Replace with your email

-- Update expenses without user_id to your user ID
-- UPDATE expenses
-- SET user_id = 'YOUR_USER_ID_HERE'  -- Replace with your actual user ID
-- WHERE user_id IS NULL;

-- =============================================
-- VERIFICATION
-- =============================================

-- Check RLS status
SELECT
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'expenses';

-- Check all policies
SELECT
    policyname,
    cmd as operation,
    qual::text as using_clause,
    with_check::text as with_check_clause
FROM pg_policies
WHERE tablename = 'expenses'
ORDER BY cmd;

-- Count total expenses
SELECT
    'Total expenses in database: ' || COUNT(*) as message
FROM expenses;

-- =============================================
-- RECOMMENDED APPROACH FOR PRODUCTION
-- =============================================
-- For a multi-user production app, you might want:
--
-- 1. Managers can see ALL expenses
-- 2. Staff can only see their own expenses
--
-- Here's how:
/*
DROP POLICY IF EXISTS "expenses_select_all" ON expenses;

CREATE POLICY "expenses_select_by_role"
ON expenses FOR SELECT
TO authenticated
USING (
    -- Allow if user is a manager
    EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_roles.user_id = auth.uid()
        AND user_roles.role = 'manager'
    )
    OR
    -- Or if the expense belongs to the current user
    user_id = auth.uid()
);
*/

-- =============================================
-- AFTER RUNNING THIS SCRIPT
-- =============================================
-- 1. Refresh your app
-- 2. Check browser console for the new count logs
-- 3. You should see: "Total count from database: X"
-- 4. All expenses should now be visible
