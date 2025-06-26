#' Convert Text to IPA
#' 
#' Converts text strings to phonetic spelling using the international phonetic alphabet (IPA)
#' 
#' @param sentence a regular text string that you want to convert to phonetic spellings
#' @param dict_path path to the local phonetic dictionary file
#' 
#' @return a tibble with words from the text string and their phonetic spellings; will return "NA" for words not found in dictionary.
#' @export
#' 
#' @importFrom readr read_csv
#' @importFrom stringr str_replace_all str_split str_remove_all
#' @importFrom purrr map_chr
#' @importFrom dplyr filter pull arrange
#' @importFrom tibble tibble

#sentences to phonetic spelling

clean_ipa <- function(ipa) {
  ipa %>%
    str_remove_all("^/|/$") %>%
    str_remove_all("[ˈˌ\\.]") %>%
    str_remove_all("[()]")
}

text_to_ipa <- function(sentence, dict_path = "phonetic_dictionary.csv") {
  dict <- read_csv(dict_path, show_col_types = FALSE)
  
  clean_sentence <- tolower(sentence)
  clean_sentence <- str_replace_all(clean_sentence, "[^a-z\\s']", "") #drop punctuation
  words <- unlist(str_split(clean_sentence, "\\s+"))
  
  ipa_seq <- map_chr(words, function(w) {
    match <- dict %>% filter(word == w) %>% pull(ipa)
    if (length(match) == 0) return (NA) else return(clean_ipa(match[1]))
  })
  
  if (any(is.na(ipa_seq))) {
    missing_words <- words[is.na(ipa_seq)]
    warning(
      "Oh no! We couldn't find the following word(s) in the local dictionary: ",
      paste(unique(missing_words), collapse = ", "),
      ". Use `add_to_dictionary()` to add them."
    )
  }
  
  return(tibble(word = words, ipa = ipa_seq))
}