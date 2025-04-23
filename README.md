# Markdown Memory Server

A lightweight R tool that renders markdown files to HTML and serves them via a local web server entirely from memory, without writing permanent files to disk.

## Features

- Renders multiple markdown files (`.md`, `.Rmd`, `.markdown`) to HTML in a single command
- Keeps all rendered content in memory (RAM) - no HTML files are written to disk
- Creates an index page showing document titles and filenames
- Extracts titles from markdown content automatically
- Serves documents via a local web server for easy viewing in any browser
- Supports various markdown formats and features

## Installation

### Requirements

- R (>= 3.5.0)
- Required R packages: `rmarkdown`, `httpuv`, `servr`

### Install Dependencies

```r
install.packages(c("rmarkdown", "httpuv", "servr"))
```

### Download the Script

```bash
# Clone the repository
git clone https://github.com/yourusername/markdown-memory-server.git

# Or download the script directly
curl -O https://raw.githubusercontent.com/yourusername/markdown-memory-server/main/render_folder.R
chmod +x render_folder.R  # Make executable (optional)
```

## Usage

```bash
# Basic usage
Rscript render_folder.R /path/to/markdown/folder

# Specify a custom port (default is 8000)
Rscript render_folder.R /path/to/markdown/folder 3000

# If you made the script executable
./render_folder.R /path/to/markdown/folder
```

Once running, open your browser and navigate to:
```
http://localhost:8000
```

You'll see an index page listing all markdown documents with their titles and filenames. Click any document to view it rendered as HTML.

Press `Ctrl+C` in the terminal to stop the server.

## How It Works

1. The script scans the specified folder for markdown files
2. Each file is rendered to HTML using `rmarkdown::render()`
3. The HTML content is stored in memory
4. A local web server is started using the `httpuv` package
5. The server serves HTML directly from memory when requested
6. An index page is created with titles extracted from the markdown content

## Title Extraction

The script automatically extracts document titles in this order:

1. From YAML front matter: `title: Your Document Title`
2. From the first Markdown heading: `# Your Heading`
3. From setext-style headings (with `===` or `---` underlines)
4. If no title is found, the filename is used

## Use Cases

- Quickly preview markdown notes or documentation
- Review a collection of markdown files without cluttering your system with HTML files
- Share local documentation with colleagues on the same network
- Temporary viewing of markdown content without permanent conversion
- Teaching and presentations involving multiple markdown documents

## Limitations

- Images referenced in markdown files need to be absolute paths or URLs
- No editing capabilities (view only)
- Basic styling using default R Markdown HTML templates
- Session ends when the R script is terminated

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- The R Project and the developers of rmarkdown, httpuv, and servr packages
- Inspired by the need for a lightweight, no-installation markdown viewer
