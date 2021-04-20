-- Copyright 2004-2021 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT NULL IS NULL;
>> TRUE

SELECT NULL IS NOT NULL;
>> FALSE

SELECT NOT NULL IS NULL;
>> FALSE

SELECT NOT NULL IS NOT NULL;
>> TRUE

SELECT 1 IS NULL;
>> FALSE

SELECT 1 IS NOT NULL;
>> TRUE

SELECT NOT 1 IS NULL;
>> TRUE

SELECT NOT 1 IS NOT NULL;
>> FALSE

SELECT () IS NULL;
>> TRUE

SELECT () IS NOT NULL;
>> TRUE

SELECT NOT () IS NULL;
>> FALSE

SELECT NOT () IS NOT NULL;
>> FALSE

SELECT (NULL, NULL) IS NULL;
>> TRUE

SELECT (NULL, NULL) IS NOT NULL;
>> FALSE

SELECT NOT (NULL, NULL) IS NULL;
>> FALSE

SELECT NOT (NULL, NULL) IS NOT NULL;
>> TRUE

SELECT (NULL, 1) IS NULL;
>> FALSE

SELECT (NULL, 1) IS NOT NULL;
>> FALSE

SELECT NOT (NULL, 1) IS NULL;
>> TRUE

SELECT NOT (NULL, 1) IS NOT NULL;
>> TRUE

SELECT (1, 2) IS NULL;
>> FALSE

SELECT (1, 2) IS NOT NULL;
>> TRUE

SELECT NOT (1, 2) IS NULL;
>> TRUE

SELECT NOT (1, 2) IS NOT NULL;
>> FALSE

CREATE TABLE TEST(A INT, B INT) AS VALUES (NULL, NULL), (1, NULL), (NULL, 2), (1, 2);
> ok

CREATE INDEX TEST_A_IDX ON TEST(A);
> ok

CREATE INDEX TEST_B_IDX ON TEST(B);
> ok

CREATE INDEX TEST_A_B_IDX ON TEST(A, B);
> ok

SELECT * FROM TEST T1 JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NULL;
> A B A B
> - - - -
> rows: 0

EXPLAIN SELECT * FROM TEST T1 JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX: A IS NULL */ /* WHERE T2.A IS NULL */ INNER JOIN "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX: A = T2.A */ ON 1=1 WHERE ("T2"."A" IS NULL) AND ("T1"."A" = "T2"."A")

SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NULL;
> A    B    A    B
> ---- ---- ---- ----
> null 2    null null
> null null null null
> rows: 2

EXPLAIN SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX */ LEFT OUTER JOIN "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX: A = T1.A */ ON "T1"."A" = "T2"."A" WHERE "T2"."A" IS NULL

SELECT * FROM TEST T1 JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NOT NULL;
> A B    A B
> - ---- - ----
> 1 2    1 2
> 1 2    1 null
> 1 null 1 2
> 1 null 1 null
> rows: 4

EXPLAIN SELECT * FROM TEST T1 JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NOT NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX */ INNER JOIN "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX: A = T1.A */ ON 1=1 WHERE ("T2"."A" IS NOT NULL) AND ("T1"."A" = "T2"."A")

SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NOT NULL;
> A B    A B
> - ---- - ----
> 1 2    1 2
> 1 2    1 null
> 1 null 1 2
> 1 null 1 null
> rows: 4

EXPLAIN SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON T1.A = T2.A WHERE T2.A IS NOT NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX */ LEFT OUTER JOIN "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX: A = T1.A */ ON "T1"."A" = "T2"."A" WHERE "T2"."A" IS NOT NULL

SELECT * FROM TEST T1 JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NULL;
> A B A B
> - - - -
> rows: 0

EXPLAIN SELECT * FROM TEST T1 JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX: A IS NULL AND B IS NULL */ /* WHERE ROW (T2.A, T2.B) IS NULL */ INNER JOIN "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX */ ON 1=1 WHERE (ROW ("T2"."A", "T2"."B") IS NULL) AND (ROW ("T1"."A", "T1"."B") = ROW ("T2"."A", "T2"."B"))

SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NULL;
> A    B    A    B
> ---- ---- ---- ----
> 1    null null null
> null 2    null null
> null null null null
> rows: 3

EXPLAIN SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX */ LEFT OUTER JOIN "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX */ ON ROW ("T1"."A", "T1"."B") = ROW ("T2"."A", "T2"."B") WHERE ROW ("T2"."A", "T2"."B") IS NULL

SELECT * FROM TEST T1 JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NOT NULL;
> A B A B
> - - - -
> 1 2 1 2
> rows: 1

EXPLAIN SELECT * FROM TEST T1 JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NOT NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX */ INNER JOIN "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX */ ON 1=1 WHERE (ROW ("T2"."A", "T2"."B") IS NOT NULL) AND (ROW ("T1"."A", "T1"."B") = ROW ("T2"."A", "T2"."B"))

SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NOT NULL;
> A B A B
> - - - -
> 1 2 1 2
> rows: 1

EXPLAIN SELECT * FROM TEST T1 LEFT JOIN TEST T2 ON (T1.A, T1.B) = (T2.A, T2.B) WHERE (T2.A, T2.B) IS NOT NULL;
>> SELECT "T1"."A", "T1"."B", "T2"."A", "T2"."B" FROM "PUBLIC"."TEST" "T1" /* PUBLIC.TEST_A_B_IDX */ LEFT OUTER JOIN "PUBLIC"."TEST" "T2" /* PUBLIC.TEST_A_B_IDX */ ON ROW ("T1"."A", "T1"."B") = ROW ("T2"."A", "T2"."B") WHERE ROW ("T2"."A", "T2"."B") IS NOT NULL

EXPLAIN SELECT A, B FROM TEST WHERE (A, NULL) IS NULL;
>> SELECT "A", "B" FROM "PUBLIC"."TEST" /* PUBLIC.TEST_A_B_IDX: A IS NULL */ WHERE "A" IS NULL

EXPLAIN SELECT A, B FROM TEST WHERE (A, NULL) IS NOT NULL;
>> SELECT "A", "B" FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan: FALSE */ WHERE FALSE

EXPLAIN SELECT A, B FROM TEST WHERE NOT (A, NULL) IS NULL;
>> SELECT "A", "B" FROM "PUBLIC"."TEST" /* PUBLIC.TEST_A_B_IDX */ WHERE "A" IS NOT NULL

EXPLAIN SELECT A, B FROM TEST WHERE NOT (A, NULL) IS NOT NULL;
>> SELECT "A", "B" FROM "PUBLIC"."TEST" /* PUBLIC.TEST_A_B_IDX */

EXPLAIN SELECT A, B FROM TEST WHERE (A, NULL, B) IS NULL;
>> SELECT "A", "B" FROM "PUBLIC"."TEST" /* PUBLIC.TEST_A_B_IDX: A IS NULL AND B IS NULL */ WHERE ROW ("A", "B") IS NULL

EXPLAIN SELECT A, B FROM TEST WHERE (A, NULL, B, NULL) IS NULL;
>> SELECT "A", "B" FROM "PUBLIC"."TEST" /* PUBLIC.TEST_A_B_IDX: A IS NULL AND B IS NULL */ WHERE ROW ("A", "B") IS NULL

DROP TABLE TEST;
> ok
