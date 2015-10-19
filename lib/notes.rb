
SELECT json_agg(
	json_build_object(
	'id', t979.id,
	'comments',
		(
		SELECT json_agg(json_build_object('id', t582.id,'content', t582.content,'post_id', t582.post_id))
		FROM
		(SELECT "comments".* FROM "comments" WHERE "comments"."post_id" in (t979.id))t582
		)
	)
) as json FROM(SELECT "posts".* FROM "posts" LIMIT 5)t979
