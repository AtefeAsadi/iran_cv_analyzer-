library(shiny)
library(bslib)
library(pdftools)
library(stringr)

# =========================
# THEME
# =========================
theme <- bs_theme(
  version = 5,
  bg = "#fff0f6",
  fg = "#111827",
  primary = "#ff4da6",
  base_font = font_google("Inter")
)

# =========================
# UI
# =========================
ui <- page_sidebar(
  theme = theme,
  title = "IRAN CV Analyzer",
  sidebar = sidebar(
    fileInput("file", "Upload CV (PDF)", accept = ".pdf")
  ),
  div(
    style = "background:white;padding:20px;border-radius:18px;border:2px solid #ffb3d9;margin-bottom:16px;",
    h3("CV Analysis Dashboard"),
    p("Upload your resume → AI generates career roadmap")
  ),
  layout_column_wrap(
    width = 1/3,
    card(
      card_header(" Suggested Job"),
      h3(textOutput("best_job"), style = "color:#ff4da6;")
    ),
    card(
      card_header(" Missing Skills"),
      verbatimTextOutput("missing")
    ),
    card(
      card_header(" Skill Roadmap"),
      htmlOutput("ai_output")
    )
  )
)

# =========================
# SERVER
# =========================
server <- function(input, output) {
 
  cv_text <- reactive({
    req(input$file)
    tryCatch({
      text <- pdf_text(input$file$datapath)
      text <- paste(text, collapse = " ")
      
      # Strong cleaning - remove contact & personal info
      text <- str_remove_all(text, regex(
        "(?i)(miss\\.asadi99@gmail\\.com|datascienceanna@gmail\\.com|linkedin|github|tehran|iran|contact|email|phone|asadi-1995anna)", 
        ignore_case = TRUE
      ))
      
      text <- str_squish(tolower(text))
      
      if (nchar(text) < 100) {
        showNotification("متن PDF به درستی خوانده نشد!", type = "error")
        return(NULL)
      }
      text
    }, error = function(e) {
      showNotification("خطا در خواندن PDF", type = "error")
      NULL
    })
  })
 
  clean_output <- function(text) {
    if (is.null(text)) return("")
    text <- gsub("\u001B\\[[0-9;?]*[a-zA-Z]", "", text, perl = TRUE)
    text <- gsub("[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]+", "", text)
    text <- str_trim(text)
    text
  }
 
  call_ai <- function(prompt) {
    tryCatch({
      res <- system2(
        "ollama",
        args = c("run", "llama3.2:3b", prompt),
        stdout = TRUE,
        stderr = TRUE,
        timeout = 120
      )
      clean_output(paste(res, collapse = "\n"))
    }, error = function(e) {
      paste("خطا:", e$message)
    })
  }
 
  best_job <- reactive({
    req(cv_text())
    prompt <- paste0(
      'Use ONLY the CV. Return exactly ONE job title, no extra text.\n\nCV:\n',
      cv_text()
    )
    clean_output(call_ai(prompt))
  })
 
  missing_skills <- reactive({
    req(cv_text())
    prompt <- paste0(
      'Use ONLY the CV. Never invent skills that exist in the CV. ',
      'List maximum 4 real missing skills.\n',
      'Format exactly:\n- Skill: short reason\n\nCV:\n',
      cv_text()
    )
    clean_output(call_ai(prompt))
  })
 
  ai_output <- reactive({
    req(cv_text())
    prompt <- paste0(
      'Strict coach. Use ONLY CV content. No hallucination. ',
      'Do not repeat numbers. Return exactly this format:\n\n',
      'TARGET ROLE: [title]\n',
      'CURRENT LEVEL: Junior/Mid/Senior\n\n',
      'SKILL ROADMAP:\n',
      'SQL: Current=... | Next=...\n',
      'Python/R: Current=... | Next=...\n',
      'Excel: Current=... | Next=...\n',
      'Statistics: Current=... | Next=...\n',
      'Power BI: Current=... | Next=...\n\n',
      'TOP 3 PRIORITIES:\n1. ...\n2. ...\n3. ...\n\n',
      'ADVICE: Two short sentences.\n\nCV:\n',
      cv_text()
    )
    clean_output(call_ai(prompt))
  })
 
  # Beautiful HTML rendering for roadmap
  output$ai_output <- renderUI({
    req(ai_output())
    txt <- ai_output()
    
    # Clean duplicate numbers like "1. 1."
    txt <- gsub("(\\d+)\\.\\s*\\1\\.", "\\1.", txt)
    
    lines <- str_split(txt, "\n")[[1]]
    html_content <- "<div style='line-height:1.7;'>"
    
    for (line in lines) {
      line <- str_trim(line)
      if (line == "") next
      
      if (str_detect(line, "^TARGET ROLE:")) {
        html_content <- paste0(html_content, "<h5 style='color:#ff4da6; margin-top:10px;'>", line, "</h5>")
      } 
      else if (str_detect(line, "^CURRENT LEVEL:")) {
        html_content <- paste0(html_content, "<p><strong>", line, "</strong></p>")
      } 
      else if (str_detect(line, "^SKILL ROADMAP:")) {
        html_content <- paste0(html_content, "<h6 style='margin-top:15px;'>SKILL ROADMAP</h6><ul style='padding-left:20px;'>")
      } 
      else if (str_detect(line, "^TOP 3 PRIORITIES:")) {
        html_content <- paste0(html_content, "</ul><h6>TOP 3 PRIORITIES</h6><ol style='padding-left:20px;'>")
      } 
      else if (str_detect(line, "^ADVICE:")) {
        html_content <- paste0(html_content, "</ol><p><strong>ADVICE:</strong> ", 
                              str_remove(line, "^ADVICE:\\s*"), "</p>")
      } 
      else if (str_detect(line, "^[A-Za-z/]+:")) {
        html_content <- paste0(html_content, "<li><strong>", line, "</strong></li>")
      } 
      else if (str_detect(line, "^\\d+\\.")) {
        html_content <- paste0(html_content, "<li>", str_remove(line, "^\\d+\\.\\s*"), "</li>")
      } 
      else {
        html_content <- paste0(html_content, "<p>", line, "</p>")
      }
    }
    html_content <- paste0(html_content, "</div>")
    HTML(html_content)
  })
 
  output$best_job <- renderText({ req(best_job()); best_job() })
  output$missing <- renderText({ req(missing_skills()); missing_skills() })
}

shinyApp(ui, server)