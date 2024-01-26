```markdown
# revigo_query

The `revigo_query` R function utilizes the Revigo (http://revigo.irb.hr) API to summarize a list of Gene Ontology (GO) terms into simpler terms. The function accepts either a vector of GO terms or a data frame with two columns: one for GO terms and the second for associated values (e.g., p-values). The function provides three options for the returned object: a list with three tables (one for each GO aspect - BP, CC, MF) (obj_return = "list"), a combined data frame with a "go_type" column (obj_return = "dataframe"), or a simplified data frame with essential information (obj_return = "links").

## Function Parameters

- `goList`: Vector of GO terms or a data frame with two columns (GO terms and values).
- `cutoff`: Cutoff value for the Revigo summary (default: "0.7").
- `valueType`: Type of values provided in the input data (default: "pvalue").
- `speciesTaxon`: Taxonomic ID of the species (default: "0").
- `measure`: Measure used for the Revigo summary (default: "SIMREL").
- `removeObsolete`: Remove obsolete GO terms (default: TRUE).
- `obj_return`: Desired return type ("list", "dataframe", "links").

## Installation

To use `revigo_query`, you need to have the required R packages installed:

```R
install.packages("httr")
install.packages("rvest")
install.packages("readr")
```

## Usage

```R
# Example usage
library(httr)
library(rvest)
library(readr)

# Your GO terms or data frame
goList <- c("GO:0008150", "GO:0009987", "GO:0007275")

# Call the revigo_query function
result <- revigo_query(goList, cutoff = "0.7", valueType = "pvalue", speciesTaxon = "0", measure = "SIMREL", removeObsolete = TRUE, obj_return = "list")

# Print the result
print(result)
```

## Output

The function provides flexibility in the format of the output. The result can be a list of data frames, a combined data frame, or a simplified data frame with essential information.

- For a list of data frames:
    ```R
    result_list <- revigo_query(goList, obj_return = "list")
    ```

- For a combined data frame:
    ```R
    result_df <- revigo_query(goList, obj_return = "dataframe")
    ```

- For a simplified data frame:
    ```R
    result_links <- revigo_query(goList, obj_return = "links")
    ```
