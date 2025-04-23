#!/usr/bin/env Rscript

# Function to render all markdown files in a directory to HTML
render_markdown_folder <- function(folder_path) {
  # Check if folder exists
  if (!dir.exists(folder_path)) {
    stop("Error: The specified folder does not exist")
  }
  
  # Check if rmarkdown is installed
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Please install the 'rmarkdown' package first using: install.packages('rmarkdown')")
  }
  
  # List all markdown files in the folder
  md_files <- list.files(
    path = folder_path, 
    pattern = "\\.(md|Rmd|markdown)$", 
    full.names = TRUE
  )
  
  # Check if any markdown files were found
  if (length(md_files) == 0) {
    message("No markdown files found in the specified folder")
    return(invisible(NULL))
  }
  
  message(paste("Found", length(md_files), "markdown files to render"))
  
  # Render each file
  for (file in md_files) {
    message(paste("Rendering:", basename(file)))
    tryCatch({
      rmarkdown::render(
        input = file,
        output_format = "html_document",
        quiet = TRUE
      )
      message(paste("  ✓ Successfully rendered:", basename(file)))
    }, error = function(e) {
      message(paste("  ✗ Failed to render:", basename(file)))
      message(paste("    Error:", e$message))
    })
  }
  
  message("Rendering complete!")
}

# Handle command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  message("Usage: Rscript render_folder.R <folder_path>")
  message("       or")
  message("       ./render_folder.R <folder_path>  (if script is executable)")
} else {
  render_markdown_folder(args[1])
}
