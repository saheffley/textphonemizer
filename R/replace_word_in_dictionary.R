#' Replace the IPA Spelling for a Word in the Dictionary
#' 
#' Updates the IPA spelling of an existing word in the local phonetic dictionary.
#' 
#' @param word the word for which the spelling is being replaced
#' @param old_spelling the current ipa spelling that needs to be replaced
#' @param new_spelling the manually updated ipa spelling
#' @param dict_path path to the local phonetic dictionary
#' 
#' @return the word and its updated spelling
#' @importFrom dplyr mutate
#' @importFrom magrittr %>%
#' @importFrom readr read_csv write_csv
#' 

replace_word_in_dictionary <- function(word, old_spelling, new_spelling, dict_path = "phonetic_dictionary.csv") {
  if (!file.exists(dict_path)) {
    stop("Dictionary file not found. Create dictionary with add_to_dictionary or generate_dictionary_from_csv.")
  }
  
  dict <- read_csv(dict_path, show_col_types = FALSE)
  
  if (!(word %in% dict$word)) {
    stop("'", word, "' is not in the dictionary. Check spelling or use add_manual_ipa() to add word.")
  }
  
  current_ipa <- dict$ipa[dict$word == word]
  if (!(old_spelling %in% current_ipa)) {
    stop("The current ipa spelling for '", word, "' does not match the provided 'old_spelling'.")
  }
  
  dict <- dict %>%
    mutate(ipa = ifelse(word == !!word & ipa == !!old_spelling, new_spelling, ipa))
  
  write_csv(dict, dict_path)
  message("Updated IPA spelling for '", word, "' from", old_spelling, " to ", new_spelling, ".")
  
  invisible(dict)
}