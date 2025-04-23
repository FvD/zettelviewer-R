#!/usr/bin/env Rscript

# Function to render all markdown files in a directory to HTML and keep in memory
render_markdown_folder <- function(folder_path, output_to_console = TRUE) {
  # Check if folder exists
  if (!dir.exists(folder_path)) {
    stop("Error: The specified folder does not exist")
  }
  
  # Check if required packages are installed
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
  
  # Create a list to store HTML content
  html_content <- list()
  
  # Create a temporary directory for intermediate files
  temp_dir <- tempdir()
  
  # Render each file
  for (file in md_files) {
    file_basename <- basename(file)
    message(paste("Rendering:", file_basename))
    
    # Generate output filename in the temporary directory
    output_file <- file.path(temp_dir, gsub("\\.(md|Rmd|markdown)$", ".html", file_basename))
    
    tryCatch({
      # Render to temporary file
      rmarkdown::render(
        input = file,
        output_file = output_file,
        output_format = "html_document",
        quiet = TRUE
      )
      
      # Read HTML content into memory
      html_content[[file_basename]] <- readChar(output_file, file.info(output_file)$size)
      
      # Remove temporary file
      if (file.exists(output_file)) {
        file.remove(output_file)
      }
      
      message(paste("  ✓ Successfully rendered:", file_basename))
      
      # Print to console if requested
      if (output_to_console) {
        cat("\n--- HTML for", file_basename, "---\n")
        cat(html_content[[file_basename]])
        cat("\n--- End of HTML ---\n\n")
      }
      
    }, error = function(e) {
      message(paste("  ✗ Failed to render:", file_basename))
      message(paste("    Error:", e$message))
    })
  }
  
  message("Rendering complete!")
  
  # Return the HTML content (invisible)
  invisible(html_content)
}

# Handle command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  message("Usage: Rscript render_folder.R <folder_path> [--quiet]")
  message("       or")
  message("       ./render_folder.R <folder_path> [--quiet]  (if script is executable)")
  message("Options:")
  message("  --quiet    Don't output HTML to console (store in memory only)")
} else {
  # Check for quiet flag
  output_to_console <- !("--quiet" %in% args)
  folder_path <- args[1]
  
  # Return the result (can be captured in R if sourced)
  result <- render_markdown_folder(folder_path, output_to_console = output_to_console)
  
  # Make result available in global environment if sourced
  if (!interactive()) {
    .GlobalEnv$html_content <- result
  }
}
