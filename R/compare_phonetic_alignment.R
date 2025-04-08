#' Compare Phonetic Alignment
#' 
#' Function to generate IPA versions of two text strings for comparison with tally of errors, error types (substitution, deletion, insertion), and misalignment percentage.
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
  ipa1 <- text_to_ipa(text1, dict_path)$ipa %>% paste(collapse = "")
  ipa2 <- text_to_ipa(text2, dict_path)$ipa %>% paste(collapse = "")
  
  seq1 <- strsplit(ipa1, "")[[1]]
  seq2 <- strsplit(ipa2, "")[[1]]
  
  match <- 1
  mismatch <- -1
  gap <- -1
  
  n <- length(seq1)
  m <- length(seq2)
  
  score <- matrix(0, nrow = n+1, ncol = m+1)
  
  for (i in 1:(n+1)) score[i, 1] <- (i-1)*gap
  for (j in 1:(m+1)) score[1, j] <- (j-1)*gap
  
  for (i in 2:(n+1)) {
    for (j in 2:(m+1)) {
      match_score <- ifelse(seq1[i-1] == seq2[j-1], match, mismatch)
      score[i, j] <- max(
        score[i-1, j-1] + match_score,
        score[i-1, j] + gap,
        score[i, j-1] + gap
      )
    }
  }
  
  aligned1 <- c()
  aligned2 <- c()
  i <- n+1
  j <- m+1
  
  while (i > 1 || j > 1) {
    if (i > 1 && j > 1 && score[i, j] == score[i - 1, j - 1] + 
        ifelse(seq1[i-1] == seq2[j-1], match, mismatch)) {
      aligned1 <- c(seq1[i-1], aligned1)
      aligned2 <- c(seq2[j-1], aligned2)
      i <- i-1
      j <- j-1
    } else if (i > 1 && score[i, j] == score[i-1, j] + gap) {
      aligned1 <- c(seq1[i-1], aligned1)
      aligned2 <- c("-", aligned2)
      i <- i-1
    } else {
      aligned1 <- c("-", aligned1)
      aligned2 <- c(seq2[j-1], aligned2)
      j <- j-1
    }
  }
  
  substitutions <- sum(aligned1 != aligned2 & aligned1 != "-" & aligned2 != "-")
  deletions <- sum(aligned1 != "-" & aligned2 == "-")
  insertions <- sum (aligned1 == "-" & aligned2 != "-")
  total_errors <- substitutions + deletions + insertions
  percent_error <- round(100*total_errors/length(aligned1), 1)
  
  return(list(
    total_errors = total_errors,
    substitutions = substitutions,
    deletions = deletions,
    insertions = insertions,
    percent_misaligned = percent_error,
    aligned_seq1 = paste(aligned1, collapse = ""),
    aligned_seq2 = paste(aligned2, collapse = "")
  ))
}