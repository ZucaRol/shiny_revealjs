`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

default_reveal_config <- function() {
  list(
    controls = TRUE,
    progress = TRUE,
    center = TRUE,
    hash = FALSE,
    embedded = TRUE,
    width = "100%",
    height = "100%",
    margin = 0.1,
    transition = "slide"
  )
}

merge_reveal_config <- function(config = NULL) {
  utils::modifyList(default_reveal_config(), config %||% list())
}

reveal_config_json <- function(config = NULL) {
  jsonlite::toJSON(
    merge_reveal_config(config),
    auto_unbox = TRUE,
    null = "null",
    pretty = FALSE
  )
}

reveal_theme_href <- function(theme = "black") {
  paste0(
    "https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/theme/",
    theme,
    ".css"
  )
}

plot_to_data_uri <- function(plot_fn, width = 800, height = 500, res = 96) {
  if (!is.function(plot_fn)) {
    stop("`plot_fn` must be a function that draws the plot.")
  }

  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)

  png(tmp, width = width, height = height, res = res)
  plot_fn()
  dev.off()

  paste0(
    "data:image/png;base64,",
    base64enc::base64encode(tmp)
  )
}

slide_text <- function(title, body, subtitle = NULL, type_label = "Texto") {
  list(
    title = title,
    type = "text",
    body = body,
    subtitle = subtitle,
    type_label = type_label
  )
}

slide_html <- function(title, body, subtitle = NULL, type_label = "HTML") {
  list(
    title = title,
    type = "html",
    body = body,
    subtitle = subtitle,
    type_label = type_label
  )
}

slide_plot <- function(title, plot, subtitle = NULL, type_label = "Grafico") {
  list(
    title = title,
    type = "plot",
    plot = plot,
    subtitle = subtitle,
    type_label = type_label
  )
}

slide_image <- function(title, src, alt = title, subtitle = NULL, type_label = "Imagen") {
  list(
    title = title,
    type = "image",
    src = src,
    alt = alt,
    subtitle = subtitle,
    type_label = type_label
  )
}

text_body_to_html <- function(body) {
  body <- as.character(body %||% "")
  paragraphs <- unlist(strsplit(body, "\n\n", fixed = TRUE), use.names = FALSE)

  if (length(paragraphs) == 0) {
    paragraphs <- ""
  }

  paragraph_html <- vapply(
    paragraphs,
    function(paragraph) {
      line_html <- gsub(
        "\n",
        "<br>",
        htmltools::htmlEscape(paragraph),
        fixed = TRUE
      )
      paste0("<p>", line_html, "</p>")
    },
    character(1)
  )

  paste(paragraph_html, collapse = "\n")
}

slide_content_to_html <- function(slide) {
  slide_type <- slide$type %||% "text"

  switch(
    slide_type,
    text = text_body_to_html(slide$body %||% ""),
    html = as.character(slide$body %||% ""),
    plot = paste0(
      '<img src="',
      plot_to_data_uri(slide$plot),
      '" alt="',
      htmltools::htmlEscape(slide$alt %||% slide$title %||% "Grafico"),
      '">'
    ),
    image = paste0(
      '<img src="',
      htmltools::htmlEscape(slide$src %||% ""),
      '" alt="',
      htmltools::htmlEscape(slide$alt %||% slide$title %||% "Imagen"),
      '">'
    ),
    stop("Unsupported slide type: ", slide_type)
  )
}

default_slide_renderer <- function(slides) {
  if (length(slides) == 0) {
    return(paste(
      "<section>",
      "<h2>Bienvenido</h2>",
      "<p>Usa los controles de la izquierda para agregar slides.</p>",
      "<p>Los cambios apareceran aqui de forma inmediata.</p>",
      "</section>",
      sep = "\n"
    ))
  }

  slide_sections <- lapply(seq_along(slides), function(i) {
    slide <- slides[[i]]
    title <- htmltools::htmlEscape(slide$title %||% paste("Slide", i))

    info_parts <- Filter(
      nzchar,
      c(
        as.character(slide$type_label %||% ""),
        as.character(slide$subtitle %||% "")
      )
    )

    info_html <- ""
    if (length(info_parts) > 0) {
      info_html <- paste0(
        '<p class="reveal-slides-meta">',
        htmltools::htmlEscape(paste(info_parts, collapse = " - ")),
        "</p>"
      )
    }

    paste0(
      "<section>",
      "<h2>", title, "</h2>",
      info_html,
      slide_content_to_html(slide),
      "</section>"
    )
  })

  paste(unlist(slide_sections, use.names = FALSE), collapse = "\n")
}

reveal_slides_dependencies <- function(theme = "black") {
  shiny::tagList(
    shiny::singleton(
      shiny::tags$link(
        rel = "stylesheet",
        href = "https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.css"
      )
    ),
    shiny::singleton(
      shiny::tags$link(
        rel = "stylesheet",
        href = reveal_theme_href(theme)
      )
    ),
    shiny::singleton(
      shiny::tags$style(shiny::HTML("
        .reveal-slides-host {
          width: 100%;
          height: 100%;
          background: #000;
        }
        .reveal-slides-host .slides section {
          padding: 20px;
        }
        .reveal-slides-host img {
          display: block;
          max-width: 80%;
          max-height: 70vh;
          margin: 20px auto;
          object-fit: contain;
        }
        .reveal-slides-meta {
          color: #bdc3c7;
        }
      "))
    ),
    shiny::singleton(
      shiny::tags$script(src = "https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.js")
    ),
    shiny::singleton(
      shiny::tags$script(shiny::HTML("
        (function() {
          const decks = {};

          function readConfig(host) {
            const rawConfig = host.dataset.revealConfig || '{}';
            try {
              return JSON.parse(rawConfig);
            } catch (error) {
              console.error('Invalid Reveal config', error);
              return {};
            }
          }

          function ensureDeck(id) {
            const host = document.getElementById(id);
            if (!host || typeof Reveal === 'undefined') {
              return null;
            }

            let deck = decks[id];
            if (!deck) {
              deck = new Reveal(host, readConfig(host));
              decks[id] = deck;

              const initResult = deck.initialize();
              if (initResult && typeof initResult.then === 'function') {
                initResult.then(function() {
                  deck.layout();
                });
              } else {
                deck.layout();
              }

              return deck;
            }

            deck.sync();
            deck.layout();
            return deck;
          }

          function updateSlides(message) {
            const container = document.getElementById(message.id + '-slides');
            if (!container) {
              return;
            }

            container.innerHTML = message.html;

            const deck = ensureDeck(message.id);
            if (!deck) {
              return;
            }

            deck.sync();
            if (message.reset_index !== false) {
              deck.slide(0, 0);
            }
            deck.layout();
          }

          function initAllDecks() {
            document.querySelectorAll('.reveal-slides-host').forEach(function(host) {
              ensureDeck(host.id);
            });
          }

          document.addEventListener('DOMContentLoaded', initAllDecks);
          window.addEventListener('resize', function() {
            Object.keys(decks).forEach(function(id) {
              if (decks[id]) {
                decks[id].layout();
              }
            });
          });

          if (window.Shiny) {
            Shiny.addCustomMessageHandler('reveal-slides-update', updateSlides);
          } else {
            document.addEventListener('shiny:connected', function() {
              Shiny.addCustomMessageHandler('reveal-slides-update', updateSlides);
            }, { once: true });
          }
        })();
      "))
    )
  )
}

reveal_slides_ui <- function(
  id,
  initial_slides = list(),
  renderer = default_slide_renderer,
  config = NULL,
  style = NULL
) {
  host_style <- paste(
    "width:100%; height:100%;",
    style %||% "",
    sep = " "
  )

  shiny::tags$div(
    id = id,
    class = "reveal reveal-slides-host",
    style = host_style,
    `data-reveal-config` = reveal_config_json(config),
    shiny::tags$div(
      id = paste0(id, "-slides"),
      class = "slides",
      shiny::HTML(renderer(initial_slides))
    )
  )
}

render_reveal_slides <- function(
  session,
  id,
  slides,
  renderer = default_slide_renderer,
  reset_index = TRUE
) {
  slides_html <- renderer(slides)

  session$sendCustomMessage(
    "reveal-slides-update",
    list(
      id = id,
      html = slides_html,
      reset_index = reset_index
    )
  )

  invisible(slides_html)
}

build_reveal_html <- function(
  slides,
  title = "Presentacion",
  renderer = default_slide_renderer,
  theme = "black",
  config = NULL
) {
  slides_html <- renderer(slides)

  paste0(
    "<!DOCTYPE html>",
    "<html>",
    "<head>",
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">',
    "<title>", htmltools::htmlEscape(title), "</title>",
    '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.css">',
    '<link rel="stylesheet" href="', reveal_theme_href(theme), '">',
    "<style>",
    "html, body { height: 100%; margin: 0; background: #000; }",
    "body { overflow: hidden; }",
    ".reveal { width: 100%; height: 100%; }",
    ".reveal .slides section { padding: 20px; }",
    ".reveal img { display:block; max-width:80%; max-height:70vh; margin:20px auto; object-fit:contain; }",
    ".reveal-slides-meta { color: #bdc3c7; }",
    "</style>",
    "</head>",
    "<body>",
    '<div class="reveal" id="reveal-export-host">',
    '<div class="slides">',
    slides_html,
    "</div>",
    "</div>",
    '<script src="https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.js"></script>',
    "<script>",
    "const revealConfig = ", reveal_config_json(config), ";",
    "const revealDeck = new Reveal(document.getElementById('reveal-export-host'), revealConfig);",
    "revealDeck.initialize();",
    "</script>",
    "</body>",
    "</html>"
  )
}

# Uso minimo en otra app:
# source('reveal_slides.R')
# ui <- fluidPage(
#   tags$head(reveal_slides_dependencies()),
#   reveal_slides_ui('deck')
# )
# server <- function(input, output, session) {
#   slides <- list(slide_text('Hola', 'Contenido'))
#   render_reveal_slides(session, 'deck', slides)
# }
