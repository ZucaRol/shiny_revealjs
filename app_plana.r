library(shiny)
library(base64enc)

slide_type_labels <- c(
  "Texto" = "text",
  "Grafico Dispersion" = "scatter",
  "Grafico Barras" = "bar"
)

reveal_config_js <- function() {
  '{
    controls: true,
    progress: true,
    center: true,
    hash: false,
    embedded: true,
    width: "100%",
    height: "100%",
    margin: 0.1,
    transition: "slide"
  }'
}

generate_plot_base64 <- function(plot_fn) {
  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)

  png(tmp, width = 800, height = 500, res = 96)
  plot_fn()
  dev.off()

  base64enc::base64encode(tmp)
}

generate_slides_html <- function(slide_data) {
  if (length(slide_data) == 0) {
    return(
      paste(
        "<section>",
        "<h2>Bienvenido</h2>",
        "<p>Usa los controles de la izquierda para agregar slides.</p>",
        "<p>Los cambios apareceran aqui de forma inmediata.</p>",
        "</section>",
        sep = "\n"
      )
    )
  }

  slides_html <- lapply(seq_along(slide_data), function(i) {
    slide <- slide_data[[i]]

    content <- switch(
      slide$type,
      text = "<p>Este es un slide de texto. Puedes escribir lo que quieras.</p>",
      scatter = {
        img_b64 <- generate_plot_base64(function() {
          plot(
            mtcars$wt,
            mtcars$mpg,
            main = "Relacion Peso vs MPG",
            xlab = "Peso (1000 lbs)",
            ylab = "Millas por Galon",
            col = "#3498db",
            pch = 19,
            cex = 1.5
          )
          grid()
        })

        paste0(
          '<img src="data:image/png;base64,',
          img_b64,
          '" alt="Grafico de dispersion" style="display:block; max-width:80%; margin:20px auto;">'
        )
      },
      bar = {
        img_b64 <- generate_plot_base64(function() {
          counts <- table(mtcars$cyl)
          barplot(
            counts,
            main = "Distribucion de Cilindros",
            xlab = "Cilindros",
            ylab = "Frecuencia",
            col = "#e74c3c",
            ylim = c(0, 15)
          )
        })

        paste0(
          '<img src="data:image/png;base64,',
          img_b64,
          '" alt="Grafico de barras" style="display:block; max-width:80%; margin:20px auto;">'
        )
      },
      "<p>Tipo de slide no soportado.</p>"
    )

    type_label <- names(slide_type_labels)[match(slide$type, slide_type_labels)]
    if (is.na(type_label)) {
      type_label <- slide$type
    }

    paste0(
      "<section>",
      "<h2>", htmltools::htmlEscape(slide$title), "</h2>",
      '<p style="color:#bdc3c7;">Slide ', i, " - ", htmltools::htmlEscape(type_label), "</p>",
      content,
      "</section>"
    )
  })

  paste(slides_html, collapse = "\n")
}

build_presentation_html <- function(slides_content, title = "Mi Presentacion") {
  paste0(
    '<!DOCTYPE html>',
    '<html>',
    '<head>',
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">',
    "<title>", htmltools::htmlEscape(title), "</title>",
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.css">',
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/theme/black.css">',
    "<style>",
    "html, body { height: 100%; margin: 0; background: #000; }",
    "body { overflow: hidden; }",
    ".reveal { width: 100%; height: 100%; }",
    ".reveal .slides section { padding: 20px; }",
    ".reveal img { max-height: 70vh; object-fit: contain; }",
    "</style>",
    "</head>",
    "<body>",
    '<div class="reveal">',
    '<div class="slides">',
    slides_content,
    "</div>",
    "</div>",
    '<script src="https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.js"></script>',
    "<script>",
    "const revealConfig = ", reveal_config_js(), ";",
    "Reveal.initialize(revealConfig);",
    "</script>",
    "</body>",
    "</html>"
  )
}

