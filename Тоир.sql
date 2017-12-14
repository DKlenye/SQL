SELECT * FROM DBF_CY18 WHERE kvo = 2 ORDER BY kmrk
SELECT * FROM DBF_CY03 WHERE kvo = 2
SELECT * FROM DBF_CY04 WHERE kvo = 2
SELECT * FROM DBF_CY28 WHERE kvo = 2

 
 
SELECT DISTINCT ng,mrk FROM (
SELECT 
	cy28.kvo,
	cy28.kg,
	cy04.ng,
	cy28.kmrk,
	cy18.mrk,
	cy28.ti,
	cy28.ku,
	cy28.uku
FROM DBF_CY28 as cy28
LEFT JOIN DBF_CY04 cy04 ON cy04.kg = cy28.kg AND cy04.kvo = cy28.kvo
LEFT JOIN DBF_CY18 cy18 ON cy18.kmrk = cy28.kmrk AND cy18.kvo = cy28.kvo
WHERE cy28.kvo = 2 
)a
ORDER BY 2,1