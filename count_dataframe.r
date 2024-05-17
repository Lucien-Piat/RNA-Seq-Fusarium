#Packages import
list.of.packages <- c("pheatmap", "ggplot2", "reshape2")
new.packages <- list.of.packages[!(list.of.packages %in%
                                     installed.packages()[,"Package"])]
if(length(new.packages))
  install.packages(new.packages,repos="https://pbil.univ-lyon1.fr/CRAN/")
lapply(list.of.packages,require,character.only=TRUE)



create_dendogram <- function(expression_data)
{
    # Extract expression levels for two conditions
    expression_data <- expression_data[, c("gene_id", "value_1", "value_2")]
    expression_data <- expression_data[is.finite(rowSums(expression_data[, -1])), ]

    # Reshape data to have genes as rows and samples/conditions as columns
    expression_matrix <- as.matrix(expression_data[, -1])
    rownames(expression_matrix) <- expression_data$gene_id
    expression_matrix[, 2] <- expression_matrix[, 2] + 10000

    # Generate the heatmap
    dist_matrix <- dist(expression_matrix, method = "euclidean")
    hc <- hclust(dist_matrix, method = "complete")

    # Save the dendrogram to a PDF
    pdf("dendrogram.pdf")

    # Plot the dendrogram
    plot(hc, main = "Hierarchical Clustering Dendrogram", xlab = "Gene ID", sub = "", cex = 0.9)

    # Close the PDF device
    dev.off()

}

create_scatter_plot <- function(expression_data) {
    # Filter for finite values
    expression_data <- expression_data[is.finite(rowSums(expression_data[, c("value_1", "value_2")])), ]

    pdf("scatterplot_differential_expression.pdf")

    # Create the scatter plot
    ggplot(expression_data, aes(x = value_1, y = value_2)) +
        geom_point(alpha = 0.5) +
        labs(title = "Scatter Plot of Expression Levels", x = "Condition 1 Expression", y = "Condition 2 Expression") +
        theme_minimal()

    dev.off()
}

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

preprocess <- function(path) {
    gene_exp <- read.table(path, header = TRUE, sep = "\t")
    expressed_gene <- subset(gene_exp, status != "NOTEST")
    expression_data <- na.omit(expressed_gene)
    return(expression_data)
}

process_file <- function(path) {
    table <- preprocess(path)
    create_heatmap(table)
    create_dendogram(table)
}

main <- function() {
    path = "gene_exp.diff"
    process_file(path)
}

if (interactive()) {
  main()
}

