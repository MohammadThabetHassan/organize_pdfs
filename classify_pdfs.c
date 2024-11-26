#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <dirent.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

#define MAX_FILES 10000
#define MAX_FILENAME_LENGTH 1024
#define MAX_KEYWORDS 20
#define MAX_SUBCATEGORIES 10

typedef struct {
    char *category;
    char *keywords[MAX_KEYWORDS];
    int keyword_count;
    char *subcategories[MAX_SUBCATEGORIES];
    int subcategory_count;
    char *subcat_keywords[MAX_SUBCATEGORIES][MAX_KEYWORDS];
    int subcat_keyword_counts[MAX_SUBCATEGORIES];
} Category;

char *root_dir = "root_folder";
char *pdf_files[MAX_FILES];
int total_files = 0;
pthread_mutex_t lock;

void to_lowercase(char *str) {
    for (; *str; ++str) *str = tolower(*str);
}

void normalize_string(char *str) {
    char *src = str;
    char *dst = str;
    while (*src) {
        if (*src != ' ' && *src != '_' && *src != '-') {
            *dst++ = tolower(*src);
        }
        src++;
    }
    *dst = '\0';
}

void scan_root_directory() {
    DIR *d;
    struct dirent *dir;
    char path[MAX_FILENAME_LENGTH];

    d = opendir(root_dir);
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            if (dir->d_type == DT_DIR) continue;

            if (strstr(dir->d_name, ".pdf") || strstr(dir->d_name, ".PDF")) {
                snprintf(path, MAX_FILENAME_LENGTH, "%s/%s", root_dir, dir->d_name);
                pdf_files[total_files] = strdup(path);
                total_files++;
            }
        }
        closedir(d);
    } else {
        perror("Unable to open root directory");
        exit(EXIT_FAILURE);
    }
}

void *classify_files(void *arg) {
    Category *category = (Category *)arg;
    char dest_path[MAX_FILENAME_LENGTH];

    for (int i = 0; i < total_files; i++) {
        if (pdf_files[i] == NULL) continue;

        int moved = 0;
        char *filename = strrchr(pdf_files[i], '/') + 1;
        char filename_normalized[MAX_FILENAME_LENGTH];
        strncpy(filename_normalized, filename, MAX_FILENAME_LENGTH);
        to_lowercase(filename_normalized);
        normalize_string(filename_normalized);

        for (int k = 0; k < category->keyword_count; k++) {
            char keyword_normalized[MAX_FILENAME_LENGTH];
            strncpy(keyword_normalized, category->keywords[k], MAX_FILENAME_LENGTH);
            normalize_string(keyword_normalized);

            if (strstr(filename_normalized, keyword_normalized)) {
                for (int s = 0; s < category->subcategory_count; s++) {
                    int subcat_moved = 0;
                    for (int sk = 0; sk < category->subcat_keyword_counts[s]; sk++) {
                        char subcat_keyword_normalized[MAX_FILENAME_LENGTH];
                        strncpy(subcat_keyword_normalized, category->subcat_keywords[s][sk], MAX_FILENAME_LENGTH);
                        normalize_string(subcat_keyword_normalized);
                        if (strstr(filename_normalized, subcat_keyword_normalized)) {
                            snprintf(dest_path, MAX_FILENAME_LENGTH, "%s/%s/%s/%s", root_dir, category->category, category->subcategories[s], filename);
                            pthread_mutex_lock(&lock);
                            if (rename(pdf_files[i], dest_path) == 0) {
                                free(pdf_files[i]);
                                pdf_files[i] = NULL;
                            } else {
                                fprintf(stderr, "Error moving file '%s' to '%s': %s\n", pdf_files[i], dest_path, strerror(errno));
                            }
                            pthread_mutex_unlock(&lock);
                            moved = 1;
                            subcat_moved = 1;
                            break;
                        }
                    }
                    if (subcat_moved) break;
                }
                if (!moved) {
                    snprintf(dest_path, MAX_FILENAME_LENGTH, "%s/%s/%s", root_dir, category->category, filename);
                    pthread_mutex_lock(&lock);
                    if (rename(pdf_files[i], dest_path) == 0) {
                        free(pdf_files[i]);
                        pdf_files[i] = NULL;
                    } else {
                        fprintf(stderr, "Error moving file '%s' to '%s': %s\n", pdf_files[i], dest_path, strerror(errno));
                    }
                    pthread_mutex_unlock(&lock);
                    moved = 1;
                }
                break;
            }
        }
    }
    pthread_exit(NULL);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        root_dir = argv[1];
    }

    pthread_mutex_init(&lock, NULL);

    Category categories[] = {
        {
            "Programming",
            {"programming", "code", "development", "python", "java", "c programming", "software"},
            7,
            {"Python", "Java", "C"},
            3,
            {{"python"}, {"java"}, {"c"}},
            {1, 1, 1}
        },
        {
            "AI",
            {"ai", "artificial intelligence", "machine learning", "neural network", "deep learning", "data science"},
            6,
            {"Machine_Learning", "Neural_Networks"},
            2,
            {{"machine learning", "machinelearning"}, {"neural networks", "neuralnetworks"}},
            {2, 2}
        },
        {
            "Math",
            {"math", "mathematics", "calculus", "linear", "algebra", "geometry"},
            6,
            {"Linear_Algebra", "Calculus"},
            2,
            {{"linear algebra", "linearalgebra", "linear"}, {"calculus"}},
            {3, 1}
        },
        {
            "Database",
            {"database", "sql", "nosql", "data management", "mongodb", "mysql"},
            6,
            {"SQL", "NoSQL"},
            2,
            {{"sql", "mysql"}, {"nosql", "nosql", "mongodb"}},
            {2, 2}
        },
        {
            "Security",
            {"security", "cryptography", "network security", "cybersecurity", "information security"},
            5,
            {"Cryptography", "Network_Security"},
            2,
            {{"cryptography"}, {"network security", "networksecurity"}},
            {1, 2}
        },
        {
            "Others",
            {""},
            0,
            {""},
            0,
            {{}},
            {0}
        }
    };
    int category_count = sizeof(categories) / sizeof(Category);
    pthread_t threads[category_count];

    scan_root_directory();

    for (int i = 0; i < category_count; i++) {
        pthread_create(&threads[i], NULL, classify_files, (void *)&categories[i]);
    }

    for (int i = 0; i < category_count; i++) {
        pthread_join(threads[i], NULL);
    }

    for (int i = 0; i < total_files; i++) {
        if (pdf_files[i] != NULL) {
            char *filename = strrchr(pdf_files[i], '/') + 1;
            char dest_path[MAX_FILENAME_LENGTH];
            snprintf(dest_path, MAX_FILENAME_LENGTH, "%s/Others/%s", root_dir, filename);
            pthread_mutex_lock(&lock);
            if (rename(pdf_files[i], dest_path) == 0) {
                free(pdf_files[i]);
                pdf_files[i] = NULL;
            } else {
                fprintf(stderr, "Error moving file '%s' to '%s': %s\n", pdf_files[i], dest_path, strerror(errno));
            }
            pthread_mutex_unlock(&lock);
        }
    }

    pthread_mutex_destroy(&lock);

    printf("File classification completed.\n");
    return 0;
}

