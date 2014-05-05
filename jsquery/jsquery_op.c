/*
 * contrib/jsquery/jsquery_op.c
 */
#include "postgres.h"

#include "miscadmin.h"
#include "utils/builtins.h"
#include "utils/pg_crc.h"

#include "jsquery.h"

static bool recursiveExecute(char *jqBase, int32 jqPos, JsonbValue *jb);

static int
compareNumeric(Numeric a, Numeric b)
{
	return	DatumGetInt32(
				DirectFunctionCall2(
					numeric_cmp,
					PointerGetDatum(a),
					PointerGetDatum(b)
				)
			);

}

static bool
recursiveAny(char *jqBase, int32 jqPos, JsonbValue *jb)
{
	bool			res = false;
	JsonbIterator	*it;
	int32			r;
	JsonbValue		v;

	check_stack_depth();


	it = JsonbIteratorInit(jb->val.binary.data);

	while(res == false && (r = JsonbIteratorNext(&it, &v, true)) != WJB_DONE)
	{
		if (r == WJB_KEY)
		{
			r = JsonbIteratorNext(&it, &v, true);
			Assert(r == WJB_VALUE);
		}

		if (r == WJB_VALUE || r == WJB_ELEM)
		{
			res = recursiveExecute(jqBase, jqPos, &v);

			if (res == false && v.type == jbvBinary)
				res = recursiveAny(jqBase, jqPos, &v);
		}
	}

	return res;
}

static bool
checkEquality(char *jqBase, int32 jqPos, int32 type, JsonbValue *jb)
{
	int		len;

	if (jb->type == jbvBinary)
		return false;
	if (jb->type != type /* see enums */)
		return false;

	switch(type)
	{
		case jqiNull:
			return true;
		case jqiString:
			read_int32(len, jqBase, jqPos);
			return (len == jb->val.string.len && memcmp(jb->val.string.val, jqBase + jqPos, len) == 0);
		case jqiBool:
			read_byte(len, jqBase, jqPos);
			return (jb->val.boolean == (bool)len);
		case jqiNumeric:
			return (compareNumeric((Numeric)(jqBase + jqPos), jb->val.numeric) == 0);
		default:
			elog(ERROR,"Wrong state");
	}
}

static bool
makeCompare(char *jqBase, int32 jqPos, int32 type, int32 op, JsonbValue *jb)
{
	int	res;

	if (jb->type != jbvNumeric)
		return false;
	if (jb->type != type /* see enums */)
		return false;

	res = compareNumeric(jb->val.numeric, (Numeric)(jqBase + jqPos));

	switch(op)
	{
		case jqiLess:
			return (res < 0);
		case jqiGreater:
			return (res > 0);
		case jqiLessOrEqual:
			return (res <= 0);
		case jqiGreaterOrEqual:
			return (res >= 0);
		default:
			elog(ERROR, "Unknown operation");
			return false;
	}
}

