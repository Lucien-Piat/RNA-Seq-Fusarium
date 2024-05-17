#Packages import
list.of.packages <- c("pheatmap", "ggplot2", "reshape2")
new.packages <- list.of.packages[!(list.of.packages %in%
                                     installed.packages()[,"Package"])]
if(length(new.packages))
  install.packages(new.packages,repos="https://pbil.univ-lyon1.fr/CRAN/")
lapply(list.of.packages,require,character.only=TRUE)


# Function to create dendrogram
create_dendrogram <- function(expression_data) {
    # Extract expression levels for two conditions
    expression_data <- expression_data[, c("gene_id", "value_1", "value_2")]
    expression_data <- expression_data[is.finite(rowSums(expression_data[, -1])), ]

    # Reshape data to have genes as rows and samples/conditions as columns
    expression_matrix <- as.matrix(expression_data[, -1])
    rownames(expression_matrix) <- expression_data$gene_id

    # Generate the heatmap
    dist_matrix <- dist(expression_matrix, method = "euclidean")
    hc <- hclust(dist_matrix, method = "complete")

    # Save the dendrogram to a PDF
    pdf("dendrogram.pdf")
    plot(hc, main = "Hierarchical Clustering Dendrogram", xlab = "Gene ID", sub = "", cex = 0.9)
    dev.off()
}

# Function to create heatmap
create_heatmap <- function(expression_data) {
    # Ensure the necessary columns are finite
    expression_data <- expression_data[is.finite(rowSums(expression_data[, c("value_1", "value_2")])), ]

    # Extract expression levels (FPKM) for significant genes
    expression_matrix <- as.matrix(expression_data[, c("value_1", "value_2")])
    rownames(expression_matrix) <- expression_data$gene_id

    # Optional: Log-transform the data to stabilize variance
    expression_matrix <- log2(expression_matrix + 1)

    pdf("heatmap.pdf")

    # Create the heatmap with clustering
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

# Function to process the file
process_file <- function(path) {
    expression_data <- preprocess(path)
    tryCatch({
        create_heatmap(expression_data)
    }, error = function(e) {
        cat("An error occurred during heatmap creation:", conditionMessage(e), "\n")
    })
    tryCatch({
        create_dendrogram(expression_data)
    }, error = function(e) {
        cat("An error occurred during dendrogram creation:", conditionMessage(e), "\n")
    })
}

# Main function
main <- function(path) {
    process_file(path)
}

# Extract the file path from command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if a file path was provided as an argument
if (length(args) == 0) {
    cat("Usage: Rscript count_dataframe.r <file_path>\n")
    quit(status = 1)
}

process_file(args[1])