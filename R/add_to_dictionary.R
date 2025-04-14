#' Manually Add Words to Phonetic Dictionary
#' 
#' Allows users to manually add one or more words to their local phonetic dictionary
#' 
#' @param words a character vector of one or more words to add
#' @param dict_path path to the local phonetic dictionary (defaults to "phonetic_dictionary.csv")
#' 
#' @return an updated tibble with all dictionary entries
#' @export
#' @importFrom readr read_csv write_csv
#' @importFrom stringr str_replace_all str_split
#' @importFrom glue glue
#' @importFrom dplyr distinct bind_rows
#' @importFrom tibble tibble
#' @importFrom progress progress_bar
#' @importFrom purrr map_df
#' @importFrom magrittr %>%


add_to_dictionary <- function(words, dict_path = "phonetic_dictionary.csv") {
  
  if (file.exists(dict_path)) {
    dict <- read_csv(dict_path, show_col_types = FALSE)
  } else {
    dict <- tibble(word = character(), ipa = character())
  }
  
  words <- tolower(words)
  new_words <- setdiff(words, dict$word)
  
  if (length(new_words) == 0) {
    message("No new words here! Everything is already in the dictionary.")
    return(dict)
  }
  
  message("Adding ", length(new_words), " new word(s) to your dictionary...")
  pb <- progress_bar$new(total = length(new_words), format = " [:bar] :percent")
  
  new_entries <- map_df(new_words, function(w) {
    ipa <- get_phonetic_spelling_wiktionary(w)
    pb$tick()
    tibble(word = w, ipa = ipa)
  })
  
  updated_dict <- bind_rows(dict, new_entries) %>%
    distinct(word, .keep_all = TRUE)
  
  write_csv(updated_dict, dict_path)
  return(new_entries)
}