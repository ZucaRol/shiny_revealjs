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

reveal_slides_presentation <- function(theme = "black", style = NULL, config = NULL) {
  structure(
    list(
      theme = theme,
      style = style,
      config = config
    ),
    class = "reveal_slides_presentation"
  )
}

resolve_reveal_presentation <- function(
  presentation = NULL,
  theme = "black",
  style = NULL,
  config = NULL
) {
  if (!is.null(presentation) && !inherits(presentation, "reveal_slides_presentation")) {
    stop("`presentation` must be created with reveal_slides_presentation().")
  }

  list(
    theme = if (!is.null(presentation$theme)) presentation$theme else theme,
    style = if (!is.null(style)) style else presentation$style %||% NULL,
    config = if (!is.null(config)) config else presentation$config %||% NULL
  )
}

default_reveal_style <- function() {
  list(
    background_color = "#000000",
    text_color = "#f7f7f7",
    title_color = "#ffffff",
    meta_color = "#bdc3c7",
    accent_color = "#6cc3d5",
    border_color = "rgba(255, 255, 255, 0.18)",
    shell_padding = "1.25rem 1.5rem 1rem",
    slide_gap = "0.5rem",
    title_size = "clamp(1.45rem, 2.4vw, 2.3rem)",
    body_size = "clamp(0.9rem, 1.2vw, 1.15rem)",
    meta_size = "clamp(0.72rem, 0.95vw, 0.9rem)",
    title_line_height = "1.1",
    body_line_height = "1.35",
    widget_max_height = "min(100%, 52vh)",
    widget_frame_padding = "0",
    dt_font_scale = "0.82em"
  )
}

reveal_slides_style <- function(
  background_color = NULL,
  text_color = NULL,
  title_color = NULL,
  meta_color = NULL,
  accent_color = NULL,
  border_color = NULL,
  shell_padding = NULL,
  slide_gap = NULL,
  title_size = NULL,
  body_size = NULL,
  meta_size = NULL,
  title_line_height = NULL,
  body_line_height = NULL,
  widget_max_height = NULL,
  widget_frame_padding = NULL,
  dt_font_scale = NULL
) {
  Filter(
    Negate(is.null),
    list(
      background_color = background_color,
      text_color = text_color,
      title_color = title_color,
      meta_color = meta_color,
      accent_color = accent_color,
      border_color = border_color,
      shell_padding = shell_padding,
      slide_gap = slide_gap,
      title_size = title_size,
      body_size = body_size,
      meta_size = meta_size,
      title_line_height = title_line_height,
      body_line_height = body_line_height,
      widget_max_height = widget_max_height,
      widget_frame_padding = widget_frame_padding,
      dt_font_scale = dt_font_scale
    )
  )
}

merge_reveal_style <- function(style = NULL) {
  utils::modifyList(default_reveal_style(), style %||% list())
}

