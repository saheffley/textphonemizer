
<!-- README.md is generated from README.Rmd. Please edit that file -->

# textphonemizer

<!-- badges: start -->

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg) ![R
version](https://img.shields.io/badge/R-4.0%2B-success)
<!-- badges: end -->

Use textphonemizer to convert natural language text into phonetic
spellings using the International Phonetic Alphabet (IPA).  
This package includes tools for:

- Scraping phonetic spellings from Wiktionary
- Converting sentences & text strings to IPA
- Comparing phoneme-level differences (e.g., substitutions, insertions,
  deletions)
- Building and expanding a custom phonetic dictionary

## Installation

You can install the development version of textphonemizer like so:

``` r
# install from GitHub
# remotes::install_github("saheffley/textphonemizer")
```

## Example

``` r
# create dictionary

textphonemizer::generate_dictionary_from_csv("sample_data.csv", text_columns = c("auto_transcript", "manual_transcript"))
#> please be patient, I'm scraping 11 new words and I'm just a function
#> # A tibble: 11 × 2
#>    word   ipa        
#>    <chr>  <chr>      
#>  1 he     /ˈhiː/     
#>  2 went   /wɛnt/     
#>  3 over   /ˈəʊ.və(ɹ)/
#>  4 the    /ˈðiː/     
#>  5 bridge /bɹɪd͡ʒ/    
#>  6 cat    /kæt/      
#>  7 sat    /sæt/      
#>  8 on     /ɒn/       
#>  9 mat    /mæt/      
#> 10 ridge  /ɹɪd͡ʒ/     
#> 11 in     /ɪn/
```

``` r
# add words

textphonemizer::add_to_dictionary("word")
#> Adding 1 new word(s) to your dictionary...
#> # A tibble: 1 × 2
#>   word  ipa   
#>   <chr> <chr> 
#> 1 word  /wɜːd/
```

``` r
textphonemizer::add_to_dictionary(c("you", "can", "also", "add", "multiple", "words", "at", "once"))
#> Adding 8 new word(s) to your dictionary...
#> # A tibble: 8 × 2
#>   word     ipa       
#>   <chr>    <chr>     
#> 1 you      /juː/     
#> 2 can      /ˈkæn/    
#> 3 also     /ˈɔːl.səʊ/
#> 4 add      /æd/      
#> 5 multiple /ˈmʌltɪpl̩/
#> 6 words    /wɜːdz/   
#> 7 at       /æt/      
#> 8 once     /wʌn(t)s/
```

``` r
# manually add custom words (for names, invented words, etc)

textphonemizer::add_manual_ipa("Heffley", "ˈhɛf.li")
#> Added 'heffley' to the dictionary.
#> # A tibble: 1 × 2
#>   word    ipa    
#>   <chr>   <chr>  
#> 1 heffley ˈhɛf.li
```

``` r
# compare two IPA strings

textphonemizer::compare_phonetic_sequences("he went over the bridge", "he went over the ridge")
#> $total_edit_distance
#> [1] 1
#> 
#> $seq1
#> [1] "hiːwɛntəʊvə(ɹ)ðiːbɹɪd͡ʒ"
#> 
#> $seq2
#> [1] "hiːwɛntəʊvə(ɹ)ðiːɹɪd͡ʒ"
```

``` r
# view alignment details

textphonemizer::compare_phonetic_alignment("the cat sat on the mat", "the cat sat in the mat")
#> $total_errors
#> [1] 1
#> 
#> $substitutions
#> [1] 1
#> 
#> $deletions
#> [1] 0
#> 
#> $insertions
#> [1] 0
#> 
#> $percent_misaligned
#> [1] 5.9
#> 
#> $aligned_seq1
#> [1] "ðiːkætsætɒnðiːmæt"
#> 
#> $aligned_seq2
#> [1] "ðiːkætsætɪnðiːmæt"
```

``` r
# Some sample errors

textphonemizer::compare_phonetic_alignment("he went on the bridge", "she went on the bridge")
#> Warning in text_to_ipa(text2, dict_path): Oh no! We couldn't find the following
#> word(s) in the dictionary: she. Use `add_manual_ipa()` to manually add them.
#> $total_errors
#> [1] 3
#> 
#> $substitutions
#> [1] 2
#> 
#> $deletions
#> [1] 1
#> 
#> $insertions
#> [1] 0
#> 
#> $percent_misaligned
#> [1] 16.7
#> 
#> $aligned_seq1
#> [1] "hiːwɛntɒnðiːbɹɪd͡ʒ"
#> 
#> $aligned_seq2
#> [1] "-NAwɛntɒnðiːbɹɪd͡ʒ"
```

``` r
textphonemizer::add_to_dictionary("supercalifragilisticality")
#> Adding 1 new word(s) to your dictionary...
#> # A tibble: 1 × 2
#>   word                      ipa  
#>   <chr>                     <lgl>
#> 1 supercalifragilisticality NA
```