static bool
executeExpr(char *jqBase, int32 jqPos, int32 op, JsonbValue *jb)
{
	int32	type;
	int32	nextPos;

	check_stack_depth();

	jqPos = readJsQueryHeader(jqBase, jqPos, &type, &nextPos);

	Assert(nextPos == 0);
	Assert(type == jqiString || type == jqiNumeric || type == jqiNull || type == jqiBool || type == jqiArray);

	if (op == jqiEqual)
	{
		return checkEquality(jqBase, jqPos, type, jb); 
	}
	else if (op == jqiOverlap && jb->type != jbvBinary)
	{
		/*
		 * scalar && array emulates scalar IN ()
		 */
		int32   i, nelems, *arrayPos;

		if (type != jqiArray)
			return false;

		read_int32(nelems, jqBase, jqPos);
		arrayPos = (int32*)(jqBase + jqPos);

		for(i=0; i<nelems; i++)
			if (executeExpr(jqBase, arrayPos[i], jqiEqual, jb))
				return true;

		return false;
	}
	else if (op == jqiOverlap || op == jqiContains || op == jqiContained)
	{
		int32   i, nelems, *arrayPos;
		int32	r;
		JsonbIterator	*it;
		JsonbValue		v;
		int32			nres = 0, nval = 0;

		if (jb->type != jbvBinary)
			return false;
		if (type != jqiArray)
			return false;

		read_int32(nelems, jqBase, jqPos);
		arrayPos = (int32*)(jqBase + jqPos);

		it = JsonbIteratorInit(jb->val.binary.data);

		while((r = JsonbIteratorNext(&it, &v, true)) != WJB_DONE)
		{
			if (r == WJB_BEGIN_ARRAY)
				nval = v.val.array.nElems;

			if (r == WJB_ELEM)
			{
				bool res = false;

				for(i=0; i<nelems; i++)
				{
					if (executeExpr(jqBase, arrayPos[i], jqiEqual, &v))
					{
						if (op == jqiOverlap)
							return true;
						nres++;
						res = true;
						break;
					}
				}
			}
		}

		if (op == jqiContains)
			return (nres == nelems && nelems > 0);
		if (op == jqiContained)
			return (nres == nval && nval > 0);
		return false;
	} else {
		return makeCompare(jqBase, jqPos, type, op, jb);
	}
}

static bool
recursiveExecute(char *jqBase, int32 jqPos, JsonbValue *jb)
{
	int32	type;
	int32	nextPos;
	int32	left, right, arg;
	bool	res = false;

	check_stack_depth();

	jqPos = readJsQueryHeader(jqBase, jqPos, &type, &nextPos);

	switch(type) {
		case jqiAnd:
			read_int32(left, jqBase, jqPos);
			read_int32(right, jqBase, jqPos);
			Assert(nextPos == 0);
			res = (recursiveExecute(jqBase, left, jb) && recursiveExecute(jqBase, right, jb));
			break;
		case jqiOr:
			read_int32(left, jqBase, jqPos);
			read_int32(right, jqBase, jqPos);
			Assert(nextPos == 0);
			res = (recursiveExecute(jqBase, left, jb) || recursiveExecute(jqBase, right, jb));
			break;
		case jqiNot:
			read_int32(arg, jqBase, jqPos);
			Assert(nextPos == 0);
			res = ! recursiveExecute(jqBase, arg, jb);
			break;
		case jqiKey:
			if (jb->type == jbvBinary) {
				int32 		len;
				JsonbValue	*v, key;

				read_int32(len, jqBase, jqPos);
				key.type = jbvString;
				key.val.string.val = jqBase + jqPos;
				key.val.string.len = len;
				jqPos += len + 1;

				v = findJsonbValueFromSuperHeader(jb->val.binary.data, JB_FOBJECT, NULL, &key);

				Assert(nextPos != 0);
				res = ((v != NULL) && recursiveExecute(jqBase, nextPos, v));
			}
			break;
		case jqiAny:
			Assert(nextPos != 0);
			if (recursiveExecute(jqBase, nextPos, jb))
				res = true;
			else if (jb->type == jbvBinary)
				res = recursiveAny(jqBase, nextPos, jb);
			break;
		case jqiAnyArray:
			Assert(nextPos != 0);
			if (jb->type == jbvBinary) {
				JsonbIterator	*it;
				int32			r;
				JsonbValue		v;

				it = JsonbIteratorInit(jb->val.binary.data);

				while(res == false && (r = JsonbIteratorNext(&it, &v, true)) != WJB_DONE)
				{
					if (r == WJB_KEY)
						break;

					if (r == WJB_ELEM)
						res = recursiveExecute(jqBase, nextPos, &v);
				}
			}
			break;
		case jqiEqual:
		case jqiLess:
		case jqiGreater:
		case jqiLessOrEqual:
		case jqiGreaterOrEqual:
		case jqiContains:
		case jqiContained:
		case jqiOverlap:
			read_int32(arg, jqBase, jqPos);
			res = executeExpr(jqBase, arg, type, jb);
			break;
		default:
			elog(ERROR,"Wrong state: %d", type);
	}

	return res;
}

