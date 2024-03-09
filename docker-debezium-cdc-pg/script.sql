-- migrate:up
CREATE SCHEMA IF NOT EXISTS financial_db;

CREATE TABLE IF NOT EXISTS financial_db.transactions (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    event_data JSONB not null default '{}'::jsonb,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE  financial_db.transactions REPLICA IDENTITY FULL;


CREATE TABLE IF NOT EXISTS transactions (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    event_data JSONB not null default '{}'::jsonb,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE transactions REPLICA IDENTITY FULL;

-- migrate:down
DROP TABLE financial_db.transactions;