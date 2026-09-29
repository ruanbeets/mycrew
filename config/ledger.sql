CREATE SCHEMA IF NOT EXISTS ledger;
CREATE TABLE IF NOT EXISTS ledger.missions (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 title text NOT NULL, status text NOT NULL DEFAULT 'pending',
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS ledger.tasks (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 mission_id bigint REFERENCES ledger.missions(id), title text NOT NULL,
 status text NOT NULL DEFAULT 'pending',
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS ledger.agent_runs (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 task_id bigint REFERENCES ledger.tasks(id), parent_run_id bigint REFERENCES ledger.agent_runs(id),
 agent text NOT NULL, status text NOT NULL DEFAULT 'pending',
 started_at timestamptz NOT NULL DEFAULT now(), finished_at timestamptz
);
CREATE TABLE IF NOT EXISTS ledger.model_calls (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 agent_run_id bigint REFERENCES ledger.agent_runs(id), model text NOT NULL,
 input_tokens bigint, output_tokens bigint, cost_usd numeric(16,8),
 status text NOT NULL DEFAULT 'pending', created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS ledger.system_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 kind text NOT NULL, status text NOT NULL DEFAULT 'info', details jsonb NOT NULL DEFAULT '{}',
 created_at timestamptz NOT NULL DEFAULT now()
);
