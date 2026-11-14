-- Synthetic data for local development (users alice, bob), modeled on the real
-- schema but not derived from real data. Load it with `make db` / `make db-reset`.

--
-- PostgreSQL database dump
--


-- Dumped from database version 17.12
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.transaction DROP CONSTRAINT IF EXISTS transaction_payment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transaction DROP CONSTRAINT IF EXISTS transaction_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.plaidconnection DROP CONSTRAINT IF EXISTS plaidconnection_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.plaidaccount DROP CONSTRAINT IF EXISTS plaidaccount_connection_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payment DROP CONSTRAINT IF EXISTS payment_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.exchange DROP CONSTRAINT IF EXISTS fk_exchange_cashback_transaction;
ALTER TABLE IF EXISTS ONLY public.exchangepayment DROP CONSTRAINT IF EXISTS exchangepayment_payment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.exchangepayment DROP CONSTRAINT IF EXISTS exchangepayment_exchange_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credittransaction DROP CONSTRAINT IF EXISTS credittransaction_transaction_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credittransaction DROP CONSTRAINT IF EXISTS credittransaction_credit_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit DROP CONSTRAINT IF EXISTS credit_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bankaccount DROP CONSTRAINT IF EXISTS bankaccount_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bankaccount DROP CONSTRAINT IF EXISTS bankaccount_plaid_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_plaid_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_bank_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public."user" DROP CONSTRAINT IF EXISTS user_pkey;
ALTER TABLE IF EXISTS ONLY public.exchange DROP CONSTRAINT IF EXISTS uq_exchange_cashback_transaction_id;
ALTER TABLE IF EXISTS ONLY public.transaction DROP CONSTRAINT IF EXISTS transaction_pkey;
ALTER TABLE IF EXISTS ONLY public.transaction DROP CONSTRAINT IF EXISTS transaction_import_id_key;
ALTER TABLE IF EXISTS ONLY public.plaidconnection DROP CONSTRAINT IF EXISTS plaidconnection_pkey;
ALTER TABLE IF EXISTS ONLY public.plaidaccount DROP CONSTRAINT IF EXISTS plaidaccount_plaid_account_id_key;
ALTER TABLE IF EXISTS ONLY public.plaidaccount DROP CONSTRAINT IF EXISTS plaidaccount_pkey;
ALTER TABLE IF EXISTS ONLY public.payment DROP CONSTRAINT IF EXISTS payment_pkey;
ALTER TABLE IF EXISTS ONLY public.payment DROP CONSTRAINT IF EXISTS payment_import_id_key;
ALTER TABLE IF EXISTS ONLY public.exchangerate DROP CONSTRAINT IF EXISTS exchangerate_pkey;
ALTER TABLE IF EXISTS ONLY public.exchangepayment DROP CONSTRAINT IF EXISTS exchangepayment_pkey;
ALTER TABLE IF EXISTS ONLY public.exchange DROP CONSTRAINT IF EXISTS exchange_pkey;
ALTER TABLE IF EXISTS ONLY public.exchange DROP CONSTRAINT IF EXISTS exchange_import_id_key;
ALTER TABLE IF EXISTS ONLY public.exchange DROP CONSTRAINT IF EXISTS exchange_actual_id_key;
ALTER TABLE IF EXISTS ONLY public.credittransaction DROP CONSTRAINT IF EXISTS credittransaction_pkey;
ALTER TABLE IF EXISTS ONLY public.credit DROP CONSTRAINT IF EXISTS credit_pkey;
ALTER TABLE IF EXISTS ONLY public.credit DROP CONSTRAINT IF EXISTS credit_import_id_key;
ALTER TABLE IF EXISTS ONLY public.bankaccount DROP CONSTRAINT IF EXISTS bankaccount_pkey;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_pkey;
ALTER TABLE IF EXISTS public."user" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.transaction ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.plaidconnection ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.plaidaccount ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payment ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.exchange ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.credit ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.bankaccount ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.account ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.user_id_seq;
DROP TABLE IF EXISTS public."user";
DROP SEQUENCE IF EXISTS public.transaction_id_seq;
DROP TABLE IF EXISTS public.transaction;
DROP SEQUENCE IF EXISTS public.plaidconnection_id_seq;
DROP TABLE IF EXISTS public.plaidconnection;
DROP SEQUENCE IF EXISTS public.plaidaccount_id_seq;
DROP TABLE IF EXISTS public.plaidaccount;
DROP SEQUENCE IF EXISTS public.payment_id_seq;
DROP TABLE IF EXISTS public.payment;
DROP TABLE IF EXISTS public.exchangerate;
DROP TABLE IF EXISTS public.exchangepayment;
DROP SEQUENCE IF EXISTS public.exchange_id_seq;
DROP TABLE IF EXISTS public.exchange;
DROP TABLE IF EXISTS public.credittransaction;
DROP SEQUENCE IF EXISTS public.credit_id_seq;
DROP TABLE IF EXISTS public.credit;
DROP SEQUENCE IF EXISTS public.bankaccount_id_seq;
DROP TABLE IF EXISTS public.bankaccount;
DROP TABLE IF EXISTS public.alembic_version;
DROP SEQUENCE IF EXISTS public.account_id_seq;
DROP TABLE IF EXISTS public.account;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account (
    id integer NOT NULL,
    actual_id character varying(255),
    import_id character varying(255),
    name character varying(255) NOT NULL,
    institution character varying(255) NOT NULL,
    due_day integer,
    autopay_offset integer,
    color character varying(255),
    target_spend integer,
    user_id integer NOT NULL,
    bank_account_id integer,
    plaid_account_id integer,
    active boolean NOT NULL,
    issuer character varying
);
ALTER TABLE ONLY public.account ALTER COLUMN id SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN actual_id SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN import_id SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN name SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN institution SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN due_day SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN autopay_offset SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN color SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN target_spend SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN user_id SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN bank_account_id SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN plaid_account_id SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN active SET (pg_attver=22141440);
ALTER TABLE ONLY public.account ALTER COLUMN issuer SET (pg_attver=22141440);


