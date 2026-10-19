.PHONY: all install uninstall clean build test

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

TEST_FILES = python_intro java_tutorial machine_learning_guide calculus_tutorial sql_query_basics cryptography_basics test_others

test: build
	@echo "Running organize_pdfs on sample files..."
	rm -rf test_root && mkdir -p test_root
	for f in $(TEST_FILES); do echo "sample" > test_root/$$f.pdf; done
	bash ./organize_pdfs --root test_root
	test -f test_root/Programming/Python/python_intro.pdf
	test -f test_root/Programming/Java/java_tutorial.pdf
	test -f test_root/AI/Machine_Learning/machine_learning_guide.pdf
	test -f test_root/Math/Calculus/calculus_tutorial.pdf
	test -f test_root/Database/SQL/sql_query_basics.pdf
	test -f test_root/Security/Cryptography/cryptography_basics.pdf
	test -f test_root/Others/test_others.pdf
	rm -rf test_root
	@echo "All tests passed."

clean:
	@echo "Cleaning up..."
	rm -f classify_pdfs
	rm -rf test_root

