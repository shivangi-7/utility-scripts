
# Author:  Shivangi
# Purpose: Plots precision, recall and f1-score from som.py ROC data
# Usage:   Rscript plot_PR_and_F1score.R -d <dirname> -n <plot-prefix> -o <path-to-save-outputs>
# Date: 2021

library("ggplot2")
library("optparse")

# --- optparse {{{ 
option_list = list(
  make_option(c("-d", "--dir"), type="character",
              help="Directory name in which .roc.csv files are stored", metavar="character"),
  make_option(c("-n", "--name"), type="character", default="out", 
              help="Prefix for output plots [default=%default]", metavar="character"),
  make_option(c("-o", "--output"), type="character", default=getwd(), 
              help="Path to save plots [default=%default]", metavar="character")
); 

option_parser = OptionParser(usage = "Usage: Rscript %prog [options]",
                             description = "Plots precision, recall and f1-score from som.py ROC data",
                             option_list = option_list);
options = parse_args(option_parser)

if (is.null(options$dir)){
  print_help(option_parser)
  stop("Required argument -d missing.", call. = FALSE)
}
# ---}}}

# --- Extracts precision and recall; calculates f1-score {{{
preprocessROCData <- function(dir_path, variant_caller, csv_file) {
  ROC_data <- read.csv(paste(dir_path, csv_file, sep = "/"))
  message("[INFO] Reading CSV file: ", csv_file)
  ROC_data_pr <- data.frame(rep(variant_caller, nrow(ROC_data)), ROC_data$precision, ROC_data$recall)
  colnames(ROC_data_pr) <- c("Caller","Precision","Recall")
  
  ROC_data_pr$F1_score <- 2* ((ROC_data_pr$Precision*ROC_data_pr$Recall)/(ROC_data_pr$Precision + ROC_data_pr$Recall))
  
  return(ROC_data_pr)
}
# }}} ---

# --- {{{
combineDataFromAllCallers <- function(...) {
  return(rbind(...))
}
# }}} ---

# --- Precision vs recall {{{
plotPRCurve <- function(name, combined_ROC_data, output_dir) {
  image_name = paste0(name, "_PR_curve.png")
  message("[INFO] Plotting PR curve: ", image_name,  " [", output_dir ,"]")
  PR_curve <- ggplot(combined_ROC_data, aes(x=Recall, y=Precision, color=Caller)) +
                     geom_point() + geom_line(linetype = "dashed")
  ggsave(image_name, path = output_dir, plot = PR_curve)
}
# }}} ---

# --- F1-score box plot {{{
plotF1Score <- function(name, combined_ROC_data, output_dir) {
  image_name = paste0(name, "_F1_score.png")
  message("[INFO] Plotting F1-score: ", image_name, " [", output_dir ,"]")
  F1_score_graph <- ggplot(combined_ROC_data, aes(x=Caller, y=F1_score, color=Caller)) +
                           geom_boxplot()
  ggsave(image_name, path = output_dir, plot = F1_score_graph)
}
# }}} ---

# --- Reads csv files from given directory and calls other functions {{{
masterFunction <- function(dir_path, plot_name, output_dir) {
  message("[INFO] Input directory : ", dir_path)
  csv_files <- list.files(path = dir_path, pattern = "*.roc.csv")
  ROC_data_list=list()
  
  for (i in 1:length(csv_files)) {
    file_name <- gsub("*.roc.csv$", "", csv_files[i])
    ROC_data_list[[file_name]] <- do.call("<-",list(file_name, preprocessROCData(dir_path, file_name, csv_files[i])))
  }
  
  combined_ROC_data <- do.call(combineDataFromAllCallers, ROC_data_list)
  plotPRCurve(plot_name, combined_ROC_data, output_dir)
  plotF1Score(plot_name, combined_ROC_data, output_dir)
}
# }}} ---

if (file.exists(options$dir)){
  masterFunction(dir_path = options$dir, plot_name = options$name, output_dir = options$output)
} else {
  stop(paste0(options$dir, " directory doesn't exist"), prog = FALSE)
}
  

