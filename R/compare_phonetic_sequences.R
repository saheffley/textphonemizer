#' Compare Phonetic Sequences
#' 
#' Function to compute the Levenshtein edit distance between two IPA (international phonetic alphabet) strings. 
#' Will produce collapsed phonetic sequences for two text sequences and the edit distance (i.e., differences between the sequences without distinguishing between error types).
#' 
#' @param text1 a text string for the first sentence
#' @param text2 a text string for the second sentence
#' @param dict_path path to the local phonetic dictionary file
#' 
#' @return a list containing:
#'  \describe{
#'    \item{total_edit_distance}{the Levenshtein edit distance between the two text sequences.}
#'    \item{seq1}{the phonetic sequence for the first sentence.}
#'    \item{seq2}{the phonetic sequence for the second sentence.}
#' }
#' @export
#' 
#' @importFrom stringdist stringdist

compare_phonetic_sequences <- function(text1, text2, dict_path = "phonetic_dictionary.csv") {
  phonemes1 <- text_to_ipa(text1, dict_path)
  phonemes2 <- text_to_ipa(text2, dict_path)
  
  ipa1 <- paste(phonemes1$ipa, collapse = "")
  ipa2 <- paste(phonemes2$ipa, collapse = "")
  
  distance <- stringdist::stringdist(ipa1, ipa2, method = "lv")
  
  list(
    total_edit_distance = distance,
    seq1 = ipa1,
    seq2 = ipa2
  )
}