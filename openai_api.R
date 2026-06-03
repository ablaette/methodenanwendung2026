install.packages(c("httr2", "jsonlite"))

library(httr2)

Sys.setenv(OPENAI_API_KEY = "sk-...")  # better: put this in .Renviron

req <- request("https://api.openai.com/v1/responses") |>
  req_auth_bearer_token(Sys.getenv("OPENAI_API_KEY")) |>
  req_body_json(list(
    model = "gpt-5.5",
    input = "Explain logistic regression in two sentences."
  ))

resp <- req_perform(req)
out <- resp_body_json(resp)

out$output[[1]]$content[[1]]$text