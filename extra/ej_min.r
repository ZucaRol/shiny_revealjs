library(shiny)
library(ggiraph)
library(DT)
library(tibble)
library(ggplot2)

source("reveal_slides.R")

mtcars_db <- rownames_to_column(mtcars, var = "carname")

myplot <- ggplot(
  data = mtcars_db,
  mapping = aes(
    x = disp,
    y = qsec,
    tooltip = carname,
    data_id = carname
  )
) +
  geom_point_interactive(
    size = 3,
    hover_nearest = TRUE
  )

interactive_plot <- girafe(
  ggobj = myplot,
  width_svg = 8,
  height_svg = 5
)

interactive_table <- datatable(
  mtcars_db,
  options = list(pageLength = 8, scrollX = TRUE)
)


mi_estilo <- reveal_slides_style(
  background_color = "#fcfcfc",
  text_color = "#1f2937",
  title_color = "#0f172a",
  meta_color = "#475569",
  accent_color = "#2563eb",
  title_size = "clamp(1.3rem, 2vw, 2rem)",
  body_size = "clamp(0.88rem, 1.1vw, 1.05rem)",
  dt_font_scale = "0.78rem"
)

mi_presentacion <- reveal_slides_presentation(
  theme = "white",
  style = mi_estilo
)


ui <- fluidPage(
  tags$head(
    reveal_slides_dependencies(presentation = mi_presentacion)
  ),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "obs",
        "Number of observations:",
        min = 1,
        max = nrow(mtcars_db),
        value = 10
      ),
      downloadButton("download", "Descargar HTML")
    ),
    mainPanel(
      fluidRow(
        column(
          12,
          div(
            style = "height: 100vh;",
            reveal_slides_ui("deck", presentation = mi_presentacion)
          )
        )
      ),
      fluidRow(
        div(p("Este texto esta fuera del deck Reveal."))
      )
    )
  )
)

server <- function(input, output, session) {
  slides <- reactive({
    filtered <- mtcars_db[seq_len(input$obs), , drop = FALSE]

    list(
      slide_text(
        title = "Hola",
        body = "Esta presentacion se genera desde otra app Shiny."
      ),
      slide_plot(
        title = "Grafico base R",
        subtitle = "Ejemplo",
        plot = function() {
          plot(pressure)
        }
      ),
      slide_widget(
        title = "Grafica interactiva",
        subtitle = "ggiraph",
        type_label = "HTML Widget",
        widget = interactive_plot,
        fit = "contain"
      ),
      slide_widget(
        title = "Tabla interactiva",
        subtitle = "DT",
        type_label = "HTML Widget",
        widget = datatable(
          filtered,
          options = list(pageLength = 6, scrollX = TRUE)
        )
      ),
      slide_html(
        title = "HTML arbitrario",
        subtitle = "Compatibilidad",
        body = tags$div(
          style = "padding: 1rem; border: 1px solid #666;",
          tags$p("Los widgets conviven con HTML simple y otros tipos de slides.")
        )
      )
    )
  })

  observe({
    render_reveal_slides(session, "deck", slides())
  })

  output$download <- downloadHandler(
    filename = function() {
      paste0("widgets_reveal_", Sys.Date(), ".html")
    },
    content = function(file) {
      save_reveal_html(
        slides = slides(),
        file = file,
        title = "Reveal widgets demo",
        presentation = mi_presentacion,
        selfcontained = TRUE
      )
    }
  )
}

shinyApp(ui, server)
