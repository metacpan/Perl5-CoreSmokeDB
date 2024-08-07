--
-- PostgreSQL database dump
--

-- Dumped from database version 14.12 (Ubuntu 14.12-1.pgdg22.04+1)
-- Dumped by pg_dump version 14.12 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE coresmokedb;
--
-- Name: coresmokedb; Type: DATABASE; Schema: -; Owner: coresmokedb
--

CREATE DATABASE coresmokedb WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


ALTER DATABASE coresmokedb OWNER TO coresmokedb;

\connect coresmokedb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: git_describe_as_plevel(character varying); Type: FUNCTION; Schema: public; Owner: coresmokedb
--

CREATE FUNCTION public.git_describe_as_plevel(character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
    declare
        vparts varchar array [5];
        plevel varchar;
        clean  varchar;
    begin
        select regexp_replace($1, E'^v', '') into clean;
        select regexp_replace(clean, E'-g\.\+$', '') into clean;

        select regexp_split_to_array(clean, E'[\.\-]') into vparts;

        select vparts[1] || '.' into plevel;
        select plevel || lpad(vparts[2], 3, '0') into plevel;
        select plevel || lpad(vparts[3], 3, '0') into plevel;
        if array_length(vparts, 1) = 3 then
            select array_append(vparts, '0') into vparts;
        end if;
        if regexp_matches(vparts[4], 'RC') = array['RC'] then
            select plevel || vparts[4] into plevel;
        else
            select plevel || 'zzz' into plevel;
        end if;
        select plevel || lpad(vparts[array_upper(vparts, 1)], 3, '0') into plevel;

        return plevel;
    end;
$_$;


ALTER FUNCTION public.git_describe_as_plevel(character varying) OWNER TO coresmokedb;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: config; Type: TABLE; Schema: public; Owner: coresmokedb
--

CREATE TABLE public.config (
    id integer NOT NULL,
    report_id integer NOT NULL,
    arguments character varying NOT NULL,
    debugging character varying NOT NULL,
    started timestamp with time zone,
    duration integer,
    cc character varying,
    ccversion character varying
);


ALTER TABLE public.config OWNER TO coresmokedb;

--
-- Name: config_id_seq; Type: SEQUENCE; Schema: public; Owner: coresmokedb
--

CREATE SEQUENCE public.config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.config_id_seq OWNER TO coresmokedb;

--
-- Name: config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: coresmokedb
--

ALTER SEQUENCE public.config_id_seq OWNED BY public.config.id;


--
-- Name: failure; Type: TABLE; Schema: public; Owner: coresmokedb
--

CREATE TABLE public.failure (
    id integer NOT NULL,
    test character varying NOT NULL,
    status character varying NOT NULL,
    extra character varying
);


ALTER TABLE public.failure OWNER TO coresmokedb;

--
-- Name: failure_id_seq; Type: SEQUENCE; Schema: public; Owner: coresmokedb
--

CREATE SEQUENCE public.failure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.failure_id_seq OWNER TO coresmokedb;

--
-- Name: failure_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: coresmokedb
--

ALTER SEQUENCE public.failure_id_seq OWNED BY public.failure.id;


--
-- Name: failures_for_env; Type: TABLE; Schema: public; Owner: coresmokedb
--

CREATE TABLE public.failures_for_env (
    result_id integer NOT NULL,
    failure_id integer NOT NULL
);


ALTER TABLE public.failures_for_env OWNER TO coresmokedb;

--
-- Name: report; Type: TABLE; Schema: public; Owner: coresmokedb
--

CREATE TABLE public.report (
    id integer NOT NULL,
    sconfig_id integer,
    duration integer,
    config_count integer,
    reporter character varying,
    reporter_version character varying,
    smoke_perl character varying,
    smoke_revision character varying,
    smoke_version character varying,
    smoker_version character varying,
    smoke_date timestamp with time zone NOT NULL,
    perl_id character varying NOT NULL,
    git_id character varying NOT NULL,
    git_describe character varying NOT NULL,
    applied_patches character varying,
    hostname character varying NOT NULL,
    architecture character varying NOT NULL,
    osname character varying NOT NULL,
    osversion character varying NOT NULL,
    cpu_count character varying,
    cpu_description character varying,
    username character varying,
    test_jobs character varying,
    lc_all character varying,
    lang character varying,
    user_note character varying,
    manifest_msgs bytea,
    compiler_msgs bytea,
    skipped_tests character varying,
    log_file bytea,
    out_file bytea,
    harness_only character varying,
    harness3opts character varying,
    summary character varying NOT NULL,
    smoke_branch character varying DEFAULT 'blead'::character varying,
    nonfatal_msgs bytea,
    plevel character varying GENERATED ALWAYS AS (public.git_describe_as_plevel(git_describe)) STORED
);


ALTER TABLE public.report OWNER TO coresmokedb;

--
-- Name: report_id_seq; Type: SEQUENCE; Schema: public; Owner: coresmokedb
--

CREATE SEQUENCE public.report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.report_id_seq OWNER TO coresmokedb;

--
-- Name: report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: coresmokedb
--

ALTER SEQUENCE public.report_id_seq OWNED BY public.report.id;


--
-- Name: result; Type: TABLE; Schema: public; Owner: coresmokedb
--

CREATE TABLE public.result (
    id integer NOT NULL,
    config_id integer NOT NULL,
    io_env character varying NOT NULL,
    locale character varying,
    summary character varying NOT NULL,
    statistics character varying,
    stat_cpu_time double precision,
    stat_tests integer
);


ALTER TABLE public.result OWNER TO coresmokedb;

--
-- Name: result_id_seq; Type: SEQUENCE; Schema: public; Owner: coresmokedb
--

CREATE SEQUENCE public.result_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.result_id_seq OWNER TO coresmokedb;

--
-- Name: result_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: coresmokedb
--

ALTER SEQUENCE public.result_id_seq OWNED BY public.result.id;


--
-- Name: smoke_config; Type: TABLE; Schema: public; Owner: coresmokedb
--

CREATE TABLE public.smoke_config (
    id integer NOT NULL,
    md5 character varying NOT NULL,
    config character varying
);


ALTER TABLE public.smoke_config OWNER TO coresmokedb;

--
-- Name: smoke_config_id_seq; Type: SEQUENCE; Schema: public; Owner: coresmokedb
--

CREATE SEQUENCE public.smoke_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.smoke_config_id_seq OWNER TO coresmokedb;

--
-- Name: smoke_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: coresmokedb
--

ALTER SEQUENCE public.smoke_config_id_seq OWNED BY public.smoke_config.id;


--
-- Name: tsgateway_config; Type: TABLE; Schema: public; Owner: tsgateway
--

CREATE TABLE public.tsgateway_config (
    id integer NOT NULL,
    name character varying NOT NULL,
    value character varying
);


ALTER TABLE public.tsgateway_config OWNER TO tsgateway;

--
-- Name: tsgateway_config_id_seq; Type: SEQUENCE; Schema: public; Owner: tsgateway
--

CREATE SEQUENCE public.tsgateway_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tsgateway_config_id_seq OWNER TO tsgateway;

--
-- Name: tsgateway_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tsgateway
--

ALTER SEQUENCE public.tsgateway_config_id_seq OWNED BY public.tsgateway_config.id;


--
-- Name: config id; Type: DEFAULT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.config ALTER COLUMN id SET DEFAULT nextval('public.config_id_seq'::regclass);


--
-- Name: failure id; Type: DEFAULT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.failure ALTER COLUMN id SET DEFAULT nextval('public.failure_id_seq'::regclass);


--
-- Name: report id; Type: DEFAULT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.report ALTER COLUMN id SET DEFAULT nextval('public.report_id_seq'::regclass);


--
-- Name: result id; Type: DEFAULT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.result ALTER COLUMN id SET DEFAULT nextval('public.result_id_seq'::regclass);


--
-- Name: smoke_config id; Type: DEFAULT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.smoke_config ALTER COLUMN id SET DEFAULT nextval('public.smoke_config_id_seq'::regclass);


--
-- Name: tsgateway_config id; Type: DEFAULT; Schema: public; Owner: tsgateway
--

ALTER TABLE ONLY public.tsgateway_config ALTER COLUMN id SET DEFAULT nextval('public.tsgateway_config_id_seq'::regclass);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- Name: failure failure_pkey; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.failure
    ADD CONSTRAINT failure_pkey PRIMARY KEY (id);


--
-- Name: failure failure_test_status_extra_key; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.failure
    ADD CONSTRAINT failure_test_status_extra_key UNIQUE (test, status, extra);


--
-- Name: failures_for_env failures_for_env_result_id_failure_id_key; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.failures_for_env
    ADD CONSTRAINT failures_for_env_result_id_failure_id_key UNIQUE (result_id, failure_id);


--
-- Name: report report_git_id_smoke_date_duration_hostname_architecture_key; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_git_id_smoke_date_duration_hostname_architecture_key UNIQUE (git_id, smoke_date, duration, hostname, architecture);


--
-- Name: report report_pkey; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_pkey PRIMARY KEY (id);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (id);


--
-- Name: smoke_config smoke_config_md5_key; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.smoke_config
    ADD CONSTRAINT smoke_config_md5_key UNIQUE (md5);


--
-- Name: smoke_config smoke_config_pkey; Type: CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.smoke_config
    ADD CONSTRAINT smoke_config_pkey PRIMARY KEY (id);


--
-- Name: tsgateway_config tsgateway_config_name_key; Type: CONSTRAINT; Schema: public; Owner: tsgateway
--

ALTER TABLE ONLY public.tsgateway_config
    ADD CONSTRAINT tsgateway_config_name_key UNIQUE (name);


--
-- Name: tsgateway_config tsgateway_config_pkey; Type: CONSTRAINT; Schema: public; Owner: tsgateway
--

ALTER TABLE ONLY public.tsgateway_config
    ADD CONSTRAINT tsgateway_config_pkey PRIMARY KEY (id);


--
-- Name: report_architecture_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_architecture_idx ON public.report USING btree (architecture);


--
-- Name: report_hostname_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_hostname_idx ON public.report USING btree (hostname);


--
-- Name: report_osname_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_osname_idx ON public.report USING btree (osname);


--
-- Name: report_osversion_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_osversion_idx ON public.report USING btree (osversion);


--
-- Name: report_perl_id_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_perl_id_idx ON public.report USING btree (perl_id);


--
-- Name: report_plevel_hostname_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_plevel_hostname_idx ON public.report USING btree (hostname, plevel);


--
-- Name: report_plevel_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_plevel_idx ON public.report USING btree (plevel);


--
-- Name: report_smoke_date_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_smoke_date_idx ON public.report USING btree (smoke_date);


--
-- Name: report_smokedate_hostname_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_smokedate_hostname_idx ON public.report USING btree (hostname, smoke_date);


--
-- Name: report_smokedate_plevel_hostname_idx; Type: INDEX; Schema: public; Owner: coresmokedb
--

CREATE INDEX report_smokedate_plevel_hostname_idx ON public.report USING btree (hostname, plevel, smoke_date);


--
-- Name: config config_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.report(id);


--
-- Name: failures_for_env failures_for_env_failure_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.failures_for_env
    ADD CONSTRAINT failures_for_env_failure_id_fkey FOREIGN KEY (failure_id) REFERENCES public.failure(id);


--
-- Name: failures_for_env failures_for_env_result_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.failures_for_env
    ADD CONSTRAINT failures_for_env_result_id_fkey FOREIGN KEY (result_id) REFERENCES public.result(id);


--
-- Name: report report_sconfig_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_sconfig_id_fkey FOREIGN KEY (sconfig_id) REFERENCES public.smoke_config(id);


--
-- Name: result result_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coresmokedb
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_config_id_fkey FOREIGN KEY (config_id) REFERENCES public.config(id);


--
-- Name: TABLE config; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.config TO tsgateway;
GRANT SELECT ON TABLE public.config TO backup;


--
-- Name: SEQUENCE config_id_seq; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT USAGE ON SEQUENCE public.config_id_seq TO tsgateway;


--
-- Name: TABLE failure; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.failure TO tsgateway;
GRANT SELECT ON TABLE public.failure TO backup;


--
-- Name: SEQUENCE failure_id_seq; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT USAGE ON SEQUENCE public.failure_id_seq TO tsgateway;


--
-- Name: TABLE failures_for_env; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.failures_for_env TO tsgateway;
GRANT SELECT ON TABLE public.failures_for_env TO backup;


--
-- Name: TABLE report; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.report TO tsgateway;
GRANT SELECT ON TABLE public.report TO backup;


--
-- Name: SEQUENCE report_id_seq; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT USAGE ON SEQUENCE public.report_id_seq TO tsgateway;


--
-- Name: TABLE result; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.result TO tsgateway;
GRANT SELECT ON TABLE public.result TO backup;


--
-- Name: SEQUENCE result_id_seq; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT USAGE ON SEQUENCE public.result_id_seq TO tsgateway;


--
-- Name: TABLE smoke_config; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.smoke_config TO tsgateway;
GRANT SELECT ON TABLE public.smoke_config TO backup;


--
-- Name: SEQUENCE smoke_config_id_seq; Type: ACL; Schema: public; Owner: coresmokedb
--

GRANT USAGE ON SEQUENCE public.smoke_config_id_seq TO tsgateway;


--
-- Name: TABLE tsgateway_config; Type: ACL; Schema: public; Owner: tsgateway
--

GRANT SELECT ON TABLE public.tsgateway_config TO backup;


--
-- PostgreSQL database dump complete
--

-- Handcrafted: pg_dump -d -t '*_seq' coresmokedb | grep SELECT | grep setval

SELECT pg_catalog.setval('public.config_id_seq', 550000, true);
SELECT pg_catalog.setval('public.failure_id_seq', 5000, true);
SELECT pg_catalog.setval('public.report_id_seq', 5500000, true);
SELECT pg_catalog.setval('public.result_id_seq', 850000, true);
SELECT pg_catalog.setval('public.smoke_config_id_seq', 1, true);
SELECT pg_catalog.setval('public.tsgateway_config_id_seq', 1, true);

