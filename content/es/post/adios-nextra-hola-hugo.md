+++
title = "Adiós Nextra, hola Hugo"
description = "La historia de la migración de este blog de Nextra a Hugo, más como lo estoy restructurando conceptualmente."
date = 2024-07-31T17:00:00-00:00
slug = "adios-nextra-hola-hugo"
author = "Luis Angel Ortega"
categories = ["Blogposts"]
tags = ["hugo", "nextra", "blogging"]
draft = false
+++

Este blog ha estado abandonado años para este punto. Desde que dejé de escribir en [Aviyel](HTTPS://aviyel.com) no he hecho nada muy técnico y sobre escritos más personales se me ha aconsejado no publicarlos en línea de manera tan libre como lo solía hacer, ya que hay convocatorias que cuentan como publicado un cuento si se encuentra en una web.

Eso no quiere decir que durante estos años me haya desinteresado el tema, al contrario. Gracias a Hacker News y Mastodon he conocido un montón de blogs que me encantan y de donde he estado tomando inspiración para la siguiente etapa del mío.

## El gran cambio de generador de sitios estáticos

Anteriormente mi web se usaba [Nextra](https://github.com/shuding/nextra) y estaba *hosteada* en[ Vercel](https://vercel.com/). La verdad es que este combo hizo que el desarrollo y el *deploy* fuera muy sencillo, así como agregar mi dominio personalizado. Pero dado a que adopté el Nextra en una etapa muy temprana la personalización que se podía hacer era mínima. Ahora parece estar más enfocado en páginas de documentación de proyectos y el estilo puede ser cambiado a través de los *helpers* de [Tailwind](https://tailwindcss.com/).

Aún con esto, durante mi tiempo inactivo conocí a Hugo y empecé a jugar con él. Hice varios proyectos de prueba con diferentes temas y objetivos a manera de práctica, y si bien Hugo tiene muchas ventajas en cuanto a la velocidad de generar el sitio web gracias a que está hecho en Go, lo que me llamó la atención fue la cantidad de temas ya hechos y la facilidad de personalizarlos. Desde cosas sencillas como los colores u otros estilos a través de un archivo de CSS hasta poder modificar partes esenciales del tema como los *headers*, la *navbar* y el *feed* *RSS*. Finalmente me decidí por el tema[ hugo-classic](https://github.com/goodroot/hugo-classic) con modificaciones en todo lo mencionado anteriormente.

Para el hosting pasé de Vercel a GitHub Pages, por facilidad de tener todo lo relacionado con el blog en un mismo lugar. La migración del dominio no fue compleja pero sí tuvo sus detalles, nada que borrar todos los registros en[ Porkbun](https://porkbun.com/) y agregarlos de nuevo no haya resuelto. Por otro lado, el *deployment* fue más complejo. Hugo tiene en su documentación una[ guía](https://gohugo.io/hosting-and-deployment/hosting-on-github/#prose) de como hacer el *deploy* a través de una acción, pero en mi opinión está incompleta. Faltan cosas como si se está usando un tema asegurarse de incluir el submódulo de git entre otras pequeñas cosas que se puede tener que llegar a necesitar modificar. Al día de escribir esto el sitio está libre de errores de este tipo aunque sí hay algunos temas con el estilo en pantallas de móviles.

En general, a pesar de los múltiples intentos que me tomó tener el sitio arriba de manera correcta estoy muy contento con el nuevo setup y lo recomiendo a cualquiera que esté pensando en seguir por este camino.

## La nueva organización y filosofía sobre blog

Cuando recién creé la primera versión de la web no tenía mucha experiencia leyendo o siguiendo blogs de otras personas, entonces lo estructuré lo mejor que pude. Ahora las cosas han cambiado, se lo que me gusta y lo que no; que y como compartirlo.

Por ahora el acomodo de las páginas será el siguiente. Como el enfoque principal de la página es como blog la sección más extensa es la de los escritos. Si bien el feed rss va a meter todos los post en un solo lugar, no quería que vivieran así dentro de la página. Blogposts será para este tipo de cosas, simplemente escritos al vacío del internet. Los artículos son para guías y cosas más técnicas. Reseñas es para escribir sobre películas, libros, juegos, etc. Finalmente los trabajos son para mis obras publicadas, aunque por el momento solo vivo una espero que sea una de las más amplias.

Fuera de los escritos, proyectos la carta de presentación de mi trabajo, como un pequeño cv de mi huella en linea. Sobre mí es bueno, una pequeña biografía y finalmente, el jardín es algo raro y complejo pero básicamente ahí vive lo demás. La mejor sección honestamente.

En el índice aparte listo que es lo que estoy "haciendo". Qué es lo que estoy jugando, leyendo, escuchando y viendo. Solo es una manera de compartir que me apasiona en el momento, con suerte muchos de esos *bulletpoints* se volverán reseñas. También tiene mis últimas lecturas, artículos que me parece interesante compartir y/o comentar.

En cuanto a la filosofía del blog, específicamente con los "blogposts" quiero escribir más. Tratar de capturar el espíritu de los blogs que sigo con la manera que comparten cosas, sin necesariamente llegar a escribir ensayos o guías técnicas. Además me gustaría escribir más también reseñas, compartir mis notas, mis quotes favoritos. Dejar de consumir sin pensar.

En resumen, que la página sea una excusa para seguir escribiendo y compartiendo.

## La diferencia ante las redes sociales

Finalmente estoy haciendo esto porque ya no disfruto como antes las redes sociales. Lo que era Twitter se fragmentó, Facebook e Instagram tienen un feed horrible lleno de anuncios. Realmente donde paso mi tiempo es YouTube y TikTok.

Aparte de que simplemente ya no es lo mismo, el saber que todos mis contactos ven lo que publique en su feed me ha dado un pesar al publicar. Aquí sigue siendo público, puedo seguir compartiendo las cosas que me apasionan sin la certeza de que todo mundo lo va a ver, todo mundo lo *puede* ver pero a nadie se le va a servir forzosamente.

Este post era solamente para compartir estas cosas, documentar el cambio que sufrió esta página, un rant y monólogo al aire. No tengo una verdadera conclusión, así que con esto los dejo.
