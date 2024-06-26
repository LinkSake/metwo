+++
title = "Dropdowns y Toggles con puro CSS"
description = "Sin necesidad de usar JavaScript en tu proyecto, puedes tener menus interactivos y estileros solamente con CSS"
date = 2022-11-05T11:53:11-05:00
slug = "dropdowns-y-toggles-con-css"
author = "Luis Angel Ortega"
categories = ["Articulos"]
tags = ["desarrollo web", "css"]
+++

Podríamos imaginar las tecnologías de la plataforma en la cual trabajo, [Build It](https://www.joinbuildit.com/), como un platillo; donde Ruby on Rails es nuestro platillo principal pero está acompañada de una buena porción al lado de JavaScript a través de [Stimulus JS](https://stimulus.hotwired.dev/), y mientras esta trae la funcionalidad y ese sentimiento mágico de una aplicación de una sola página (SPA, por sus siglas en inglés) hay cosas que queremos mantener simple en lugar de usar una bomba para matar una hormiga, como un profesor de la universidad solía decir. Por ello decidimos tomar nota de la página de [Apple](https://apple.com/mx) a la hora de manejar menús desplegables o dropdown y hacerlo por medio de puro CSS y HTML; sin requerir una línea de JavaScript.

## Los pilares

Nuestros dos pilares en la vista serán los elementos `<input>` de tipo checkbox y las etiquetas `<label>`. Formaremos nuestro esqueleto básico de la siguiente manera:

```html
<input id="toggle" type="checkbox"></input>
<label for="toggle"></label>
```

Estaremos usando la propiedad checked de los inputs tipo checkbox para poder controlar el contenido que mostramos y cuando lo mostramos. Para esto nos estaremos apoyando del elemento `<label>` ya que al relacionarlo a través de su propiedad `for` también será afectado por el cambio de clases cuando la propiedad checked de nuestro checkbox se encuentre presente.

Todo nuestro código realmente se encontrará dentro de `<label>` en dos secciones: container y toggle como se muestra a continuación.

```html
<input id="toggle" type="checkbox"></input>
<label for="toggle">
  <div class="toggle">
    <!-- El elemento con el cual el usuario va a interactuar -->
  </div>
  <div class="container">
    <!-- Lo que queremos mostrar-->
  </div>
</label>
```

## La magia

Ahora que ya tenemos nuestro esqueleto con HTML listo, es hora de agregar el CSS que le dará el toque mágico a nuestro componente:

```css
#toggle {
  display: none;
}

.container {
  display: none;
}

#toggle:checked + label .container { 
  display: inherit; 
}
```

Nuestro input con el id de toggle nunca se mostrará para que no tengamos la checkbox presente en nuestra página, lo que mostraremos y con lo que interactúa el usuario es lo que esté dentro de nuestra div con clase de toggle. Una vez que le den click a nuestro toggle el input tendrá el valor de checked y con `#toggle:checked+label` afectamos el estilo de nuestro `<label>` para obtener un resultado como el siguiente

![Demo 1](/images/post/dropdowns-toggle-css-1.gif)

Y con un poco más de estilo (cortesía de Thulio Philipe) podemos tener resultados como este

![Demo 2](/images/post/dropdowns-toggle-css-2.gif)

O como los ejemplos que tenemos dentro de Build It

![Demo 3](/images/post/dropdowns-toggle-css-3.gif)

Un pequeño popover que siempre está presente, dando información vital al usuario

![Demo 4](/images/post/dropdowns-toggle-css-4.gif)

O un menú de filtros que puede ser mostrado con facilidad.

Como podemos ver, el CSS moderno nos permite hacer páginas interactivas sin necesidad de hacer un script para ello; dándonos una nueva solución a un problema con infinidad de maneras de resolverlo, por lo que habrá que considerar las necesidades del proyecto y que es lo que más conviene.

Finalmente les dejo [un repositorio](https://github.com/LinkSake/toggle-dropdown-css) con un par de ejemplos vistos en este artículo para referencia futura y los invito a ver [la plataforma](https://www.joinbuildit.com/early_access/client) y en especial [mi perfil](https://www.joinbuildit.com/u/luis-ortega-160), donde podremos conectar para proyectos futuros.
