#' Generate Phonetic Dictionary from CSV
#' 
#' Function to extract all unique words from one or more columns in a .csv document.
#' 
#' @param csv_path path to user's .csv file.
#' @param text_columns character vector of columns containing text to be imported
#' @param out_path path to create or update local phonetic dictionary (defaults to "phonetic_dictionary.csv")
#' 
#' @return a tibble that contains unique words and their IPA spellings.
#' @export
#' 
#' @importFrom readr read_csv write_csv
#' @importFrom stringr str_replace_all str_split
#' @importFrom glue glue
#' @importFrom dplyr distinct bind_rows

generate_dictionary_from_csv <- function(csv_path, text_columns, out_path = "phonetic_dictionary.csv"){
  df <- read_csv(csv_path, show_col_types = FALSE)
  
  missing_cols <- setdiff(text_columns, names(df))
  if (length(missing_cols) > 0) {
    stop(glue("Oh no! These columns weren't found in your dataset: {paste(missing_cols, collapse = ', ')}"))
  }
  
  all_text <- df[, text_columns] %>%
    unlist(use.names = FALSE) %>%
    tolower() %>%
    str_replace_all("[^a-z\\s']", " ") %>%
    str_split("\\s+") %>%
    unlist()
  
  word_list <- unique(all_text[nzchar(all_text)])
  
  if (file.exists(out_path)) {
    existing_dict <- read_csv(out_path, show_col_types = FALSE)
    new_words <- setdiff(word_list, existing_dict$word)
  } else {
    existing_dict <- tibble(word = character(), ipa = character())
    new_words <- word_list
  }
  
  if (length(new_words) == 0) {
    message("No new words to scrape--dictionary is already up to date!")
    return(existing_dict)
  }
  
  new_dict <- scrape_bulk_phonetic_spelling(new_words)
  
  updated_dict <- bind_rows(existing_dict, new_dict) %>%
    distinct(word, .keep_all = TRUE)
  
  write_csv(updated_dict, out_path)
  return(new_dict)
}