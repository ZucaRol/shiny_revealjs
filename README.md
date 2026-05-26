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
| `reveal_slides_presentation()` | Agrupa `theme`, `style` y `config` para reutilizarlos en preview y descarga |
| `reveal_slides_dependencies()` | Inyecta Reveal.js, CSS base y JavaScript de inicialización |
| `reveal_slides_ui(id)` | Crea el contenedor Reveal dentro del UI |
| `render_reveal_slides(session, id, slides)` | Envía la lista de slides al navegador y actualiza el deck |
| `build_reveal_html(slides, title = ...)` | Genera un HTML standalone para descarga o exportación |
| `reveal_slides_style(...)` | Permite cambiar colores, tipografía, espaciado y tamaños desde R |
| `slide_text()`, `slide_html()`, `slide_plot()`, `slide_image()`, `slide_widget()` | Constructores de slides reutilizables |

## Contrato de datos

Cada presentación se construye como una lista de slides. Los tipos soportados actualmente son:

- `text`: texto simple;
- `html`: HTML arbitrario;
- `plot`: una función que dibuja un gráfico base de R;
- `image`: una imagen a partir de una URL o `data URI`.
- `widget`: un `htmlwidget` ya construido, como `ggiraph` o `DT`.

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
  ),
  slide_widget(
    title = "Interactivo",
    widget = DT::datatable(head(mtcars)),
    fit = "scroll"
  )
)
```

Para `ggiraph`, el ajuste recomendado es `fit = "contain"` para que la gráfica se reescale dentro de la diapositiva en lugar de crecer con scroll.

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

mi_estilo <- reveal_slides_style(
  background_color = "#fcfcfc",
  text_color = "#1f2937",
  title_color = "#0f172a",
  meta_color = "#475569",
  accent_color = "#2563eb",
  title_size = "clamp(1.3rem, 2vw, 2rem)",
  body_size = "clamp(0.88rem, 1.1vw, 1.05rem)"
)

mi_presentacion <- reveal_slides_presentation(
  theme = "white",
  style = mi_estilo
)

ui <- fluidPage(
  tags$head(
    reveal_slides_dependencies(presentation = mi_presentacion)
  ),
  div(
    style = "height: 100vh;",
    reveal_slides_ui("deck", presentation = mi_presentacion)
  )
)
```

### Personalizar tema, colores y tamaños desde R

No hace falta editar CSS manualmente. Puedes construir un estilo con `reveal_slides_style()` y reutilizarlo dentro de un objeto `reveal_slides_presentation()`.

```r
mi_estilo <- reveal_slides_style(
  background_color = "#f8fafc",
  text_color = "#111827",
  title_color = "#0f172a",
  meta_color = "#64748b",
  accent_color = "#7c3aed",
  shell_padding = "1rem 1.25rem 0.85rem",
  title_size = "clamp(1.2rem, 1.8vw, 1.8rem)",
  body_size = "clamp(0.85rem, 1vw, 1rem)",
  dt_font_scale = "0.78em",
  widget_max_height = "48vh"
)

mi_presentacion <- reveal_slides_presentation(
  theme = "white",
  style = mi_estilo
)
```

Parámetros útiles:

- `background_color`: color de fondo del deck;
- `text_color`: color general del contenido;
- `title_color`: color de títulos;
- `meta_color`: color de subtítulos/meta;
- `accent_color`: color de links y acentos;
- `title_size`, `body_size`, `meta_size`: tamaños tipográficos;
- `shell_padding`: padding interno del slide;
- `widget_max_height`: altura máxima para widgets como `DT` y `ggiraph`;
- `dt_font_scale`: escala visual de `DataTable`.

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
    save_reveal_html(
      slides(),
      file = file,
      title = "Mi Presentacion",
      presentation = mi_presentacion
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
5. Reusar `build_reveal_html()` o `save_reveal_html()` para exportación, evitando rutas distintas para preview y descarga.
6. Si necesitas personalización visual, definir un solo `reveal_slides_style()` y reutilizarlo tanto en preview como en exportación.

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