PG_FUNCTION_INFO_V1(jsquery_json_exec);
Datum
jsquery_json_exec(PG_FUNCTION_ARGS)
{
	JsQuery		*jq = PG_GETARG_JSQUERY(0);
	Jsonb		*jb = PG_GETARG_JSONB(1);
	bool		res;
	JsonbValue	jbv;

	jbv.type = jbvBinary;
	jbv.val.binary.data = VARDATA(jb);
	jbv.val.binary.len = jbv.estSize = VARSIZE_ANY_EXHDR(jb);

	res = recursiveExecute(VARDATA(jq), 0, &jbv);

	PG_FREE_IF_COPY(jq, 0);
	PG_FREE_IF_COPY(jb, 1);

	PG_RETURN_BOOL(res);
}

PG_FUNCTION_INFO_V1(json_jsquery_exec);
Datum
json_jsquery_exec(PG_FUNCTION_ARGS)
{
	Jsonb		*jb = PG_GETARG_JSONB(0);
	JsQuery		*jq = PG_GETARG_JSQUERY(1);
	bool		res;
	JsonbValue	jbv;

	jbv.type = jbvBinary;
	jbv.val.binary.data = VARDATA(jb);
	jbv.val.binary.len = jbv.estSize = VARSIZE_ANY_EXHDR(jb);

	res = recursiveExecute(VARDATA(jq), 0, &jbv);

	PG_FREE_IF_COPY(jb, 0);
	PG_FREE_IF_COPY(jq, 1);

	PG_RETURN_BOOL(res);
}

static int
compareJsQuery(char *base1, int32 pos1, char *base2, int32 pos2)
{
	int32	type1,
			nextPos1,
			type2,
			nextPos2;
	int32	res = 0;

	check_stack_depth();

	pos1 = readJsQueryHeader(base1, pos1, &type1, &nextPos1);
	pos2 = readJsQueryHeader(base2, pos2, &type2, &nextPos2);

	if (type1 != type2)
		return (type1 > type2) ? 1 : -1;

	switch(type1)
	{
		case jqiNull:
		case jqiAny:
		case jqiAnyArray:
			break;
		case jqiKey:
		case jqiString:
			{
				int32 len1, len2;

				read_int32(len1, base1, pos1);
				read_int32(len2, base2, pos2);

				if (len1 != len2)
					res = (len1 > len2) ? 1 : -1;
				else
					res = memcmp(base1 + pos1, base2 + pos2, len1);
			}
			break;
		case jqiNumeric:
			res = compareNumeric((Numeric)(base1 + pos1), (Numeric)(base2 + pos2));
			break;
		case jqiBool:
			{
				bool v1, v2;

				read_byte(v1, base1, pos1);
				read_byte(v2, base2, pos2);

				if (v1 != v2)
					res = (v1 > v2) ? 1 : -1;
			}
			break;
		case jqiArray:
			{
				int32	i;
				int32	nelems1, *arrayPos1,
						nelems2, *arrayPos2;

				read_int32(nelems1, base1, pos1);
				arrayPos1 = (int32*)(base1 + pos1);
				read_int32(nelems2, base2, pos2);
				arrayPos2 = (int32*)(base2 + pos2);

				if (nelems1 != nelems2)
					res = (nelems1 > nelems2) ? 1 : -1;

				for(i=0; i<nelems1 && res == 0; i++)
					res = compareJsQuery(base1, arrayPos1[i], base2, arrayPos2[i]);
			}
			break;
		case jqiAnd:
		case jqiOr:
			{
				int32	left1, right1,
						left2, right2;

				read_int32(left1, base1, pos1);
				read_int32(right1, base1, pos1);
				read_int32(left2, base2, pos2);
				read_int32(right2, base2, pos2);

				res = compareJsQuery(base1, left1, base2, left2);
				if (res == 0)
					res = compareJsQuery(base1, right1, base2, right2);
			}
			break;
		case jqiEqual:
		case jqiLess:
		case jqiGreater:
		case jqiLessOrEqual:
		case jqiGreaterOrEqual:
		case jqiContains:
		case jqiContained:
		case jqiOverlap:
		case jqiNot:
			{
				int32	arg1, arg2;

				read_int32(arg1, base1, pos1);
				read_int32(arg2, base2, pos2);

				res = compareJsQuery(base1, arg1, base2, arg2);
			}
			break;
		default:
			elog(ERROR, "Unknown JsQueryItem type: %d", type1);
	}

	if (res == 0 && !(nextPos2 == 0 && nextPos1 == 0))
	{
		if (nextPos1 == 0 || nextPos2 == 0)
			res = (nextPos1 > nextPos2) ? 1 : -1;
		else
			res = compareJsQuery(base1, nextPos1, base2, nextPos2);
	}

	return res;
}