reveal_style_css <- function(style = NULL) {
  style <- merge_reveal_style(style)

  paste0(
    ".reveal-slides-host {",
    "width: 100%;",
    "height: 100%;",
    "background: ", style$background_color, ";",
    "color: ", style$text_color, ";",
    "--reveal-slides-bg: ", style$background_color, ";",
    "--reveal-slides-text: ", style$text_color, ";",
    "--reveal-slides-title: ", style$title_color, ";",
    "--reveal-slides-meta: ", style$meta_color, ";",
    "--reveal-slides-accent: ", style$accent_color, ";",
    "--reveal-slides-border: ", style$border_color, ";",
    "}",
    ".reveal-slides-host .slides section {",
    "padding: 0;",
    "height: 100%;",
    "box-sizing: border-box;",
    "}",
    ".reveal-slides-host .slides section > .reveal-slide-shell {",
    "display: flex;",
    "flex-direction: column;",
    "gap: ", style$slide_gap, ";",
    "width: 100%;",
    "height: 100%;",
    "padding: ", style$shell_padding, ";",
    "box-sizing: border-box;",
    "}",
    ".reveal-slides-host .reveal-slide-title {",
    "margin: 0;",
    "color: ", style$title_color, ";",
    "font-size: ", style$title_size, ";",
    "line-height: ", style$title_line_height, ";",
    "}",
    ".reveal-slides-host .reveal-slide-body {",
    "flex: 1 1 auto;",
    "min-height: 0;",
    "width: 100%;",
    "overflow: auto;",
    "color: ", style$text_color, ";",
    "font-size: ", style$body_size, ";",
    "line-height: ", style$body_line_height, ";",
    "}",
    ".reveal-slides-host .reveal-slide-body > :first-child {",
    "margin-top: 0;",
    "}",
    ".reveal-slides-host .reveal-slide-body > :last-child {",
    "margin-bottom: 0;",
    "}",
    ".reveal-slides-host .reveal-slide-body,",
    ".reveal-slides-host .reveal-slide-body p,",
    ".reveal-slides-host .reveal-slide-body li,",
    ".reveal-slides-host .reveal-slide-body ul,",
    ".reveal-slides-host .reveal-slide-body ol,",
    ".reveal-slides-host .reveal-slide-body table,",
    ".reveal-slides-host .reveal-slide-body th,",
    ".reveal-slides-host .reveal-slide-body td,",
    ".reveal-slides-host .reveal-slide-body label {",
    "color: ", style$text_color, ";",
    "font-size: inherit;",
    "}",
    ".reveal-slides-host .reveal-slide-body a {",
    "color: ", style$accent_color, ";",
    "}",
    ".reveal-slides-host .reveal-slide-body table {",
    "width: 100% !important;",
    "}",
    ".reveal-slides-host img {",
    "display: block;",
    "max-width: 100%;",
    "max-height: 100%;",
    "margin: 0 auto;",
    "object-fit: contain;",
    "}",
    ".reveal-slides-meta {",
    "margin: 0;",
    "color: ", style$meta_color, ";",
    "font-size: ", style$meta_size, ";",
    "}",
    ".reveal-slides-widget {",
    "width: 100%;",
    "max-width: 100%;",
    "max-height: 100%;",
    "margin: 0 auto;",
    "padding: ", style$widget_frame_padding, ";",
    "box-sizing: border-box;",
    "}",
    ".reveal-slides-widget .html-widget,",
    ".reveal-slides-widget .girafe,",
    ".reveal-slides-widget .datatables,",
    ".reveal-slides-widget iframe {",
    "width: 100% !important;",
    "max-width: 100%;",
    "}",
    ".reveal-slides-widget .dataTables_wrapper {",
    "font-size: ", style$dt_font_scale, ";",
    "}",
    ".reveal-slides-widget .dataTables_scrollBody,",
    ".reveal-slides-widget .dataTables_wrapper {",
    "max-height: ", style$widget_max_height, ";",
    "}",
    ".reveal-slides-widget .girafe_container_std,",
    ".reveal-slides-widget .girafe {",
    "width: 100% !important;",
    "}",
    ".reveal-slides-widget--fit-contain {",
    "display: flex;",
    "align-items: center;",
    "justify-content: center;",
    "height: 100%;",
    "max-height: 100%;",
    "overflow: hidden;",
    "}",
    ".reveal-slide-body > .reveal-slides-widget--fit-contain:first-child:last-child {",
    "height: 100%;",
    "}",
    ".reveal-slides-widget--fit-contain .html-widget,",
    ".reveal-slides-widget--fit-contain .girafe,",
    ".reveal-slides-widget--fit-contain .girafe_container_std {",
    "max-width: 100%;",
    "max-height: 100%;",
    "}",
    ".reveal-slides-host .reveal-slide-body pre,",
    ".reveal-slides-host .reveal-slide-body code {",
    "font-size: 0.9em;",
    "}",
    ".reveal-slides-host .reveal-slide-body hr {",
    "border-color: ", style$border_color, ";",
    "}",
    ".reveal-slides-host .reveal-slide-body blockquote {",
    "border-left: 3px solid ", style$accent_color, ";",
    "padding-left: 0.8rem;",
    "margin-left: 0;",
    "color: ", style$text_color, ";",
    "}"
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

slide_widget <- function(
  title,
  widget,
  subtitle = NULL,
  type_label = "Widget",
  fit = NULL,
  aspect_ratio = NULL
) {
  if (!inherits(widget, "htmlwidget")) {
    stop("`widget` must be an htmlwidget object.")
  }

  widget_kind <- "htmlwidget"
  widget_fit <- fit %||% "scroll"
  widget_ratio <- aspect_ratio %||% NULL

  if (inherits(widget, "girafe")) {
    widget_kind <- "girafe"
    widget_fit <- fit %||% "contain"
    widget_ratio <- aspect_ratio %||% widget$x$ratio %||% NULL
  } else if (inherits(widget, "datatables")) {
    widget_kind <- "datatable"
  }

  list(
    title = title,
    type = "widget",
    widget = widget,
    widget_kind = widget_kind,
    widget_fit = widget_fit,
    widget_ratio = widget_ratio,
    subtitle = subtitle,
    type_label = type_label
  )
}

text_body_to_tag <- function(body) {
  body <- as.character(body %||% "")
  paragraphs <- unlist(strsplit(body, "\n\n", fixed = TRUE), use.names = FALSE)

  if (length(paragraphs) == 0) {
    paragraphs <- ""
  }

  htmltools::tagList(
    lapply(paragraphs, function(paragraph) {
      line_html <- gsub(
        "\n",
        "<br>",
        htmltools::htmlEscape(paragraph),
        fixed = TRUE
      )

      shiny::tags$p(htmltools::HTML(line_html))
    })
  )
}

html_body_to_tag <- function(body) {
  if (inherits(body, c("shiny.tag", "shiny.tag.list", "html"))) {
    return(body)
  }

  htmltools::HTML(as.character(body %||% ""))
}

slide_content_to_tag <- function(slide) {
  slide_type <- slide$type %||% "text"

  switch(
    slide_type,
    text = text_body_to_tag(slide$body %||% ""),
    html = html_body_to_tag(slide$body),
    plot = shiny::tags$img(
      src = plot_to_data_uri(slide$plot),
      alt = slide$alt %||% slide$title %||% "Grafico"
    ),
    image = shiny::tags$img(
      src = slide$src %||% "",
      alt = slide$alt %||% slide$title %||% "Imagen"
    ),
    widget = shiny::tags$div(
      class = paste(
        "reveal-slides-widget",
        paste0("reveal-slides-widget--kind-", slide$widget_kind %||% "htmlwidget"),
        paste0("reveal-slides-widget--fit-", slide$widget_fit %||% "scroll")
      ),
      `data-widget-kind` = slide$widget_kind %||% "htmlwidget",
      `data-widget-fit` = slide$widget_fit %||% "scroll",
      `data-widget-ratio` = if (!is.null(slide$widget_ratio)) as.character(slide$widget_ratio) else NULL,
      slide$widget
    ),
    stop("Unsupported slide type: ", slide_type)
  )
}

slide_info_tag <- function(slide) {
  info_parts <- Filter(
    nzchar,
    c(
      as.character(slide$type_label %||% ""),
      as.character(slide$subtitle %||% "")
    )
  )

  if (length(info_parts) == 0) {
    return(NULL)
  }

  shiny::tags$p(
    class = "reveal-slides-meta",
    htmltools::htmlEscape(paste(info_parts, collapse = " - "))
  )
}

slide_section_tag <- function(slide, index) {
  shiny::tags$section(
    shiny::tags$div(
      class = "reveal-slide-shell",
      shiny::tags$h2(
        class = "reveal-slide-title",
        htmltools::htmlEscape(slide$title %||% paste("Slide", index))
      ),
      slide_info_tag(slide),
      shiny::tags$div(
        class = "reveal-slide-body",
        slide_content_to_tag(slide)
      )
    )
  )
}

default_slide_renderer <- function(slides) {
  if (length(slides) == 0) {
    return(
      htmltools::tagList(
        shiny::tags$section(
          shiny::tags$div(
            class = "reveal-slide-shell",
            shiny::tags$h2(class = "reveal-slide-title", "Bienvenido"),
            shiny::tags$div(
              class = "reveal-slide-body",
              shiny::tags$p("Usa los controles de la izquierda para agregar slides."),
              shiny::tags$p("Los cambios apareceran aqui de forma inmediata.")
            )
          )
        )
      )
    )
  }

  htmltools::tagList(
    lapply(seq_along(slides), function(i) {
      slide_section_tag(slides[[i]], i)
    })
  )
}

compile_reveal_slides <- function(slides, renderer = default_slide_renderer) {
  slide_tags <- renderer(slides)
  rendered <- htmltools::renderTags(slide_tags)
  dependencies <- htmltools::resolveDependencies(rendered$dependencies %||% list())

  list(
    tags = slide_tags,
    html = as.character(rendered$html),
    dependencies = dependencies,
    head = rendered$head,
    singletons = rendered$singletons
  )
}

as_web_dependencies <- function(dependencies) {
  if (length(dependencies) == 0) {
    return(list())
  }

  create_web_dependency <- getFromNamespace("createWebDependency", "shiny")

  lapply(dependencies, function(dep) {
    unclass(create_web_dependency(dep, scrubFile = TRUE))
  })
}

reveal_runtime_script <- function() {
  paste(
    "(function() {",
    "  const decks = {};",
    "  function fitContainedWidgets(root) {",
    "    const scope = root || document;",
    "    scope.querySelectorAll('.reveal-slides-widget[data-widget-fit=\"contain\"]').forEach(function(container) {",
    "      const widget = container.querySelector('.html-widget');",
    "      if (!widget) {",
    "        return;",
    "      }",
    "      const availableWidth = container.clientWidth;",
    "      const availableHeight = container.clientHeight;",
    "      if (!availableWidth || !availableHeight) {",
    "        return;",
    "      }",
    "      const ratio = parseFloat(container.dataset.widgetRatio || '');",
    "      let width = availableWidth;",
    "      let height = availableHeight;",
    "      if (Number.isFinite(ratio) && ratio > 0) {",
    "        width = Math.min(availableWidth, availableHeight * ratio);",
    "        height = width / ratio;",
    "      }",
    "      widget.style.width = width + 'px';",
    "      widget.style.height = height + 'px';",
    "      widget.style.maxWidth = '100%';",
    "      widget.style.maxHeight = '100%';",
    "      widget.style.margin = '0 auto';",
    "    });",
    "  }",
    "  function triggerWidgetResize() {",
    "    window.setTimeout(function() {",
    "      fitContainedWidgets(document);",
    "      window.dispatchEvent(new Event('resize'));",
    "      if (window.HTMLWidgets && typeof window.HTMLWidgets.staticRender === 'function') {",
    "        try {",
    "          window.HTMLWidgets.staticRender();",
    "        } catch (error) {",
    "          console.warn('HTMLWidgets staticRender failed', error);",
    "        }",
    "      }",
    "    }, 0);",
    "  }",
    "  function bindDeckEvents(deck) {",
    "    if (!deck || deck.__revealSlidesBound) {",
    "      return;",
    "    }",
    "    deck.__revealSlidesBound = true;",
    "    deck.on('ready', triggerWidgetResize);",
    "    deck.on('slidechanged', triggerWidgetResize);",
    "  }",
    "  function readConfig(host) {",
    "    const rawConfig = host.dataset.revealConfig || '{}';",
    "    try {",
    "      return JSON.parse(rawConfig);",
    "    } catch (error) {",
    "      console.error('Invalid Reveal config', error);",
    "      return {};",
    "    }",
    "  }",
    "  function ensureDeck(id) {",
    "    const host = document.getElementById(id);",
    "    if (!host || typeof Reveal === 'undefined') {",
    "      return null;",
    "    }",
    "    let deck = decks[id];",
    "    if (!deck) {",
    "      deck = new Reveal(host, readConfig(host));",
    "      decks[id] = deck;",
    "      const initResult = deck.initialize();",
    "      if (initResult && typeof initResult.then === 'function') {",
    "        initResult.then(function() {",
    "          bindDeckEvents(deck);",
    "          deck.layout();",
    "          triggerWidgetResize();",
    "        });",
    "      } else {",
    "        bindDeckEvents(deck);",
    "        deck.layout();",
    "        triggerWidgetResize();",
    "      }",
    "      return deck;",
    "    }",
    "    bindDeckEvents(deck);",
    "    deck.sync();",
    "    deck.layout();",
    "    return deck;",
    "  }",
    "  function syncDeck(message) {",
    "    const deck = ensureDeck(message.id);",
    "    if (!deck) {",
    "      return;",
    "    }",
    "    deck.sync();",
    "    if (message.reset_index !== false) {",
    "      deck.slide(0, 0);",
    "    }",
    "    deck.layout();",
    "    triggerWidgetResize();",
    "  }",
    "  async function updateSlides(message) {",
    "    const container = document.getElementById(message.id + '-slides');",
    "    if (!container) {",
    "      return;",
    "    }",
    "    const payload = { html: message.html || '', deps: message.deps || [] };",
    "    if (window.Shiny && typeof window.Shiny.renderContentAsync === 'function') {",
    "      await window.Shiny.renderContentAsync(container, payload);",
    "    } else if (window.Shiny && typeof window.Shiny.renderContent === 'function') {",
    "      window.Shiny.renderContent(container, payload);",
    "    } else {",
    "      container.innerHTML = payload.html;",
    "      if (window.HTMLWidgets && typeof window.HTMLWidgets.staticRender === 'function') {",
    "        window.HTMLWidgets.staticRender();",
    "      }",
    "    }",
    "    fitContainedWidgets(container);",
    "    syncDeck(message);",
    "  }",
    "  function initAllDecks() {",
    "    document.querySelectorAll('.reveal-slides-host').forEach(function(host) {",
    "      ensureDeck(host.id);",
    "    });",
    "  }",
    "  document.addEventListener('DOMContentLoaded', initAllDecks);",
    "  window.addEventListener('resize', function() {",
    "    Object.keys(decks).forEach(function(id) {",
    "      if (decks[id]) {",
    "        decks[id].layout();",
    "      }",
    "    });",
    "  });",
    "  if (window.Shiny) {",
    "    Shiny.addCustomMessageHandler('reveal-slides-update', updateSlides);",
    "  } else {",
    "    document.addEventListener('shiny:connected', function() {",
    "      Shiny.addCustomMessageHandler('reveal-slides-update', updateSlides);",
    "    }, { once: true });",
    "  }",
    "})();",
    sep = "\n"
  )
}

reveal_base_dependencies <- function(theme = "black", style = NULL) {
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
      shiny::tags$style(
        shiny::HTML(reveal_style_css(style))
      )
    ),
    shiny::singleton(
      shiny::tags$script(
        src = "https://cdn.jsdelivr.net/npm/reveal.js@4.5.0/dist/reveal.min.js"
      )
    )
  )
}

