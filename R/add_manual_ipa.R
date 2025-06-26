#' Manually Add a Word to the Phonetic Dictionary
#' 
#' Adds a custom word and IPA transcription to your local phonetic dictionary.
#' 
#' @param word a single word
#' @param ipa the IPA string representing the phonetic spelling of that word
#' @param dict_path path to the local phonetic dictionary csv (default = "phonetic_dictionary.csv") 
#' 
#' @return an updated tibble with the new entry
#' @export
#' 
#' @importFrom tibble tibble
#' @importFrom readr read_csv write_csv
#' @importFrom dplyr arrange
#' 

add_manual_ipa <- function(word, ipa, dict_path = "phonetic_dictionary.csv", overwrite = TRUE) {
  word <- tolower(word)
  
  if (file.exists(dict_path)) {
    dict <- read_csv(dict_path, show_col_types = FALSE)
  } else {
    dict <- tibble(word = character(), ipa = character())
  }
  
  if (word %in% dict$word) {
    if (overwrite) {
      dict <- dplyr::filter(dict, word != !!word) #removing old entry
      message("The word '", word, "' already existed and is being overwritten.")
    } else {
      message("The word '", word, "' already exists in the dictionary and no changes have been made.")
      return(head(dict))
    }
  }
  
  new_entry <- tibble(word = word, ipa = ipa)
  
  updated_dict <- bind_rows(dict, new_entry) %>%
    distinct(word, .keep_all = TRUE) %>%
    arrange(word)
  
  message("Added '", word, "' to the dictionary.")
  
  write_csv(updated_dict, dict_path)
  
  return(new_entry)
}