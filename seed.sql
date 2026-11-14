-- Pseudonymized, reduced copy of the production database for local development
-- (users alice, bob, carol). Load it with `make db` / `make db-reset`.

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
ALTER TABLE ONLY public.account ALTER COLUMN id SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN actual_id SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN import_id SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN name SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN institution SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN due_day SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN autopay_offset SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN color SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN target_spend SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN user_id SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN bank_account_id SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN plaid_account_id SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN active SET (pg_attver=23670048);
ALTER TABLE ONLY public.account ALTER COLUMN issuer SET (pg_attver=23670048);


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
ALTER TABLE ONLY public.alembic_version ALTER COLUMN version_num SET (pg_attver=23692128);


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
ALTER TABLE ONLY public.bankaccount ALTER COLUMN id SET (pg_attver=23696592);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN name SET (pg_attver=23696592);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN institution SET (pg_attver=23696592);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN balance SET (pg_attver=23696592);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN import_id SET (pg_attver=23696592);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN user_id SET (pg_attver=23696592);
ALTER TABLE ONLY public.bankaccount ALTER COLUMN plaid_account_id SET (pg_attver=23696592);


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
ALTER TABLE ONLY public.credit ALTER COLUMN id SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN account_id SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN import_id SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN date SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN counterparty SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN description SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN category SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN amount_usd SET (pg_attver=23714936);
ALTER TABLE ONLY public.credit ALTER COLUMN posted_date SET (pg_attver=23714936);


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
ALTER TABLE ONLY public.credittransaction ALTER COLUMN credit_id SET (pg_attver=23745320);
ALTER TABLE ONLY public.credittransaction ALTER COLUMN transaction_id SET (pg_attver=23745320);
ALTER TABLE ONLY public.credittransaction ALTER COLUMN amount SET (pg_attver=23745320);


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
ALTER TABLE ONLY public.exchange ALTER COLUMN id SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN actual_id SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN date SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN amount_usd SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN paid_eur SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN exchange_rate SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN amount_eur SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN fees_eur SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN import_id SET (pg_attver=23751040);
ALTER TABLE ONLY public.exchange ALTER COLUMN cashback_transaction_id SET (pg_attver=23751040);


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
ALTER TABLE ONLY public.exchangepayment ALTER COLUMN exchange_id SET (pg_attver=23772088);
ALTER TABLE ONLY public.exchangepayment ALTER COLUMN payment_id SET (pg_attver=23772088);
ALTER TABLE ONLY public.exchangepayment ALTER COLUMN amount SET (pg_attver=23772088);


--
-- Name: exchangerate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchangerate (
    date date NOT NULL,
    source integer NOT NULL,
    exchange_rate numeric(10,8) NOT NULL
);
ALTER TABLE ONLY public.exchangerate ALTER COLUMN date SET (pg_attver=23777712);
ALTER TABLE ONLY public.exchangerate ALTER COLUMN source SET (pg_attver=23777712);
ALTER TABLE ONLY public.exchangerate ALTER COLUMN exchange_rate SET (pg_attver=23777712);


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
ALTER TABLE ONLY public.payment ALTER COLUMN id SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN account_id SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN import_id SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN actual_id SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN date SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN counterparty SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN description SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN category SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN amount_usd SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN amount_eur SET (pg_attver=23783440);
ALTER TABLE ONLY public.payment ALTER COLUMN status SET (pg_attver=23783440);


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
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN id SET (pg_attver=23804944);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN name SET (pg_attver=23804944);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN plaid_account_id SET (pg_attver=23804944);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN connection_id SET (pg_attver=23804944);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN cursor SET (pg_attver=23804944);
ALTER TABLE ONLY public.plaidaccount ALTER COLUMN last_successful_update SET (pg_attver=23804944);


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
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN id SET (pg_attver=23823784);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN user_id SET (pg_attver=23823784);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN name SET (pg_attver=23823784);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN plaid_item_id SET (pg_attver=23823784);
ALTER TABLE ONLY public.plaidconnection ALTER COLUMN plaid_access_token SET (pg_attver=23823784);


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
ALTER TABLE ONLY public.transaction ALTER COLUMN id SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN account_id SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN import_id SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN actual_id SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN date SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN counterparty SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN description SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN category SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN amount_usd SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN amount_eur SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN status SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN payment_id SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN fees_and_risk_eur SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN ignore SET (pg_attver=23849400);
ALTER TABLE ONLY public.transaction ALTER COLUMN posted_date SET (pg_attver=23849400);


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
ALTER TABLE ONLY public."user" ALTER COLUMN id SET (pg_attver=23886704);
ALTER TABLE ONLY public."user" ALTER COLUMN name SET (pg_attver=23886704);
ALTER TABLE ONLY public."user" ALTER COLUMN super_user SET (pg_attver=23886704);
ALTER TABLE ONLY public."user" ALTER COLUMN actual_sync_id SET (pg_attver=23886704);
ALTER TABLE ONLY public."user" ALTER COLUMN actual_encryption_password SET (pg_attver=23886704);
ALTER TABLE ONLY public."user" ALTER COLUMN actual_misc_account SET (pg_attver=23886704);


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
3	b588b00e-5310-46f1-fafc-a357dbebd76c	acct_e260746aa4b73deb1351da3c	Delta SkyMiles® Blue	American Express	4	10	#86B556	\N	2	2	6	t	amex
5	d2e5d438-5490-f992-5634-48e32b28f9e1	\N	Hilton Honors	American Express	1	10	#d0d0d0	\N	1	1	10	t	amex
2	aae0f5f3-8623-e7cb-2a8f-4ecb78a1d860	acct_4178aa5024ee5c053a3af0ae	Delta SkyMiles® Blue	American Express	3	10	#cdb761	\N	1	1	\N	f	amex
8	a5ea753a-3f15-3791-86d1-8cf82e995110	\N	Venture	Capital One	12	0	#00264d	\N	1	1	22	t	capital_one
1	7e47740e-73b5-3791-e5f8-9487fe7cc8a8	acct_df63acac8e713f8e47cab3ea	Savor	Capital One	2	0	#983d2e	\N	1	1	3	t	capital_one
4	\N	acct_b11ee75694be40895a723f59	Platinum Secured	Capital One	3	0	#9da4e3	\N	3	3	\N	f	capital_one
6	fedb3ccb-1fe5-ea43-aac0-e82fe1cfaaff	\N	Marriott Bonvoy Boundless	Chase	5	\N	#ff8d6b	\N	1	1	20	t	chase
7	7965bce5-fcc7-aa27-8b9d-f5cb781822fc	\N	Sapphire Preferred	Chase	1	0	#43a6d1	\N	1	1	21	t	chase
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
2	Checking	Example Credit Union	3335	\N	2	18
1	Checking	Example Credit Union	163188	acct_22224ba5464c1f32e0980c4c	1	16
3	Checking	Example Bank	5013	\N	3	9
\.


--
-- Data for Name: credit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit (id, account_id, import_id, date, counterparty, description, category, amount_usd, posted_date) FROM stdin;
45	5	cr_12f2d7b1e41e58a28a38230d	2026-06-27	Book Nook	Credit BOOK NOOK ONLINE	\N	1227	\N
42	4	cr_97f19e92091abc39eae77215	2026-04-08	Home Supply	Credit HOME SUPPLY HAMBURG	\N	120	\N
39	4	cr_487fcd801d180ac45a764f14	2026-03-09	Home Supply	Credit HOME SUPPLY HAMBURG	\N	120	\N
36	4	cr_2d65dc0728e72b7d82ca7a67	2026-02-06	Home Supply	Credit HOME SUPPLY HAMBURG	\N	109	\N
35	4	cr_39ef87eb46de6f2f1bcc9911	2026-01-09	Home Supply	Credit HOME SUPPLY HAMBURG	\N	101	\N
30	4	cr_8e200d1a02a5a3bc6b789137	2025-12-09	Home Supply	Credit HOME SUPPLY HAMBURG	\N	109	\N
15	4	cr_b36f49e6dd7909d7c492e223	2025-08-09	Home Supply	Credit HOME SUPPLY HAMBURG	\N	84	\N
52	8	cr_9593096947aab16142c9e027	2026-10-27	Outdoor Gear Co	Credit OUTDOOR GEAR CO BERLIN	\N	1994	\N
50	7	cr_a7efbc40aba63305b01a1cea	2026-07-30	Stream Plus	Credit STREAM PLUS HAMBURG	\N	429	\N
49	7	cr_7dcc1d15a9a8318695e9e5af	2026-06-29	Stream Plus	Credit STREAM PLUS HAMBURG	\N	204	\N
48	7	cr_7d41b9bae0b9b9ec235bd145	2026-08-12	Gym Central	Credit GYM CENTRAL ONLINE	\N	374	\N
43	1	cr_dcb889f916f9049673c5ebd0	2026-04-24	Yoga Studio	Credit YOGA STUDIO NEW YORK	\N	2	\N
47	6	cr_a5740e1891a8d3bd7971db38	2026-07-19	Garden Center	Credit GARDEN CENTER NEW YORK	\N	7495	\N
46	6	cr_a197ee999db0bdb814938c16	2026-06-26	Garden Center	Credit GARDEN CENTER NEW YORK	\N	3755	\N
20	4	cr_07e9aca0a00be96ea4f1295d	2025-10-01	Hardware Store	Credit HARDWARE STORE HAMBURG	\N	5983	\N
53	8	cr_a036359d26f7b21830393a83	2026-10-28	Print Shop	Credit PRINT SHOP BERLIN	\N	13140	\N
51	8	cr_e4ffb8e129b968d90e8b2f6a	2026-10-22	Print Shop	Credit PRINT SHOP BERLIN	\N	32062	\N
44	7	cr_ca7eb286195987ad1c1f4b04	2026-06-15	Print Shop	Credit PRINT SHOP BERLIN	\N	7254	\N
\.


--
-- Data for Name: credittransaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credittransaction (credit_id, transaction_id, amount) FROM stdin;
15	548	84
47	1338	7495
20	663	94
20	828	5493
30	830	109
36	936	109
20	601	302
44	1353	7254
48	1587	374
20	741	94
35	888	101
39	1018	120
42	1145	120
43	1225	2
49	1506	204
46	1471	3755
45	1443	1227
50	1603	429
53	1756	13140
51	1753	32062
52	1709	1994
\.


--
-- Data for Name: exchange; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exchange (id, actual_id, date, amount_usd, paid_eur, exchange_rate, amount_eur, fees_eur, import_id, cashback_transaction_id) FROM stdin;
39	\N	2026-10-10	20458	0	0.00000000	0	0	\N	1735
40	\N	2026-10-10	13589	0	0.00000000	0	0	\N	1734
41	\N	2026-09-16	17218	0	0.00000000	0	0	\N	1685
42	\N	2026-09-10	9183	0	0.00000000	0	0	\N	1670
31	\N	2026-04-10	92330	79139	1.17113000	78838	301	\N	\N
32	\N	2026-05-11	118960	101289	1.17795000	100989	300	\N	\N
33	\N	2026-06-15	314370	271079	1.16099000	270778	301	\N	\N
34	\N	2026-07-14	186506	163824	1.14054000	163524	300	\N	\N
35	\N	2026-07-21	121800	106926	1.14231000	106626	300	\N	\N
36	\N	2026-08-16	162056	140200	1.15837000	139900	300	\N	\N
37	\N	2026-09-16	57398	50005	1.15477000	49705	300	\N	\N
38	\N	2026-10-08	147840	132228	1.11810000	132224	4	\N	\N
43	\N	2026-11-02	404460	361515	1.11972000	361215	300	\N	\N
\.


--
-- Data for Name: exchangepayment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exchangepayment (exchange_id, payment_id, amount) FROM stdin;
31	133	92330
32	133	3127
32	149	19932
34	157	136243
34	164	30089
36	164	30805
36	181	11363
42	181	9183
41	181	17218
38	181	102
32	137	143
32	134	6318
32	138	3786
32	146	3758
33	145	26431
33	144	89
36	165	165
32	135	39092
32	141	41638
32	148	1166
34	162	2382
33	149	133105
33	154	129
34	158	166
33	150	8656
34	156	17626
33	157	145960
35	164	121800
36	161	4968
36	166	51302
36	169	199
36	174	37768
36	170	25486
38	176	159
38	183	1128
37	181	57398
\.


