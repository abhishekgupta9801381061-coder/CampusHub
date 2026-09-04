-- ====================================================================
-- CampusHub: Production PostgreSQL & Supabase Database Migration
-- PRIVACY-FIRST CORE:
-- 1. NO phone number column.
-- 2. NO email column.
-- 3. NO room number column (Hostel only).
-- 4. Passwords and security answers stored only as salted hashes.
-- ====================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    handle TEXT UNIQUE NOT NULL CHECK (handle ~ '^@[a-zA-Z0-9_]{2,20}$'),
    roll_no TEXT UNIQUE NOT NULL,
    branch TEXT NOT NULL,
    hostel TEXT NOT NULL, -- Room number is strictly NOT collected
    password_hash TEXT NOT NULL,
    security_question TEXT NOT NULL,
    security_answer_hash TEXT NOT NULL,
    avatar_url TEXT,
    is_ghost_mode BOOLEAN DEFAULT FALSE,
    allow_promotional_consent BOOLEAN DEFAULT FALSE,
    skills TEXT[] DEFAULT '{}',
    interests TEXT[] DEFAULT '{}',
    whatsapp_encrypted TEXT, -- Ephemeral or encrypted
    instagram_handle TEXT,
    linkedin_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for handle and roll search
CREATE INDEX IF NOT EXISTS idx_users_handle ON public.users(handle);
CREATE INDEX IF NOT EXISTS idx_users_roll ON public.users(roll_no);
CREATE INDEX IF NOT EXISTS idx_users_ghost ON public.users(is_ghost_mode);

-- 2. PARTNER REQUESTS TABLE
CREATE TABLE IF NOT EXISTS public.partner_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    edit_count INT DEFAULT 0,
    last_edited_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '5 days'),
    is_closed BOOLEAN DEFAULT FALSE,
    report_count INT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_partner_requests_expiry ON public.partner_requests(expires_at);
CREATE INDEX IF NOT EXISTS idx_partner_requests_author_date ON public.partner_requests(author_id, created_at);

-- 3. SERVER-SIDE TRIGGER: Max 1 Partner Request Per Calendar Day
CREATE OR REPLACE FUNCTION check_daily_partner_request_limit()
RETURNS TRIGGER AS $$
DECLARE
    today_count INT;
BEGIN
    SELECT COUNT(*) INTO today_count
    FROM public.partner_requests
    WHERE author_id = NEW.author_id
      AND DATE(created_at AT TIME ZONE 'UTC') = DATE(NOW() AT TIME ZONE 'UTC');

    IF today_count >= 1 THEN
        RAISE EXCEPTION 'Rate limit exceeded: You can only create 1 partner request per calendar day.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_daily_partner_request_limit ON public.partner_requests;
CREATE TRIGGER trg_check_daily_partner_request_limit
    BEFORE INSERT ON public.partner_requests
    FOR EACH ROW
    EXECUTE FUNCTION check_daily_partner_request_limit();

-- 4. SERVER-SIDE TRIGGER: Max 3 Edits Per Calendar Day
CREATE OR REPLACE FUNCTION check_daily_partner_request_edit_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.last_edited_at IS NOT NULL AND DATE(OLD.last_edited_at AT TIME ZONE 'UTC') = DATE(NOW() AT TIME ZONE 'UTC') THEN
        IF OLD.edit_count >= 3 THEN
            RAISE EXCEPTION 'Rate limit exceeded: Maximum 3 edits allowed per calendar day.';
        END IF;
        NEW.edit_count := OLD.edit_count + 1;
    ELSE
        NEW.edit_count := 1;
    END IF;
    NEW.last_edited_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_daily_partner_request_edit_limit ON public.partner_requests;
CREATE TRIGGER trg_check_daily_partner_request_edit_limit
    BEFORE UPDATE OF title, description, tags ON public.partner_requests
    FOR EACH ROW
    EXECUTE FUNCTION check_daily_partner_request_edit_limit();

-- 5. GROUPS & GROUP MEMBERS
CREATE TABLE IF NOT EXISTS public.groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    tags TEXT[] DEFAULT '{}',
    creator_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    member_count INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SERVER-SIDE TRIGGER: Maximum 4 Active Groups Per User
CREATE OR REPLACE FUNCTION check_max_active_groups_limit()
RETURNS TRIGGER AS $$
DECLARE
    created_count INT;
BEGIN
    SELECT COUNT(*) INTO created_count
    FROM public.groups
    WHERE creator_id = NEW.creator_id;

    IF created_count >= 4 THEN
        RAISE EXCEPTION 'Quota exceeded: A student may create a maximum of 4 active collaboration groups.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_max_active_groups_limit ON public.groups;
CREATE TRIGGER trg_check_max_active_groups_limit
    BEFORE INSERT ON public.groups
    FOR EACH ROW
    EXECUTE FUNCTION check_max_active_groups_limit();

CREATE TABLE IF NOT EXISTS public.group_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member', -- 'admin' or 'member'
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (group_id, user_id)
);

-- 6. CONTESTS
CREATE TABLE IF NOT EXISTS public.contests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    organizer TEXT NOT NULL,
    event_date TIMESTAMPTZ NOT NULL,
    deadline TIMESTAMPTZ NOT NULL,
    mode TEXT NOT NULL,
    tags TEXT[] DEFAULT '{}',
    description TEXT NOT NULL,
    prize_pool TEXT NOT NULL,
    registration_url TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ANONYMOUS CONFESSIONS
CREATE TABLE IF NOT EXISTS public.confessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category TEXT NOT NULL,
    content TEXT NOT NULL,
    upvotes INT DEFAULT 0,
    downvotes INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    author_secret_hash TEXT NOT NULL, -- Never exposes student ID or roll number
    report_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.confession_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    confession_id UUID NOT NULL REFERENCES public.confessions(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. CROSS-HOSTEL ACADEMIC EXCHANGE
CREATE TABLE IF NOT EXISTS public.exchange_listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_name TEXT NOT NULL,
    description TEXT NOT NULL,
    condition TEXT NOT NULL,
    category TEXT NOT NULL,
    owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    hostel TEXT NOT NULL, -- Room number is strictly NOT stored
    price_or_free TEXT NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. VERIFIED ACHIEVEMENTS
CREATE TABLE IF NOT EXISTS public.achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    proof_url TEXT,
    status TEXT DEFAULT 'pending', -- 'pending', 'verified', 'rejected'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. ENCRYPTED EPHEMERAL SOCIAL BRIDGE
CREATE TABLE IF NOT EXISTS public.social_bridge_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    platform TEXT NOT NULL,
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.confessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exchange_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

-- Exclude Ghost Mode users from public discovery queries
CREATE POLICY "Discoverable students only" ON public.users
    FOR SELECT USING (is_ghost_mode = FALSE OR id = auth.uid());

-- Never expose password hashes or security answers to public views
CREATE VIEW public.public_user_profiles AS
    SELECT id, name, handle, branch, hostel, avatar_url, skills, interests, allow_promotional_consent, created_at
    FROM public.users
    WHERE is_ghost_mode = FALSE;
