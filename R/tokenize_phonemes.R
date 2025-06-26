#' Tokenize IPA Strings into Phonemes
#' 
#' Internal function that breaks strings into phonemes using regex rules. (English)
#' 
#' @param ipa_string  a cleaned IPA string
#' 
#' @return character vector of phonemes
#' @export
#' 
#' @importFrom stringr str_replace_all str_extract_all


tokenize_phonemes <- function(ipa_string) {
  
  ipa_string <- str_replace_all(ipa_string, "\\s+", "")
  
  complex_phonemes <- c(
    # affricates
    "t͡ʃ", "d͡ʒ",
    # fricatives & sibilants
    "ʃ", "ʒ", "θ", "ð", "ŋ", "ɲ", "ʔ",
    # velars and others
    "x", "ɡ",
    # diphthongs & glides
    "aɪ", "aʊ", "oʊ", "eɪ", "ɔɪ", "ɪə", "ɛə", "ʊə", "ju", "əʊ", "eə")
  
  # escape for regex
  complex_esc <- str_replace_all(complex_phonemes, "(\\W)", "\\\\\\1")
  
  # combining diacritics/unicode marks
  diac <- "[\\u0300-\\u036F\\u02D0]"
  
  # regex pattern for matching
  pattern <- paste0(
    "(",
    paste(complex_esc, collapse = "|"),
    ")[", diac, "]*",
    "|",
    "(.{1})[", diac, "]*"
  )
  
  # apply tokenizer
  tokens <- str_extract_all(ipa_string, pattern)[[1]]
  return(tokens)
}