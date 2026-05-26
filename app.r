library(shiny)

app_file <- tryCatch(
  normalizePath(sys.frame(1)$ofile, winslash = "\\", mustWork = TRUE),
  error = function(e) normalizePath("app.r", winslash = "\\", mustWork = FALSE)
)

source(file.path(dirname(app_file), "reveal_slides.R"), local = FALSE)

slide_type_labels <- c(
  "Texto" = "text",
  "Grafico Dispersion" = "scatter",
  "Grafico Barras" = "bar"
)

build_demo_slide <- function(title, type) {
  switch(
    type,
    text = slide_text(
      title = title,
      body = "Este es un slide de texto. Puedes escribir lo que quieras.",
      type_label = "Texto"
    ),
    scatter = slide_plot(
      title = title,
      subtitle = "Relacion Peso vs MPG",
      type_label = "Grafico Dispersion",
      plot = function() {
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
      }
    ),
    bar = slide_plot(
      title = title,
      subtitle = "Distribucion de Cilindros",
      type_label = "Grafico Barras",
      plot = function() {
        counts <- table(mtcars$cyl)
        barplot(
          counts,
          main = "Distribucion de Cilindros",
          xlab = "Cilindros",
          ylab = "Frecuencia",
          col = "#e74c3c",
          ylim = c(0, 15)
        )
      }
    ),
    stop("Unsupported demo slide type: ", type)
  )
}

ui <- fluidPage(
  tags$head(
    reveal_slides_dependencies(theme = "black"),
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
    "))
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
    reveal_slides_ui("deck")
  )
)

server <- function(input, output, session) {
  slides <- reactiveVal(list())

  output$slide_list <- renderUI({
    current <- slides()

    if (length(current) == 0) {
      return(p("No hay slides aun"))
    }

    lapply(seq_along(current), function(i) {
      div(
        style = "background:#34495e; margin:5px 0; padding:8px; border-radius:4px;",
        strong(paste(i, "-", current[[i]]$title)),
        p(current[[i]]$type_label %||% current[[i]]$type, style = "font-size:0.8em; margin:0;"),
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
    slides(c(current, list(build_demo_slide(input$title, input$type))))
    updateTextInput(session, "title", value = "Mi Slide")
  })

  observeEvent(input$remove, {
    current <- slides()
    if (length(current) > 0) {
      slides(current[-length(current)])
    }
  })

  observe({
    render_reveal_slides(session, "deck", slides())
  })

  output$download <- downloadHandler(
    filename = function() {
      paste0("presentacion_", Sys.Date(), ".html")
    },
    content = function(file) {
      writeLines(
        build_reveal_html(
          slides = slides(),
          title = "Mi Presentacion"
        ),
        file,
        useBytes = TRUE
      )
    }
  )
}

shinyApp(ui, server)