--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_id_seq OWNED BY public.account.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);
ALTER TABLE ONLY public.alembic_version ALTER COLUMN version_num SET (pg_attver=22224520);


--
-- Name: bankaccount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bankaccount (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    institution character varying(255) NOT NULL,
    balance integer NOT NULL,
    import_id character varying(255),
    user_id integer NOT NULL,
    plaid_account_id integer
);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN id SET (pg_attver=22229008);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN name SET (pg_attver=22229008);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN institution SET (pg_attver=22229008);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN balance SET (pg_attver=22229008);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN import_id SET (pg_attver=22229008);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN user_id SET (pg_attver=22229008);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN plaid_account_id SET (pg_attver=22229008);


--
-- Name: bankaccount_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bankaccount_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bankaccount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bankaccount_id_seq OWNED BY public.bankaccount.id;


--
-- Name: credit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit (
    id integer NOT NULL,
    account_id integer NOT NULL,
    import_id character varying(255) NOT NULL,
    date date NOT NULL,
    counterparty character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    category character varying(255),
    amount_usd integer NOT NULL,
    posted_date date
);
ALTER TABLE ONLY public.credit ALTER COLUMN id SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN account_id SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN import_id SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN date SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN counterparty SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN description SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN category SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN amount_usd SET (pg_attver=22247664);
ALTER TABLE ONLY public.credit ALTER COLUMN posted_date SET (pg_attver=22247664);


--
-- Name: credit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.credit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.credit_id_seq OWNED BY public.credit.id;


--
-- Name: credittransaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credittransaction (
    credit_id integer NOT NULL,
    transaction_id integer NOT NULL,
    amount integer NOT NULL
);
ALTER TABLE ONLY public.credittransaction ALTER COLUMN credit_id SET (pg_attver=22281512);
ALTER TABLE ONLY public.credittransaction ALTER COLUMN transaction_id SET (pg_attver=22281512);
ALTER TABLE ONLY public.credittransaction ALTER COLUMN amount SET (pg_attver=22281512);


--
-- Name: exchange; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange (
    id integer NOT NULL,
    actual_id character varying(255),
    date date NOT NULL,
    amount_usd integer NOT NULL,
    paid_eur integer NOT NULL,
    exchange_rate numeric(10,8) NOT NULL,
    amount_eur integer NOT NULL,
    fees_eur integer,
    import_id character varying(255),
    cashback_transaction_id integer
);
ALTER TABLE ONLY public.exchange ALTER COLUMN id SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN actual_id SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN date SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN amount_usd SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN paid_eur SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN exchange_rate SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN amount_eur SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN fees_eur SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN import_id SET (pg_attver=22287040);
ALTER TABLE ONLY public.exchange ALTER COLUMN cashback_transaction_id SET (pg_attver=22287040);


--
-- Name: exchange_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exchange_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exchange_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exchange_id_seq OWNED BY public.exchange.id;


--
-- Name: exchangepayment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchangepayment (
    exchange_id integer NOT NULL,
    payment_id integer NOT NULL,
    amount integer NOT NULL
);
ALTER TABLE ONLY public.exchangepayment ALTER COLUMN exchange_id SET (pg_attver=22307256);
ALTER TABLE ONLY public.exchangepayment ALTER COLUMN payment_id SET (pg_attver=22307256);
ALTER TABLE ONLY public.exchangepayment ALTER COLUMN amount SET (pg_attver=22307256);


--
-- Name: exchangerate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchangerate (
    date date NOT NULL,
    source integer NOT NULL,
    exchange_rate numeric(10,8) NOT NULL
);
ALTER TABLE ONLY public.exchangerate ALTER COLUMN date SET (pg_attver=22312776);
ALTER TABLE ONLY public.exchangerate ALTER COLUMN source SET (pg_attver=22312776);
ALTER TABLE ONLY public.exchangerate ALTER COLUMN exchange_rate SET (pg_attver=22312776);


--
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    account_id integer NOT NULL,
    import_id character varying(255),
    actual_id character varying(255),
    date date NOT NULL,
    counterparty character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    category character varying(255),
    amount_usd integer NOT NULL,
    amount_eur integer,
    status integer NOT NULL
);
ALTER TABLE ONLY public.payment ALTER COLUMN id SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN account_id SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN import_id SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN actual_id SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN date SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN counterparty SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN description SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN category SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN amount_usd SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN amount_eur SET (pg_attver=22318304);
ALTER TABLE ONLY public.payment ALTER COLUMN status SET (pg_attver=22318304);


--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: plaidaccount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plaidaccount (
    id integer NOT NULL,
    name character varying NOT NULL,
    plaid_account_id character varying NOT NULL,
    connection_id integer NOT NULL,
    cursor character varying,
    last_successful_update timestamp with time zone
);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN id SET (pg_attver=22354680);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN name SET (pg_attver=22354680);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN plaid_account_id SET (pg_attver=22354680);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN connection_id SET (pg_attver=22354680);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN cursor SET (pg_attver=22354680);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN last_successful_update SET (pg_attver=22354680);


--
-- Name: plaidaccount_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plaidaccount_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plaidaccount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plaidaccount_id_seq OWNED BY public.plaidaccount.id;


--
-- Name: plaidconnection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plaidconnection (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying,
    plaid_item_id character varying NOT NULL,
    plaid_access_token character varying NOT NULL
);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN id SET (pg_attver=22372384);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN user_id SET (pg_attver=22372384);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN name SET (pg_attver=22372384);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN plaid_item_id SET (pg_attver=22372384);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN plaid_access_token SET (pg_attver=22372384);


