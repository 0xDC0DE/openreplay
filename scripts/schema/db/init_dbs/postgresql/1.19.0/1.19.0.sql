\set previous_version 'v1.18.0'
\set next_version 'v1.19.0'
SELECT openreplay_version()                       AS current_version,
       openreplay_version() = :'previous_version' AS valid_previous,
       openreplay_version() = :'next_version'     AS is_next
\gset

\if :valid_previous
\echo valid previous DB version :'previous_version', starting DB upgrade to :'next_version'
BEGIN;
SELECT format($fn_def$
CREATE OR REPLACE FUNCTION openreplay_version()
    RETURNS text AS
$$
SELECT '%1$s'
$$ LANGUAGE sql IMMUTABLE;
$fn_def$, :'next_version')
\gexec

--
ALTER TABLE IF EXISTS events.clicks
    ADD COLUMN IF NOT EXISTS normalized_x smallint NULL,
    ADD COLUMN IF NOT EXISTS normalized_y smallint NULL,
    DROP COLUMN IF EXISTS x,
    DROP COLUMN IF EXISTS y;

UPDATE public.metrics
SET default_config=default_config || '{"col":2}'
WHERE metric_type = 'webVitals'
  AND default_config ->> 'col' = '1';

UPDATE public.dashboard_widgets
SET config=config || '{"col":2}'
WHERE metric_id IN (SELECT metric_id
                    FROM public.metrics
                    WHERE metric_type = 'webVitals')
  AND config ->> 'col' = '1';

UPDATE public.metrics
SET view_type='table'
WHERE view_type = 'pieChart';

UPDATE public.metrics
SET view_type='lineChart'
WHERE view_type = 'progress';

COMMIT;

\elif :is_next
\echo new version detected :'next_version', nothing to do
\else
\warn skipping DB upgrade of :'next_version', expected previous version :'previous_version', found :'current_version'
\endif
