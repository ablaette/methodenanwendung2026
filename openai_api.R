# install.packages(c("httr2", "jsonlite"))

library(httr2)
library(jsonlite)
library(cli)

openai_api_key <- Sys.getenv("OPENAI_API_KEY")

system_prompt <- readLines("~/Lab/github/methodenanwendung2026/prompts/sampleprompt.txt", encoding = "UTF-8") |>
  paste(collapse = "\n")

kommentare_df <- read.csv(file = "~/Downloads/ColienFernandesInsta.csv")

klassifiziere <- function(kommentar) {
  cli::cli_alert_info(sprintf("classifying comment: %s", kommentar))
  req <- request("https://api.openai.com/v1/chat/completions") |>
    req_auth_bearer_token(Sys.getenv("OPENAI_API_KEY")) |>
    req_body_json(list(
      model = "gpt-4o",          # aktuelles, stabiles Modell
      temperature = 0,           # deterministisch für Klassifikation
      messages = list(
        list(role = "system", content = system_prompt),
        list(role = "user",   content = kommentar)
      )
    )) |>
    req_retry(max_tries = 3) |>  # bei Rate-Limit-Fehlern automatisch wiederholen
    req_throttle(rate = 20 / 60) # max. 20 Requests/Minute (Tier-1-Limit)
  
  resp <- req_perform(req)
  out  <- resp_body_json(resp)
  cli::cli_alert_success(out$choices[[1]]$message$content)
  out$choices[[1]]$message$content
}

# Alle Kommentare klassifizieren
ergebnisse <- data.frame(
  kommentar  = kommentare,
  kategorie  = sapply(kommentare_df$Kommentar, klassifiziere),
  stringsAsFactors = FALSE
)

# print(ergebnisse)
# write.csv(ergebnisse, "klassifikation_ergebnisse.csv", row.names = FALSE, fileEncoding = "UTF-8")