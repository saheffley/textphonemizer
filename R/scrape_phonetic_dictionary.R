#' Scrape Dictionary
#' 
#' Scrapes Wiktionary for the International Phonetic Alphabet (IPA) spelling of words. Defaults to US pronunciation.
#' 
#' @param word_list a character vector of words to scrape
#' @param out_path path to local phonetic dictionary csv file; will default to "phonetic_dictionary.csv"
#' 
#' @return a .csv with words and their phonetic spellings
#' @export
#' 
#' @importFrom magrittr %>%
#' @importFrom readr read_csv write_csv
#' @importFrom tibble tibble
#' @importFrom progress progress_bar
#' @importFrom purrr map_df
#' @importFrom dplyr bind_rows distinct
#' @importFrom rvest html_node html_text read_html html_nodes
#' @importFrom httr GET user_agent status_code

#scrape & build word cache
scrape_bulk_phonetic_spelling <- function(word_list, out_path = "phonetic_dictionary.csv") {
  if (file.exists(out_path)) {
    existing <- read_csv(out_path, show_col_types = FALSE)
  } else {
    existing <- tibble(word = character(), ipa = character())
  }
  
  to_lookup <- setdiff(tolower(word_list), existing$word)
  if (length(to_lookup) == 0) {
    message("No new words to scrape today!")
    return(existing)
  }
  message("please be patient, I'm scraping ", length(to_lookup), " new words and I'm just a function")
  pb <- progress_bar$new(total = length(to_lookup), format = " [:bar] :percent")
  
  new_data <- map_df(to_lookup, function(word) {
    ipa <- tryCatch(
      get_phonetic_spelling_wiktionary(word),
      warning = function(w) {
        message("Warning for '", word, "': ", conditionMessage(e))
        return(NA)
      }
    )
    pb$tick()
    tibble(word = tolower(word), ipa = as.character(ipa))
  })
  
  missing <- new_data %>% filter(is.na(ipa))
  if (nrow(missing) >0) {
    cat("\nWords that need manual IPA transcriptions:\n")
    print(missing$word)
  }
  
  updated <- bind_rows (existing, new_data) %>% distinct(word, .keep_all = TRUE)
  write_csv(updated, out_path)
  return(updated)
}


#internal function to scrape single word from wiktionary:

get_phonetic_spelling_wiktionary <- function(word) {
  
  url  <- paste0("https://en.wiktionary.org/wiki/", word)
  page <- tryCatch(read_html(url), error = function(e) return (NA))
  if (is.na(page)) return(NA)
  
  ipa_nodes <- html_nodes(page, ".IPA")
  ipa_texts <- purrr::map_chr(ipa_nodes, html_text)
  
  parent_texts <- purrr::map_chr(ipa_nodes, function(node) {
    parent <- html_node(node, xpath = "./ancestor::li[1] | ./ancestor::p[1]")
    html_text(parent)
  })
  
  us_ipa <- ipa_texts[stringr::str_detect(parent_texts, stringr::regex("US", ignore_case = TRUE))]
  
  if (length(us_ipa) > 0) {
    return(us_ipa[1])
  } else {
    return(NA)
  }
  
}