--
-- Name: plaidconnection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plaidconnection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plaidconnection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plaidconnection_id_seq OWNED BY public.plaidconnection.id;


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction (
    id integer NOT NULL,
    account_id integer NOT NULL,
    import_id character varying(255) NOT NULL,
    actual_id character varying(255),
    date date NOT NULL,
    counterparty character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    category character varying(255),
    amount_usd integer NOT NULL,
    amount_eur integer,
    status integer NOT NULL,
    payment_id integer,
    fees_and_risk_eur integer,
    ignore boolean,
    posted_date date
);
ALTER TABLE ONLY public.transaction ALTER COLUMN id SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN account_id SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN import_id SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN actual_id SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN date SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN counterparty SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN description SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN category SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN amount_usd SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN amount_eur SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN status SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN payment_id SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN fees_and_risk_eur SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN ignore SET (pg_attver=22397192);
ALTER TABLE ONLY public.transaction ALTER COLUMN posted_date SET (pg_attver=22397192);


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transaction_id_seq OWNED BY public.transaction.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    super_user boolean NOT NULL,
    actual_sync_id character varying(255),
    actual_encryption_password character varying(255),
    actual_misc_account character varying
);
ALTER TABLE ONLY public."user" ALTER COLUMN id SET (pg_attver=22421184);
ALTER TABLE ONLY public."user" ALTER COLUMN name SET (pg_attver=22421184);
ALTER TABLE ONLY public."user" ALTER COLUMN super_user SET (pg_attver=22421184);
ALTER TABLE ONLY public."user" ALTER COLUMN actual_sync_id SET (pg_attver=22421184);
ALTER TABLE ONLY public."user" ALTER COLUMN actual_encryption_password SET (pg_attver=22421184);
ALTER TABLE ONLY public."user" ALTER COLUMN actual_misc_account SET (pg_attver=22421184);


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: account id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT nextval('public.account_id_seq'::regclass);


--
-- Name: bankaccount id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bankaccount ALTER COLUMN id SET DEFAULT nextval('public.bankaccount_id_seq'::regclass);


--
-- Name: credit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit ALTER COLUMN id SET DEFAULT nextval('public.credit_id_seq'::regclass);


