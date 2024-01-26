#revigo_query####
#this function uses the API of revigo (http://revigo.irb.hr/FAQ) to summarize a list of GO terms into simpler terms. 
#it accepts as input both a vector of GOterms, or a data frame with two columns, the first being the GOterms and the second being the value (like pvalue for instance)
#it has 3 options for the returned object: 
#list = will return a list with 3 tables, one for BP, one for CC, and one for MF; 
#dataframe = will return a single dataframe combining the 3 dataframes of the list, with an additional column named "go_type" indicating from which list each GO term comes from.
#links = is a simplified version of the dataframe where only the GO ID, the GO name, the Representative ID and the representative name are provided.
revigo_query <- function(goList, cutoff = "0.7", valueType = "pvalue", speciesTaxon = "0", measure = "SIMREL", removeObsolete = TRUE, obj_return = c("list", "dataframe", "links")){
  require(httr)
  require(rvest)
  require(readr)
  
  obj_return <- match.arg(obj_return) 
  
  #first convert the provided table to a temporary tsv file
  write_tsv(as.data.frame(goList), file = "temp.tsv")
  #now load the tsv file as is
  input <- readChar("temp.tsv",file.info("temp.tsv")$size)
  #file.remove("temp.tsv")
  #now use the RESTful API to query the results (for more information check: http://revigo.irb.hr/FAQ)
  print("Making request to RESTful API of revigo (this might take a while) ...")
  results <- httr::POST(
    url = "http://revigo.irb.hr/Revigo",
    body = list(
      cutoff = cutoff,
      valueType = valueType,
      speciesTaxon = speciesTaxon,
      measure = measure,
      goList = input,
      removeObsolete = tolower(as.character(removeObsolete))
    ),
    # application/x-www-form-urlencoded
    encode = "form"
  )
  print("done!")
  #convert the html output to a dataframe
  dat <- httr::content(results, encoding = "UTF-8")
  dat <- rvest::html_table(dat)
  names(dat) <- c("biological_process", "cellular_compartment", "molecular_function")
  
  if(obj_return == "list"){
    return(dat)
  }
  
  #at this point dat is a list with 3 data frames, one for biological processes, one for cellular component, and one for molecular function.
  #here it will merge these 3 dataframes into a single one. 
  dat_df <- c()
  for(i in c(1:length(dat))){
    df <- dat[[i]]
    df$go_type <- names(dat)[i]
    dat_df <- rbind(dat_df, df)
  }
  #formating the column names
  colnames(dat_df) <- colnames(dat_df) %>%
    gsub(" ", "_", .) %>%
    tolower()
  
  #finally it will, for each GO term, add a column indicating its representative term
  #OBS: parental terms have a "null" string in the 'Representative' column.
  dat_df$repr_id <- dat_df$term_id
  dat_df$repr_name <- dat_df$name
  
  for(i in c(1:nrow(dat_df))){
    if(tolower(dat_df$representative[i]) == "null"){
      next
    }else{
      dat_df$repr_id[i] <- dat_df$repr_id[i-1]
      dat_df$repr_name[i] <- dat_df$repr_name[i-1]
    }
  }
  
  if(obj_return == "dataframe"){
    return(dat_df)
  }
  
  if(obj_return == "links"){
    dat_df <- dat_df[,c("term_id", "name", "repr_id", "repr_name")]
    return(dat_df)
  }
}