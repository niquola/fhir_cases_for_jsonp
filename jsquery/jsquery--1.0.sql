-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION jsquery" to load this file. \quit

CREATE TYPE jsquery;

CREATE FUNCTION jsquery_in(cstring)
	RETURNS jsquery
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION jsquery_out(jsquery)
	RETURNS cstring
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE TYPE jsquery (
	INTERNALLENGTH = -1,
	INPUT = jsquery_in,
	OUTPUT = jsquery_out,
	STORAGE = extended
);

CREATE FUNCTION jsquery_json_exec(jsquery, jsonb)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION json_jsquery_exec(jsonb, jsquery)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR @@ (
	LEFTARG = jsquery,
	RIGHTARG = jsonb,
	PROCEDURE = jsquery_json_exec,
	COMMUTATOR = '@@',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR @@ (
	LEFTARG = jsonb,
	RIGHTARG = jsquery,
	PROCEDURE = json_jsquery_exec,
	COMMUTATOR = '@@',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE FUNCTION jsquery_lt(jsquery, jsquery)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION jsquery_le(jsquery, jsquery)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION jsquery_eq(jsquery, jsquery)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION jsquery_ne(jsquery, jsquery)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION jsquery_ge(jsquery, jsquery)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION jsquery_gt(jsquery, jsquery)
	RETURNS bool
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR < (
	LEFTARG = jsquery,
	RIGHTARG = jsquery,
	PROCEDURE = jsquery_lt,
	COMMUTATOR = '>',
	NEGATOR = '>=',
	RESTRICT = scalarltsel,
	JOIN = scalarltjoinsel
);

CREATE OPERATOR <= (
	LEFTARG = jsquery,
	RIGHTARG = jsquery,
	PROCEDURE = jsquery_le,
	COMMUTATOR = '>=',
	NEGATOR = '>',
	RESTRICT = scalarltsel,
	JOIN = scalarltjoinsel
);

CREATE OPERATOR = (
	LEFTARG = jsquery,
	RIGHTARG = jsquery,
	PROCEDURE = jsquery_eq,
	COMMUTATOR = '=',
	NEGATOR = '<>',
	RESTRICT = eqsel,
	JOIN = eqjoinsel,
	HASHES, 
	MERGES
);

CREATE OPERATOR <> (
	LEFTARG = jsquery,
	RIGHTARG = jsquery,
	PROCEDURE = jsquery_eq,
	COMMUTATOR = '<>',
	NEGATOR = '=',
	RESTRICT = neqsel,
	JOIN = neqjoinsel
);

CREATE OPERATOR >= (
	LEFTARG = jsquery,
	RIGHTARG = jsquery,
	PROCEDURE = jsquery_ge,
	COMMUTATOR = '<=',
	NEGATOR = '<',
	RESTRICT = scalargtsel,
	JOIN = scalargtjoinsel
);

CREATE OPERATOR > (
	LEFTARG = jsquery,
	RIGHTARG = jsquery,
	PROCEDURE = jsquery_ge,
	COMMUTATOR = '<',
	NEGATOR = '<=',
	RESTRICT = scalargtsel,
	JOIN = scalargtjoinsel
);

CREATE FUNCTION jsquery_cmp(jsquery, jsquery)
	RETURNS int4
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR CLASS jsquery_ops
	DEFAULT FOR TYPE jsquery USING btree AS
		OPERATOR	1	< ,
	    OPERATOR	2	<= ,
		OPERATOR	3	= ,
		OPERATOR	4	>= ,
		OPERATOR	5	>,
		FUNCTION	1	jsquery_cmp(jsquery, jsquery);

CREATE FUNCTION jsquery_hash(jsquery)
	RETURNS int4
	AS 'MODULE_PATHNAME'
	LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR CLASS jsquery_ops
	DEFAULT FOR TYPE jsquery USING hash AS
	OPERATOR	1	=,
	FUNCTION	1	jsquery_hash(jsquery);
