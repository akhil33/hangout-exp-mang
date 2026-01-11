-- Step 7: Set ART as Manager
-- 
-- Instructions:
-- 1. First, create the user "ART" in Supabase Dashboard:
--    - Go to Authentication → Users → Add User
--    - Enter email (e.g., art@hangoutbar.com) and password
--    - Enable "Auto Confirm User" for testing
--    - Click "Create User"
--    - Copy the User ID (UUID) from the user list
--
-- 2. Replace 'YOUR_USER_ID_HERE' below with the actual UUID from step 1
-- 3. Run this SQL in Supabase SQL Editor

INSERT INTO user_roles (user_id, role)
VALUES ('YOUR_USER_ID_HERE', 'manager')
ON CONFLICT (user_id) 
DO UPDATE SET role = 'manager';

-- To verify the role was set correctly, run:
-- SELECT * FROM user_roles WHERE role = 'manager';
