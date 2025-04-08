#' Scrape Dictionary
#' 
#' Scrapes Wiktionary for the International Phonetic Alphabet (IPA) spelling of words
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
#' @importFrom rvest html_node html_text
#' @importFrom xml2 read_html

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
    ipa <- get_phonetic_spelling_wiktionary(word)
    pb$tick()
    tibble(word = word, ipa = ipa)
  })
  
  updated <- bind_rows (existing, new_data) %>% distinct(word, .keep_all = TRUE)
  write_csv(updated, out_path)
  return(updated)
}


#internal function to scrape single word from wiktionary:

get_phonetic_spelling_wiktionary <- function(word) {
  url <- paste0("https://en.wiktionary.org/wiki/", word)
  
  tryCatch({
    page <- read_html(url)
    ipa <- page %>%
      html_node(xpath = "//span[@class='IPA']") %>%
      html_text()
    
    ipa_clean <- ipa[1]
    return(ipa_clean)
  }, error = function(e) {
    return(NA)
  })
}