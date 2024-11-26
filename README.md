
# organize_pdfs

## Overview
`organize_pdfs` is a tool designed to organize PDF files into categorized directories based on their content. This tool helps in maintaining a structured and easily navigable repository of PDF documents.

## Features
- **Automatic Classification**: Categorizes PDF files into predefined folders based on their content.
- **Reporting**: Generates a detailed report of the classification process.
- **Customizable**: Users can define their own categories and rules for classification.

## Installation
To build and install the tool, follow these steps:

```sh
make build
sudo make install
```

## Usage
Run the `organize_pdfs` tool with the following command:

```sh
organize_pdfs --root <path_to_pdf_directory> --report
```

### Arguments
- `--root`: The root directory containing PDF files to be organized.
- `--report`: Generates a report of the classification process.

## Example
```sh
organize_pdfs --root /home/user/pdf_files --report
```

## Development
### Prerequisites
- GCC (for C code compilation)
- Make (for build automation)
- Shell (for scripting)

### Building the Project
```sh
make
```

### Running Tests
```sh
make test
```

## Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License
This project is licensed under the MIT License.

## Contact
For any questions or suggestions, please open an issue.

```
