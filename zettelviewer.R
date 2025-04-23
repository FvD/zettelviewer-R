#!/usr/bin/env Rscript

# Function to render all markdown files in a directory to HTML and serve via local server
render_markdown_folder <- function(folder_path, port = 8000) {
  # Check if folder exists
  if (!dir.exists(folder_path)) {
    stop("Error: The specified folder does not exist")
  }
  
  # Check if required packages are installed
  required_packages <- c("rmarkdown", "servr", "httpuv")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(paste0("Please install the '", pkg, "' package first using: install.packages('", pkg, "')"))
    }
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
  
  # Keep track of filenames without path and extension
  file_basenames <- c()
  file_orignames <- c()
  
  # Render each file
  for (file in md_files) {
    file_basename <- basename(file)
    file_orignames <- c(file_orignames, file_basename)
    file_basenames <- c(file_basenames, gsub("\\.(md|Rmd|markdown)$", "", file_basename))
    
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
      
    }, error = function(e) {
      message(paste("  ✗ Failed to render:", file_basename))
      message(paste("    Error:", e$message))
    })
  }
  
  message("Rendering complete!")
  
  # Create an index.html with links to all documents
  index_html <- paste0(
    "<!DOCTYPE html>\n<html>\n<head>\n",
    "<title>Markdown Viewer</title>\n",
    "<style>",
    "body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }",
    "h1 { color: #333; }",
    "ul { list-style-type: none; padding: 0; }",
    "li { margin: 10px 0; padding: 8px; background-color: #f0f0f0; border-radius: 4px; }",
    "a { color: #0066cc; text-decoration: none; }",
    "a:hover { text-decoration: underline; }",
    "</style>\n",
    "</head>\n<body>\n",
    "<h1>Markdown Files</h1>\n",
    "<ul>\n"
  )
  
  for (i in seq_along(file_basenames)) {
    index_html <- paste0(
      index_html,
      '<li><a href="/', file_basenames[i], '">', file_orignames[i], '</a></li>\n'
    )
  }
  
  index_html <- paste0(index_html, "</ul>\n</body>\n</html>")
  html_content[["index.html"]] <- index_html
  
  # Set up the server
  message(paste0("Starting server on http://localhost:", port))
  message("Press Ctrl+C to stop the server")
  
  # Create custom httpuv application to serve content from memory
  app <- list(
    call = function(req) {
      # Parse the request path
      path <- req$PATH_INFO
      if (path == "/") {
        path <- "/index"
      }
      
      # Remove leading slash
      path <- sub("^/", "", path)
      
      # Find the matching content
      content <- NULL
      
      # First check for exact matches
      for (name in names(html_content)) {
        base_name <- gsub("\\.(md|Rmd|markdown|html)$", "", name)
        if (path == base_name) {
          content <- html_content[[name]]
          break
        }
      }
      
      # If not found, try with different extensions
      if (is.null(content)) {
        # Check if it's a request for index.html
        if (path == "index") {
          content <- html_content[["index.html"]]
        } else {
          # Try matching with original extension
          for (name in names(html_content)) {
            if (startsWith(name, paste0(path, "."))) {
              content <- html_content[[name]]
              break
            }
          }
        }
      }
      
      if (!is.null(content)) {
        return(list(
          status = 200L,
          headers = list(
            'Content-Type' = 'text/html',
            'Content-Length' = nchar(content, type = "bytes")
          ),
          body = content
        ))
      } else {
        # Not found
        not_found_html <- paste0(
          "<!DOCTYPE html>\n<html>\n<head>\n",
          "<title>404 Not Found</title>\n",
          "</head>\n<body>\n",
          "<h1>404 Not Found</h1>\n",
          "<p>The requested URL ", htmlEscape(path), " was not found.</p>\n",
          "<p><a href=\"/\">Go to index</a></p>\n",
          "</body>\n</html>"
        )
        return(list(
          status = 404L,
          headers = list(
            'Content-Type' = 'text/html',
            'Content-Length' = nchar(not_found_html, type = "bytes")
          ),
          body = not_found_html
        ))
      }
    },
    
    onWSOpen = function(ws) {
      # We don't use WebSockets
      ws$close()
    }
  )
  
  # HTML escape function
  htmlEscape <- function(x) {
    x <- gsub("&", "&amp;", x)
    x <- gsub("<", "&lt;", x)
    x <- gsub(">", "&gt;", x)
    x <- gsub("'", "&#39;", x)
    x <- gsub("\"", "&quot;", x)
    return(x)
  }
  
  # Start the server
  server <- httpuv::startServer("127.0.0.1", port, app)
  
  # Keep the server running until interrupted
  while (TRUE) {
    httpuv::service()
    Sys.sleep(0.001)
  }
  
  # Return the HTML content (invisible) - will not be reached in normal operation
  invisible(html_content)
}

# Handle command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  message("Usage: Rscript render_folder.R <folder_path> [port]")
  message("       or")
  message("       ./render_folder.R <folder_path> [port]  (if script is executable)")
  message("Options:")
  message("  port    Port number for local server (default: 8000)")
} else {
  folder_path <- args[1]
  
  # Check for port specification
  port <- 8000  # default port
  if (length(args) >= 2 && grepl("^[0-9]+$", args[2])) {
    port <- as.integer(args[2])
  }
  
  # Start rendering and server
  render_markdown_folder(folder_path, port = port)
}
