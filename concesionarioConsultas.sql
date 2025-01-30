
/* ******************** EJERCICIO 1. ********************
Utilizando las tablas y campos necesarios, se pide obtener las sentencias SQL de consulta
que permitan realizar los siguientes apartados:*/

/* a) Obtener un listado de todos los vehículos que pertenezcan a concesionarios de la provincia de Córdoba
y que contenga alguna observación, ordenado por los kilómetros que tienen de mayor a menor. */
SELECT * 
FROM VEHICULO V, CONCESIONARIO CO 
WHERE V.concesionario = CO.codigo
AND CO.provincia = 'Cordoba'
AND V.observaciones IS NOT NULL
ORDER BY V.kilometros DESC;


/* b) Obtener por cada vehículo, su matrícula, marca y modelo y el número de veces que ha sido alquilado
siempre y cuando sea más de 5 veces durante el mes de Abril de 2016. */
SELECT V.matricula, V.marca, V.modelo, COUNT(A.fec_alquiler) AS VecesAlquilado
FROM VEHICULO V, ALQUILAR A
WHERE A.matricula = V.matricula
AND A.fec_alquiler BETWEEN '2016-04-01' AND '2016-04-30'
GROUP BY V.matricula
HAVING VecesAlquilado > 5; /* HAVING es un WHERE de cálculos. */


/* c) Obtener un listado con el nombre completo del cliente, la matrícula, marca y modelo del vehículo y el
número de días que lo ha tenido alquilado ordenado de mayor a menor de días de alquiler. */
SELECT CONCAT(C.nombre, ' ' , C.apellidos) AS Nombre_Completo, V.matricula, V.modelo, DATEDIFF(A.fec_entrega, A.fec_alquiler) AS Dias
FROM CLIENTE C, VEHICULO V, ALQUILAR A 
WHERE C.DNI = A.DNI
AND A.matricula = V.matricula
ORDER BY Dias DESC;

		/* Nota: en DATEDIFF primero va la fecha más reciente, luego la coma y 
        por último la fecha más lejana. */

/* d) Obtener todos los datos de los vehículos (sin repetirse) que no hayan sido alquilados nunca por clientes
nóveles (aquellos que tienen menos de un año el carnet de conducir teniendo en cuenta la fecha
actual del sistema). */
SELECT DISTINCT V.*
FROM VEHICULO V
WHERE V.matricula NOT IN (SELECT DISTINCT A.matricula
						  FROM ALQUILAR A, CLIENTE C 
                          WHERE A.DNI = C.DNI AND (DATEDIFF(CURDATE(),C.fec_carnet)/365)<1);



/* ******************** EJERCICIO 2. ********************
Teniendo en cuenta las mismas tablas del ejercicio anterior, debes realizar las siguientes
operaciones de actualización, inserción y borrado de registros mediante las sentencias SQL apropiadas: */

/* a) El cliente de DNI 55555555E alquila el vehículo de matrícula 6598HGF. Añade por tanto ese registro
en la tabla correspondiente con la fecha actual del sistema sin introducirla manualmente como literal
sino con la función correspondiente. No introduzcas más datos todavía. */
INSERT INTO ALQUILAR (matricula, dni, fec_alquiler) VALUES ('6598HGF','55555555E', CURDATE());
				                      /* Nota: a los INSERT no les gusta mucho el SYSDATE() */

/* b) Actualiza la clase de todos los vehículos que son de tipo A y que tengan más de 75.000 km o el año
de fabricación es igual o anterior al 2020. Deben cambiarse a clase B. */
UPDATE VEHICULO
SET clase = 'B'
WHERE clase = 'A'
AND (kilometros>75000 OR anio_fab <= '2020'); 
			/* Nota: las dos condiciones del OR entre paréntesis! */

			/* Vamos a comprobar los datos mostrando el select antes de la actualización: */
            SELECT V.* FROM VEHICULO V
            WHERE clase = 'A'
			AND (kilometros>75000 OR anio_fab <= '2020'); /* Dsp de la actualización ya no habrá nada aquí */

/* c) Incrementa en 10 euros la bonificación de aquellos clientes que han gastado en total de sus alquileres
más que la media de todos los alquileres que se han realizado. */
UPDATE CLIENTE
SET bonificacion = bonificacion + 10
WHERE DNI IN (SELECT DNI
FROM ALQUILAR 
GROUP BY DNI
HAVING SUM(Importe) > (SELECT AVG(Importe) FROM ALQUILAR));

    /* Por pates. */
    /*Esta sería la parte "aquellos clientes que han gastado en total de sus alquileres"; */
    SELECT A.DNI, SUM(A.Importe)
    FROM ALQUILAR A
    GROUP BY A.DNI;
	
    /* Y este sería el cálculo de la media: */
    SELECT AVG(Importe) FROM ALQUILAR;  


/* d) Eliminar los vehículos que no se han alquilado nunca y tengan más de 200.000 kilómetros. */
DELETE FROM VEHICULO V
WHERE V.matricula NOT IN (SELECT DISTINCT A.matricula FROM ALQUILAR A) AND V.kilometros>200000;

			/* Mostramos por pantalla los vehículos que vamos a borrar: */
            SELECT * FROM VEHICULO V
            WHERE V.matricula NOT IN (SELECT DISTINCT A.matricula FROM ALQUILAR A) AND V.kilometros>200000;
										/* Nota: el SELECT entre paréntesis te da los que sí se han alquilado (4)
                                        Entonces con el NOT IN te estás refiriendo al resto. Y filtrándolos tb 
                                        por la otra condición*/

/* Nota para evitar error 1175: */
SET SQL_SAFE_UPDATES = 0;
/*  El error se debe a que tu UPDATE está intentando modificar filas basándose en una subconsulta 
y no en una clave primaria o única.
Se activa para proteger la base de datos. */
SET SQL_SAFE_UPDATES = 1;