ui <- fluidPage(
  tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.css"
    ),
    tags$link(
      rel = "stylesheet",
      href = "https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/theme/black.css"
    ),
    tags$script(src = "https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.js"),
    tags$style(HTML("
      html, body {
        margin: 0;
        padding: 0;
        height: 100%;
        overflow: hidden;
        background: #000;
      }
      #controls {
        position: fixed;
        left: 0;
        top: 0;
        width: 280px;
        height: 100%;
        background: #2c3e50;
        color: white;
        padding: 20px;
        z-index: 1000;
        overflow-y: auto;
        box-shadow: 2px 0 10px rgba(0, 0, 0, 0.3);
      }
      #controls h3, #controls h4, #controls label {
        color: white;
      }
      #presentation-panel {
        position: fixed;
        left: 280px;
        top: 0;
        right: 0;
        bottom: 0;
        width: calc(100% - 280px);
        height: 100vh;
        background: #000;
      }
      #presentation-host {
        width: 100%;
        height: 100%;
      }
      #presentation-host .slides section {
        padding: 20px;
      }
      #presentation-host img {
        display: block;
        max-width: 80%;
        max-height: 70vh;
        margin: 20px auto;
        object-fit: contain;
      }
      .btn-primary {
        background-color: #3498db;
        width: 100%;
        margin: 5px 0;
      }
      .btn-danger {
        width: 100%;
        margin: 5px 0;
      }
      .btn-success {
        width: 100%;
      }
    ")),
    tags$script(HTML(paste0(
      "(function() {",
      "  const revealConfig = ", reveal_config_js(), ";",
      "  let deck = null;",
      "  function ensureDeck() {",
      "    const host = document.getElementById('presentation-host');",
      "    if (!host || typeof Reveal === 'undefined') {",
      "      return;",
      "    }",
      "    if (!deck) {",
      "      deck = new Reveal(host, revealConfig);",
      "      deck.initialize().then(function() {",
      "        deck.layout();",
      "      });",
      "      return;",
      "    }",
      "    deck.sync();",
      "    deck.layout();",
      "  }",
      "  function updateSlides(message) {",
      "    const container = document.getElementById('slides-container');",
      "    if (!container) {",
      "      return;",
      "    }",
      "    container.innerHTML = message.html;",
      "    if (!deck) {",
      "      ensureDeck();",
      "      return;",
      "    }",
      "    deck.sync();",
      "    deck.slide(0, 0);",
      "    deck.layout();",
      "  }",
      "  document.addEventListener('DOMContentLoaded', function() {",
      "    ensureDeck();",
      "  });",
      "  window.addEventListener('resize', function() {",
      "    if (deck) {",
      "      deck.layout();",
      "    }",
      "  });",
      "  if (window.Shiny) {",
      "    Shiny.addCustomMessageHandler('update-reveal-slides', updateSlides);",
      "  } else {",
      "    document.addEventListener('shiny:connected', function() {",
      "      Shiny.addCustomMessageHandler('update-reveal-slides', updateSlides);",
      "    }, { once: true });",
      "  }",
      "})();"
    )))
  ),
  div(
    id = "controls",
    h3("\U0001F3A8 Constructor de Slides"),
    textInput("title", "Titulo", "Mi Slide"),
    selectInput("type", "Tipo", choices = slide_type_labels),
    actionButton("add", "\u2795 Agregar Slide", class = "btn-primary"),
    actionButton("remove", "\U0001F5D1 Eliminar Ultimo", class = "btn-danger"),
    hr(),
    h4("Slides creados:"),
    uiOutput("slide_list"),
    hr(),
    downloadButton("download", "\U0001F4BE Descargar HTML", class = "btn-success")
  ),
  div(
    id = "presentation-panel",
    tags$div(
      id = "presentation-host",
      class = "reveal",
      tags$div(
        id = "slides-container",
        class = "slides",
        HTML(generate_slides_html(list()))
      )
    )
  )
)

server <- function(input, output, session) {
  slides <- reactiveVal(list())

  current_slides_html <- reactive({
    generate_slides_html(slides())
  })

  output$slide_list <- renderUI({
    current <- slides()

    if (length(current) == 0) {
      return(p("No hay slides aun"))
    }

    lapply(seq_along(current), function(i) {
      div(
        style = "background:#34495e; margin:5px 0; padding:8px; border-radius:4px;",
        strong(paste(i, "-", current[[i]]$title)),
        p(current[[i]]$type, style = "font-size:0.8em; margin:0;"),
        actionButton(
          paste0("del_", i),
          "Eliminar",
          style = "padding:2px 6px; font-size:0.7em; margin-top:4px;",
          class = "btn-warning"
        )
      )
    })
  })

  observe({
    current <- slides()

    lapply(seq_along(current), function(i) {
      observeEvent(input[[paste0("del_", i)]], {
        updated <- slides()
        if (i <= length(updated)) {
          updated[[i]] <- NULL
          slides(updated)
        }
      }, ignoreInit = TRUE)
    })
  })

  observeEvent(input$add, {
    current <- slides()

    new_slide <- list(
      title = input$title,
      type = input$type,
      id = length(current) + 1
    )

    slides(c(current, list(new_slide)))
    updateTextInput(session, "title", value = "Mi Slide")
  })

  observeEvent(input$remove, {
    current <- slides()
    if (length(current) > 0) {
      slides(current[-length(current)])
    }
  })

  observe({
    session$sendCustomMessage(
      "update-reveal-slides",
      list(html = current_slides_html())
    )
  })

  output$download <- downloadHandler(
    filename = function() {
      paste0("presentacion_", Sys.Date(), ".html")
    },
    content = function(file) {
      writeLines(
        build_presentation_html(
          slides_content = current_slides_html(),
          title = "Mi Presentacion"
        ),
        file,
        useBytes = TRUE
      )
    }
  )
}

shinyApp(ui, server)
