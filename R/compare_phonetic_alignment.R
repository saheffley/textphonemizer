#' Compare Phonetic Alignment
#' 
#' Function to break two text strings into strings of phonemes for comparison with tally of errors, error types (substitution, deletion, insertion), and misalignment percentage.
#' 
#' This function might be retired.
#' 
#' @param text 1 a text string for the first sentence
#' @param text2 a text string for the second sentence
#' @param dict_path path to the local phonetic dictionary file
#' 
#' @return a list with:
#'  \describe{
#'    \item{total_errors}{the number of total errors}
#'    \item{substitutions}{the number of phonetic substitutions}
#'    \item{deletions}{the number of phonetic character deletions}
#'    \item{insertions}{the numnber of phonetic character insertions}
#'    \item{percent_misaligned}{the percent of the sequence that doesn't match}
#'    \item{aligned_seq1}{the aligned IPA sequence for the first text string}
#'    \itme{aligned_seq2}{the aligned IPA sequence for the second text string}
#'    }
#' @export
#' 
#' @importFrom magrittr %>%

compare_phonetic_alignment <- function(text1, text2, dict_path = "phonetic_dictionary.csv") {
  ipa1 <- text_to_ipa(text1, dict_path)$ipa %>% paste(collapse = "") %>% clean_ipa()
  ipa2 <- text_to_ipa(text2, dict_path)$ipa %>% paste(collapse = "") %>% clean_ipa()
  
  seq1 <- tokenize_phonemes(ipa1)
  seq2 <- tokenize_phonemes(ipa2)
  
  join1 <- paste(seq1, collapse = "")
  join2 <- paste(seq2, collapse = "")
  
  alignment <- Biostrings::
  
  return(list(
    total_errors = total_errors,
    substitutions = substitutions,
    deletions = deletions,
    insertions = insertions,
    percent_misaligned = percent_error,
    seq1 = join1,
    seq2 = join2
  ))
}