PG_FUNCTION_INFO_V1(jsquery_cmp);
Datum
jsquery_cmp(PG_FUNCTION_ARGS)
{
	JsQuery		*jq1 = PG_GETARG_JSQUERY(0);
	JsQuery		*jq2 = PG_GETARG_JSQUERY(1);
	int32		res;

	res = compareJsQuery(VARDATA(jq1), 0, VARDATA(jq2), 0); 

	PG_FREE_IF_COPY(jq1, 0);
	PG_FREE_IF_COPY(jq2, 1);

	PG_RETURN_INT32(res);
}

PG_FUNCTION_INFO_V1(jsquery_lt);
Datum
jsquery_lt(PG_FUNCTION_ARGS)
{
	JsQuery		*jq1 = PG_GETARG_JSQUERY(0);
	JsQuery		*jq2 = PG_GETARG_JSQUERY(1);
	int32		res;

	res = compareJsQuery(VARDATA(jq1), 0, VARDATA(jq2), 0); 

	PG_FREE_IF_COPY(jq1, 0);
	PG_FREE_IF_COPY(jq2, 1);

	PG_RETURN_BOOL(res < 0);
}

PG_FUNCTION_INFO_V1(jsquery_le);
Datum
jsquery_le(PG_FUNCTION_ARGS)
{
	JsQuery		*jq1 = PG_GETARG_JSQUERY(0);
	JsQuery		*jq2 = PG_GETARG_JSQUERY(1);
	int32		res;

	res = compareJsQuery(VARDATA(jq1), 0, VARDATA(jq2), 0); 

	PG_FREE_IF_COPY(jq1, 0);
	PG_FREE_IF_COPY(jq2, 1);

	PG_RETURN_BOOL(res <= 0);
}

PG_FUNCTION_INFO_V1(jsquery_eq);
Datum
jsquery_eq(PG_FUNCTION_ARGS)
{
	JsQuery		*jq1 = PG_GETARG_JSQUERY(0);
	JsQuery		*jq2 = PG_GETARG_JSQUERY(1);
	int32		res;

	res = compareJsQuery(VARDATA(jq1), 0, VARDATA(jq2), 0); 

	PG_FREE_IF_COPY(jq1, 0);
	PG_FREE_IF_COPY(jq2, 1);

	PG_RETURN_BOOL(res == 0);
}

PG_FUNCTION_INFO_V1(jsquery_ne);
Datum
jsquery_ne(PG_FUNCTION_ARGS)
{
	JsQuery		*jq1 = PG_GETARG_JSQUERY(0);
	JsQuery		*jq2 = PG_GETARG_JSQUERY(1);
	int32		res;

	res = compareJsQuery(VARDATA(jq1), 0, VARDATA(jq2), 0); 

	PG_FREE_IF_COPY(jq1, 0);
	PG_FREE_IF_COPY(jq2, 1);

	PG_RETURN_BOOL(res != 0);
}

