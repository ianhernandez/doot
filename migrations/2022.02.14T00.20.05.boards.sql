create table boards (
  board_id citext primary key,
  description text,
  created_at timestamptz not null default now()
);

create table board_admins (
  board_id citext not null references boards,
  user_id uuid not null references users,
  created_at timestamptz not null default now(),
  primary key (board_id, user_id)
);

create table posts (
  post_id uuid primary key default gen_random_uuid(),
  board_id citext not null references boards,
  user_id uuid not null references users,
  title text,
  body text,
  search tsvector not null
    generated always as (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(body, '')), 'B')
      ) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint either_title_or_body check (title is not null or body is not null)
);

create index on posts (user_id);
create index on posts (board_id);
create index on posts (created_at desc);

create type vote_type as enum ('down', 'up');
create table posts_votes (
  post_id uuid not null references posts,
  user_id uuid not null references users,
  vote vote_type not null,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table posts_comments (
  comment_id uuid primary key default gen_random_uuid(),
  post_id uuid not null references posts,
  user_id uuid not null references users,
  body text not null,
  search tsvector not null generated always as (to_tsvector('english', body)) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index on posts_comments (post_id);
create index on posts_comments (user_id);
create index on posts_comments (created_at desc);

create table comments_votes (
  comment_id uuid not null references posts_comments,
  user_id uuid not null references users,
  vote vote_type not null,
  created_at timestamptz not null default now(),
  primary key (comment_id, user_id)
);
create index on comments_votes (user_id);