--
-- Name: exchange id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange ALTER COLUMN id SET DEFAULT nextval('public.exchange_id_seq'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: plaidaccount id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plaidaccount ALTER COLUMN id SET DEFAULT nextval('public.plaidaccount_id_seq'::regclass);


--
-- Name: plaidconnection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plaidconnection ALTER COLUMN id SET DEFAULT nextval('public.plaidconnection_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction ALTER COLUMN id SET DEFAULT nextval('public.transaction_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account (id, actual_id, import_id, name, institution, due_day, autopay_offset, color, target_spend, user_id, bank_account_id, plaid_account_id, active, issuer) FROM stdin;
1	\N	\N	Everyday Cash	Capital One	7	0	#3b82f6	\N	1	1	2	t	capital_one
2	\N	\N	Travel Rewards	Chase	21	0	#0f766e	\N	1	1	3	t	chase
3	\N	\N	Gold Card	American Express	14	10	#d4a72c	\N	1	1	4	t	amex
4	\N	\N	Blue Cash	American Express	3	10	#8b5cf6	\N	2	2	5	t	amex
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
b7d2f04a9c13
\.


--
-- Data for Name: bankaccount; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bankaccount (id, name, institution, balance, import_id, user_id, plaid_account_id) FROM stdin;
1	Checking	Example Credit Union	399965	\N	1	1
2	Checking	Example Bank	22238	\N	2	\N
\.


--
-- Data for Name: credit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit (id, account_id, import_id, date, counterparty, description, category, amount_usd, posted_date) FROM stdin;
1	1	cr_50582934db193b05fa760fb3	2026-09-26	Capital One Travel Credit	TRAVEL CREDIT	\N	1416	\N
2	1	cr_c44b2b5a08c1abb9fbd05dec	2026-10-03	Capital One Travel Credit	TRAVEL CREDIT	\N	10000	\N
3	2	cr_4856870061db1cb2e5db023d	2026-09-17	Chase Travel Credit	TRAVEL CREDIT	\N	2921	\N
4	1	cr_ab8ec889c40df48986081960	2026-11-10	Online Marketplace	ONLINE MARKETPLACE REFUND	\N	2399	\N
\.


--
-- Data for Name: credittransaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credittransaction (credit_id, transaction_id, amount) FROM stdin;
1	7	1416
2	15	10000
3	58	2921
\.


--
-- Data for Name: exchange; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exchange (id, actual_id, date, amount_usd, paid_eur, exchange_rate, amount_eur, fees_eur, import_id, cashback_transaction_id) FROM stdin;
1	\N	2026-10-02	83151	72226	1.15607000	71926	300	\N	\N
2	\N	2026-09-29	6890	6276	1.15311000	5975	301	\N	\N
\.


--
-- Data for Name: exchangepayment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exchangepayment (exchange_id, payment_id, amount) FROM stdin;
1	1	51397
1	3	19947
1	5	11807
2	7	6890
\.


--
-- Data for Name: exchangerate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exchangerate (date, source, exchange_rate) FROM stdin;
2026-09-03	2	1.15408949
2026-09-04	2	1.15583099
2026-09-05	2	1.15958320
2026-09-06	2	1.15780332
2026-09-07	2	1.15834131
2026-09-08	2	1.15890678
2026-09-09	2	1.15944009
2026-09-10	2	1.15692553
2026-09-11	2	1.15891540
2026-09-12	2	1.15855213
2026-09-13	2	1.16240094
2026-09-14	2	1.15701934
2026-09-15	2	1.15453435
2026-09-16	2	1.15094899
2026-09-17	2	1.14872755
2026-09-18	2	1.15040484
2026-09-19	2	1.15054402
2026-09-20	2	1.15253131
2026-09-21	2	1.15670782
2026-09-22	2	1.15498326
2026-09-23	2	1.16004982
2026-09-24	2	1.15557809
2026-09-25	2	1.15862517
2026-09-26	2	1.15688929
2026-09-27	2	1.15087814
2026-09-28	2	1.15160379
2026-09-29	2	1.15109454
2026-09-30	2	1.14611568
2026-10-01	2	1.15537077
2026-10-02	2	1.15441996
2026-10-03	2	1.15305500
2026-10-04	2	1.15476450
2026-10-05	2	1.15246744
2026-10-06	2	1.14962793
2026-10-07	2	1.15110938
2026-10-08	2	1.14987189
2026-10-09	2	1.15207481
2026-10-10	2	1.15318182
2026-10-11	2	1.15642973
2026-10-12	2	1.15921624
2026-10-13	2	1.16229006
2026-10-14	2	1.16157457
2026-10-15	2	1.16328618
2026-10-16	2	1.16240937
2026-10-17	2	1.16340383
2026-10-18	2	1.16073639
2026-10-19	2	1.16411130
2026-10-20	2	1.16870466
2026-10-21	2	1.16971157
2026-10-22	2	1.16741915
2026-10-23	2	1.17082261
2026-10-24	2	1.17219060
2026-10-25	2	1.16890488
2026-10-26	2	1.16879957
2026-10-27	2	1.16339548
2026-10-28	2	1.15925455
2026-10-29	2	1.15763322
2026-10-30	2	1.16047161
2026-10-31	2	1.16096351
2026-11-01	2	1.15484559
2026-11-02	2	1.16718786
2026-11-03	2	1.16379215
2026-11-04	2	1.16176704
2026-11-05	2	1.16185261
2026-11-06	2	1.16005854
2026-11-07	2	1.16013951
2026-11-08	2	1.15843113
2026-11-09	2	1.15376310
2026-11-10	2	1.15370877
2026-11-11	2	1.14982193
2026-11-12	2	1.15025590
2026-11-13	2	1.14604710
2026-11-14	2	1.14591855
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment (id, account_id, import_id, actual_id, date, counterparty, description, category, amount_usd, amount_eur, status) FROM stdin;
2	1	pay_8288aacd6a0ff27482578044	\N	2026-11-07	Capital One	AUTOPAY PAYMENT - THANK YOU	\N	98609	\N	2
4	2	pay_636cb563c8c41a64d126ca76	\N	2026-11-21	Chase	Upcoming Payment	\N	20672	\N	1
6	3	pay_fdeb9e462180ba25bedfd7f5	\N	2026-11-14	American Express	AUTOPAY PAYMENT - THANK YOU	\N	23190	\N	2
8	4	pay_0ff60fd2a96eb16a609a6dba	\N	2026-11-03	American Express	AUTOPAY PAYMENT - THANK YOU	\N	32949	\N	2
1	1	pay_fc8871b1aa6cddc4dfd3baef	\N	2026-10-07	Capital One	AUTOPAY PAYMENT - THANK YOU	\N	51397	44458	3
3	2	pay_5a5e7fe6cb8fd00a58710142	\N	2026-10-21	Chase	AUTOPAY PAYMENT - THANK YOU	\N	19947	17254	3
5	3	pay_4a754a9058769f270f513031	\N	2026-10-14	American Express	AUTOPAY PAYMENT - THANK YOU	\N	11807	10213	3
7	4	pay_b5947ccf73e9b013f27e8d6b	\N	2026-10-03	American Express	AUTOPAY PAYMENT - THANK YOU	\N	6890	5975	3
\.


--
-- Data for Name: plaidaccount; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plaidaccount (id, name, plaid_account_id, connection_id, cursor, last_successful_update) FROM stdin;
1	Checking	c77ec1b8c58b7c3c58c5f3b300528c64	1	\N	2026-11-13 04:41:00+00
2	Everyday Cash	9983f379c643714db2ebbb16e3295904	2	\N	2026-11-13 06:59:00+00
3	Travel Rewards	7029f4fb75bfcd45b819eee99f0e79de	3	\N	2026-11-13 09:28:00+00
4	Gold Card	57e03e85edc33addd2d8e0d82babc103	4	\N	2026-11-13 07:39:00+00
5	Blue Cash	4aee34c6c8fa3ba1a0cb65e89f219a9c	5	\N	2026-11-13 06:44:00+00
\.


--
-- Data for Name: plaidconnection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plaidconnection (id, user_id, name, plaid_item_id, plaid_access_token) FROM stdin;
1	1	Example Credit Union	item-sandbox-fe60ca6dd48bb503c5ed337e	access-sandbox-46588e2109b3ea414813fe9f
2	1	Capital One	item-sandbox-92d6b9b19089555c5873c008	access-sandbox-69188d151bbd898ccb59fec5
3	1	Chase	item-sandbox-edd3565ec012e7e2a6b073f3	access-sandbox-6938885c23fe30d8a2ebc9fe
4	1	American Express	item-sandbox-4580732282c426da2dc93179	access-sandbox-2e3e3c2eeba7f4b57aeae997
5	2	American Express	item-sandbox-acd73352bfc72218b936ad15	access-sandbox-04cad9de51e436ae0d43512e
\.


--
-- Data for Name: transaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transaction (id, account_id, import_id, actual_id, date, counterparty, description, category, amount_usd, amount_eur, status, payment_id, fees_and_risk_eur, ignore, posted_date) FROM stdin;
1	1	tx_24a0a32896cbb78571883670	\N	2026-09-12	Online Marketplace	ONLINE MARKETPLACE ONLINE	\N	11139	9615	3	1	29	f	\N
2	1	tx_0c0ecc1c5074b607fffb7ef6	\N	2026-09-14	Metro Transit	METRO TRANSIT BOSTON	transportation	2406	2079	3	1	18	f	\N
3	1	tx_d745fb5b50d5c9f4a1fc9220	\N	2026-09-16	Fresh Market	FRESH MARKET BOSTON	\N	3837	3334	3	1	14	f	\N
4	1	tx_0844804798e5d3face24c72e	\N	2026-09-20	Daily Bakery	DAILY BAKERY BOSTON	\N	916	795	3	1	6	f	\N
5	1	tx_4a7c05834a0b9a66e56afdc0	\N	2026-09-20	Coffee Roasters	COFFEE ROASTERS NEW YORK	dining	636	552	3	1	3	f	\N
6	1	tx_3d5a9da414c4d167bbde7800	\N	2026-09-23	Book Nook	BOOK NOOK NEW YORK	\N	1914	1650	3	1	11	f	\N
7	1	tx_20c2c05f73e7824f9bf9a202	\N	2026-09-23	Metro Transit	METRO TRANSIT ONLINE	transportation	1416	1221	3	1	2	f	\N
8	1	tx_e3e4434dee6b293f00c6f393	\N	2026-09-23	Corner Grocery	CORNER GROCERY NEW YORK	groceries	5517	4756	3	1	22	f	\N
9	1	tx_9d735e6c08576084a0e6ca4b	\N	2026-09-24	Noodle House	NOODLE HOUSE SEATTLE	dining	3217	2784	3	1	14	f	\N
10	1	tx_7528302f600bae42de303531	\N	2026-09-25	Fresh Market	FRESH MARKET SEATTLE	\N	7632	6587	3	1	60	f	\N
11	1	tx_42a8a9373a91f7da1a994ff5	\N	2026-09-26	Book Nook	BOOK NOOK ONLINE	\N	1882	1627	3	1	8	f	\N
12	1	tx_6c3b998c268da61dcfb19ea2	\N	2026-09-28	Daily Bakery	DAILY BAKERY BOSTON	\N	974	846	3	1	5	f	\N
13	1	tx_369b4af470bd5aefde81264c	\N	2026-09-28	Noodle House	NOODLE HOUSE NEW YORK	\N	3638	3159	3	1	18	f	\N
14	1	tx_e4bb00367892f85a967e11ea	\N	2026-09-28	Daily Bakery	DAILY BAKERY ONLINE	dining	431	374	3	1	2	f	\N
15	1	tx_2833eef2ba5378ee9bb55c35	\N	2026-09-30	Harbor Hotel	HARBOR HOTEL NEW YORK	\N	17258	15058	3	1	33	f	\N
16	1	tx_e64745e4ae28c3855f01899d	\N	2026-10-01	Blue Door Bistro	BLUE DOOR BISTRO BOSTON	\N	6495	\N	2	\N	\N	f	\N
17	1	tx_67687078579f987ce92b5633	\N	2026-10-01	Coffee Roasters	COFFEE ROASTERS BOSTON	\N	473	\N	2	\N	\N	f	\N
18	1	tx_7ca293b25fa3a80ec8fdd1dc	\N	2026-10-01	Corner Grocery	CORNER GROCERY NEW YORK	\N	5347	\N	2	\N	\N	f	\N
19	1	tx_271a02aa1973a113abb4c964	\N	2026-10-05	Daily Bakery	DAILY BAKERY ONLINE	\N	600	\N	2	\N	\N	f	\N
20	1	tx_fdbb5a753e69c60421a6f7f1	\N	2026-10-06	Blue Door Bistro	BLUE DOOR BISTRO ONLINE	dining	3560	\N	2	\N	\N	f	\N
21	1	tx_af7ebb4bd2681e824f114b4f	\N	2026-10-08	Metro Transit	METRO TRANSIT NEW YORK	\N	1504	\N	2	\N	\N	f	\N
22	1	tx_4fcc7ea679a933870f6f075a	\N	2026-10-09	Daily Bakery	DAILY BAKERY BOSTON	\N	1003	\N	2	\N	\N	f	\N
23	1	tx_440bde5bdbc05164a0987049	\N	2026-10-09	Rail Express	RAIL EXPRESS BOSTON	\N	4303	\N	2	\N	\N	f	\N
24	1	tx_8f23b2d50eaa1257b98fe788	\N	2026-10-09	Blue Door Bistro	BLUE DOOR BISTRO ONLINE	dining	4214	\N	2	\N	\N	f	\N
25	1	tx_932c78fd28cf7488ec0dbaad	\N	2026-10-11	Coffee Roasters	COFFEE ROASTERS ONLINE	\N	478	\N	2	\N	\N	f	\N
26	1	tx_285aed3cd0b67205954eedae	\N	2026-10-12	Coffee Roasters	COFFEE ROASTERS NEW YORK	\N	479	\N	2	\N	\N	f	\N
27	1	tx_d87c44a3b1019a2b7093a1ce	\N	2026-10-13	Pet Supplies	PET SUPPLIES BOSTON	\N	3261	\N	2	\N	\N	f	\N
28	1	tx_42b4598d753f64393c84f71f	\N	2026-10-15	Code Tools Ltd	CODE TOOLS LTD ONLINE	\N	1325	\N	2	\N	\N	f	\N
29	1	tx_44ed78b21444500bf037f5f7	\N	2026-10-15	Harbor Hotel	HARBOR HOTEL BOSTON	\N	19674	\N	2	\N	\N	f	\N
30	1	tx_83a89ad92b7526799ec255e2	\N	2026-10-17	Blue Door Bistro	BLUE DOOR BISTRO SEATTLE	dining	3540	\N	2	\N	\N	f	\N
31	1	tx_e3e29a30ca5aef7656c4613d	\N	2026-10-19	Hardware Store	HARDWARE STORE BOSTON	\N	2426	\N	2	\N	\N	f	\N
32	1	tx_a38ddf6a633db6d84a278238	\N	2026-10-21	Coffee Roasters	COFFEE ROASTERS SEATTLE	dining	636	\N	2	\N	\N	f	\N
33	1	tx_927e62690c4c0d8001345691	\N	2026-10-22	Hardware Store	HARDWARE STORE ONLINE	\N	5064	\N	2	\N	\N	f	\N
34	1	tx_1bedec6c83487115bb2fec2a	\N	2026-10-24	Fresh Market	FRESH MARKET NEW YORK	\N	3712	\N	2	\N	\N	f	\N
35	1	tx_fd4871895678a62cbea0cfb2	\N	2026-10-25	City Pharmacy	CITY PHARMACY SEATTLE	\N	1289	\N	2	\N	\N	f	\N
36	1	tx_6a536fb775d375d46eaf86bc	\N	2026-10-25	Corner Grocery	CORNER GROCERY BOSTON	\N	6199	\N	2	\N	\N	f	\N
37	1	tx_0dc2a58d73bb5eb90d067863	\N	2026-10-25	Hardware Store	HARDWARE STORE BOSTON	shopping	1765	\N	2	\N	\N	f	\N
38	1	tx_72cae417b514c8e760e4a36e	\N	2026-10-26	Fresh Market	FRESH MARKET SEATTLE	\N	9229	\N	2	\N	\N	f	\N
39	1	tx_5f7f68621b5125d93fbb3b43	\N	2026-10-26	Fresh Market	FRESH MARKET NEW YORK	\N	6986	\N	2	\N	\N	f	\N
40	1	tx_ab6c6983e210ffb03d68c4d9	\N	2026-10-28	Cloud Storage Inc	CLOUD STORAGE INC BOSTON	\N	620	\N	2	\N	\N	f	\N
41	1	tx_e7f438f672e29eeafca2de2c	\N	2026-10-30	Hardware Store	HARDWARE STORE BOSTON	\N	2574	\N	2	\N	\N	f	\N
42	1	tx_d90e2db6d5bc63aabdcd6e15	\N	2026-11-01	Hardware Store	HARDWARE STORE NEW YORK	\N	1853	\N	2	\N	\N	f	\N
43	1	tx_fafcde8c2c6c79661931f311	\N	2026-11-02	Noodle House	NOODLE HOUSE SEATTLE	\N	3334	\N	2	\N	\N	f	\N
44	1	tx_ffae34fa3fd38abf34e1e048	\N	2026-11-03	Metro Transit	METRO TRANSIT NEW YORK	transportation	2817	\N	2	\N	\N	f	\N
45	1	tx_87d10a885bbbc6a1865a48a6	\N	2026-11-03	Cinema Lux	CINEMA LUX BOSTON	\N	2492	\N	2	\N	\N	f	\N
46	1	tx_72ba9f300a8d50aec4d86b02	\N	2026-11-04	Cinema Lux	CINEMA LUX NEW YORK	\N	2737	\N	2	\N	\N	f	\N
47	1	tx_56220871f2b7dd45d6970168	\N	2026-11-05	Daily Bakery	DAILY BAKERY BOSTON	\N	1179	\N	2	\N	\N	f	\N
48	1	tx_0471e7a1e36449b87222ebd5	\N	2026-11-05	Corner Grocery	CORNER GROCERY ONLINE	\N	1355	\N	2	\N	\N	f	\N
49	1	tx_cd0858bbb71c890bc3bd860e	\N	2026-11-06	Online Marketplace	ONLINE MARKETPLACE ONLINE	\N	4901	\N	2	\N	\N	f	\N
50	1	tx_7d5893bab5d8e585e29d66ee	\N	2026-11-07	Rail Express	RAIL EXPRESS ONLINE	transportation	8819	\N	2	\N	\N	f	\N
51	1	tx_7e000738eee0a87fcaf7ae62	\N	2026-11-09	Harbor Hotel	HARBOR HOTEL BOSTON	\N	15879	\N	2	\N	\N	f	\N
52	1	tx_a8086bdbef3d3574e0baaf7d	\N	2026-11-10	Hardware Store	HARDWARE STORE NEW YORK	\N	4116	\N	2	\N	\N	f	\N
53	1	tx_5b8c561cf17364ff975f1312	\N	2026-11-10	Blue Door Bistro	BLUE DOOR BISTRO SEATTLE	\N	5035	\N	2	\N	\N	f	\N
54	1	tx_1fc38638cfb5a9865883b85d	\N	2026-11-12	Corner Grocery	CORNER GROCERY ONLINE	\N	5045	\N	1	\N	\N	f	\N
55	1	tx_c68bf81b83198928d2a52200	\N	2026-11-12	Corner Grocery	CORNER GROCERY NEW YORK	\N	4792	\N	1	\N	\N	f	\N
56	1	tx_8a3d819a655360f825223388	\N	2026-11-13	Daily Bakery	DAILY BAKERY NEW YORK	\N	938	\N	1	\N	\N	f	\N
57	2	tx_8de85ffd9e4ba298b7ded803	\N	2026-09-13	Corner Grocery	CORNER GROCERY NEW YORK	\N	5353	4605	3	3	13	f	\N
58	2	tx_14dded165a36d8eadd2e1f8e	\N	2026-09-14	Metro Transit	METRO TRANSIT ONLINE	\N	2921	2525	3	3	18	f	\N
59	2	tx_09acb141e7201f9b0032e7f4	\N	2026-09-16	Noodle House	NOODLE HOUSE BOSTON	dining	3659	3179	3	3	22	f	\N
60	2	tx_7cdaa4790a7a0bd93ddcc78c	\N	2026-09-20	Cinema Lux	CINEMA LUX ONLINE	entertainment	2210	1918	3	3	18	f	\N
61	2	tx_b28e108383dee5840431c229	\N	2026-09-21	Daily Bakery	DAILY BAKERY SEATTLE	\N	695	601	3	3	4	f	\N
62	2	tx_c9f862269e3bfc77dd46005f	\N	2026-09-23	Metro Transit	METRO TRANSIT SEATTLE	transportation	2562	2209	3	3	5	f	\N
63	2	tx_d909f105a27d25aa6d144d54	\N	2026-09-30	Daily Bakery	DAILY BAKERY SEATTLE	\N	1082	944	3	3	7	f	\N
64	2	tx_28152b6ce5df88827d423f50	\N	2026-09-30	Blue Door Bistro	BLUE DOOR BISTRO ONLINE	\N	4386	3827	3	3	27	f	\N
65	2	tx_7baeb3e87bcef593f267042c	\N	2026-10-02	Metro Transit	METRO TRANSIT ONLINE	\N	729	\N	2	\N	\N	f	\N
66	2	tx_f5d36c49860b95c40ccdd072	\N	2026-10-04	Book Nook	BOOK NOOK SEATTLE	\N	1585	\N	2	\N	\N	f	\N
67	2	tx_960c71eec70ed1766f3243c3	\N	2026-10-12	Coffee Roasters	COFFEE ROASTERS NEW YORK	\N	651	\N	2	\N	\N	f	\N
68	2	tx_0d3fdf2361d0b9110ede8ed6	\N	2026-10-13	Fresh Market	FRESH MARKET NEW YORK	groceries	9291	\N	2	\N	\N	f	\N
69	2	tx_cc2f87de904c59ebdc5a820f	\N	2026-10-13	Online Marketplace	ONLINE MARKETPLACE ONLINE	general	3765	\N	2	\N	\N	f	\N
70	2	tx_0c5f4bee792ed964163ca1f6	\N	2026-10-15	Corner Grocery	CORNER GROCERY BOSTON	groceries	4013	\N	2	\N	\N	f	\N
71	2	tx_2811f59f2fdc01c150b4609f	\N	2026-10-26	Coffee Roasters	COFFEE ROASTERS SEATTLE	\N	638	\N	2	\N	\N	f	\N
72	2	tx_015099df5fd05cbac04d495a	\N	2026-10-28	Daily Bakery	DAILY BAKERY ONLINE	\N	949	\N	2	\N	\N	f	\N
73	2	tx_9ecdf97df16d56686da4423f	\N	2026-11-05	Fresh Market	FRESH MARKET ONLINE	groceries	2062	\N	2	\N	\N	f	\N
74	2	tx_c44fde85c624efd315866331	\N	2026-11-05	Coffee Roasters	COFFEE ROASTERS ONLINE	\N	710	\N	2	\N	\N	f	\N
75	2	tx_208c622c0d326812c9921b7a	\N	2026-11-09	Online Marketplace	ONLINE MARKETPLACE NEW YORK	\N	5304	\N	2	\N	\N	f	\N
76	3	tx_063c6d3f6fec11ae467af61e	\N	2026-09-10	Book Nook	BOOK NOOK SEATTLE	\N	2031	1756	3	5	11	f	\N
77	3	tx_ba18a133f635e7225664d885	\N	2026-09-21	Coffee Roasters	COFFEE ROASTERS NEW YORK	\N	502	434	3	5	1	f	\N
78	3	tx_6777c2dc66bd69acf0d57cdb	\N	2026-09-24	Metro Transit	METRO TRANSIT NEW YORK	\N	2005	1735	3	5	8	f	\N
79	3	tx_c4937555478abc27316c3b8e	\N	2026-09-30	Hardware Store	HARDWARE STORE BOSTON	\N	2708	2363	3	5	16	f	\N
80	3	tx_cecf2bc1eace15e39527aae8	\N	2026-09-30	Corner Grocery	CORNER GROCERY SEATTLE	\N	4561	3980	3	5	15	f	\N
81	3	tx_5cbcbf54db29bd37f7f079a9	\N	2026-10-02	Online Marketplace	ONLINE MARKETPLACE BOSTON	\N	10429	\N	2	\N	\N	f	\N
82	3	tx_4387b85164e1b478417fcd18	\N	2026-10-10	Metro Transit	METRO TRANSIT ONLINE	transportation	3620	\N	2	\N	\N	f	\N
83	3	tx_a1892c3ce2a9f0b7764a0f64	\N	2026-10-12	Corner Grocery	CORNER GROCERY BOSTON	groceries	3814	\N	2	\N	\N	f	\N
84	3	tx_ce99aaad172492f010163309	\N	2026-10-22	Noodle House	NOODLE HOUSE SEATTLE	dining	3241	\N	2	\N	\N	f	\N
85	3	tx_b0a127a8853fb08958ef481b	\N	2026-10-29	Coffee Roasters	COFFEE ROASTERS ONLINE	\N	1082	\N	2	\N	\N	f	\N
86	3	tx_ca6f2d0f9193412e547448bf	\N	2026-10-30	Daily Bakery	DAILY BAKERY ONLINE	dining	1004	\N	2	\N	\N	f	\N
87	3	tx_4242ac5243e54fbded270872	\N	2026-11-01	Online Marketplace	ONLINE MARKETPLACE ONLINE	general	3401	\N	2	\N	\N	f	\N
88	3	tx_2aa2d7be40d424b4f8525d96	\N	2026-11-02	Hardware Store	HARDWARE STORE ONLINE	shopping	4548	\N	2	\N	\N	f	\N
89	3	tx_3dad7eae8e055ac01ae3590d	\N	2026-11-10	Corner Grocery	CORNER GROCERY BOSTON	\N	3060	\N	2	\N	\N	f	\N
90	3	tx_eeb97dfca632e8e249a8ea35	\N	2026-11-11	Metro Transit	METRO TRANSIT NEW YORK	\N	2002	\N	2	\N	\N	f	\N
91	4	tx_068ce8a251c2f5ecb40aa9cb	\N	2026-09-11	Noodle House	NOODLE HOUSE SEATTLE	\N	2789	2407	3	7	24	f	\N
92	4	tx_2a634f26c433fd37e1ae1373	\N	2026-09-29	Fresh Market	FRESH MARKET NEW YORK	\N	4101	3563	3	7	26	f	\N
93	4	tx_53f7b2808343c926f01fa8a8	\N	2026-10-03	Online Marketplace	ONLINE MARKETPLACE BOSTON	\N	5609	\N	2	\N	\N	f	\N
94	4	tx_8fbc2d938d1b561c5e395ba9	\N	2026-10-03	Corner Grocery	CORNER GROCERY SEATTLE	groceries	4572	\N	2	\N	\N	f	\N
95	4	tx_59e671df5eafe2f34cf8fdb8	\N	2026-10-05	Cloud Storage Inc	CLOUD STORAGE INC ONLINE	\N	689	\N	2	\N	\N	f	\N
96	4	tx_6cab16df50d3f95644d4a00f	\N	2026-10-07	Cinema Lux	CINEMA LUX SEATTLE	\N	1320	\N	2	\N	\N	f	\N
97	4	tx_f8b8dd8ceb26020030fc9c27	\N	2026-10-09	Corner Grocery	CORNER GROCERY NEW YORK	groceries	5318	\N	2	\N	\N	f	\N
98	4	tx_a593f557767e8e00c222d957	\N	2026-10-11	Fresh Market	FRESH MARKET BOSTON	\N	5474	\N	2	\N	\N	f	\N
99	4	tx_90fb2b4e923c12696b81ea70	\N	2026-10-19	Daily Bakery	DAILY BAKERY ONLINE	\N	898	\N	2	\N	\N	f	\N
100	4	tx_beb167af13936212a002d513	\N	2026-10-24	Noodle House	NOODLE HOUSE NEW YORK	dining	2590	\N	2	\N	\N	f	\N
101	4	tx_ea7ef2fe39c0306c500d9665	\N	2026-10-24	Noodle House	NOODLE HOUSE ONLINE	dining	2884	\N	2	\N	\N	f	\N
102	4	tx_19266d8c87efb0e91c362fe0	\N	2026-11-01	Corner Grocery	CORNER GROCERY ONLINE	\N	3595	\N	2	\N	\N	f	\N
103	4	tx_50ce3ed03e5f25b6506afa0f	\N	2026-11-02	Cinema Lux	CINEMA LUX ONLINE	\N	1713	\N	2	\N	\N	f	\N
104	4	tx_c7d5bd487131f5252fa1fd18	\N	2026-11-04	Corner Grocery	CORNER GROCERY BOSTON	\N	1827	\N	2	\N	\N	f	\N
105	4	tx_90393f38caccd19dc2e25a36	\N	2026-11-05	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	3742	\N	2	\N	\N	f	\N
106	4	tx_c54e26b6685869f6cf269d6c	\N	2026-11-08	Daily Bakery	DAILY BAKERY SEATTLE	\N	679	\N	2	\N	\N	f	\N
107	4	tx_0d456e3a4e96b9e365f3b7d3	\N	2026-11-12	Rail Express	RAIL EXPRESS SEATTLE	transportation	5601	\N	1	\N	\N	f	\N
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."user" (id, name, super_user, actual_sync_id, actual_encryption_password, actual_misc_account) FROM stdin;
1	alice	t	\N	\N	\N
2	bob	f	\N	\N	\N
\.


--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.account_id_seq', 4, true);


--
-- Name: bankaccount_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bankaccount_id_seq', 2, true);


--
-- Name: credit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.credit_id_seq', 4, true);


--
-- Name: exchange_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.exchange_id_seq', 2, true);


--
-- Name: payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payment_id_seq', 8, true);


--
-- Name: plaidaccount_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plaidaccount_id_seq', 5, true);


--
-- Name: plaidconnection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plaidconnection_id_seq', 5, true);


--
-- Name: transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transaction_id_seq', 107, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_id_seq', 2, true);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: bankaccount bankaccount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bankaccount
    ADD CONSTRAINT bankaccount_pkey PRIMARY KEY (id);


--
-- Name: credit credit_import_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit
    ADD CONSTRAINT credit_import_id_key UNIQUE (import_id);


--
-- Name: credit credit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit
    ADD CONSTRAINT credit_pkey PRIMARY KEY (id);


--
-- Name: credittransaction credittransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credittransaction
    ADD CONSTRAINT credittransaction_pkey PRIMARY KEY (credit_id, transaction_id);


--
-- Name: exchange exchange_actual_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange
    ADD CONSTRAINT exchange_actual_id_key UNIQUE (actual_id);


--
-- Name: exchange exchange_import_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange
    ADD CONSTRAINT exchange_import_id_key UNIQUE (import_id);


--
-- Name: exchange exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange
    ADD CONSTRAINT exchange_pkey PRIMARY KEY (id);


--
-- Name: exchangepayment exchangepayment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchangepayment
    ADD CONSTRAINT exchangepayment_pkey PRIMARY KEY (exchange_id, payment_id);


--
-- Name: exchangerate exchangerate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchangerate
    ADD CONSTRAINT exchangerate_pkey PRIMARY KEY (date, source);


--
-- Name: payment payment_import_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_import_id_key UNIQUE (import_id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: plaidaccount plaidaccount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plaidaccount
    ADD CONSTRAINT plaidaccount_pkey PRIMARY KEY (id);


--
-- Name: plaidaccount plaidaccount_plaid_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plaidaccount
    ADD CONSTRAINT plaidaccount_plaid_account_id_key UNIQUE (plaid_account_id);


--
-- Name: plaidconnection plaidconnection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plaidconnection
    ADD CONSTRAINT plaidconnection_pkey PRIMARY KEY (id);


--
-- Name: transaction transaction_import_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_import_id_key UNIQUE (import_id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: exchange uq_exchange_cashback_transaction_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange
    ADD CONSTRAINT uq_exchange_cashback_transaction_id UNIQUE (cashback_transaction_id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: account account_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bankaccount(id) ON DELETE SET NULL;


--
-- Name: account account_plaid_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_plaid_account_id_fkey FOREIGN KEY (plaid_account_id) REFERENCES public.plaidaccount(id) ON DELETE SET NULL;


--
-- Name: account account_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: bankaccount bankaccount_plaid_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bankaccount
    ADD CONSTRAINT bankaccount_plaid_account_id_fkey FOREIGN KEY (plaid_account_id) REFERENCES public.plaidaccount(id) ON DELETE SET NULL;


--
-- Name: bankaccount bankaccount_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bankaccount
    ADD CONSTRAINT bankaccount_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: credit credit_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit
    ADD CONSTRAINT credit_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: credittransaction credittransaction_credit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credittransaction
    ADD CONSTRAINT credittransaction_credit_id_fkey FOREIGN KEY (credit_id) REFERENCES public.credit(id);


--
-- Name: credittransaction credittransaction_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credittransaction
    ADD CONSTRAINT credittransaction_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transaction(id);


--
-- Name: exchangepayment exchangepayment_exchange_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchangepayment
    ADD CONSTRAINT exchangepayment_exchange_id_fkey FOREIGN KEY (exchange_id) REFERENCES public.exchange(id);


--
-- Name: exchangepayment exchangepayment_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchangepayment
    ADD CONSTRAINT exchangepayment_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payment(id);


--
-- Name: exchange fk_exchange_cashback_transaction; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange
    ADD CONSTRAINT fk_exchange_cashback_transaction FOREIGN KEY (cashback_transaction_id) REFERENCES public.transaction(id);


--
-- Name: payment payment_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: plaidaccount plaidaccount_connection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plaidaccount
    ADD CONSTRAINT plaidaccount_connection_id_fkey FOREIGN KEY (connection_id) REFERENCES public.plaidconnection(id);


--
-- Name: plaidconnection plaidconnection_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plaidconnection
    ADD CONSTRAINT plaidconnection_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: transaction transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: transaction transaction_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payment(id);


--
-- PostgreSQL database dump complete
--