reveal_slides_dependencies <- function(theme = "black", style = NULL, presentation = NULL) {
  presentation_values <- resolve_reveal_presentation(
    presentation = presentation,
    theme = theme,
    style = style
  )

  shiny::tagList(
    reveal_base_dependencies(
      theme = presentation_values$theme,
      style = presentation_values$style
    ),
    shiny::singleton(
      shiny::tags$script(shiny::HTML(reveal_runtime_script()))
    )
  )
}

reveal_slides_ui <- function(
  id,
  initial_slides = list(),
  renderer = default_slide_renderer,
  config = NULL,
  style = NULL,
  presentation = NULL
) {
  presentation_values <- resolve_reveal_presentation(
    presentation = presentation,
    config = config
  )

  slide_tags <- renderer(initial_slides)
  host_style <- paste(
    "width:100%; height:100%;",
    style %||% "",
    sep = " "
  )

  shiny::tags$div(
    id = id,
    class = "reveal reveal-slides-host",
    style = host_style,
    `data-reveal-config` = reveal_config_json(presentation_values$config),
    shiny::tags$div(
      id = paste0(id, "-slides"),
      class = "slides",
      slide_tags
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
  compiled <- compile_reveal_slides(slides, renderer = renderer)

  session$sendCustomMessage(
    "reveal-slides-update",
    list(
      id = id,
      html = compiled$html,
      deps = as_web_dependencies(compiled$dependencies),
      reset_index = reset_index
    )
  )

  invisible(compiled)
}

build_reveal_document <- function(
  slides,
  title = "Presentacion",
  renderer = default_slide_renderer,
  theme = "black",
  config = NULL,
  style = NULL,
  presentation = NULL
) {
  presentation_values <- resolve_reveal_presentation(
    presentation = presentation,
    theme = theme,
    style = style,
    config = config
  )

  compiled <- compile_reveal_slides(slides, renderer = renderer)

  shiny::tags$html(
    shiny::tags$head(
      shiny::tags$meta(charset = "utf-8"),
      shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1.0, user-scalable=no"),
      shiny::tags$title(htmltools::htmlEscape(title)),
      reveal_base_dependencies(
        theme = presentation_values$theme,
        style = presentation_values$style
      ),
      shiny::tags$style(
        shiny::HTML("
          html, body { height: 100%; margin: 0; }
          body { overflow: hidden; }
          .reveal { width: 100%; height: 100%; }
        ")
      )
    ),
    shiny::tags$body(
      shiny::tags$div(
        id = "reveal-export-host",
        class = "reveal reveal-slides-host",
        `data-reveal-config` = reveal_config_json(presentation_values$config),
        shiny::tags$div(
          id = "reveal-export-host-slides",
          class = "slides",
          compiled$tags
        )
      ),
      shiny::tags$script(shiny::HTML(reveal_runtime_script()))
    )
  )
}

guess_mime_type <- function(path) {
  ext <- tolower(tools::file_ext(path))

  switch(
    ext,
    css = "text/css",
    js = "application/javascript",
    png = "image/png",
    jpg = "image/jpeg",
    jpeg = "image/jpeg",
    gif = "image/gif",
    svg = "image/svg+xml",
    webp = "image/webp",
    woff = "font/woff",
    woff2 = "font/woff2",
    ttf = "font/ttf",
    eot = "application/vnd.ms-fontobject",
    otf = "font/otf",
    json = "application/json",
    html = "text/html",
    "application/octet-stream"
  )
}

is_external_resource <- function(path) {
  grepl("^(?:[A-Za-z][A-Za-z0-9+.-]*:|//|#)", path)
}

normalize_resource_reference <- function(path) {
  sub("[?#].*$", "", path)
}

resource_file_path <- function(path, base_dir) {
  if (is_external_resource(path) || startsWith(path, "data:")) {
    return(NULL)
  }

  normalized <- normalize_resource_reference(path)
  candidate <- normalizePath(
    file.path(base_dir, normalized),
    winslash = "/",
    mustWork = FALSE
  )

  if (!file.exists(candidate) || dir.exists(candidate)) {
    return(NULL)
  }

  candidate
}

data_uri_from_file <- function(path) {
  bytes <- readBin(path, what = "raw", n = file.info(path)$size)
  paste0(
    "data:",
    guess_mime_type(path),
    ";base64,",
    base64enc::base64encode(bytes)
  )
}

replace_matches <- function(text, pattern, replacer) {
  matches <- gregexpr(pattern, text, perl = TRUE)[[1]]

  if (identical(matches, -1L)) {
    return(text)
  }

  match_lengths <- attr(matches, "match.length")

  for (i in rev(seq_along(matches))) {
    start <- matches[[i]]
    end <- start + match_lengths[[i]] - 1
    match_text <- substr(text, start, end)
    replacement <- replacer(match_text)

    text <- paste0(
      if (start > 1) substr(text, 1, start - 1) else "",
      replacement,
      if (end < nchar(text)) substr(text, end + 1, nchar(text)) else ""
    )
  }

  text
}

inline_css_urls <- function(css_text, css_dir) {
  replace_matches(
    css_text,
    "url\\(([^)]+)\\)",
    function(match_text) {
      ref <- sub("^url\\((.*)\\)$", "\\1", match_text)
      ref <- trimws(gsub("^[\"']|[\"']$", "", ref))

      resource_path <- resource_file_path(ref, css_dir)
      if (is.null(resource_path)) {
        return(match_text)
      }

      paste0("url('", data_uri_from_file(resource_path), "')")
    }
  )
}

inline_local_resources <- function(html_path) {
  html_text <- paste(readLines(html_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  base_dir <- dirname(html_path)

  html_text <- replace_matches(
    html_text,
    "<script[^>]+src=[\"'][^\"']+[\"'][^>]*></script>",
    function(match_text) {
      src <- sub('.*src=[\"\']([^\"\']+)[\"\'].*', "\\1", match_text)
      resource_path <- resource_file_path(src, base_dir)

      if (is.null(resource_path)) {
        return(match_text)
      }

      script_text <- paste(readLines(resource_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
      paste0("<script>\n", script_text, "\n</script>")
    }
  )

  html_text <- replace_matches(
    html_text,
    "<link[^>]+href=[\"'][^\"']+[\"'][^>]*rel=[\"'][^\"']*stylesheet[^\"']*[\"'][^>]*>|<link[^>]+rel=[\"'][^\"']*stylesheet[^\"']*[\"'][^>]+href=[\"'][^\"']+[\"'][^>]*>",
    function(match_text) {
      href <- sub('.*href=[\"\']([^\"\']+)[\"\'].*', "\\1", match_text)
      resource_path <- resource_file_path(href, base_dir)

      if (is.null(resource_path)) {
        return(match_text)
      }

      css_text <- paste(readLines(resource_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
      css_text <- inline_css_urls(css_text, dirname(resource_path))

      paste0("<style>\n", css_text, "\n</style>")
    }
  )

  html_text <- replace_matches(
    html_text,
    "<img[^>]+src=[\"'][^\"']+[\"'][^>]*>",
    function(match_text) {
      src <- sub('.*src=[\"\']([^\"\']+)[\"\'].*', "\\1", match_text)
      resource_path <- resource_file_path(src, base_dir)

      if (is.null(resource_path)) {
        return(match_text)
      }

      sub(
        'src=[\"\'][^\"\']+[\"\']',
        paste0('src="', data_uri_from_file(resource_path), '"'),
        match_text
      )
    }
  )

  html_text
}

save_reveal_html <- function(
  slides,
  file,
  title = "Presentacion",
  renderer = default_slide_renderer,
  theme = "black",
  config = NULL,
  style = NULL,
  presentation = NULL,
  selfcontained = TRUE,
  libdir = NULL,
  background = NULL
) {
  presentation_values <- resolve_reveal_presentation(
    presentation = presentation,
    theme = theme,
    style = style,
    config = config
  )
  merged_style <- merge_reveal_style(presentation_values$style)
  document <- build_reveal_document(
    slides = slides,
    title = title,
    renderer = renderer,
    theme = presentation_values$theme,
    config = presentation_values$config,
    style = merged_style
  )

  if (!selfcontained) {
    htmltools::save_html(
      html = document,
      file = file,
      libdir = libdir,
      background = background %||% merged_style$background_color
    )
    return(invisible(file))
  }

  temp_file <- tempfile(fileext = ".html")
  temp_libdir <- tempfile(pattern = "reveal_libs_")

  on.exit({
    if (file.exists(temp_file)) {
      unlink(temp_file)
    }
    if (dir.exists(temp_libdir)) {
      unlink(temp_libdir, recursive = TRUE)
    }
  }, add = TRUE)

  htmltools::save_html(
    html = document,
    file = temp_file,
    libdir = temp_libdir,
    background = background %||% merged_style$background_color
  )

  pandoc_available <- FALSE
  if (requireNamespace("rmarkdown", quietly = TRUE)) {
    pandoc_available <- rmarkdown::pandoc_available()
  }

  if (pandoc_available) {
    htmlwidgets:::pandoc_self_contained_html(temp_file, file)
  } else {
    writeLines(
      inline_local_resources(temp_file),
      con = file,
      useBytes = TRUE
    )
  }

  invisible(file)
}

build_reveal_html <- function(
  slides,
  title = "Presentacion",
  renderer = default_slide_renderer,
  theme = "black",
  config = NULL,
  style = NULL,
  presentation = NULL
) {
  temp_file <- tempfile(fileext = ".html")
  on.exit(if (file.exists(temp_file)) unlink(temp_file), add = TRUE)

  save_reveal_html(
    slides = slides,
    file = temp_file,
    title = title,
    renderer = renderer,
    theme = theme,
    config = config,
    style = style,
    presentation = presentation,
    selfcontained = TRUE
  )

  paste(readLines(temp_file, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

# Uso minimo en otra app:
# source('reveal_slides.R')
# ui <- fluidPage(
#   tags$head(reveal_slides_dependencies()),
#   reveal_slides_ui('deck')
# )
# server <- function(input, output, session) {
#   slides <- list(
#     slide_text('Hola', 'Contenido'),
#     slide_widget('Tabla', DT::datatable(head(mtcars)))
#   )
#   render_reveal_slides(session, 'deck', slides)
# }
