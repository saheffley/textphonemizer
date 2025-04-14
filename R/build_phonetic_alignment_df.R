#' Compare Paired IPA Strings in a CSV
#' 
#' Compares phonemic strings row-by-row from a csv file, returning alignment error information (substitutions, insertions, deletions, misalignment percentage).
#' 
#' @param csv_path path to the csv file being analyzed
#' @param auto_col column with the automatically transcribed text
#' @param manual_col column with the manually transcribed text
#' @param speaker column name for speaker id
#' @param dict_path path to the local phonetic dictionary
#' @param store logical; defaults to TRUE and adds results to 'ipa_comparison_df' in global environment
#' 
#' @return a tibble with original text, phonetic spellings, alignment error metrics, speaker ID (if provided), and video source.
#' @export
#' 
#' @importFrom tibble tibble
#' @importFrom readr read_csv write_csv
#' @importFrom purrr pmap_dfr
#' @importFrom dplyr bind_rows
#' 

build_phonetic_alignment_df <- function(csv_path,
                                        auto_col,
                                        manual_col,
                                        speaker = FALSE,
                                        dict_path = "phonetic_dictionary.csv",
                                        store = TRUE) {
  
  data <- read_csv(csv_path, show_col_types = FALSE)
  
  videofilename <- basename(csv_path)
  video_id <- tools::file_path_sans_ext(videofilename)
  
  if(!identical(speaker, FALSE)) {
    if(!(speaker %in% names(data))) stop("Speaker column not found.")
    speaker_vector <- data[[speaker]]
  } else {
    speaker_vector <- rep(NA, nrow(data))
  }
  
  results <- pmap_dfr(
    list(data[[auto_col]], data[[manual_col]], speaker_vector),
    function(auto, manual, spkr) {
      cmp <- compare_phonetic_alignment(auto, manual, dict_path)
      tibble(
        auto_text = auto,
        manual_text = manual,
        speaker = spkr,
        video_id = video_id,
        substitutions = cmp$substitutions,
        deletions = cmp$deletions,
        insertions = cmp$insertions,
        total_errors = cmp$total_errors,
        percent_misaligned = cmp$percent_misaligned
      )
    }
  )
  
  if (store) {
    if (!exists("ipa_comparison_results", envir = .GlobalEnv)) {
      assign("ipa_comparison_results", results, envir = .GlobalEnv)
    } else {
      existing <- get("ipa_comparison_results", envir = .GlobalEnv)
      assign("ipa_comparison_results", bind_rows(existing, results), envir = .GlobalEnv)
    }
  }
  return(results)
}