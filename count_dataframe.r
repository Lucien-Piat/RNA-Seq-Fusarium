# Packages import
list.of.packages <- c("pheatmap", "ggplot2", "reshape2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos="https://pbil.univ-lyon1.fr/CRAN/")
lapply(list.of.packages, require, character.only=TRUE)

# Function to create dendrogram
create_dendrogram <- function(expression_data) {
    expression_data <- expression_data[, c("gene_id", "value_1", "value_2")]
    expression_data <- expression_data[is.finite(rowSums(expression_data[, -1])), ]
    
    if (nrow(expression_data) < 2) {
        stop("Not enough data to create dendrogram.")
    }

    expression_matrix <- as.matrix(expression_data[, -1])
    rownames(expression_matrix) <- expression_data$gene_id

    dist_matrix <- dist(expression_matrix, method = "euclidean")
    hc <- hclust(dist_matrix, method = "complete")

    pdf("dendrogram.pdf")
    plot(hc, main = "Hierarchical Clustering Dendrogram", xlab = "Gene ID", sub = "", cex = 0.9)
    dev.off()
}

# Function to create heatmap
create_heatmap <- function(expression_data) {
    expression_data <- expression_data[is.finite(rowSums(expression_data[, c("value_1", "value_2")])), ]

    if (nrow(expression_data) < 2) {
        stop("Not enough data to create heatmap.")
    }

    expression_matrix <- as.matrix(expression_data[, c("value_1", "value_2")])
    rownames(expression_matrix) <- expression_data$gene_id

    expression_matrix <- log2(expression_matrix + 1)

    pdf("heatmap.pdf")
    pheatmap(expression_matrix, clustering_distance_rows = "euclidean", clustering_distance_cols = "euclidean",
             clustering_method = "complete", show_rownames = TRUE, show_colnames = TRUE)
    dev.off()
}

# Function to preprocess data
preprocess <- function(path) {
    gene_exp <- read.table(path, header = TRUE, sep = "\t")
    expressed_gene <- subset(gene_exp, status != "NOTEST")
    expression_data <- na.omit(expressed_gene)
    return(expression_data)
}

# Function to process a single file
process_file <- function(path) {
    cat("Processing file:", path, "\n")
    expression_data <- preprocess(path)
    
    if (nrow(expression_data) == 0) {
        cat("No valid expression data found in", path, "\n")
        return()
    }
    
    cat("Number of valid genes in", path, ":", nrow(expression_data), "\n")
    
    tryCatch({
        create_heatmap(expression_data)
    }, error = function(e) {
        cat("An error occurred during heatmap creation for", path, ":", conditionMessage(e), "\n")
    })
    tryCatch({
        create_dendrogram(expression_data)
    }, error = function(e) {
        cat("An error occurred during dendrogram creation for", path, ":", conditionMessage(e), "\n")
    })
}

# Function to process multiple files
process_files <- function(paths) {
    for (path in paths) {
        process_file(path)
    }
}

# Main function
main <- function(paths) {
    process_files(paths)
}

# Extract the file path from command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if a file path was provided as an argument
if (length(args) == 0) {
    cat("Usage: Rscript count_dataframe.r <file_path>...\n")
    quit(status = 1)
}

# List files in the directory to help debug
dir_path <- dirname(args[1])
cat("Listing files in directory:", dir_path, "\n")
print(list.files(dir_path))

# Expand wildcards and process files
expanded_paths <- Sys.glob(args)
cat("Expanded paths:", expanded_paths, "\n")
main(expanded_paths)