--
-- Data for Name: exchangerate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exchangerate (date, source, exchange_rate) FROM stdin;
2026-04-25	2	1.17209930
2026-04-27	2	1.17559930
2026-04-29	2	1.17219960
2026-05-01	2	1.17369930
2026-05-03	2	1.17859900
2026-05-02	2	1.17859900
2026-05-04	2	1.17599880
2026-05-06	2	1.17979900
2026-05-07	2	1.17789930
2026-05-08	2	1.17879910
2026-05-09	2	1.17879910
2026-05-11	2	1.17929950
2026-05-12	2	1.17909930
2026-05-13	2	1.17479960
2026-05-15	2	1.17239890
2026-05-14	2	1.17239890
2026-05-16	2	1.16829940
2026-05-18	2	1.16579870
2026-05-19	2	1.16649910
2026-05-20	2	1.16469890
2026-05-21	2	1.16369870
2026-05-22	2	1.16319920
2026-05-23	2	1.16319920
2026-05-24	2	1.16319920
2026-05-26	2	1.16469890
2026-05-28	2	1.16629910
2026-05-29	2	1.16889890
2026-05-30	2	1.16889890
2026-05-31	2	1.16889890
2026-06-01	2	1.16889890
2026-06-02	2	1.16559900
2026-06-03	2	1.16419990
2026-06-05	2	1.16449950
2026-06-04	2	1.16459990
2026-06-06	2	1.16449950
2026-06-07	2	1.16449950
2026-06-08	2	1.15559910
2026-06-09	2	1.15789920
2026-06-10	2	1.15739940
2026-06-11	2	1.15609880
2026-06-12	2	1.15919990
2026-06-13	2	1.15919990
2026-06-14	2	1.15919990
2026-06-15	2	1.16229870
2026-06-16	2	1.16199890
2026-06-17	2	1.16209880
2026-06-19	2	1.14769980
2026-06-20	2	1.14769980
2026-06-21	2	1.14769980
2026-06-22	2	1.14809900
2026-06-23	2	1.14409930
2026-06-24	2	1.13859940
2026-06-25	2	1.13889900
2026-06-26	2	1.14359950
2026-06-27	2	1.14359950
2026-06-28	2	1.14359950
2026-06-29	2	1.14259990
2026-07-04	2	1.14639980
2026-07-03	2	1.14639980
2026-07-01	2	1.14289890
2026-07-05	2	1.14639980
2026-07-06	2	1.14459960
2026-07-07	2	1.14499930
2026-07-09	2	1.14509890
2026-07-10	2	1.14619880
2026-07-11	2	1.14619880
2026-07-13	2	1.14469910
2026-07-17	2	1.14539930
2026-07-19	2	1.14539930
2026-07-21	2	1.14299950
2026-07-22	2	1.14229970
2026-07-23	2	1.14229970
2026-07-24	2	1.14379960
2026-07-25	2	1.14019890
2026-07-27	2	1.14199970
2026-07-26	2	1.14019890
2026-07-28	2	1.14029900
2026-07-29	2	1.14059940
2026-07-30	2	1.15379910
2026-08-01	2	1.15369930
2026-08-02	2	1.15369930
2026-08-04	2	1.15319900
2026-08-07	2	1.15819960
2026-08-09	2	1.15819960
2026-08-10	2	1.15819960
2026-08-11	2	1.15549900
2026-08-13	2	1.15459980
2026-08-14	2	1.15869890
2026-08-15	2	1.15869890
2026-08-17	2	1.16159940
2026-08-18	2	1.15949960
2026-08-21	2	1.17119880
2026-08-22	2	1.17119880
2026-08-25	2	1.16769910
2026-08-26	2	1.16809880
2026-08-27	2	1.16609920
2026-08-28	2	1.16609920
2026-08-31	2	1.16219880
2026-09-01	2	1.16259870
2026-09-03	2	1.16329930
2026-09-02	2	1.16099920
2026-09-04	2	1.16439920
2026-09-05	2	1.16439920
2026-09-07	2	1.16379890
2026-09-10	2	1.16549980
2026-09-09	2	1.16549980
2026-09-11	2	1.16299900
2026-09-12	2	1.16299900
2026-09-14	2	1.16039970
2026-09-16	2	1.15579950
2026-09-17	2	1.15489980
2026-09-18	2	1.14939890
2026-09-19	2	1.14939890
2026-09-21	2	1.14969880
2026-09-22	2	1.14809900
2026-09-24	2	1.14000000
2026-09-26	2	1.14119950
2026-09-28	2	1.13929990
2026-09-29	2	1.13889900
2026-09-30	2	1.13819900
2026-10-01	2	1.13449940
2026-10-03	2	1.12869870
2026-10-05	2	1.12699930
2026-10-07	2	1.12689900
2026-10-08	2	1.12279950
2026-10-10	2	1.12439900
2026-10-09	2	1.12439900
2026-10-12	2	1.12189880
2026-10-13	2	1.12059880
2026-10-14	2	1.12130000
2026-10-15	2	1.12429910
2026-10-16	2	1.12699930
2026-10-17	2	1.12699930
2026-10-19	2	1.12369900
2026-10-20	2	1.12619970
2026-10-21	2	1.12429910
2026-10-22	2	1.12569890
2026-10-23	2	1.12319920
2026-10-24	2	1.12319920
2026-10-28	2	1.11449920
2026-10-27	2	1.11959890
2026-10-26	2	1.12289910
2026-10-30	2	1.12159930
2026-11-01	2	1.12159930
2026-10-31	2	1.12159930
2026-11-02	2	1.12379880
2026-11-03	2	1.12099960
2026-11-05	2	1.12699930
2026-11-06	2	1.12459880
2026-11-07	2	1.12459880
2026-11-09	2	1.12059880
2026-11-10	2	1.12059880
2026-11-11	2	1.11719990
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment (id, account_id, import_id, actual_id, date, counterparty, description, category, amount_usd, amount_eur, status) FROM stdin;
180	6	\N	\N	2026-11-05	Chase	Upcoming Payment	\N	0	\N	1
137	4	pay_edf84f143fd9776c046fc342	b48abf4c-30b2-f9e2-a993-9de106048794	2026-06-03	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	143	121	3
126	1	pay_0e4056d80fdd243969b3100b	daa4d11d-5a12-9c9d-414c-7f2482302ca7	2026-05-02	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	14876	13004	3
134	5	pay_a202611bd12cce77eff377f9	8ee8bf28-4980-d5fd-96bc-d317051d89ea	2026-05-22	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	6318	5364	3
133	6	pay_fa63a27511d40a64c5a96a98	e925d68e-ceb4-0f62-8744-83c6aa50617c	2026-05-05	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	446283	388180	3
138	3	pay_90cf7c0dbdc19f341f9cd8a4	eaa73f71-1310-1a40-97b7-44e9ec52fa36	2026-05-25	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	3786	3214	3
146	3	pay_d70e6dead6f0f5afdb20aa73	f042540d-2a2b-1515-6c3c-78394fa009a7	2026-06-24	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	3758	3191	3
145	1	pay_df22f86d514793c817ef5f48	29350781-4633-296f-3493-8a696e293b0d	2026-07-02	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	26431	22766	3
144	4	pay_7c8e38e541321e56832f35b5	5ead3d57-d715-b375-104d-88052291f8f8	2026-07-03	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	89	76	3
165	4	pay_3ee97f1466ac31c428eeae12	3e11299e-b535-77d5-ded5-fe82a69704d9	2026-09-03	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	165	142	3
135	1	pay_444340212c5251ddcd3589f6	dda13041-6781-d84c-0807-d8b41e89230f	2026-06-02	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	39092	33187	3
141	6	pay_7b929d73d387d6f1f47afc60	d8256669-b912-15c9-5081-5800bae146f8	2026-06-05	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	41638	35348	3
178	1	pay_0dde96d2d421c0a846c88c6e	\N	2026-11-02	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	66	\N	2
148	5	pay_3edaf98652d8c1b8bc12b604	d78216cf-5492-c7f9-acc3-4681ba0a4d89	2026-06-20	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	1166	990	3
162	3	pay_4d71a60668eb8719714bbbe8	9096bf3e-edca-944f-ed5d-a80524748eb7	2026-08-25	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	2382	2088	3
149	7	pay_ce0cb64bc42e710b0ea00ff5	596820f7-6cbf-bcd7-7902-f352b9a1fb68	2026-07-01	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	153037	131569	3
154	4	pay_5e6722e981c047f647935f6c	8e533337-85d0-75a1-9770-7dc280a647cc	2026-07-12	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	129	111	3
158	1	pay_c1022877628f209c75d12116	458721fd-b92c-f69f-58d0-036767c54ce8	2026-08-03	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	166	146	3
150	6	pay_4c5274567c9b1d3ed092ea55	88eaaae5-c4d5-c0ac-38d9-08d8e147b8f4	2026-07-05	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	8656	7455	3
156	6	pay_9e73f387410d04d5556d2a1e	893d4bcc-7df4-a05a-e830-c87f033a667f	2026-08-05	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	17626	15454	3
157	7	pay_be8ab64d13d8364d9334285c	aa2518b2-e8c0-1aa4-a299-87678b531e7f	2026-07-31	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	282203	245175	3
164	7	pay_004758d66df4f5047e0b9cbd	ca240588-704a-9efa-407a-63174f593a18	2026-09-01	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	182694	159601	3
161	1	pay_5aab146d7ffbe98aa75df225	acfca5ee-aad9-f1dc-8b10-70a919eedc39	2026-09-02	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	4968	4289	3
177	7	pay_97c6b2b66fd02c439a3edf80	\N	2026-11-01	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	2621	\N	2
166	6	pay_76517c62556243dce6607748	f1df92de-6828-d202-f1b6-1f20b68c189c	2026-09-04	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	51302	44288	3
184	7	\N	\N	2026-12-01	Chase	Upcoming Payment	\N	1224	\N	1
169	5	pay_94d39f7a3eb632d91dfc3462	49a5c9ce-b491-413f-0f33-71cd32bff373	2026-09-21	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	199	172	3
185	5	\N	\N	2026-11-21	American Express	Upcoming Payment	\N	178	\N	1
174	7	pay_dfa2014b4fdf8dda9a6c7e6f	99ea4ebc-796a-3555-0b27-c18f005dbef5	2026-10-01	AUTOMATIC PAYMENT - THANK	AUTOMATIC PAYMENT - THANK	\N	37768	32604	3
182	8	\N	\N	2026-11-12	Capital One	Upcoming Payment	\N	314683	\N	1
186	1	\N	\N	2026-12-02	Capital One	Upcoming Payment	\N	145243	\N	1
170	1	pay_1cc5baedbe6f8158c812cbd8	fc4b6718-77b7-1dd9-33a0-e74ba4373363	2026-10-02	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	25486	22001	3
187	3	\N	\N	2026-11-24	American Express	Upcoming Payment	\N	1198	\N	1
176	5	pay_c0c1815bfe48808fe2a95332	8501115e-b953-39a7-2a37-5b8b8b8d041e	2026-10-22	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	159	142	3
188	6	\N	\N	2026-12-05	Chase	Upcoming Payment	\N	2933	\N	1
183	3	pay_273ecec1d01de8e8fec57383	09da67f4-4457-b4fc-6cd8-ce412a41c34f	2026-10-24	AUTOPAY PAYMENT - THANK YOU	AUTOPAY PAYMENT - THANK YOU	\N	1128	1009	3
181	8	pay_943a448848a8a1472409d048	b360ded3-510d-9617-5c6d-a3864f7dab76	2026-10-12	Capital One	CAPITAL ONE AUTOPAY PYMT	\N	95264	59606	3
\.


--
-- Data for Name: plaidaccount; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plaidaccount (id, name, plaid_account_id, connection_id, cursor, last_successful_update) FROM stdin;
18	Checking	4a2212b9746e932a278035a7	12	\N	2026-11-13 08:59:27.157+00
11	Delta SkyMiles® Gold Card	470f4b98cb31d9636f2f3f50	8	\N	\N
17	Savings Account	f5998040bf52fa4972b8a842	11	\N	\N
19	Savings Account	27bf3eb4c92da283cf5eb2cf	12	\N	\N
20	CREDIT CARD	9776775c7a1708c7a0b555b3	13	\N	2026-11-12 15:28:04.017+00
21	Sapphire Preferred	acf493cf820a35d34ceeb4fb	13	\N	2026-11-12 15:28:04.017+00
6	Delta SkyMiles® Gold Card	182832dd95bf17313b280670	5	\N	2026-11-12 16:08:57.852+00
10	Hilton Honors Card	32b9af3f44b7ade2a43d1677	8	\N	2026-11-12 19:20:26.459+00
16	Checking	d125afd421dd40e7e78a4b50	11	\N	2026-11-13 01:32:28.166+00
22	Venture	05cfd429088c95f3728aa159	2	\N	2026-11-13 03:20:26.817+00
3	Savor	4a285d5ee43592bd657768dd	2	\N	2026-11-13 03:20:26.817+00
9	Checking	2ce3b906c7d864f5d850c881	7	\N	\N
\.


--
-- Data for Name: plaidconnection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plaidconnection (id, user_id, name, plaid_item_id, plaid_access_token) FROM stdin;
2	1	Capital One	item-sandbox-25413ac9ca62750d3649d2e4	access-sandbox-7f994c1bae6d78b514d07c54
5	2	American Express	item-sandbox-7730196ee24907435595a96d	access-sandbox-10f839dbb04a2e91b9eb55cc
8	1	American Express	item-sandbox-9e4832f82e0093893b3312b7	access-sandbox-657d113a264ccf7cec6c3a89
13	1	Chase	item-sandbox-0940a964e41e11e0769adbea	access-sandbox-cb36a516890781d704641326
11	1	Example Credit Union	item-sandbox-4133fd07704b0a9046ffba88	access-sandbox-ed7458107bd30b70d6050343
12	2	Example Credit Union	item-sandbox-5ae2c1e68c0e4a034fda20f6	access-sandbox-83daf930dfcd3daec43594e4
7	3	Example Bank	item-sandbox-cfb15fd4e13752485df6444a	access-sandbox-dbe7302fdc6a2a956f378cf5
\.


