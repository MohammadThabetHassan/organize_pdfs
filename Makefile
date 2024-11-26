.PHONY: all install uninstall clean build

all: build

build:
	@echo "Compiling C program..."
	gcc -o classify_pdfs classify_pdfs.c -lpthread
	@echo "Build complete."

install: build
	@echo "Installing the tool..."
	sudo mkdir -p /usr/local/bin/pdf_organizer
	sudo cp classify_pdfs setup_directories.sh generate_report.sh organize_pdfs /usr/local/bin/pdf_organizer/
	sudo chmod +x /usr/local/bin/pdf_organizer/*
	sudo ln -sf /usr/local/bin/pdf_organizer/organize_pdfs /usr/local/bin/organize_pdfs
	@echo "Installation complete."

uninstall:
	@echo "Uninstalling the tool..."
	sudo rm -rf /usr/local/bin/pdf_organizer
	sudo rm -f /usr/local/bin/organize_pdfs
	@echo "Uninstallation complete."

clean:
	@echo "Cleaning up..."
	rm -f classify_pdfs

