/*
    Desafío SQL - Consultas en múltiples tablas
    Benjamín Alejandro Segura Hernández
    fullstack-js-g37-1
*/

/* 1) Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo pedido. */
CREATE DATABASE desafio3_benjamin_segura_hernandez_123;

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    nombre VARCHAR NOT NULL,
    apellido VARCHAR NOT NULL,
    rol VARCHAR NOT NULL
);

INSERT INTO usuarios (id, email, nombre, apellido, rol) VALUES
(1, 'admin1@email.com', 'Dana', 'Scully', 'administrador'),
(2, 'admin2@email.com', 'Fox', 'Mulder', 'administrador'),
(3, 'usuario1@email.com', 'Homer', 'Simpson', 'usuario'),
(4, 'usuario2@email.com', 'Marge', 'Simpson', 'usuario'),
(5, 'usuario3@email.com', 'Bart', 'Simpson', 'usuario');

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL,
    fecha_actualizacion TIMESTAMP,
    destacado BOOLEAN,
    usuario_id BIGINT
);

INSERT INTO posts (id, titulo, contenido, fecha_creacion, destacado, usuario_id) VALUES
/* administradores */
(1, 'Back to the Future (1985)', 'A classic time-travel adventure directed by Robert Zemeckis, following the eccentric Doc Brown and Marty McFly as they navigate the past, present, and future.', '2023-01-01 01:11:11', true, 1),
(2, 'Interstellar (2014)', 'Directed by Christopher Nolan, this epic explores space and time as a group of astronauts embarks on a journey through a wormhole to find a new habitable planet.', '2023-02-01 02:22:22', true, 2),
/* usuarios */
(3, 'Armageddon (1998)', 'Directed by Michael Bay, this action-packed film depicts a group of oil drillers sent into space to prevent a massive asteroid from colliding with Earth and causing extinction-level events.', '2023-03-01 03:33:33', false, 3),
(4, 'The Tomorrow War (2021)', 'A sci-fi thriller directed by Chris McKay, where humanity recruits soldiers from the past to fight a war against an alien species threatening the future of Earth.', '2023-04-01 04:44:44', false, 4),
/* ningún usuario */
(5, 'District 9 (2009)', 'A unique sci-fi film directed by Neill Blomkamp, telling the story of extraterrestrial refugees in South Africa and the government agent who becomes entangled in their struggle for freedom.', '2023-05-01 05:55:55', false, NULL);

CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL,
    usuario_id BIGINT,
    post_id BIGINT
);

INSERT INTO comentarios (id, contenido, fecha_creacion, usuario_id, post_id) VALUES
/* Los comentarios con id 1, 2 y 3 deben estar asociados al post 1, a los usuarios 1, 2 y 3 respectivamente. */
(1, 'Timeless classic!', '2023-01-01 01:11:11', 1, 1),
(2, 'Iconic DeLorean scenes.', '2023-02-01 02:22:22', 2, 1),
(3, 'Time-travel brilliance.', '2023-03-01 03:33:33', 3, 1),

/* Los comentarios 4 y 5 deben estar asociados al post 2, a los usuarios 1 y 2 respectivamente. */
(4, 'Epic space odyssey.', '2023-03-01 03:33:33', 1, 2),
(5, 'Gravity of love transcends.', '2023-03-01 03:33:33', 2, 2);

/* 2) Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: 
      nombre y email del usuario junto al título y contenido del post. */
SELECT
    usuarios.nombre,
    usuarios.email,
    posts.titulo,
    posts.contenido
FROM 
    posts 

INNER JOIN usuarios ON posts.usuario_id = usuarios.id;

/* 3) Muestra el id, título y contenido de los posts de los administradores. 
      El administrador puede ser cualquier id. */
SELECT
    posts.id,
    posts.titulo,
    posts.contenido
FROM 
    posts 

INNER JOIN usuarios ON posts.usuario_id = usuarios.id

WHERE usuarios.rol = 'administrador';

/* 4) Cuenta la cantidad de posts de cada usuario.
      La tabla resultante debe mostrar el id e email del usuario junto con la
      cantidad de posts de cada usuario. */
SELECT
    usuarios.id, 
    usuarios.email, 
    COUNT(posts.id) as total_posts
FROM
    usuarios

LEFT JOIN posts ON usuarios.id = posts.usuario_id

GROUP BY usuarios.id, usuarios.email;


/* 5) Muestra el email del usuario que ha creado más posts. 
      Aquí la tabla resultante tiene un único registro y muestra solo el email. */
SELECT 
    usuarios.email
FROM
    usuarios

LEFT JOIN posts ON usuarios.id = posts.usuario_id

GROUP BY usuarios.id, usuarios.email
ORDER BY COUNT(posts.id) DESC

LIMIT 1;


/* 6) Muestra la fecha del último post de cada usuario. 
      Utiliza la función de agregado MAX sobre la fecha de creación. */
SELECT
    usuarios.id,
    usuarios.email,
    MAX(posts.fecha_creacion) AS fecha_ultimo_post
FROM 
    usuarios 

LEFT JOIN posts ON usuarios.id = posts.usuario_id

GROUP BY usuarios.id, usuarios.email;

/* 7) Muestra el título y contenido del post (artículo) con más comentarios. */
SELECT
    posts.titulo,
    posts.contenido,
    COUNT(comentarios.id) AS total_comentarios
FROM 
    posts 

INNER JOIN comentarios ON posts.id = comentarios.post_id

GROUP BY posts.id, posts.titulo, posts.contenido

ORDER BY total_comentarios DESC

LIMIT 1;

/* 8) Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario asociado 
      a los posts mostrados, junto con el email del usuario que lo escribió. */
SELECT
    posts.titulo    AS post_titulo,
    posts.contenido AS post_contenido,
    comentarios.contenido AS comentario_contenido,
    usuarios.email
FROM 
    comentarios 

INNER JOIN posts ON comentarios.post_id = posts.id
LEFT JOIN usuarios ON comentarios.usuario_id = usuarios.id;

/* 9) Muestra el contenido del último comentario de cada usuario. */
SELECT
    usuarios.id,
    usuarios.email,
    comentarios.fecha_creacion AS ultimo_comentario_fecha_creacion,
    comentarios.contenido      AS ultimo_comentario_contenido
FROM 
    usuarios 

LEFT JOIN comentarios ON usuarios.id = comentarios.usuario_id

WHERE comentarios.fecha_creacion = (SELECT MAX(fecha_creacion) FROM comentarios WHERE usuario_id = usuarios.id);

/* 10) Muestra los emails de los usuarios que no han escrito ningún comentario. */
SELECT
    usuarios.email
FROM
    usuarios

LEFT JOIN comentarios ON usuarios.id = comentarios.usuario_id

WHERE comentarios.id IS NULL;

SELECT
    usuarios.email
FROM
    usuarios

LEFT JOIN comentarios ON usuarios.id = comentarios.usuario_id

GROUP BY usuarios.id, usuarios.email

HAVING COUNT(comentarios.id) = 0;
