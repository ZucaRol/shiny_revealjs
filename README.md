# shinySlides

Aplicación Shiny para construir y previsualizar presentaciones dinámicas con [Reveal.js](https://revealjs.com/) desde R.

La idea principal del proyecto es resolver dos problemas:

1. **Crear slides dinámicos dentro de Shiny** sin regenerar archivos HTML temporales o depender de inspeccionar el DOM para ver el contenido.
2. **Reutilizar la misma lógica en otras aplicaciones** mediante helpers de R, para no tener que copiar manualmente bloques de HTML, CSS y JavaScript cada vez.

## Qué hace esta aplicación

La app de ejemplo (`app.r`) permite:

- agregar slides desde un panel lateral;
- mostrar texto y gráficos en una presentación Reveal.js embebida en la interfaz;
- actualizar el deck en tiempo real desde `server`;
- exportar la presentación a un archivo HTML standalone.

Aunque la app sirve como demo funcional, el valor principal del proyecto está en `reveal_slides.R`, que extrae la integración reusable entre **R + Shiny + Reveal.js**.

## Estructura del proyecto

- `app.r`: demo interactiva de la solución.
- `reveal_slides.R`: helpers reutilizables para integrar Reveal.js en otras apps.
- `presentation_template.html`: referencia inicial usada durante el desarrollo.

## Intención de diseño

Este proyecto busca que una app Shiny pueda pasar de una **lista de slides** a una **visualización Reveal.js** con una API pequeña y explícita.

En lugar de escribir manualmente:

- dependencias de Reveal;
- estilos CSS del contenedor;
- JavaScript de inicialización;
- `customMessageHandler()` para sincronizar el deck;
- HTML standalone para exportación;

la app solo necesita cargar un script R y usar funciones helper.

## API reusable

El archivo `reveal_slides.R` expone estas funciones principales:

| Función | Propósito |
| --- | --- |
| `reveal_slides_dependencies()` | Inyecta Reveal.js, CSS base y JavaScript de inicialización |
| `reveal_slides_ui(id)` | Crea el contenedor Reveal dentro del UI |
| `render_reveal_slides(session, id, slides)` | Envía la lista de slides al navegador y actualiza el deck |
| `build_reveal_html(slides, title = ...)` | Genera un HTML standalone para descarga o exportación |
| `slide_text()`, `slide_html()`, `slide_plot()`, `slide_image()` | Constructores de slides reutilizables |

## Contrato de datos

Cada presentación se construye como una lista de slides. Los tipos soportados actualmente son:

- `text`: texto simple;
- `html`: HTML arbitrario;
- `plot`: una función que dibuja un gráfico base de R;
- `image`: una imagen a partir de una URL o `data URI`.

Ejemplo:

```r
slides <- list(
  slide_text(
    title = "Resumen",
    body = "Este es un slide de texto."
  ),
  slide_plot(
    title = "Grafico",
    subtitle = "Relacion entre variables",
    plot = function() {
      plot(mtcars$wt, mtcars$mpg)
    }
  )
)
```

## Cómo ejecutar esta app

Desde R o RStudio:

```r
shiny::runApp("app.r")
```

## Cómo reutilizarlo en otras aplicaciones

### 1. Cargar el helper

```r
source("reveal_slides.R")
```

### 2. Agregar dependencias y el contenedor al UI

```r
library(shiny)

ui <- fluidPage(
  tags$head(
    reveal_slides_dependencies(theme = "black")
  ),
  div(
    style = "height: 100vh;",
    reveal_slides_ui("deck")
  )
)
```

### 3. Construir la lista de slides y renderizarla en `server`

```r
server <- function(input, output, session) {
  slides <- reactive({
    list(
      slide_text(
        title = "Hola",
        body = "Esta presentacion se genera desde otra app Shiny."
      ),
      slide_plot(
        title = "Grafico",
        subtitle = "Ejemplo",
        plot = function() {
          plot(pressure)
        }
      )
    )
  })

  observe({
    render_reveal_slides(session, "deck", slides())
  })
}
```

### 4. Si necesitas descarga, reutiliza el mismo renderer

```r
output$download <- downloadHandler(
  filename = function() "presentacion.html",
  content = function(file) {
    writeLines(
      build_reveal_html(slides(), title = "Mi Presentacion"),
      file,
      useBytes = TRUE
    )
  }
)
```

## Patrón recomendado de integración

La forma recomendada de usar esta solución en una app más grande es:

1. Mantener la lógica de negocio y la generación de datos en tu app principal.
2. Convertir esos datos a una lista de slides con `slide_text()`, `slide_plot()`, etc.
3. Usar `reveal_slides_ui()` como host visual.
4. Llamar `render_reveal_slides()` cada vez que cambien los slides.
5. Reusar `build_reveal_html()` para exportación, evitando rutas distintas para preview y descarga.

## Ventajas de este enfoque

- evita repetir HTML/CSS/JS manualmente;
- centraliza la integración con Reveal.js en un solo archivo;
- mantiene consistente el preview en Shiny y el HTML exportado;
- facilita migrar este helper a un paquete R más adelante si el proyecto crece.

## Posibles mejoras futuras

- soporte para más tipos de slide;
- temas Reveal configurables por presentación;
- conservación opcional de la posición actual al actualizar slides;
- conversión del helper a un paquete R formal;
- integración con módulos Shiny.