PG_FUNCTION_INFO_V1(jsquery_ge);
Datum
jsquery_ge(PG_FUNCTION_ARGS)
{
	JsQuery		*jq1 = PG_GETARG_JSQUERY(0);
	JsQuery		*jq2 = PG_GETARG_JSQUERY(1);
	int32		res;

	res = compareJsQuery(VARDATA(jq1), 0, VARDATA(jq2), 0); 

	PG_FREE_IF_COPY(jq1, 0);
	PG_FREE_IF_COPY(jq2, 1);

	PG_RETURN_BOOL(res >= 0);
}

PG_FUNCTION_INFO_V1(jsquery_gt);
Datum
jsquery_gt(PG_FUNCTION_ARGS)
{
	JsQuery		*jq1 = PG_GETARG_JSQUERY(0);
	JsQuery		*jq2 = PG_GETARG_JSQUERY(1);
	int32		res;

	res = compareJsQuery(VARDATA(jq1), 0, VARDATA(jq2), 0); 

	PG_FREE_IF_COPY(jq1, 0);
	PG_FREE_IF_COPY(jq2, 1);

	PG_RETURN_BOOL(res > 0);
}

static void
hashJsQuery(char *base, int32 pos, pg_crc32 *crc)
{
	int32	type;
	int32	nextPos;

	check_stack_depth();

	pos = readJsQueryHeader(base, pos, &type, &nextPos);

	COMP_CRC32(*crc, &type, sizeof(type));

	switch(type)
	{
		case jqiNull:
			COMP_CRC32(*crc, "null", 5);
			break;
		case jqiKey:
		case jqiString:
			{
				int32	len;

				read_int32(len, base, pos);

				if (type == jqiKey)
					len++; /* include trailing '\0' */
				COMP_CRC32(*crc, base + pos, len);
			}
			break;
		case jqiNumeric:
			*crc ^= (pg_crc32)DatumGetInt32(DirectFunctionCall1(
												hash_numeric,
												PointerGetDatum((Numeric)(base + pos))));
			break;
		case jqiBool:
			{
				bool	v;

				read_byte(v, base, pos);

				COMP_CRC32(*crc, &v, 1);
			}
			break;
		case jqiArray:
			{
				int32	i, nelems, *arrayPos;

				read_int32(nelems, base, pos);
				arrayPos = (int32*)(base + pos);

				COMP_CRC32(*crc, &nelems, sizeof(nelems));

				for(i=0; i<nelems; i++)
					hashJsQuery(base, arrayPos[i], crc);
			}
			break;
		case jqiAnd:
		case jqiOr:
			{
				int32 left, right;

				read_int32(left, base, pos);
				read_int32(right, base, pos);

				hashJsQuery(base, left, crc);
				hashJsQuery(base, right, crc);
			}
			break;
		case jqiNot:
		case jqiEqual:
		case jqiLess:
		case jqiGreater:
		case jqiLessOrEqual:
		case jqiGreaterOrEqual:
		case jqiContains:
		case jqiContained:
		case jqiOverlap:
			{
				int32 arg;

				read_int32(arg, base, pos);
				hashJsQuery(base, arg, crc);
			}
			break;
		case jqiAny:
		case jqiAnyArray:
			break;
		default:
			elog(ERROR, "Unknown JsQueryItem type: %d", type);
	}
}

PG_FUNCTION_INFO_V1(jsquery_hash);
Datum
jsquery_hash(PG_FUNCTION_ARGS)
{
	JsQuery		*jq = PG_GETARG_JSQUERY(0);
	pg_crc32	res;

	INIT_CRC32(res);
	hashJsQuery(VARDATA(jq), 0, &res);
	FIN_CRC32(res);

	PG_FREE_IF_COPY(jq, 0);

	PG_RETURN_INT32(res);
}

