setwd("C:/Users/SCASTEL/Downloads")
library(stringr)
library(dplyr)
library(sqldf)

sp<- read.csv("sp.csv")
azure <- read.csv("azure.csv")

PBImatch <- function(azure,sp, report = F){
  
  # Note that the Sharepoint data file needs to be CSV and exported from the 'All items' view. 

  
  azure_cols <- c(colnames(azure)[grepl("User", colnames(azure), fixed = TRUE)],
                  colnames(azure)[grepl("Access", colnames(azure), fixed = TRUE)],
                  colnames(azure)[grepl("Workspace", colnames(azure), fixed = TRUE)]
  )
  
  sp_cols <- c(colnames(sp)[grepl("User", colnames(sp), fixed = TRUE)],
                  colnames(sp)[grepl("Access", colnames(sp), fixed = TRUE)],
                  colnames(sp)[grepl("Workspace", colnames(sp), fixed = TRUE)],
                  colnames(sp)[grepl("Environments", colnames(sp), fixed = TRUE)]
  )
  
  
  azure_cl <- azure[azure_cols]
  sp_cl <- sp[sp_cols]
  
  colnames(azure_cl) <- c("User","Access","Workspace")
  colnames(sp_cl) <- c("User","Access","Workspace","Viewer.Env")
 
  
  # Algorithms to remove French from SP list
  
  accs <- c("Viewer", "Contributor", "Member")
  wkspcs <- c("ADM", "POD", "EHPD", "PRSD", "MDCCD", "CPCSD", "LABS", "HPCD", "CD", "All ROEB")
  
    # Access column
    for (i in 1:length(accs)){
      sp_cl$Access[grepl(accs[i], sp_cl$Access, fixed = TRUE)] <- accs[i]
    }
    
    # Workspace column
    for (i in 1:length(wkspcs)){
      sp_cl$Workspace[grepl(paste0(wkspcs[i], " |"), sp_cl$Workspace, fixed = TRUE)] <- wkspcs[i]
    }
  
    
  
  # Transform Sharepoint data
  
    for(i in 1:length(sp_cl$User)){
      
      # Last name  
      sp_cl$last[i] <- strsplit(sp_cl$User[i], "[,]")[[1]][1]
      
      # First name
      temp <- sub(".*, " , "", sp_cl$User[i]) 
      sp_cl$first[i] <- substr(temp,1,nchar(temp)-8)
      
      # Name
      temp <- paste(sp_cl$first[i],sp_cl$last[i], sep="")
      sp_cl$User[i] <- str_replace_all(temp, " ", "")
      
      # Strange French character replace
      sp_cl$User[i] <- str_replace_all(sp_cl$User[i], "Ã©", "e")
      sp_cl$User[i] <- str_replace_all(sp_cl$User[i], "'", "")
      
      sp_cl$User[i] <- tolower(sp_cl$User[i])
      
    }
    
      # new dataframe
      sp_cl <- sp_cl[c("User", "Access", "Workspace", "Viewer.Env")]
      
      # Parse Viewer environments
      for(i in 1:length(sp_cl$User)){
        
        # Default for Viewers
        if(sp_cl$Access[i] == "Viewer" & sp_cl$Viewer.Env[i] == ""){
          sp_cl$Viewer.Env[i] <- "Prod"
        }
        
      
        # Parse multiple environments
        sp_cl$Viewer.Env[i] <- gsub("[^A-Za-z0-9 ]","",sp_cl$Viewer.Env[i])
        sp_cl$Viewer.Env[i] <- str_replace_all(string =  sp_cl$Viewer.Env[i],
                                                  pattern = "([[:upper:]])",
                                                  replacement = " \\1"
                                                ) %>% 
                                                  str_trim()
        }
        
      
        # coerce column to vectors
        envs <- str_split(sp_cl$Viewer.Env, " ")
        
        # paste list into sp_cl df
        sp_cl <- data.frame(sp_cl, envs = I(envs), stringsAsFactors = F)

        # use repeat function to repeat rows
        times <- sapply(sp_cl$envs,length)
        
        sp_cl <- sp_cl[rep(seq_len(nrow(sp_cl)), times),]
        
        # assign back unlisted envs
        sp_cl$envs <- unlist(envs)
        
        # subset df
        sp_cl <- sp_cl[c("User","Access","Workspace","envs")]
        colnames(sp_cl) <- c("User","Access","Workspace","Viewer.Env")

        
        
        
        
        
    
  # Transform Azure data
    
    # Remove rogue spelling of "Viewer"
    azure_cl$Access <- str_replace(azure_cl$Access, "VIewer", "Viewer")
            
        
    for(i in 1:length(azure_cl$User)){
      
      # Remove email
      azure_cl$User[i] <- str_replace_all(azure_cl$User[i], "@hc-sc.gc.ca","")
      azure_cl$User[i] <- str_replace_all(azure_cl$User[i], "@phac-aspc.gc.ca","")
      
                                    
      # Name
      azure_cl$User[i] <- str_replace_all(azure_cl$User[i], "\\.","")
      azure_cl$User[i] <- tolower(azure_cl$User[i])

      # Parse Viewer environments
      
      if(!(azure_cl$Access[i] %in% c("Contributor","Member"))){
        azure_cl$Viewer.Env[i] <- str_split(azure_cl$Access[i], " - ")[[1]][1]
        azure_cl$Access[i] <- str_split(azure_cl$Access[i], " - ")[[1]][2]
      }
      else azure_cl$Viewer.Env[i] <- ""
      
    }
  
  

    
    # View(azure_cl)
    # View(sp_cl)
    
    # PERFORM MATCHING ALGORITHM
  
    # Rows in Azure not in SP
    azureNotInsp <- sqldf('SELECT * FROM azure_cl EXCEPT SELECT * FROM sp_cl')
    
    # Rows in SP not in Azure
    spNotInazure <- sqldf('SELECT * FROM sp_cl EXCEPT SELECT * FROM azure_cl')
  
  
    return_list <- list(
      "Rows in Azure not in SP",
      azureNotInsp,
      "Rows in SP not in Azure",
      spNotInazure
    )
    
    if(!report){
    return(return_list)
    }
    
    if(report){
      sink('report.txt')
      print(return_list)
      sink()
      return("Report exported to directory (txt).")
    }
}