--
-- Data for Name: transaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transaction (id, account_id, import_id, actual_id, date, counterparty, description, category, amount_usd, amount_eur, status, payment_id, fees_and_risk_eur, ignore, posted_date) FROM stdin;
1271	4	tx_17f77567ac798a8c43cab3a4	\N	2026-05-11	Garden Center	GARDEN CENTER NEW YORK	\N	89	75	3	144	1	f	\N
1657	4	tx_cfb2b3054444396d2f011fbe	\N	2026-07-10	Garden Center	GARDEN CENTER NEW YORK	\N	165	143	3	165	-1	f	\N
548	4	tx_5deef45b59d85a05da55bbf5	\N	2025-07-10	Garden Center	GARDEN CENTER NEW YORK	\N	84	0	3	137	0	f	\N
1216	4	tx_752f0f3cf30bb37d9fca1c0d	\N	2026-04-10	Garden Center	GARDEN CENTER NEW YORK	\N	143	121	3	137	0	f	\N
1665	8	tx_3cb68bdf1ed768586763d60e	fa8f47e8-9165-c71a-5b68-04e0259e8fa5	2026-09-07	Home Supply	HOME SUPPLY HAMBURG	\N	603	518	3	181	4	f	\N
1177	6	tx_2a77b57644764e540643c130	7865b8ad-edba-6440-4660-3af5a32d0532	2026-03-20	Sushi Bar	SUSHI BAR BERLIN	\N	546	470	3	133	5	f	\N
1557	7	tx_3bce028aa874765538ed2f36	38ad916d-8b8b-51c2-9b77-80f25ea4627c	2026-07-22	Cinema Lux	CINEMA LUX MUNICH	\N	259	226	3	164	0	f	\N
1338	6	tx_bb8501f2ad9ca06a63bfabf3	4ceeafdb-847f-f34a-81c1-fa2b9657ea23	2026-05-28	Print Shop	PRINT SHOP BERLIN	\N	11015	9444	3	150	-6413	f	\N
1339	7	tx_b4e1e45204d8733b1fff85ff	58cf0c81-e606-5382-dc1a-9e444f50ac2a	2026-05-28	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	834	715	3	149	2	f	\N
1558	7	tx_4766fdd2a32f6017c805cadd	a5754048-81c6-e96d-4566-672199c159c8	2026-07-22	Cinema Lux	CINEMA LUX MUNICH	\N	944	826	3	164	-2	f	\N
1559	7	tx_e516a4c1cd2932133f84ae27	f258c7cd-e27c-fd81-74d3-b554b1d88b10	2026-07-22	Metro Transit	METRO TRANSIT ONLINE	\N	4677	4092	3	164	-6	f	\N
1562	7	tx_4fd4b8bc35ffd1d3d374ae3c	8a018867-d7b9-2bb6-7d24-67625bb4ec83	2026-07-23	Phone Carrier	PHONE CARRIER HAMBURG	\N	4193	3670	3	164	-8	f	\N
1563	7	tx_2eed46b1f8f9124019b4aeac	3f3113db-e059-9095-da9c-0c32e643d1f0	2026-07-23	Furniture Barn	FURNITURE BARN MUNICH	\N	4337	3796	3	164	-8	f	\N
663	4	tx_f0dcce3a91831b6601321dbd	\N	2025-09-10	Garden Center	GARDEN CENTER NEW YORK	\N	94	0	3	137	0	f	\N
1564	7	tx_15cbd4ca6b1c08f53e87d335	04e40024-aad8-97bc-1906-3c2e0b047666	2026-07-23	Hair Salon	HAIR SALON HAMBURG	\N	419	367	3	164	0	f	\N
1568	7	tx_d385235fe5e9a4242502fc1b	7d4065c4-167b-ee61-06c6-222d7bfc36cd	2026-07-24	Hardware Store	HARDWARE STORE HAMBURG	\N	14410	12598	3	164	-9	f	\N
1570	7	tx_cd5c87a4d0b07680445b20c4	86f7e44e-43a0-e3cb-abec-cf69c6958897	2026-07-25	Metro Transit	METRO TRANSIT ONLINE	\N	2203	1931	3	164	-7	f	\N
1571	7	tx_66406f685266a3d9e51cdcf9	0ef6d6c2-81c5-74a5-fbab-9367c50aacf5	2026-07-26	Power Utility	POWER UTILITY MUNICH	\N	258	226	3	164	-1	f	\N
1575	7	tx_6cca5555a41b418614aedf04	6b29fb84-7cf1-4d21-cd4d-05954899e332	2026-07-27	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	263	231	3	164	-1	f	\N
1347	7	tx_dc99eb4ad38a3bb2ca05e842	438c2be9-10cd-9829-7e8b-35b65657fcca	2026-05-29	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1267	1087	3	149	3	f	\N
1543	7	tx_1ce38cf98b71dc7884007f85	77503206-bbb2-45ac-956d-9243d66a8964	2026-07-17	Home Supply	HOME SUPPLY HAMBURG	\N	185	161	3	164	1	f	\N
1544	7	tx_7fec03718d9b935aafc8826a	7de30e9b-c646-a177-6654-00715f124c95	2026-07-17	Print Shop	PRINT SHOP BERLIN	\N	481	419	3	164	1	f	\N
1348	7	tx_1ce8996869a23e4c2cead255	bb00c17d-7892-dbcd-8ffb-575464e8830e	2026-05-30	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	292	250	3	149	1	f	\N
1577	7	tx_d01559fb4b8f832d5fc61506	f1f23481-f6aa-b3ab-e15b-b46887814ccb	2026-07-28	Concert Hall	CONCERT HALL BERLIN	\N	1694	1483	3	164	-3	f	\N
1578	7	tx_bf1b9ca1912b85aaf352312e	0d4912f4-5d7b-85a8-0a25-36738ca0b3eb	2026-07-28	Burger Joint	BURGER JOINT MUNICH	\N	1285	1125	3	164	-3	f	\N
1286	7	tx_5e671937a5f775edc21661f5	6ad8a8fe-dfbb-7e83-34fa-0e9339cf035e	2026-05-15	Toy Store	TOY STORE ONLINE	\N	1446	1233	3	149	10	f	\N
1182	6	tx_d72e4eae14df400365318c95	a4041a4f-f503-6381-45d4-4542fb7772d7	2026-03-22	Daily Bakery	DAILY BAKERY HAMBURG	\N	5201	4485	3	133	40	f	\N
1183	6	tx_a4efa45cc80c11a76e6a433b	fe14bb0a-7abb-cd5f-49fd-f4b82a264ed3	2026-03-22	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	1454	1253	3	133	12	f	\N
1282	7	tx_3bde7f1901436cfcd58ca373	31809897-44dc-94d1-90f1-7254ef8b15c1	2026-05-16	Print Shop	PRINT SHOP BERLIN	\N	3105	2658	3	149	11	f	\N
1302	7	tx_2286debe3be35600d65969bf	e3a4cd99-ea82-c83c-026f-3eba351ffd11	2026-05-20	Gym Central	GYM CENTRAL ONLINE	\N	655	561	3	149	1	f	\N
828	4	tx_fcab332d39e0c121daefc2b2	\N	2025-11-08	Stream Plus	STREAM PLUS HAMBURG	\N	5493	0	3	137	0	f	\N
830	4	tx_7f898c065510886784a49f43	\N	2025-11-10	Garden Center	GARDEN CENTER NEW YORK	\N	109	0	3	137	0	f	\N
936	4	tx_72722a8e3815136a3d510222	\N	2026-01-12	Garden Center	GARDEN CENTER NEW YORK	\N	109	0	3	137	0	f	\N
1303	7	tx_0cde05dfcc962d31dd9df363	92743bc5-5a7f-5ea7-6b98-601fe3a284b1	2026-05-20	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	1984	1701	3	149	5	f	\N
1307	7	tx_05689327280edc34fd0d2173	4da2980d-c8ab-5f2e-f31d-990666bb5e79	2026-05-21	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	2971	2551	3	149	3	f	\N
1308	7	tx_2769008c45483bbc6538dbb0	bf752309-3d4a-97a3-d28e-2887b22e4dd5	2026-05-21	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	242	208	3	149	0	f	\N
1319	7	tx_7db17bab416c08b54d15514b	6b7705bd-918c-75be-2672-b1c37e53f45b	2026-05-22	Pet Supplies	PET SUPPLIES BERLIN	\N	5074	4361	3	149	2	f	\N
1321	7	tx_7551085939977ee65b3e5c9f	86837beb-d3f7-8982-367b-d1158f0d77d2	2026-05-22	Power Utility	POWER UTILITY MUNICH	\N	441	379	3	149	0	f	\N
1324	7	tx_1915087a6ed9fa15c42322b8	ace62d29-5fa0-ac94-b4de-fe5b6586f0d6	2026-05-22	Gym Central	GYM CENTRAL ONLINE	\N	6523	5605	3	149	3	f	\N
1418	7	tx_3e600bee2bc98046aaf6977c	3ca1e4ca-aeb7-ba79-27fc-8c6bf5227080	2026-06-14	Print Shop	PRINT SHOP BERLIN	\N	925	798	3	157	5	f	\N
1417	7	tx_d0d9e5e1996bdbab180a3222	09f623d1-4399-ef3f-1d9b-a15a75b059ef	2026-06-15	Print Shop	PRINT SHOP BERLIN	\N	9040	7799	3	157	55	f	\N
1184	6	tx_a2d54ad62ef9e6c17a7178b3	b0a60445-25d7-4f7e-825e-2763251de55b	2026-03-22	Hardware Store	HARDWARE STORE HAMBURG	\N	2708	2335	3	133	21	f	\N
1579	7	tx_eb13ecf3dbd7b260c4f85f99	9c2314ce-df14-fdc2-118a-82dbe96a8008	2026-07-28	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	1139	997	3	164	-2	f	\N
1593	7	tx_e5b675d86892bed4686698c2	6cfae798-a27e-eded-45d4-d483ce14ee9e	2026-07-29	Print Shop	PRINT SHOP BERLIN	\N	11114	9744	3	164	-35	f	\N
601	4	tx_9152312868f69c7f290437ae	\N	2025-08-11	Garden Center	GARDEN CENTER NEW YORK	\N	302	0	3	137	0	f	\N
1218	6	tx_eb7f8ef2950212c84b5412e6	e3a4dc4c-bb60-90d7-86e6-7237a4b1d7d2	2026-04-09	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	486	415	3	141	-2	f	\N
1230	6	tx_028f05ce10e67104cebe57c4	b9718c63-9a3a-86c7-b3b4-4c1f31df1204	2026-04-17	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1719	1454	3	141	6	f	\N
1346	7	tx_524d8c3906ac0817f7a6a23d	5a75a175-350f-a718-3e9b-21604f1339a2	2026-05-30	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	869	744	3	149	4	f	\N
1585	7	tx_8be96f4abe320e3d83ec33f3	89bb65b0-77fd-10de-a0c9-a7df4fb7595d	2026-07-30	Stream Plus	STREAM PLUS HAMBURG	\N	204	176	3	164	2	f	\N
1586	7	tx_0f839dcacff3fd185c3e94a0	bc3e84dc-a070-e3b4-be51-8e0e05f9fcd6	2026-07-30	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1351	1178	3	164	2	f	\N
1352	7	tx_245fa8c39f09340b391ff530	a64e9e0c-fd67-8363-1bb9-851782d2905f	2026-05-31	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	4275	3657	3	149	19	f	\N
1369	7	tx_f87b80dd8385f76b9aa526a3	4c3698b2-b07d-15a2-57f1-8de6875140ab	2026-06-04	Daily Bakery	DAILY BAKERY HAMBURG	\N	785	675	3	157	8	f	\N
1353	7	tx_f4d65b59400e82d0e1dade9b	6063ab2f-3dba-6298-31d1-6cf20e545698	2026-06-01	Noodle House	NOODLE HOUSE HAMBURG	\N	9025	1515	3	149	8	f	\N
1356	7	tx_0d63d93f231e1a7b1fcd711e	95694195-11df-fea7-5594-32c076ab5d47	2026-06-01	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	773	661	3	149	4	f	\N
1355	3	tx_b7a151a99e998ba83b556612	20ddc1d0-44a0-b11b-a6e8-3183d52bd0e8	2026-06-01	Print Shop	PRINT SHOP BERLIN	\N	3758	3221	3	146	-30	f	\N
1587	7	tx_d69b4a54aea33c4cbae2987a	7748fc7e-1651-2205-4dc9-cf95f3f7ddf7	2026-07-30	Print Shop	PRINT SHOP BERLIN	\N	2244	1956	3	164	-322	f	\N
1588	7	tx_23149478d94f3217866d45fc	b93c2ee3-0e9e-608c-edf2-084db7a4189e	2026-07-30	Print Shop	PRINT SHOP BERLIN	\N	5105	4450	3	164	10	f	\N
741	4	tx_e67f949c40975f68ae878767	\N	2025-10-10	Garden Center	GARDEN CENTER NEW YORK	\N	94	0	3	137	0	f	\N
1591	7	tx_32066f2764f62bb63ab6a9f8	b8584111-7a0f-312c-e4f2-f0d24b66adee	2026-07-30	Print Shop	PRINT SHOP BERLIN	\N	2884	2514	3	164	6	f	\N
888	4	tx_fd35474cc768704f183b1731	\N	2025-12-10	Garden Center	GARDEN CENTER NEW YORK	\N	101	0	3	137	0	f	\N
1018	4	tx_f2b91e72048c9a3a4e85f79f	\N	2026-02-10	Garden Center	GARDEN CENTER NEW YORK	\N	120	0	3	137	0	f	\N
1545	7	tx_cd38a85b34191e6a57c99352	07cd9806-a6c8-e505-203b-cb5f361b6b6a	2026-07-19	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	94027	82091	3	164	49	f	\N
1592	7	tx_d5a208d957150e23f784930d	7cfcb600-7eb1-99d8-bd79-5f55fc14f52d	2026-07-30	Print Shop	PRINT SHOP BERLIN	\N	1413	1232	3	164	3	f	\N
1350	1	tx_55d94ea155c347a9c0450be1	c8d9a4f8-4dd7-513b-1c8e-924e0c7d04f4	2026-06-01	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	2719	2324	3	145	16	f	\N
1181	6	tx_c7ffa7a6c148e0dea17385d3	fb38d247-a13d-9f92-24b8-5dbebf83221a	2026-03-22	Stream Plus	STREAM PLUS HAMBURG	\N	580	500	3	133	5	f	\N
1231	6	tx_c66c64bdcdb6d309af2c19ae	cdb8861d-dc23-58d9-d668-c8c5d707e4fc	2026-04-18	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	113	95	3	141	0	f	\N
1238	6	tx_aa2c80a4ef8e48b80366aad2	1b06f01a-4962-2eeb-fd1a-e42b81cfce6d	2026-04-21	Gym Central	GYM CENTRAL ONLINE	\N	3198	2713	3	141	2	f	\N
1233	1	tx_fd3e3981bf60885e3d9fd2ae	4962c0f9-b846-25ba-d494-905ec8e7d57d	2026-04-20	Music Box	MUSIC BOX MUNICH	\N	671	566	3	135	3	f	\N
1361	7	tx_d04b7d023268f7b9dc25e5e5	99658177-b59b-dd31-d14b-1d440e47ab2b	2026-06-02	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	143	123	3	149	1	f	\N
1234	1	tx_f2fec3a376e5f721b0206983	c948d2dc-db9c-51ac-3af7-dd644b7553f0	2026-04-20	Gym Central	GYM CENTRAL ONLINE	\N	847	715	3	135	4	f	\N
1243	1	tx_4ab748b1993d359de1882673	b0560a95-4033-46de-4013-0a669493c04d	2026-04-27	Rail Express	RAIL EXPRESS NEW YORK	\N	4143	3535	3	135	-18	f	\N
1264	6	tx_b22cfee9c3892056b2a793a3	e82857d8-6775-4575-007b-f5da3e066eaa	2026-05-03	Ice Cream Parlor	ICE CREAM PARLOR HAMBURG	\N	14565	12357	3	141	8	f	\N
1265	6	tx_36c5f4a9becb4d5c60a81207	b672ebfd-3703-d798-81de-cbaa53463e9a	2026-05-03	Print Shop	PRINT SHOP BERLIN	\N	5330	4522	3	141	3	f	\N
1186	1	tx_dfe08cacbe2249acd6e7cc07	053632de-f448-338c-0f8c-750ded9cc844	2026-03-23	Phone Carrier	PHONE CARRIER HAMBURG	\N	588	506	3	126	8	f	\N
1187	6	tx_41c1a543fc35abd083b6f1ea	b243d9c3-0e01-123d-927b-539f832f9251	2026-03-23	Stream Plus	STREAM PLUS HAMBURG	\N	1533	1322	3	133	12	f	\N
1245	1	tx_017cf558ece748ae9749eaad	e32d514a-343f-a2de-c8ec-159e26dcba50	2026-04-27	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1391	1187	3	135	-6	f	\N
1246	1	tx_886a7adc0271494a2fd74ca3	919089d9-982d-c7c3-f3fd-94d9406dcf0d	2026-04-27	Gym Central	GYM CENTRAL ONLINE	\N	4113	3509	3	135	-17	f	\N
1250	1	tx_04859938719177526d52af07	1c9ff577-03ce-a95d-1ec6-f0ff06d637ed	2026-04-29	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	413	352	3	135	-1	f	\N
1255	1	tx_977f8fdebdb55e1e7a8c378f	1d3aab83-b753-91c3-48a8-b20a40a14724	2026-05-01	Furniture Barn	FURNITURE BARN MUNICH	\N	974	829	3	135	-3	f	\N
1259	1	tx_4c52a9c557f54af14483145c	c24dd931-b880-2a10-7f59-018defd82583	2026-05-02	Toy Store	TOY STORE ONLINE	\N	1473	1255	3	135	-4	f	\N
1261	1	tx_ab53463660cdc6545e50c01a	f3fc341c-f20d-1647-fb9d-2d13acecb01c	2026-05-04	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1240	1052	3	135	1	f	\N
1364	7	tx_c430c3dd8599f81dfd973088	8a6ad205-7009-d9b0-a924-03bb76283b41	2026-06-03	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1712	1469	3	149	3	f	\N
1365	7	tx_91a2182f16bf9a760340d2b8	3fc5c064-2619-c31e-c459-8ce00c067523	2026-06-03	Dry Cleaners	DRY CLEANERS MUNICH	\N	1779	1527	3	149	3	f	\N
1366	7	tx_5c1ec8c205fd3c088518e881	aeb19ba3-49ed-3912-a44a-39b3574ddd2e	2026-06-03	Pizza Forno	PIZZA FORNO MUNICH	\N	941	808	3	149	2	f	\N
1519	7	tx_33f73b9c7f2fe0b8776fed9e	0b661444-5eac-3e0d-811a-1df2048474d0	2026-07-07	Cinema Lux	CINEMA LUX MUNICH	\N	612	535	3	164	1	f	\N
1520	7	tx_305900ccae40962e764c4abb	16c784ef-ba86-d216-567d-324ef2da3d22	2026-07-07	Gym Central	GYM CENTRAL ONLINE	\N	629	549	3	164	1	f	\N
1262	1	tx_5af7737b4ec9fdeb6f845e85	4e8d0e7f-bbb3-7ea7-a2f9-26b670f8e439	2026-05-04	Burger Joint	BURGER JOINT MUNICH	\N	827	702	3	135	0	f	\N
1263	1	tx_3d89cbac1a2a6d6946c2f744	47e33d6d-9897-181a-5f7e-c926f77fc71c	2026-05-04	Fresh Market	FRESH MARKET NEW YORK	\N	3760	3190	3	135	2	f	\N
1267	1	tx_70b10e0832855120c5a861f3	245df8b0-53fe-1d60-ac23-c32b0514086a	2026-05-06	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	148	126	3	135	-1	f	\N
1268	1	tx_029c5c38f76b4f0c01e29d38	70a05b17-e97b-c54e-0f81-67eb4c0fcbcb	2026-05-07	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	376	321	3	135	-2	f	\N
1219	1	tx_c12c504cc2a55fdc351c529e	caa73c60-08e8-fae7-c30f-594c92d831c4	2026-04-11	Metro Transit	METRO TRANSIT ONLINE	\N	11984	10208	3	135	-33	f	\N
1521	7	tx_774aa88e5e74d476a3b44d8b	07a3965c-8e7d-54b0-40df-76a8d59aa3f0	2026-07-07	Burger Joint	BURGER JOINT MUNICH	\N	825	720	3	164	1	f	\N
1137	6	tx_f40201f763688286507be784	0577a852-b84f-911c-3a22-e67a543d43ff	2026-03-08	Office Supplies	OFFICE SUPPLIES MUNICH	\N	4262	3667	3	133	40	f	\N
1195	6	tx_0cb9b35aaaaa16da127c8d55	5747ea85-3b45-7e72-0db3-63904a648c24	2026-03-25	Noodle House	NOODLE HOUSE HAMBURG	\N	257	222	3	133	3	f	\N
1194	6	tx_a79677b888c7666b56c5ddab	8a84a618-c87d-1eb4-56ed-076638e99f50	2026-03-26	Corner Grocery	CORNER GROCERY ONLINE	\N	5347	4597	3	133	54	f	\N
1196	6	tx_036f1c0d297665171bda50ff	c83f029d-a265-6e75-42bc-ecddbb2921db	2026-03-26	Stream Plus	STREAM PLUS HAMBURG	\N	1071	921	3	133	11	f	\N
1317	7	tx_9e0599574510a05d8ca94f3c	18025e40-7cf5-0d03-c065-74617e43979a	2026-05-23	Sushi Bar	SUSHI BAR BERLIN	\N	2593	2230	3	149	-1	f	\N
1318	7	tx_0cd7183df0112cf22cea5bdb	bdc9c1c9-f846-cc2c-c216-5ff0a685aeec	2026-05-23	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	717	617	3	149	0	f	\N
1320	7	tx_cd25aeef95ba522ff3eee813	81a7590f-fc56-98e9-a049-f93bab910ecf	2026-05-23	Print Shop	PRINT SHOP BERLIN	\N	1408	1211	3	149	-1	f	\N
1322	7	tx_ee87071ff13beb59b711651a	22fb8f10-604d-e15e-c389-070e556ab6ab	2026-05-23	Power Utility	POWER UTILITY MUNICH	\N	629	541	3	149	0	f	\N
1197	6	tx_7a5aadf90f3e6721d015889b	405bc969-73d2-43c7-cfb6-88d87be8b654	2026-03-26	Stream Plus	STREAM PLUS HAMBURG	\N	704	605	3	133	7	f	\N
1201	6	tx_e06a499771d173f00d7e7578	3859b793-65fd-d4da-2f8d-f318367c4915	2026-03-29	Print Shop	PRINT SHOP BERLIN	\N	9597	8310	3	133	38	f	\N
1139	6	tx_a74b26c0b403c0b275ee1f6f	884f48c8-fc80-29b3-9b23-32629175893d	2026-03-09	Print Shop	PRINT SHOP BERLIN	\N	181915	156513	3	133	1721	f	\N
1239	5	tx_cc6426518388214fbea1c1b5	2499fc20-8b84-6a36-55cd-3a3e563c232f	2026-04-21	Hair Salon	HAIR SALON HAMBURG	\N	628	533	3	134	1	f	\N
1467	7	tx_6ed4e2fc1819f480aa863da2	abbe56cf-54dd-f7e4-ead2-6b78809ed3b7	2026-06-24	Print Shop	PRINT SHOP BERLIN	\N	31661	27673	3	157	-167	f	\N
1466	7	tx_f4ce1c8c08334f99f26f75c6	dd49fd16-d0f7-dc91-aaec-d9b4a8a541e2	2026-06-25	Hardware Store	HARDWARE STORE HAMBURG	\N	154	135	3	157	-2	f	\N
1258	3	tx_c4011241f5ac962551197fca	f72ce4c3-4159-0cf9-4ed5-d4e8d757105f	2026-05-01	Print Shop	PRINT SHOP BERLIN	\N	2298	1950	3	138	2	f	\N
1254	1	tx_5f001fe3d49192ff4f6e853a	32f7dda5-e7f2-fe15-9882-b55226bcfd49	2026-05-01	Hardware Store	HARDWARE STORE HAMBURG	\N	898	766	3	135	-4	f	\N
1141	6	tx_0574b12c5c70118aa84c1d0a	b9833b81-c98f-0d30-2ed8-ca0d9cff020c	2026-03-07	Print Shop	PRINT SHOP BERLIN	\N	13323	11462	3	133	127	f	\N
1166	6	tx_1eba68924d42b8329053acbc	0e416a61-dda5-cd00-91cd-cef25e063725	2026-03-17	Print Shop	PRINT SHOP BERLIN	\N	1049	910	3	133	1	f	\N
1253	6	tx_711416518da3855f0676d7c1	5a42090f-7ae1-7bc6-47b3-204e43b6b7bc	2026-04-29	Print Shop	PRINT SHOP BERLIN	\N	7176	6117	3	141	-25	f	\N
1773	8	tx_0729a68f2518b2332f900f36	c1577e19-d88a-63eb-9a12-a9abf53b3065	2026-10-26	Burger Joint	BURGER JOINT MUNICH	\N	1919	1708	2	\N	\N	f	\N
1280	7	tx_cacb1ecea1680dc746b32204	e4dece82-7daf-7012-40e7-4644186a3c83	2026-05-15	Office Supplies	OFFICE SUPPLIES MUNICH	\N	222	190	3	149	1	f	\N
1774	8	tx_56b7a2c24db8aad11a58ec43	12171480-f74a-78e2-cce1-064f57ba3d4f	2026-10-28	Sky Airways	SKY AIRWAYS HAMBURG	\N	1545	1380	2	\N	\N	f	\N
1389	4	tx_d684d26ed6e29f1efa7aee48	\N	2026-06-10	Garden Center	GARDEN CENTER NEW YORK	\N	129	111	3	154	0	f	\N
1279	6	tx_fe5d946c23efb011f492d5bb	12816f86-2f78-076e-f25e-a7d6d08ab19b	2026-05-15	Print Shop	PRINT SHOP BERLIN	\N	2109	1799	3	150	18	f	\N
1398	7	tx_2edafe4c5cf07b91d6b9e9f6	cebc398a-7226-f3e3-d754-fda63beae213	2026-06-11	Insurance Co	INSURANCE CO BERLIN	\N	587	507	3	157	2	f	\N
1399	7	tx_950e928c348c5ae9e7956863	1e23729f-3038-71b8-1742-5c50baf85e3f	2026-06-11	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	284	245	3	157	1	f	\N
1281	7	tx_878af62df40ed8d8a480d441	c8c6df28-eaf2-455f-7736-a58c58b8269c	2026-05-15	Sushi Bar	SUSHI BAR BERLIN	\N	6682	5700	3	149	45	f	\N
1270	1	tx_edcd54e6f86625a4645cb122	54b44db2-7f3a-1068-26bb-1464a286b011	2026-05-09	Dry Cleaners	DRY CLEANERS MUNICH	\N	728	618	3	145	10	f	\N
1266	6	tx_15eff1f5d49ced08b3ea409e	1a331a4a-1fbb-1648-1a92-9ea45887cd98	2026-05-03	Ice Cream Parlor	ICE CREAM PARLOR HAMBURG	\N	2039	1729	3	141	2	f	\N
1272	1	tx_b0b2f782fcf726d07faf76f5	bab53f34-0719-b7bb-369d-dcab82b88259	2026-05-11	Metro Transit	METRO TRANSIT ONLINE	\N	180	152	3	145	3	f	\N
1273	1	tx_e7746ab77656806dc0aff78c	59fe4682-f179-df1c-ace8-ac27eaf3861a	2026-05-11	Rail Express	RAIL EXPRESS NEW YORK	\N	1368	1160	3	145	18	f	\N
1283	7	tx_48b3338eb3cebf0f28c72e9c	23e22abd-d680-8040-12a9-a903934fe943	2026-05-15	Pet Supplies	PET SUPPLIES BERLIN	\N	17308	14763	3	149	117	f	\N
1284	7	tx_55eb5f0091630a4bdf780b09	d28e3ba8-dd52-b584-ad18-0657f4851b52	2026-05-15	Wine Shop	WINE SHOP ONLINE	\N	668	570	3	149	4	f	\N
1285	7	tx_a7bdb985a2993657b42b28f3	cdcdeab1-38e6-ce57-3fe0-a5874e3c3567	2026-05-15	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	702	599	3	149	5	f	\N
1275	1	tx_457fa4a6efcee57c0829219b	d721d688-de3b-448e-ca95-2eccba390f03	2026-05-13	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	2024	1716	3	145	27	f	\N
1277	1	tx_7daa7ea50c0d83304ac88368	944f0822-9cfd-9a7f-97b9-c27f8503a142	2026-05-14	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	3516	2982	3	145	47	f	\N
1202	1	tx_bc569996e235309dd73c47ef	305eb14a-264e-aef8-c00c-93575a6cb63a	2026-03-30	Toy Store	TOY STORE ONLINE	\N	1120	969	3	126	10	f	\N
1203	1	tx_c5151db7619d5e953a66315a	a54820b3-6a64-060d-e52f-6bd8cc0acef0	2026-03-30	Toy Store	TOY STORE ONLINE	\N	1120	969	3	126	10	f	\N
1244	1	tx_4596bd0f9380e2028b86d8a7	0e70a94f-ba27-beb7-cd30-41d585a57945	2026-04-27	Stream Plus	STREAM PLUS HAMBURG	\N	972	829	3	135	-4	f	\N
1145	4	tx_eb3fe55e329c30135a1c29ef	\N	2026-03-10	Garden Center	GARDEN CENTER NEW YORK	\N	120	0	3	137	0	f	\N
1374	6	tx_a380401ebc3791ad98698209	116a117e-bec8-fe14-5bff-3393130fadd7	2026-06-05	Print Shop	PRINT SHOP BERLIN	\N	1453	1247	3	150	4	f	\N
1614	1	tx_8b14844daa2add4d99c57031	2066d8ff-6b76-2d9f-3eb7-176340d6cf89	2026-08-13	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	547	473	3	170	-1	f	\N
1146	6	tx_9b5853b525bad99ee19920c2	4f3743c8-b0ed-104f-267c-352a45714418	2026-03-08	Print Shop	PRINT SHOP BERLIN	\N	4776	4109	3	133	46	f	\N
1623	1	tx_536b9f0eecc8c43d47f877fb	6f760a7f-3508-dbc1-bf91-28e1ef0b6f3d	2026-08-15	Online Marketplace	ONLINE MARKETPLACE ONLINE	\N	542	468	3	170	1	f	\N
1661	8	tx_34d71dcaf231d374ed69c780	ec0c3e26-ddd9-9439-5d97-1d20a57abe50	2026-09-07	Office Supplies	OFFICE SUPPLIES MUNICH	\N	217	187	3	181	1	f	\N
1397	1	tx_f6ce802e944f45b23201617a	0be3baa5-c09a-e9f6-d092-8629e1ce8226	2026-06-12	Metro Transit	METRO TRANSIT ONLINE	\N	166	143	3	158	3	f	\N
1674	7	tx_73bb2693acbbdf0e530c3cbd	9e46f566-be2f-40ac-6bde-4a2ba3c6183b	2026-09-10	Daily Bakery	DAILY BAKERY HAMBURG	\N	1715	1472	2	\N	\N	f	\N
1376	7	tx_7e41988270b4a4a941daa0f4	d1fad89c-a274-702f-60ba-9a73bc78d221	2026-06-05	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	817	701	3	157	8	f	\N
1323	7	tx_41f94a780677d95dea69357a	70acfcf1-0b79-730f-a9ba-12bfc0b63d57	2026-05-23	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	7829	6734	3	149	-3	f	\N
1325	7	tx_d27c6727143e0e15801fcc02	c4e6e092-2d12-703c-0924-ff60fca42ff3	2026-05-24	City Taxi	CITY TAXI BERLIN	\N	1656	1424	3	149	-1	f	\N
1326	7	tx_1ba335593e4c1473dca4ee81	7f13eeed-2386-f854-569b-75bffbc94358	2026-05-24	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	6626	5699	3	149	-2	f	\N
1331	7	tx_5353051fccde1def32dc16b2	bea131e3-9529-f12d-8892-261a508e0ddc	2026-05-26	Gym Central	GYM CENTRAL ONLINE	\N	8647	7437	3	149	-3	f	\N
1332	7	tx_331317a5d7dba014a53de867	dcf41e83-7d14-71fe-e27c-604ab3bce59e	2026-05-26	Green Basket	GREEN BASKET MUNICH	\N	4020	3458	3	149	-2	f	\N
1333	7	tx_a016598684fc59cc16ae0967	a87551d9-06f0-691c-f52c-6e7bf56ac2c9	2026-05-26	Music Box	MUSIC BOX MUNICH	\N	660	568	3	149	0	f	\N
1375	6	tx_1d63757c3240f60dc20d6d78	d1001cc6-c56f-3e6d-8b65-00d2b4de2ab2	2026-06-06	Ice Cream Parlor	ICE CREAM PARLOR HAMBURG	\N	1574	1351	3	150	4	f	\N
1309	5	tx_0795e1abb15322d09f160ca6	975c644b-03ef-d817-bb8b-59a6af2c50aa	2026-05-21	Hair Salon	HAIR SALON HAMBURG	\N	1166	1002	3	148	-12	f	\N
1690	8	tx_fe00dde50bab6f2bfc5a9f61	b7bd0a56-92c0-4e61-d121-4f8dca6b2a1d	2026-09-18	Garden Center	GARDEN CENTER NEW YORK	\N	4308	3727	2	\N	\N	f	\N
1624	1	tx_84e6fbcc0bff66d8bdec8b3e	762d6d4a-66f7-d7c1-7c9d-13ff31060eb1	2026-08-15	Pizza Forno	PIZZA FORNO MUNICH	\N	8145	7054	3	170	-23	f	\N
1147	6	tx_4837c72e83011f058359e3b6	ac8b7ad4-4766-df72-6f18-0d13715a5705	2026-03-10	Cloud Storage Inc	CLOUD STORAGE INC ONLINE	\N	122825	105520	3	133	1314	f	\N
1691	8	tx_efab904b01a0e6a4291d60fc	9146716b-b0d9-80e0-3613-48a38c1a6b5b	2026-09-18	Phone Carrier	PHONE CARRIER HAMBURG	\N	3195	2763	2	\N	\N	f	\N
1692	8	tx_46fe16db9e079f2672a78f5c	785090e5-3491-6a01-3751-cadaddff6578	2026-09-18	Corner Grocery	CORNER GROCERY ONLINE	\N	415	360	2	\N	\N	f	\N
1693	8	tx_c40c25ef1dc5b07256954129	6dee0705-b085-2a8e-2123-041d94b3b8ed	2026-09-18	Yoga Studio	YOGA STUDIO NEW YORK	\N	1116	965	2	\N	\N	f	\N
1694	8	tx_0dc4dfd23c7865126d4a2442	b362f10f-284d-8482-b661-0b8f9efd8efa	2026-09-19	Pizza Forno	PIZZA FORNO MUNICH	\N	8827	7679	2	\N	\N	f	\N
1414	7	tx_903df0008e6fa7e0459da5da	b8b4e16c-1f5b-51a7-14ed-ed1e9bbcb39e	2026-06-14	Print Shop	PRINT SHOP BERLIN	\N	5474	4723	3	157	33	f	\N
1415	7	tx_02472e093f60e8621bc097f4	caeed03c-4000-b1cc-9f93-664df1946144	2026-06-14	Print Shop	PRINT SHOP BERLIN	\N	6233	5378	3	157	38	f	\N
1413	7	tx_f440f27014675521e57b87f7	a47845e9-1b74-d2a6-4f8c-a71dd4045173	2026-06-15	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1493	1288	3	157	9	f	\N
1291	7	tx_2d005924ab5785a9d5dcb993	00018a62-0f28-3742-4959-2ced78d975e3	2026-05-18	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	2126	1820	3	149	8	f	\N
1292	7	tx_67cd824851b4a8709b1ceade	e255dfad-bed1-d80a-7ffd-8bcba740d537	2026-05-18	Book Nook	BOOK NOOK ONLINE	\N	4926	4218	3	149	17	f	\N
1274	1	tx_d5c72d32b6ac568d3b792644	fddd0cd4-2dd6-36e9-0e89-ed39ff87e983	2026-05-12	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	4366	3704	3	145	56	f	\N
1221	1	tx_eb41ac40fbc96b757dd1b736	2347be58-654d-522c-be5a-25ad414c2baa	2026-04-13	Sushi Bar	SUSHI BAR BERLIN	\N	743	633	3	135	-2	f	\N
1222	1	tx_e7224f9478ad2356e5023acf	8184f9cf-186b-2cfe-7d3f-cc6e9c66bbcc	2026-04-13	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	3348	2851	3	135	-10	f	\N
1226	1	tx_16809d65ede6e4882f35e382	5c7ccfee-6726-116a-b5a9-3224cc2b013a	2026-04-15	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	195	167	3	135	-1	f	\N
1227	6	tx_27f0c9461cd75b0397ff75ec	a6e7c20c-6fb3-5c0a-f58a-c4194994d927	2026-04-15	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	205	174	3	141	0	f	\N
1248	6	tx_a17802b93045ea78c15ea076	bace092b-c997-f759-fd93-0054c2d827e5	2026-04-25	Print Shop	PRINT SHOP BERLIN	\N	1878	1601	3	141	-7	f	\N
1278	1	tx_3bdfc1ce05c1aee6fa615ca1	38d83b8e-f388-1b56-4d4b-39fcb5fc6af3	2026-05-16	Sushi Bar	SUSHI BAR BERLIN	\N	11530	9835	3	145	96	f	\N
1290	7	tx_c8e22aa85b5f1c19b310c25e	97d622c3-f64e-6f1f-8a9e-778299642fe3	2026-05-19	Riverside Inn	RIVERSIDE INN HAMBURG	\N	7201	6175	3	149	16	f	\N
1269	1	tx_de0507beabbf3fc87bceac2f	baaef538-340d-f5e1-d9ee-136fa1417628	2026-05-08	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	367	311	3	135	1	f	\N
1300	7	tx_4f02672f7a201f90db235fb4	e514861c-2d10-b9a3-d441-126e01371df9	2026-05-20	Gym Central	GYM CENTRAL ONLINE	\N	7020	6017	3	149	17	f	\N
1301	7	tx_892888dfd3501b46939f56e7	bb4f9f50-b96d-8fd3-78de-2f0789f19556	2026-05-20	City Taxi	CITY TAXI BERLIN	\N	720	618	3	149	2	f	\N
1156	6	tx_8c68f66f64c4ce7b023bb886	f0c89783-ef65-b605-ff62-e0ed59582b7d	2026-03-13	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	6844	5936	3	133	17	f	\N
1155	6	tx_15357b70ded84dee0fd05900	4c091332-8425-a5fd-5b5c-51e6ebd84964	2026-03-14	Book Nook	BOOK NOOK ONLINE	\N	39548	34294	3	133	104	f	\N
1165	6	tx_e89bd971f181a22680377dc0	c8d27b0f-9c5e-5c2d-024c-99198e74bc8e	2026-03-17	Print Shop	PRINT SHOP BERLIN	\N	16949	14704	3	133	38	f	\N
1672	1	tx_d9852992edf1c4fc1e8d31e7	e1f069be-b1aa-ab20-bc91-509fd8094e20	2026-09-10	Metro Transit	METRO TRANSIT ONLINE	\N	115	98	2	\N	\N	f	\N
1625	1	tx_244b9631f999941e3b0e4f0a	265fbea6-f11f-38be-7c40-0938a3970a8e	2026-08-17	Gym Central	GYM CENTRAL ONLINE	\N	1178	1016	3	170	1	f	\N
1154	1	tx_902dfffe895fa9ead31577c5	ee4132fc-3005-8b51-0eb6-5d09322c7b45	2026-03-14	Print Shop	PRINT SHOP BERLIN	\N	1454	1256	3	126	15	f	\N
1158	1	tx_24172d46a37cb9537055c0d2	683942d7-699d-6e54-f40c-81edc25ad09a	2026-03-16	Riverside Inn	RIVERSIDE INN HAMBURG	\N	172	149	3	126	1	f	\N
1164	1	tx_4b716f1bb00b630afec31f3b	842d637e-98e1-fc76-d77c-b0800583202b	2026-03-19	Stream Plus	STREAM PLUS HAMBURG	\N	1433	1242	3	126	11	f	\N
1153	1	tx_fef97fe385f4abd3d3fecced	fb715e6c-1fae-69c5-1919-01c2b7c4c851	2026-03-14	Gym Central	GYM CENTRAL ONLINE	\N	7174	6196	3	126	77	f	\N
1225	1	tx_283b20963a1754b8cb31b900	9eb641c7-1dcf-409f-9fb2-13fbd7032c85	2026-04-14	Metro Transit	METRO TRANSIT ONLINE	\N	85	70	3	135	1	f	\N
1148	6	tx_96fbaa4e9d9c46c985266b83	ca8ff294-4b7e-4ce1-980f-1be8643556a3	2026-03-11	Riverside Inn	RIVERSIDE INN HAMBURG	\N	422	361	3	133	5	f	\N
1149	6	tx_59abc63c6b5d089ff6cbf116	3f881fd0-4877-036b-f436-b84cfa669b11	2026-03-11	Coastal Air	COASTAL AIR MUNICH	\N	4264	3654	3	133	55	f	\N
1223	6	tx_a0d071b382e94d792009dfbe	e186d8d5-92b6-9b0b-6932-7fdc84ee87a2	2026-04-13	Book Nook	BOOK NOOK ONLINE	\N	3135	2670	3	141	-9	f	\N
1251	6	tx_0bf1f0d4f888ba2672519aea	327383bf-caa8-af5a-9401-2062ab5f4456	2026-04-27	Print Shop	PRINT SHOP BERLIN	\N	1794	1530	3	141	-7	f	\N
1237	3	tx_541bab34bfc5540547b3c416	7a0ac059-4a62-cc84-8d33-a8011c42fa79	2026-04-20	Gym Central	GYM CENTRAL ONLINE	\N	1488	1261	3	138	2	f	\N
1217	1	tx_3606c7d78fc561905088341f	2b9d00e3-2d9e-2168-9ba1-b6f42d1c8a4d	2026-04-10	Dry Cleaners	DRY CLEANERS MUNICH	\N	126	107	3	135	-1	f	\N
1386	7	tx_4039044e09f7ab7c73dc6c26	06352b20-f0d7-12f0-4a8a-d8a28ac03be6	2026-06-08	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	1805	1550	3	157	18	f	\N
1150	6	tx_a224febdda722fcf506c1eb1	0da79157-e3ef-40a8-0ea3-c530e5679047	2026-03-11	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	3630	3110	3	133	47	f	\N
1675	8	tx_837943dd9182617c43145b9a	f38c2a6c-a4af-9614-5f9b-48ec0c13934a	2026-09-11	Pet Supplies	PET SUPPLIES BERLIN	\N	1003	861	3	181	7	f	\N
1162	6	tx_48562365e80af4505d43a09e	9051475a-7ac9-bafe-bdfe-25143c96ca15	2026-03-16	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	5371	4657	3	133	15	f	\N
1387	7	tx_9d9574caa6f9b120a481b192	df21b715-196a-2c2f-f79e-a10d610fb493	2026-06-08	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	430	369	3	157	5	f	\N
1506	7	tx_4cff0135411aa0ccc3300289	6c938120-f215-684c-e8ed-ac47d6b33c59	2026-07-03	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	1197	1044	3	164	-176	f	\N
1508	7	tx_8325ea0b9a9522c1d8885b7f	a1c19a7a-79c2-f7c6-70a4-8a9d275cf6e6	2026-07-03	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	616	537	3	164	1	f	\N
1509	7	tx_05ed12230c3621a34d667254	cc133195-1120-ce87-737f-f711f749f4b3	2026-07-03	Concert Hall	CONCERT HALL BERLIN	\N	1524	1328	3	164	3	f	\N
1213	1	tx_b51f5d68694b64fa3f700d26	65162a4a-ebf1-f277-4fba-b63cb7a500d7	2026-04-02	Gym Central	GYM CENTRAL ONLINE	\N	1815	1560	3	126	26	f	\N
1505	7	tx_26d0e15c7afd63ffc7fa833b	74439a50-bd2c-472d-fe48-f138f1acde2d	2026-07-04	Dry Cleaners	DRY CLEANERS MUNICH	\N	549	479	3	164	1	f	\N
1507	7	tx_9f98fc3e20d9e2a576202de2	f91938f8-2451-581c-1f66-31df6d5df5c2	2026-07-04	Hair Salon	HAIR SALON HAMBURG	\N	299	261	3	164	1	f	\N
1517	7	tx_fe12415b69f7c4193490f81f	989df79f-49ea-2082-9979-f4d0de87901c	2026-07-06	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	2300	2009	3	164	0	f	\N
1518	7	tx_11e87df904e1661a423f0de3	857f729c-1f5e-2d24-a13b-38313ffcfd22	2026-07-06	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	3542	3094	3	164	0	f	\N
1547	7	tx_2544f2f9ffe49268fcd9d95e	ad0bd562-8001-f47d-b682-1e798fff509b	2026-07-19	Book Nook	BOOK NOOK ONLINE	\N	509	444	3	164	0	f	\N
1553	7	tx_5f5dfae69ed3a7d34eccfa03	530567b1-0a45-14ed-b950-25a201f64c82	2026-07-19	Print Shop	PRINT SHOP BERLIN	\N	3874	3382	3	164	2	f	\N
1549	1	tx_fe3ac975b535d144cb8a8d5d	322fb8f9-0a7c-0075-1116-be7a26a83eb7	2026-07-21	Stream Plus	STREAM PLUS HAMBURG	\N	4682	4088	3	161	-46	f	\N
1546	6	tx_49bd4d4696bca4b384ef9ed0	87c36f8a-2b66-c9cc-7805-0939538e616b	2026-07-19	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	51302	40145	3	166	4143	f	\N
1626	1	tx_c3b782fb335d264c42c1261b	4e9b7625-0912-cd69-3aaa-57cc95cc848a	2026-08-17	Phone Carrier	PHONE CARRIER HAMBURG	\N	2363	2039	3	170	1	f	\N
1695	8	tx_168c0b61a379b5463903f9eb	649d4bf3-23a7-289b-9d55-65653600c42e	2026-09-21	Phone Carrier	PHONE CARRIER HAMBURG	\N	457	398	2	\N	\N	f	\N
1548	1	tx_23c30e37ceb9727146dcebdf	71b73bd6-60fe-0a68-0358-c97586c5f3a1	2026-07-21	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	93	81	3	161	-1	f	\N
1628	1	tx_3e4d675474118c7230be04c8	ab0453a5-8f16-71ea-acab-56475d81cbce	2026-08-18	Coastal Air	COASTAL AIR MUNICH	\N	1390	1200	3	170	0	f	\N
1635	1	tx_fe48ae7bb45103d3c87affb7	9e0f8529-760b-a56b-a837-94d03ce3c043	2026-08-25	Corner Grocery	CORNER GROCERY ONLINE	\N	728	621	3	170	7	f	\N
1636	1	tx_1fe9eacf800a20111882a9ef	4303a23d-7251-295f-2de5-16a3df3194c6	2026-08-26	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	107	91	3	170	1	f	\N
1637	1	tx_bfe094f6c37a5e3f71a8b7fd	302d865b-7bea-afb9-3e27-c65382bd6e6a	2026-08-26	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1639	1402	3	170	12	f	\N
1640	1	tx_ea5710de26579fa4d32d075e	82c0a855-5888-fd09-03b8-39a7cfd640b7	2026-08-27	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	148	127	3	170	1	f	\N
1645	1	tx_e2a52c56eee514170b3443b6	7b1c8a4f-0287-63e4-b34c-9086a96e96e8	2026-08-28	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	710	607	3	170	5	f	\N
1340	7	tx_bc9ab53398d319de21fc7c4c	f42382dd-8810-92be-b10c-afb94b20e18b	2026-05-28	Sushi Bar	SUSHI BAR BERLIN	\N	430	369	3	149	1	f	\N
1341	7	tx_07532b9e7ec35fd3ce51b66e	3f12b2e4-0134-f8b8-72fe-918aa21e0122	2026-05-28	Concert Hall	CONCERT HALL BERLIN	\N	2833	2429	3	149	7	f	\N
1357	7	tx_0f549039cb38457f86c420a0	d520c57b-982c-e79c-b353-dfdddf0c8a7a	2026-06-01	Gadget World	GADGET WORLD NEW YORK	\N	30317	25937	3	149	128	f	\N
1390	7	tx_dd7c164300985311d538344d	220f63ee-4794-09d3-ce9f-ac4dc2173a37	2026-06-09	Sushi Bar	SUSHI BAR BERLIN	\N	151	131	3	157	1	f	\N
1391	7	tx_c42b004c4cd1df711f5d6f84	7cdc153b-8bb4-62b7-6608-26ce3ed9b66f	2026-06-09	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	779	674	3	157	3	f	\N
1435	7	tx_05e2618d38e422e5126da9d2	a3f71a6a-28a1-8b44-4250-b91c481af67a	2026-06-19	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	2474	2145	3	157	4	f	\N
1436	7	tx_6ec3555b8895b3dbcc5f324e	d6ce0b4c-25f5-1250-abf3-48a814e661fc	2026-06-19	Noodle House	NOODLE HOUSE HAMBURG	\N	4064	3525	3	157	6	f	\N
1167	6	tx_df7761353d4694cc1d6ec459	b5fc96a2-d2eb-0692-9a5e-f049347e9e7c	2026-03-17	Print Shop	PRINT SHOP BERLIN	\N	1049	910	3	133	1	f	\N
1170	6	tx_4c55755f7b3900c6cff23340	9814597d-f151-7ce0-a834-ccbebfb72aaa	2026-03-19	Ice Cream Parlor	ICE CREAM PARLOR HAMBURG	\N	1385	1199	3	133	5	f	\N
1178	6	tx_3f7851da985b383b06e659e8	0cca8f16-8912-5812-fb47-56e15ce45454	2026-03-20	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	427	368	3	133	4	f	\N
1188	6	tx_022a8693cf8eba269893c785	3b88122b-9420-0362-f45a-3097066a0a0e	2026-03-23	Stream Plus	STREAM PLUS HAMBURG	\N	2559	2207	3	133	18	f	\N
1190	6	tx_4726bc64b1ad4cce7b06cb50	ad1e7b82-a28d-0340-418f-b24d80b1776f	2026-03-24	Stream Plus	STREAM PLUS HAMBURG	\N	421	361	3	133	4	f	\N
1200	6	tx_de4d7dc048d0efc4a3b89f71	eef0f608-8d51-c6dc-d8e4-c466db319436	2026-03-28	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1551	1343	3	133	7	f	\N
1208	6	tx_8d779b02328a11a32621d57f	685b75c5-016d-5e9a-d502-ecc8ad91b0cc	2026-03-31	Gym Central	GYM CENTRAL ONLINE	\N	16	13	3	133	0	f	\N
1211	6	tx_e2e6a525a4d51e5476f72b81	4568c9ba-c6c3-d350-d619-fc1c49c82213	2026-04-01	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	2823	2440	3	133	15	f	\N
1214	6	tx_789b0c0c78c51cb073150029	0ca96d60-64a7-8531-096c-048e7b0eb520	2026-04-02	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1876	1613	3	133	18	f	\N
1247	5	tx_8b34150c5b640523462c67fb	45151906-6eab-fbca-6b78-28cfd2e5db70	2026-04-25	Print Shop	PRINT SHOP BERLIN	\N	5690	4855	3	134	-24	f	\N
1512	7	tx_8118d1da214f4d0ed26fbef6	fa90d5dd-dfd0-42ad-0b22-ed86cd23297b	2026-07-05	Office Supplies	OFFICE SUPPLIES MUNICH	\N	2341	2042	3	164	3	f	\N
1513	7	tx_1ce4fa3b37dc4fefaecf90ba	21ebca0a-c599-0ab6-2737-49ced770f51c	2026-07-05	Cinema Lux	CINEMA LUX MUNICH	\N	490	427	3	164	1	f	\N
1525	7	tx_b3e2ec64e43ae0d0c058f81d	f0ad502c-2692-994f-60f8-df31dc854e92	2026-07-09	Yoga Studio	YOGA STUDIO NEW YORK	\N	624	545	3	164	-1	f	\N
1526	7	tx_8906499db8572fa598f13fcb	2daee024-1f8d-8db0-7910-487678238a8b	2026-07-09	City Pharmacy	CITY PHARMACY BERLIN	\N	2606	2279	3	164	-3	f	\N
1530	7	tx_11e17d312d7b52c678d67aae	dcdaddf3-9a29-fa80-a8c6-6d5a8df5d2e7	2026-07-10	Online Marketplace	ONLINE MARKETPLACE ONLINE	\N	312	273	3	164	0	f	\N
1529	7	tx_157b24708b792c6ef3c35ddd	13a80e46-99b7-9221-4726-00262d977ece	2026-07-11	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	568	496	3	164	1	f	\N
1534	7	tx_e35525e95266bddd5c9edd61	3f86e6ee-6a7e-e085-7e8f-68a6b3259f98	2026-07-13	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	431	376	3	164	1	f	\N
1535	7	tx_dfff209d768003e404f928c5	4d52170c-d31d-ea67-80d3-ee9366c7b13c	2026-07-13	Sushi Bar	SUSHI BAR BERLIN	\N	83	73	3	164	0	f	\N
1536	7	tx_279a9f83c7b7ece60e593f03	a5f2c27f-9fd8-7d18-6bcf-4099587192fa	2026-07-13	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	2391	2086	3	164	3	f	\N
1696	8	tx_7109b416b46bec38cf41da44	829fc2de-7b8c-30a1-730f-747498e6ee47	2026-09-22	City Taxi	CITY TAXI BERLIN	\N	2022	1759	2	\N	\N	f	\N
1653	1	tx_961e75eecff34ca560fae3f1	c1b9f6eb-3b16-16ca-6cb9-54eb5105756e	2026-09-03	Fresh Market	FRESH MARKET NEW YORK	\N	2210	1901	3	170	7	f	\N
1716	3	tx_dd5c038739f5ea5940513894	789502ef-ffef-407d-835b-56fa5cc99b31	2026-10-03	Noodle House	NOODLE HOUSE HAMBURG	\N	1127	999	3	183	10	f	\N
1684	8	tx_244aa8ed2754cd02ba2e1d15	3dca3ecc-a002-cd63-fbcb-51a3e2c760c8	2026-09-14	City Taxi	CITY TAXI BERLIN	\N	3825	3288	3	181	22	f	\N
1471	6	tx_22400a39ceb75d58e075c060	bac309b1-f237-a293-7f82-cc60df9d67df	2026-06-26	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	21381	15490	3	156	-36	f	\N
1777	8	tx_049213893bb8fc3659112096	7e87170a-c068-9d9c-4c79-48b52c354ce3	2026-10-30	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	453	\N	2	\N	\N	f	\N
1778	8	tx_a427a39ba7d11df183b3b05c	6b22c286-c85d-d2bf-b7fb-25103904f160	2026-10-30	Print Shop	PRINT SHOP BERLIN	\N	9359	\N	2	\N	\N	f	\N
1527	1	tx_9fb7caaffb9ce7921aad80ef	7c9daeb9-0afa-aedd-9203-4705c5686d14	2026-07-11	Metro Transit	METRO TRANSIT ONLINE	\N	193	168	3	161	-1	f	\N
1443	5	tx_15a31430d79da410c373a80c	cac1c996-3055-8167-f977-6d2a53b0197f	2026-06-21	Hair Salon	HAIR SALON HAMBURG	\N	1227	0	3	169	0	f	\N
1394	7	tx_e23f966b3ce31e529cd79ace	6af48c68-73e5-c2a5-fd19-b6a8fb7ed783	2026-06-08	Print Shop	PRINT SHOP BERLIN	\N	5932	5094	3	157	59	f	\N
1424	7	tx_836cdafe36f378271837176c	e123aebf-b320-af0b-413a-bd31680c008c	2026-06-17	Print Shop	PRINT SHOP BERLIN	\N	19173	16499	3	157	159	f	\N
1738	8	tx_28d4543a6c2089826356316a	ada56f46-17c2-a67a-e304-a17639f34a32	2026-10-12	Home Supply	HOME SUPPLY HAMBURG	\N	1011	900	2	\N	\N	f	\N
1662	8	tx_776681bd4ca2d3db57e2ac0e	ae80cd6b-1b70-ff6f-8724-2267ee8a96eb	2026-09-07	Rail Express	RAIL EXPRESS NEW YORK	\N	2667	2290	3	181	18	f	\N
1715	3	tx_bebcc457d86f1552ae39f868	dbe28844-225b-44e9-9c87-4eaf68ff5664	2026-10-03	Noodle House	NOODLE HOUSE HAMBURG	\N	1	1	3	183	0	f	\N
1720	8	tx_343020018207c66de252a5ca	ba993f54-fdd3-5735-3234-0ea95843c744	2026-10-05	Power Utility	POWER UTILITY MUNICH	\N	2788	2470	2	\N	\N	f	\N
1719	8	tx_d5af00445a7aef210c4d6d58	8cbd4c8b-d8e7-d3fa-cef7-705c959db2ab	2026-10-05	Noodle House	NOODLE HOUSE HAMBURG	\N	1	1	2	\N	\N	f	\N
1633	7	tx_32a0db1d5d8c9e93c24c97e8	6bed2f88-a685-61c2-db64-9910461bbff4	2026-08-22	Office Supplies	OFFICE SUPPLIES MUNICH	\N	156	133	3	174	1	f	\N
1619	7	tx_efe218e26bae6f29f07e4886	98e475bf-faac-71a1-213e-4d5f93454542	2026-08-15	Gym Central	GYM CENTRAL ONLINE	\N	11242	9703	3	174	4	f	\N
1697	8	tx_b14eba08173f1a828b99fec1	38e0bc13-bef3-7dd1-8a3d-37b1fd318580	2026-09-24	City Taxi	CITY TAXI BERLIN	\N	1143	995	2	\N	\N	f	\N
1699	8	tx_0bc48001573ec0abe44cfff3	82c9119a-dc24-2bfa-a2fe-6faccbf2a197	2026-09-28	Wine Shop	WINE SHOP ONLINE	\N	4047	3546	2	\N	\N	f	\N
1700	8	tx_2115d6739a6b1077f39ce97c	b4bed3f2-b0f0-df20-3869-b4cf1d97ee5a	2026-09-29	Burger Joint	BURGER JOINT MUNICH	\N	4475	3922	2	\N	\N	f	\N
1701	8	tx_4a942acd9fa08ff96c35da28	09b149e8-1b2f-6ede-edbb-57c9827bd702	2026-09-30	Payment Service	PAYMENT SERVICE NEW YORK	\N	1560	1369	2	\N	\N	f	\N
1681	8	tx_38bde7af90d1eb48b5176cb1	4e997088-d899-557a-2c5c-8e6d088afc64	2026-09-12	Print Shop	PRINT SHOP BERLIN	\N	5608	4819	3	181	36	f	\N
1704	8	tx_7bddd3c99d4f73f74a1a2863	501e01f1-1695-fd96-0d94-d703e6d23cf9	2026-09-30	Print Shop	PRINT SHOP BERLIN	\N	1715	1503	2	\N	\N	f	\N
1705	8	tx_4c508da28f85323393bc6b21	cf81b0c6-4d9f-2fee-1872-4cd622461807	2026-10-01	Home Supply	HOME SUPPLY HAMBURG	\N	4176	3667	2	\N	\N	f	\N
1702	8	tx_f6252117ad23906b8e17b626	bee220bd-166b-d6ae-20ec-bea624bd6d92	2026-09-30	Print Shop	PRINT SHOP BERLIN	\N	5964	5226	2	\N	\N	f	\N
1703	8	tx_fe2baccd16b79db28c601288	a3a5d95e-8787-73ab-f58a-7dce3b79faa5	2026-09-30	Concert Hall	CONCERT HALL BERLIN	\N	1526	1340	2	\N	\N	f	\N
1707	8	tx_ef7469d2b7fea3796275e92d	2d063986-bcac-4b9a-75af-65ceb45ab8e5	2026-10-01	Book Nook	BOOK NOOK ONLINE	\N	5151	4523	2	\N	\N	f	\N
1708	8	tx_ddf528ccf8e437e9c81590ce	9b45093b-b501-5ac2-ba4a-a76715e56dfe	2026-10-01	Print Shop	PRINT SHOP BERLIN	\N	14278	12511	2	\N	\N	f	\N
1706	8	tx_a6151de131c6601f83bcaf9c	2131a841-7c3e-fa83-1d2a-5b3726c59984	2026-10-01	Book Nook	BOOK NOOK ONLINE	\N	813	714	2	\N	\N	f	\N
1710	8	tx_bfb03809c5094585bb4c3d8d	918e9460-8493-cae4-9e70-6f9cbeafbb40	2026-10-01	Print Shop	PRINT SHOP BERLIN	\N	9902	8694	2	\N	\N	f	\N
1717	8	tx_6420ba8bea0014894fc11f17	ac7b9575-1140-4343-9978-cf26dbb2ca8c	2026-10-05	News Daily	NEWS DAILY BERLIN	\N	1401	1242	2	\N	\N	f	\N
1721	8	tx_89c3b310e4122f0c7d5b4040	20380cc4-305c-fb25-a652-af3c23dd71f1	2026-10-05	Gym Central	GYM CENTRAL ONLINE	\N	1617	1433	2	\N	\N	f	\N
1737	8	tx_5646f34628682bd71123fbdc	8b848987-46b4-2865-69c7-14b217b53555	2026-10-12	Gadget World	GADGET WORLD NEW YORK	\N	4802	4277	2	\N	\N	f	\N
1722	8	tx_98071bd23740e1910c9f280d	bd15dbf3-4956-9106-0df9-8cec49f49678	2026-10-05	Sky Airways	SKY AIRWAYS HAMBURG	\N	4156	3681	2	\N	\N	f	\N
1723	8	tx_e6ef64cce7fc118c854d3398	17bd114e-199f-161b-94a3-81e5996aac1a	2026-10-07	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	975	866	2	\N	\N	f	\N
1724	8	tx_a873ca5e70aa47597c64a486	c6673dba-50df-d96f-6d29-5b7f61e0e88c	2026-10-07	Rail Express	RAIL EXPRESS NEW YORK	\N	5678	5039	2	\N	\N	f	\N
1725	8	tx_1ea1c28a99d4f03e72d884a1	1937436a-540b-ffdf-a646-335421b050f6	2026-10-07	Cloud Storage Inc	CLOUD STORAGE INC ONLINE	\N	5966	5293	2	\N	\N	f	\N
1726	8	tx_60b492fa641eddda7f7d9432	43f1164f-798a-1299-14d0-4be667544057	2026-10-07	Print Shop	PRINT SHOP BERLIN	\N	5707	5057	2	\N	\N	f	\N
1733	8	tx_48725fc5bc7457a4cf22ac85	a07909b8-4321-0105-fc8d-68c36b365157	2026-10-10	Sushi Bar	SUSHI BAR BERLIN	\N	1419	1262	2	\N	\N	f	\N
1741	8	tx_9c5038a5a9979729e76c1268	f6c25af0-233a-931a-ed9f-0abc653b3522	2026-10-14	Taco Stand	TACO STAND BERLIN	\N	504	449	2	\N	\N	f	\N
1736	8	tx_68a5aa612d4dd739895232fe	61558348-41ad-0af7-ef18-2e5ce4fd41a5	2026-10-12	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1275	1134	2	\N	\N	f	\N
1718	8	tx_9ca307cb07af61536bdab09f	5395a67a-9ba0-0126-8ada-80d6ef8bda87	2026-10-05	Sushi Bar	SUSHI BAR BERLIN	\N	882	781	2	\N	\N	f	\N
1734	8	tx_e8c7e7df894b8a63b68cea5f	53e7a8b5-4165-4df9-0021-1d9289cb6331	2026-10-10	Gym Central	GYM CENTRAL ONLINE	\N	13589	0	2	\N	\N	f	\N
1746	8	tx_93b10c1a7e0c560ffb8487ee	fb261279-53b7-d8bf-992b-ef4766c0301c	2026-10-15	Noodle House	NOODLE HOUSE HAMBURG	\N	430	384	2	\N	\N	f	\N
1740	8	tx_f3f3b696a5bf80fadcd6e716	9e7c9725-3f3b-656f-9e51-a3c415ed0cb3	2026-10-13	Gadget World	GADGET WORLD NEW YORK	\N	422	376	2	\N	\N	f	\N
1732	5	tx_ccf8360b7d20eb7b17e3c2a9	76a1661f-b3c8-da46-3ffe-9ce493da619f	2026-10-10	Garden Center	GARDEN CENTER NEW YORK	\N	217	193	2	\N	\N	f	\N
1713	8	tx_d468c1b749710d0e9c7b8b6d	54c36b29-04a3-5484-c5ab-9676a0565797	2026-10-03	Print Shop	PRINT SHOP BERLIN	\N	1912	1685	2	\N	\N	f	\N
1742	8	tx_46185a92fc702ce3a3710571	c0c05d55-791d-1d70-37fc-672953f04078	2026-10-14	Rail Express	RAIL EXPRESS NEW YORK	\N	2854	2544	2	\N	\N	f	\N
1743	8	tx_6b6b89f1c9d8ae49bc6dbf81	054178e3-6056-11a4-5ba8-b151c2d88604	2026-10-14	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1444	1287	2	\N	\N	f	\N
1745	8	tx_4c0ccd3ea68e37e88fc1132f	66dd85d8-fef6-fbbc-b7f4-5c7e68f65242	2026-10-15	Taco Stand	TACO STAND BERLIN	\N	622	556	2	\N	\N	f	\N
1714	8	tx_eae49abaf323dc8c514f1908	b927eafc-5402-c7fa-7dde-0a86cd534bc6	2026-10-03	Cloud Storage Inc	CLOUD STORAGE INC ONLINE	\N	3220	2839	2	\N	\N	f	\N
1739	1	tx_f5e087b5f3e1765425b3e80c	54a346a6-5286-f7c2-292d-00dfca18bbca	2026-10-12	Metro Transit	METRO TRANSIT ONLINE	\N	115	102	2	\N	\N	f	\N
1735	8	tx_8e84a9cab7ae28663f56d5c7	7fa9cf49-d0e2-7e45-0c83-c6917f27cb46	2026-10-10	Gym Central	GYM CENTRAL ONLINE	\N	20458	0	2	\N	\N	f	\N
1698	8	tx_f675c0e8953782d7c8a55e15	428fafe5-b4c5-d75f-efc8-644ee531c416	2026-09-26	Burger Joint	BURGER JOINT MUNICH	\N	561	491	2	\N	\N	f	\N
1567	7	tx_a0ef96302a3ec3027c42f9f3	c34c7764-f307-364c-83c7-c7a530393756	2026-07-24	Home Supply	HOME SUPPLY HAMBURG	\N	1861	1627	3	164	-1	f	\N
1605	7	tx_de809170967481a2e3fa5f91	848372d4-230c-7e3e-f270-3dc96140f7fd	2026-08-09	Harbor Hotel	HARBOR HOTEL ONLINE	\N	175	150	3	174	0	f	\N
1611	7	tx_981422031149b16130d589c9	921a2222-4dbe-f1e9-6a8d-b218bf0584b3	2026-08-13	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	1263	1092	3	174	-1	f	\N
1594	3	tx_d05daf82644b4ac64f06a314	99ad6e28-d156-e401-6071-a9e39db8d6c7	2026-08-01	Print Shop	PRINT SHOP BERLIN	\N	2382	2067	3	162	22	f	\N
1604	5	tx_0a538ba812243917bbd4a7a1	789075db-de1c-8972-fa17-b96c8445deb9	2026-08-10	Garden Center	GARDEN CENTER NEW YORK	\N	199	172	3	169	0	f	\N
1597	7	tx_33759086772c707d963509a0	9c3c7080-0dd3-0955-5646-134d012409be	2026-08-02	Print Shop	PRINT SHOP BERLIN	\N	4868	4215	3	174	-13	f	\N
1612	7	tx_c04f6556bec358c058b74d28	fda9cc68-8783-497d-cade-3f6d01d6d469	2026-08-13	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	1473	1274	3	174	-2	f	\N
1596	7	tx_00dfb260dab73f54f5409c10	4129e3b1-b46e-d31c-ebb0-ede98e49081b	2026-08-04	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1423	1231	3	174	-2	f	\N
1602	7	tx_603f849f6dd77fb66d1d2e7e	3ebfaa8a-643c-411d-f3f4-5eeb51f98adb	2026-08-07	City Pharmacy	CITY PHARMACY BERLIN	\N	3926	2717	3	174	672	f	\N
1603	7	tx_9b4cb5f6bd9acf52e8279742	30af6d63-b267-55c8-68d5-b93ae70e48e3	2026-08-07	Stream Plus	STREAM PLUS HAMBURG	\N	429	0	3	174	0	f	\N
1613	7	tx_03c90d43c1714c30a0f55960	962c6ad3-22bc-5d15-632a-5a89fca5183c	2026-08-13	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	491	425	3	174	0	f	\N
1618	7	tx_662bb594b65c14003449c8ef	3c260f61-f208-3a88-c355-596c494180a1	2026-08-15	Book Nook	BOOK NOOK ONLINE	\N	631	545	3	174	0	f	\N
1620	7	tx_ce75f60a0650832a1329ecb0	4a4a3c36-cf32-5828-e32e-2e031a844ba1	2026-08-15	Gym Central	GYM CENTRAL ONLINE	\N	274	237	3	174	0	f	\N
1627	7	tx_a427c2fc25986d10430e2962	a45db2dc-0ea3-f452-832a-8b3ca86a189a	2026-08-17	Book Nook	BOOK NOOK ONLINE	\N	398	343	3	174	0	f	\N
1634	7	tx_efcfb5b91b4fe842094f3702	a7e3614b-fa96-729b-d9b4-d2425f7580ca	2026-08-21	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1412	1206	3	174	13	f	\N
1728	8	tx_c62c9228168f7516700b3f6d	674a1561-c84f-e38a-2728-51dde2dfbd31	2026-10-08	Gym Central	GYM CENTRAL ONLINE	\N	7073	6094	2	\N	\N	f	\N
1729	8	tx_d09a45f530e7ed226ca7302d	6bfafbb0-4030-ac2f-8033-f661879381e8	2026-10-08	Noodle House	NOODLE HOUSE HAMBURG	\N	4876	4154	2	\N	\N	f	\N
1606	1	tx_2bae7c0b6f6c9915ce3bf623	f72ec232-3d79-d3eb-e70c-47d3cc79bca3	2026-08-11	Metro Transit	METRO TRANSIT ONLINE	\N	96	83	3	170	0	f	\N
1748	8	tx_a324cec69e667f23fb01992d	d2285c65-d967-bc7d-a872-0bc7b1c57ffe	2026-10-16	Print Shop	PRINT SHOP BERLIN	\N	13455	12007	2	\N	\N	f	\N
1749	8	tx_4b69fc7eae55c05a038566e4	4e966e7c-01b0-914d-892f-1cb93b4aaf7e	2026-10-16	Print Shop	PRINT SHOP BERLIN	\N	8823	7873	2	\N	\N	f	\N
1751	8	tx_8145f4287502d07343715d02	d34d8c87-2302-a744-7199-9a05b41d3eb4	2026-10-17	Print Shop	PRINT SHOP BERLIN	\N	2020	1796	2	\N	\N	f	\N
1754	8	tx_3b84eed28cebd277ac83bc8c	97d3a72d-a1e1-b7e1-d036-34e65b67754a	2026-10-19	Gym Central	GYM CENTRAL ONLINE	\N	284	252	2	\N	\N	f	\N
1752	8	tx_a499e5c1ca4c0b8d68c6bf71	acc12bd0-1d73-7be1-1d59-a8bd947dce7e	2026-10-17	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1316	1170	2	\N	\N	f	\N
1744	8	tx_75a7f65eb3b2ac285602ef07	b69108b0-3860-f3bf-bff1-5575a151f391	2026-10-15	City Pharmacy	CITY PHARMACY BERLIN	\N	2385	2129	2	\N	\N	f	\N
1731	8	tx_254495c1a49fb79897bd5d61	72fb3160-c2a0-101d-a60a-c80179c0c977	2026-10-09	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1536	1363	2	\N	\N	f	\N
1755	8	tx_2dfc42b40fdeadd2f92e9e50	4115fbe7-fb7b-4d32-d6d0-3d54918528d2	2026-10-19	City Taxi	CITY TAXI BERLIN	\N	1124	997	2	\N	\N	f	\N
1762	8	tx_98adee8cc28a4fb0f7811b3d	67391485-3431-3b04-3ad9-a8e59644e94a	2026-10-23	Fresh Market	FRESH MARKET NEW YORK	\N	1305	1161	2	\N	\N	f	\N
1763	8	tx_59efb93dd07de2ef98afd23a	24b4e1f3-8fe5-9242-ef90-3f756a246b0f	2026-10-23	Garden Center	GARDEN CENTER NEW YORK	\N	59482	52816	2	\N	\N	f	\N
1727	8	tx_0ff17b318680a3e5f462fa75	9ff492e3-5dea-f7e8-bcc8-63a911d533b2	2026-10-08	Yoga Studio	YOGA STUDIO NEW YORK	\N	1075	953	2	\N	\N	f	\N
1750	8	tx_b0b1a357a5a5ab6d498e63a6	cf3fc4de-35b6-2a57-5d95-008988393e17	2026-10-17	Burger Joint	BURGER JOINT MUNICH	\N	3160	2810	2	\N	\N	f	\N
1643	7	tx_1f294be6ed85cea10c8c3967	dc3e68fc-6114-7863-49ed-c7b63b9800e0	2026-08-27	Fresh Market	FRESH MARKET NEW YORK	\N	539	461	3	174	4	f	\N
1644	7	tx_b262fe5ba4a3addd9f389b25	7e8d300a-a4ba-4c9b-4124-54b2aa7c5e1a	2026-08-27	Fresh Market	FRESH MARKET NEW YORK	\N	539	461	3	174	4	f	\N
1765	1	tx_b139d7909ec06de7da82b12a	48997a88-3a6e-05b0-1864-6dfb505c325d	2026-10-23	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	2082	1852	2	\N	\N	f	\N
1761	8	tx_952ce3d062704e3f58979683	b40546a7-61b1-1b44-59b2-22689100e504	2026-10-22	Coastal Air	COASTAL AIR MUNICH	\N	820	728	2	\N	\N	f	\N
1757	8	tx_712502b5ef940311fd24abd7	98fa06f5-a40f-9083-1971-d1cee254fe7c	2026-10-20	Gym Central	GYM CENTRAL ONLINE	\N	7573	6719	2	\N	\N	f	\N
1747	8	tx_72e1925a74b2d20622660770	9bcc1aad-5be9-96c5-cf28-56e2617026dd	2026-10-15	Pizza Forno	PIZZA FORNO MUNICH	\N	14252	12676	2	\N	\N	f	\N
1756	8	tx_e5e83516d55f10c35343722e	67ccf68b-f480-5a72-4494-062f02e0113e	2026-10-20	Print Shop	PRINT SHOP BERLIN	\N	26454	11660	2	\N	\N	f	\N
1649	1	tx_d8111ee31ce369569daf527a	357588d2-4601-72c5-0caa-a3b5cdcee083	2026-08-31	Northside Cafe	NORTHSIDE CAFE ONLINE	\N	426	366	3	170	2	f	\N
1673	5	tx_f211cf331c898ae97d3f4408	f81a72cc-7997-1317-0ac8-223c4a131a88	2026-09-10	Garden Center	GARDEN CENTER NEW YORK	\N	159	135	3	176	6	f	\N
1646	7	tx_87a038cfd53ed9d1afafd983	a6b2b062-0477-4368-d4ee-fb93fe572e2d	2026-08-28	Book Nook	BOOK NOOK ONLINE	\N	1274	1092	3	174	7	f	\N
1647	7	tx_457c4e8e4e6927a076975710	196a8b1c-8595-64c2-6c54-f576838f74f8	2026-08-28	Concert Hall	CONCERT HALL BERLIN	\N	3617	3102	3	174	21	f	\N
1759	8	tx_fbb123b0cdd538d83b3b85ca	a60bfd17-5510-da20-da21-72c39f058f2b	2026-10-21	Cloud Storage Inc	CLOUD STORAGE INC ONLINE	\N	6335	5637	2	\N	\N	f	\N
1760	8	tx_093442cebd54893dca38902a	bf297058-6e3b-7836-dc42-ddc06af89c03	2026-10-21	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	750	668	2	\N	\N	f	\N
1776	8	tx_05555fc290473c853a21f958	90b3075c-3100-9d54-9d36-67dd05ea420a	2026-09-02	Music Box	MUSIC BOX MUNICH	\N	5453	4696	3	181	24	f	\N
1782	3	tx_df697a771ee6ce424e4391f7	3bef13f4-7631-ebb3-bfd1-41f1d7c2e71c	2026-11-01	Print Shop	PRINT SHOP BERLIN	\N	2502	\N	2	\N	\N	f	\N
1783	8	tx_31079b4d518d320cbab38760	70952bdb-c6fd-9cef-9c8c-8a1f4561c22b	2026-11-02	Gym Central	GYM CENTRAL ONLINE	\N	758	\N	2	\N	\N	f	\N
1784	8	tx_06e43e0d2fcac7a4392d8792	a485173b-ee94-98d0-9932-f879b615e096	2026-11-02	Noodle House	NOODLE HOUSE HAMBURG	\N	4923	\N	2	\N	\N	f	\N
1785	1	tx_d2d0bea71e2a84774634a471	a07e1254-9706-37eb-2da8-ca169f0868cb	2026-11-02	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1694	\N	2	\N	\N	f	\N
1791	1	tx_983d7f58746750f146253ae4	8c9e97fa-c6ef-4c9a-cff7-1fd1ea5d643d	2026-11-06	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	625	\N	2	\N	\N	f	\N
1792	1	tx_97aeec760c338876aeefb5c8	e5e85eb6-249e-20e4-fb08-03319f0c2bc1	2026-11-07	Sushi Bar	SUSHI BAR BERLIN	\N	5228	\N	2	\N	\N	f	\N
1793	1	tx_54740932e324ccd530f239b5	6738d5e6-c869-c87a-a5b6-efdcaccdc3a5	2026-11-09	Cloud Storage Inc	CLOUD STORAGE INC ONLINE	\N	1379	\N	2	\N	\N	f	\N
1795	8	tx_c5b79f6d3da6829b5a158f8d	061da707-ac94-a0f0-dfce-203bbff3c7ef	2026-11-10	Print Shop	PRINT SHOP BERLIN	\N	1322	\N	2	\N	\N	f	\N
1796	1	tx_d3e5f1f0501678646aef0036	ccf5ce85-7dad-efc3-9aa0-67d174378357	2026-11-10	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	915	\N	2	\N	\N	f	\N
1797	5	tx_4cdc6988c4b4b2673cabdb26	349d895d-2fca-bda9-8e1c-c6ccd5076756	2026-11-10	Garden Center	GARDEN CENTER NEW YORK	\N	118	\N	2	\N	\N	f	\N
1798	8	tx_0b56079398ed5f6f9ce9aee5	8007f029-572a-6663-63bc-7785e5c671c1	2026-11-11	Print Shop	PRINT SHOP BERLIN	\N	7314	\N	2	\N	\N	f	\N
1651	7	tx_b7f2c75e56539927e858f7eb	a8703fe9-fe2d-9079-fd7e-aa54f84a53e5	2026-08-31	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	570	489	3	174	4	f	\N
1758	8	tx_b1b82656339a4ce925a50e85	00effe85-eb95-a477-2e5b-8f69568b815c	2026-10-21	Coastal Air	COASTAL AIR MUNICH	\N	690	614	2	\N	\N	f	\N
1663	8	tx_1ee455ed886d589a27d53c55	ff7f930e-00e0-ad5c-b0ca-d8cdee798a8d	2026-09-07	Riverside Inn	RIVERSIDE INN HAMBURG	\N	414	356	3	181	3	f	\N
1664	8	tx_b4745c500fa5717bf50b457b	fae9e0a2-6168-74ab-6483-d59fb95e6397	2026-09-07	City Taxi	CITY TAXI BERLIN	\N	1369	1176	3	181	9	f	\N
1667	8	tx_5a50c991a60e235500555d80	1631740b-5ba3-354e-e237-adcc4423f0c6	2026-09-09	Cloud Storage Inc	CLOUD STORAGE INC ONLINE	\N	3527	3031	3	181	22	f	\N
1668	8	tx_cacc1328153789f64148dd1e	88a1fc91-e819-58ef-52fd-01f1c0599267	2026-09-09	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	393	338	3	181	2	f	\N
1670	8	tx_68bbea68d4d8e2fb070e4bab	a21fa74e-80df-404d-1e59-53c676e5596f	2026-09-10	Gym Central	GYM CENTRAL ONLINE	\N	9183	0	3	181	0	f	\N
1671	8	tx_152518a2c045a032cc8b929d	105ae64c-dca5-46f6-caa1-6cc27b8e378b	2026-09-10	Print Shop	PRINT SHOP BERLIN	\N	11676	10028	3	181	79	f	\N
1676	8	tx_8f1244dfd69b4d4f7c7b89f1	ab24d525-860c-8dab-5e80-9a66c69a1127	2026-09-11	Green Basket	GREEN BASKET MUNICH	\N	5017	4305	3	181	38	f	\N
1677	8	tx_cefe7931e1514d66a63d61ef	0d6a7663-772d-14c5-d2cb-630ecc441c4a	2026-09-12	Wine Shop	WINE SHOP ONLINE	\N	608	522	3	181	5	f	\N
1678	8	tx_8490056e7d2a3e296d3b3b08	039c6b46-8d0d-9230-1070-6b28e95c78b2	2026-09-12	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	1143	982	3	181	7	f	\N
1679	8	tx_03711999adedbbdf3133073c	2cf9f0a2-0930-2c39-fda0-262aa657c733	2026-09-12	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	1029	884	3	181	7	f	\N
1680	8	tx_c6711fa15a8d7aa701d3fa2e	037cda5e-7b0a-c5fe-42be-fe9665a6710c	2026-09-12	Print Shop	PRINT SHOP BERLIN	\N	4551	3905	3	181	34	f	\N
1682	8	tx_09f6e1061e4c06c149fd19b6	35183587-6a7c-3314-bb28-648913359a21	2026-09-14	City Taxi	CITY TAXI BERLIN	\N	234	201	3	181	1	f	\N
1683	8	tx_0520a70f11c091392f68e3f0	3c708df7-82f7-3c87-e479-a3b8a2f20c37	2026-09-14	Gym Central	GYM CENTRAL ONLINE	\N	1334	1147	3	181	8	f	\N
1685	8	tx_dc73e6300edc64e27d07fb9e	49768b54-e00a-8f87-2e37-9ee1babc9c78	2026-09-16	Gym Central	GYM CENTRAL ONLINE	\N	17218	0	3	181	0	f	\N
1686	8	tx_ebfac159a351ce494a8f2928	c581b645-388c-5c34-5271-77d3582d6572	2026-09-16	Print Shop	PRINT SHOP BERLIN	\N	10734	9230	3	181	61	f	\N
1687	8	tx_617bd2547e5ae7e74d2859e3	0b65863f-ee8b-d988-80bc-d73e959f7568	2026-09-17	Metro Transit	METRO TRANSIT ONLINE	\N	3187	2755	3	181	4	f	\N
1688	8	tx_c6300104d1608fe5fdbca5c6	5866be8f-2201-3e26-e63e-91949bcdb174	2026-09-17	Phone Carrier	PHONE CARRIER HAMBURG	\N	312	270	3	181	1	f	\N
1689	8	tx_51f9d6b1e796ce3c0aafbe22	4e2a098d-8e11-1c5f-003f-ca56d952060d	2026-09-17	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	1009	872	3	181	1	f	\N
1786	8	tx_eb850eb917e32a6588e1d5c2	9417438d-1bc0-9c4c-1278-1a3ea595c19f	2026-11-03	Print Shop	PRINT SHOP BERLIN	\N	481	\N	2	\N	\N	f	\N
1787	1	tx_82f42401cc8afc1a5c9c66a5	349d88ca-ef2d-2ee9-997a-eb19e26f19fd	2026-11-03	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	479	\N	2	\N	\N	f	\N
1788	8	tx_b5dc140e06a48d7323710c48	5412c1a5-ab05-53cb-4396-9ad7efd26449	2026-11-05	Gym Central	GYM CENTRAL ONLINE	\N	2139	\N	2	\N	\N	f	\N
1789	1	tx_21d6ef5a8e1998ee4fa09fa1	9db7f1d9-ec15-0556-1de1-37d36417891d	2026-11-05	Music Box	MUSIC BOX MUNICH	\N	126179	\N	2	\N	\N	f	\N
1790	1	tx_808336628b4db3024fb18aa0	0537faeb-1931-6065-fe89-ad21762bd2ea	2026-11-05	Gym Central	GYM CENTRAL ONLINE	\N	1343	\N	2	\N	\N	f	\N
1407	7	tx_c462979eb638726e1dd2a4a2	d97bf5c9-5971-1979-a9a0-86d97e4f69ea	2026-06-13	Corner Grocery	CORNER GROCERY ONLINE	\N	51990	44854	3	157	542	f	\N
1655	8	tx_df688be72a50608e583fc2f8	cdb98999-a52c-a6ea-96a4-e9e2ad0b1a86	2026-09-03	Print Shop	PRINT SHOP BERLIN	\N	1052	905	3	181	6	f	\N
1621	7	tx_712166a27cd8a39b3b1c768d	c7f947fc-c946-f6ab-b701-36ee5f71ab9d	2026-08-14	Office Supplies	OFFICE SUPPLIES MUNICH	\N	3074	2663	3	174	-8	f	\N
1652	7	tx_68a9d6c136d0774fd1de69e9	d58eb582-c94a-8558-08c2-e0a6e2f8f87e	2026-09-01	City Taxi	CITY TAXI BERLIN	\N	423	364	3	174	1	f	\N
1660	8	tx_ccc11e3bba95c4eb14505800	5d55d7ca-1129-c9f1-92f5-5090507b5183	2026-09-05	Power Utility	POWER UTILITY MUNICH	\N	200	172	3	181	1	f	\N
1764	8	tx_994fed860783ea9270a4fcea	0a4b7522-8d18-faf2-9db2-a345827c5f00	2026-10-23	Garden Center	GARDEN CENTER NEW YORK	\N	66118	58709	2	\N	\N	f	\N
1780	8	tx_a9dd10f1e1ba33f9c2d02fb1	08799d17-6288-fea7-410e-1a197d4dab8f	2026-10-31	Phone Carrier	PHONE CARRIER HAMBURG	\N	1517	\N	2	\N	\N	f	\N
1377	7	tx_79aed71189deedc8dda89c13	7cfc2590-4558-3e41-dafb-89639b25f45a	2026-06-06	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	816	701	3	157	8	f	\N
1378	7	tx_648388e582a761bfbe0310b6	ca42c50b-4e44-c9c9-d921-b9a51f0a8acc	2026-06-06	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1821	1564	3	157	18	f	\N
1379	7	tx_75cc177a85f4a61f049a88cd	ad719be6-1332-aa10-8b8b-4eeefc5ed093	2026-06-06	Harbor Hotel	HARBOR HOTEL ONLINE	\N	473	407	3	157	5	f	\N
1380	7	tx_e0a37067a4fc804c5ad8e886	0d4e25de-f05a-b696-17d7-4d2982e0f221	2026-06-07	Toy Store	TOY STORE ONLINE	\N	5156	4428	3	157	52	f	\N
1395	7	tx_33e74e533608d8c54db484b4	751cdcdd-eb97-6222-0256-2ada69a48add	2026-06-10	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	131	113	3	157	1	f	\N
1405	7	tx_5b5be70d7f1fefbb5faffee1	85568424-ef62-2c62-5831-b0487ea1c14d	2026-06-12	Insurance Co	INSURANCE CO BERLIN	\N	20437	17630	3	157	125	f	\N
1406	7	tx_91ec01fde18a4bbf243d17f0	5498f3a9-f77b-04c3-4102-bca8e099c2a9	2026-06-13	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	4515	3896	3	157	27	f	\N
1419	7	tx_b116df93f3e7a08e3e530c25	2500d07f-c23f-cdc2-f1d3-99dc1fb5fff8	2026-06-15	Print Shop	PRINT SHOP BERLIN	\N	10082	8698	3	157	61	f	\N
1421	7	tx_aa67cc5df4e2b2f9285bfa1e	c4b621eb-4242-4b6e-ed44-d0025f1609a5	2026-06-16	Print Shop	PRINT SHOP BERLIN	\N	4947	4256	3	157	42	f	\N
1420	7	tx_0f01bc846450e19ad687a220	73caa26e-3be2-0e15-210d-cb343533dce1	2026-06-17	Print Shop	PRINT SHOP BERLIN	\N	5736	4949	3	157	35	f	\N
1432	7	tx_43b9d451168be9ddf14036ec	714002c2-d2a0-782e-e5f0-38858c10f854	2026-06-20	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	755	658	3	157	-2	f	\N
1433	7	tx_924c0560756bd50ed5bf5987	4369dff9-5be4-4c1d-6b58-d9bb50fde23c	2026-06-20	News Daily	NEWS DAILY BERLIN	\N	1473	1283	3	157	-3	f	\N
1434	7	tx_e9894bfdd4da03cd780cefbb	80fdc811-220e-253e-6ec0-f5b620ed8a0b	2026-06-20	News Daily	NEWS DAILY BERLIN	\N	491	428	3	157	-1	f	\N
1440	7	tx_ec9007ffbad281728428784d	a62dec36-776d-6b86-610e-d8e8079e3422	2026-06-21	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	82	71	3	157	0	f	\N
1441	7	tx_9bd447df598a479153855f4f	be5f0fd1-6c32-6eb5-a085-94dd7acc8fd7	2026-06-21	Rail Express	RAIL EXPRESS NEW YORK	\N	3580	3123	3	157	-13	f	\N
1442	7	tx_821f1d1a3da58d4c6b2142d8	3e5b5f9f-4182-0322-a542-2cb3f35aa444	2026-06-21	Stream Plus	STREAM PLUS HAMBURG	\N	1938	1688	3	157	-4	f	\N
1449	7	tx_41a3b84213c92c66886c288e	dbf7ca0d-0e10-97d9-939b-23803748b1d9	2026-06-21	Print Shop	PRINT SHOP BERLIN	\N	3073	2676	3	157	-7	f	\N
1448	7	tx_6718af030c5f7b12d7b75251	bbda9dd7-387b-9f31-1ea5-8c934b82c96f	2026-06-22	Sushi Bar	SUSHI BAR BERLIN	\N	1664	1449	3	157	-3	f	\N
1455	7	tx_42601743217a3336cb62f587	0932004a-960a-b61f-b834-3b6e41ae83ae	2026-06-22	Print Shop	PRINT SHOP BERLIN	\N	1094	953	3	157	-2	f	\N
1458	7	tx_0c48c22a25ac867c24b99824	3ad13794-2814-482c-d9db-1789ac43ff61	2026-06-22	Book Nook	BOOK NOOK ONLINE	\N	650	566	3	157	-2	f	\N
1453	7	tx_18eb78c5b0d2074564422452	df9974b6-27c7-9f42-a85c-287a343f52ba	2026-06-23	Phone Carrier	PHONE CARRIER HAMBURG	\N	223	194	3	157	-1	f	\N
1454	7	tx_8c88a6016e8efd9c05a29a7a	d80d0774-f034-2d4b-7c19-174e8ceb765f	2026-06-23	Hardware Store	HARDWARE STORE HAMBURG	\N	6197	5400	3	157	-16	f	\N
1456	7	tx_1790593c41e84684bb8f69b4	38b7d4db-6770-ed6d-d321-0ba4796f313f	2026-06-23	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	560	488	3	157	-2	f	\N
1658	1	tx_9212beb9b757b82c1e2f1fe5	809203d0-7d30-ccc5-bb4b-c2ec65ef56f2	2026-09-04	Phone Carrier	PHONE CARRIER HAMBURG	\N	3564	3070	3	170	7	f	\N
1659	1	tx_a3dd61bc34badfc5683f7c57	d0b4935d-e214-6bbd-088d-a738364fefa2	2026-09-04	Sushi Bar	SUSHI BAR BERLIN	\N	1693	1458	3	170	3	f	\N
1654	8	tx_888c378ce57c86d6fe4646cf	dfabf477-7141-054e-b428-107d993c3ba7	2026-09-02	Print Shop	PRINT SHOP BERLIN	\N	1698	1461	3	181	9	f	\N
1781	8	tx_6f0a0b2d5919b636bac09db8	39c7e213-4fbd-4796-e785-cff671fd93bb	2026-10-31	Garden Center	GARDEN CENTER NEW YORK	\N	1534	\N	2	\N	\N	f	\N
1457	7	tx_5237734110922482d6a534fc	db722c9e-cf7e-2ee5-2b94-63d42bff993f	2026-06-23	Harbor Hotel	HARBOR HOTEL ONLINE	\N	4906	4275	3	157	-13	f	\N
1460	7	tx_43c3dd73ed12b9186440d28c	74de47d3-af3a-7a8d-3ce1-46a82f188fb2	2026-06-24	Gym Central	GYM CENTRAL ONLINE	\N	1197	1046	3	157	-6	f	\N
1461	7	tx_63ecce22a0954f5e98029b12	1e6468f8-2ea5-e113-6d0f-026f352c6ca8	2026-06-24	Print Shop	PRINT SHOP BERLIN	\N	374	326	3	157	-2	f	\N
1476	7	tx_c11837b2019e77368ed7f272	cf986a1c-4bbf-a6ba-ce48-ddcd52c1043e	2026-06-26	Blue Door Bistro	BLUE DOOR BISTRO NEW YORK	\N	11444	10049	3	157	-106	f	\N
1477	7	tx_18e5f6764f0fb6cf5de72c19	999e23fd-281d-2d34-c520-3b566543588f	2026-06-26	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	1425	1251	3	157	-13	f	\N
1483	7	tx_ae53c6614ba48015a0dc7e90	eebc073d-bbe0-3a7d-20f1-2dc7eb3a1a1a	2026-06-26	Print Shop	PRINT SHOP BERLIN	\N	9735	8548	3	157	-90	f	\N
1484	7	tx_eff32bec2870c11947b29664	0669b6b3-00ff-93db-7555-debb9f73931d	2026-06-26	Print Shop	PRINT SHOP BERLIN	\N	10504	9223	3	157	-98	f	\N
1473	7	tx_79cabd643a1edde0d63b48d9	bbf1fa81-95cf-1801-a09f-5579ae53dd33	2026-06-27	Noodle House	NOODLE HOUSE HAMBURG	\N	995	870	3	157	-5	f	\N
1474	7	tx_73ea0a5938c4f9f27381abff	83259064-1497-6416-60b7-fbb277993848	2026-06-27	Sushi Bar	SUSHI BAR BERLIN	\N	1304	1141	3	157	-8	f	\N
1475	7	tx_789c080a8631c1fb90c82364	e59bad02-b397-eddf-7b81-16e3ceba1506	2026-06-27	Book Nook	BOOK NOOK ONLINE	\N	1842	1611	3	157	-11	f	\N
1482	7	tx_bd872247e2bde04be1ec863f	34b4e7aa-924e-573e-9def-99b0ec80a7d8	2026-06-28	Concert Hall	CONCERT HALL BERLIN	\N	2193	1918	3	157	-13	f	\N
1485	7	tx_337abf6b4dfe4c1e3b681878	0c2144f6-f545-7dd0-7b8b-c4ec15d4b2cd	2026-06-29	Stream Plus	STREAM PLUS HAMBURG	\N	262	0	3	157	0	f	\N
1486	7	tx_6e235c3aa8b96263c10bec75	0a38d865-a1ec-542f-d4b0-f2c4bb724982	2026-06-29	Stream Plus	STREAM PLUS HAMBURG	\N	262	229	3	157	-2	f	\N
1487	7	tx_5dc1881fe1af32133b7f3c24	5e7bbf02-7d37-d425-0568-6375e2a02d48	2026-06-29	Print Shop	PRINT SHOP BERLIN	\N	5404	4725	3	157	-30	f	\N
1492	7	tx_900796677860ffd8cda84e4f	96dfa118-cbcc-c0ca-6e27-c228472dd42e	2026-06-29	Northside Cafe	NORTHSIDE CAFE ONLINE	\N	2487	2175	3	157	-14	f	\N
1495	7	tx_7ed9b79c5a32e4773dbb5c1f	a99028d8-56a6-c2a9-ee44-4ba4c20bc802	2026-06-29	Print Shop	PRINT SHOP BERLIN	\N	557	487	3	157	-3	f	\N
1493	7	tx_5284c16f794368b6576ffa38	512330dc-4925-6c82-7605-02a16fa58d50	2026-07-01	Print Shop	PRINT SHOP BERLIN	\N	3390	2963	3	157	-18	f	\N
1494	7	tx_9ec4b9bcf519eaeeb6e1b051	90911cd4-503b-08f0-8749-0e16c5c2ec8b	2026-07-01	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	429	375	3	157	-2	f	\N
1499	7	tx_3ad87f79c9c5b3289ebf2f3e	126aa028-f696-b527-92f5-3437c7270fe4	2026-07-01	Cinema Lux	CINEMA LUX MUNICH	\N	2989	2613	3	157	-17	f	\N
1500	7	tx_74da390d2deb3010879d7428	f40a4535-945a-5c7e-25ab-ced06db719c5	2026-07-01	Print Shop	PRINT SHOP BERLIN	\N	359	314	3	157	-2	f	\N
1753	8	tx_ead03a70eeb25dca59c22c07	9a404b35-ba1b-2070-a1f5-a910588a87df	2026-10-19	Mountain Lodge	MOUNTAIN LODGE NEW YORK	\N	32062	0	2	\N	\N	f	\N
1766	8	tx_0499e4a250755945099f3aa9	4663b407-91ff-bde5-776d-c2c265116ba8	2026-10-24	Burger Joint	BURGER JOINT MUNICH	\N	2660	2363	2	\N	\N	f	\N
1767	1	tx_c85c320367d64c5d20afce14	ecd73bbd-ab43-5762-025e-c29694b7e39d	2026-10-27	Yoga Studio	YOGA STUDIO NEW YORK	\N	3748	3290	2	\N	\N	f	\N
1768	1	tx_401e40230e484d411fefe2a6	2bc56959-169f-844a-6314-a93785fd501d	2026-10-27	Music Box	MUSIC BOX MUNICH	\N	8870	7922	2	\N	\N	f	\N
1769	1	tx_0fba6a38475318a27a6960f1	b0c079cd-ceeb-6cd0-5721-3b1c2513210f	2026-10-27	Outdoor Gear Co	OUTDOOR GEAR CO BERLIN	\N	3002	2673	2	\N	\N	f	\N
1770	1	tx_a4684224b657448e76ab9c2e	386b0e76-d0b3-da98-0304-d4d2c7638efb	2026-10-28	Code Tools Ltd	CODE TOOLS LTD NEW YORK	\N	2044	1820	2	\N	\N	f	\N
1709	8	tx_4c388f049b52ed7e8cdfa046	5b1e6c35-943f-c4da-584a-1c464841dada	2026-10-01	Yoga Studio	YOGA STUDIO NEW YORK	\N	1994	0	2	\N	\N	f	\N
1771	6	tx_69c9fb21b983ffdab0a59e37	30913796-183c-c7c2-0ba8-9547a2e0e69c	2026-10-28	Concert Hall	CONCERT HALL BERLIN	\N	4000	3577	2	\N	\N	f	\N
1772	8	tx_244e37ec4718d2960c083a7f	3c18fc65-dfa6-46aa-b071-bcddb8b89bdb	2026-10-26	Dry Cleaners	DRY CLEANERS MUNICH	\N	11088	9874	2	\N	\N	f	\N
1775	7	tx_39803cc1f663d2c7c7445213	006fe4e8-45d7-d4c7-3413-46c80ec7b2d5	2026-10-28	Book Nook	BOOK NOOK ONLINE	\N	1430	1283	2	\N	\N	f	\N
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."user" (id, name, super_user, actual_sync_id, actual_encryption_password, actual_misc_account) FROM stdin;
3	carol	f	\N	\N	\N
2	bob	f	\N	\N	\N
1	alice	t	\N	\N	\N
\.


--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.account_id_seq', 8, true);


--
-- Name: bankaccount_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bankaccount_id_seq', 3, true);


--
-- Name: credit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.credit_id_seq', 53, true);


--
-- Name: exchange_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.exchange_id_seq', 43, true);


--
-- Name: payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payment_id_seq', 188, true);


--
-- Name: plaidaccount_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plaidaccount_id_seq', 22, true);


--
-- Name: plaidconnection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plaidconnection_id_seq', 13, true);


--
-- Name: transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transaction_id_seq', 1798, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_id_seq', 3, true);


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


