# the goal of this is to look through the uc500 reports and match diagnostic fusions and output the most likely diseases 

library ( stringr)
library ( openxlsx)
annt = readRDS(  "/ehome/resource/fusion.annt/fusion.annt.07-2021.rds"  ) # master annotation, see notes 

annt =  annt$master[annt$master$is.can == 1,  ] 
annt_right = annt[ grepl ( "\\*-", annt$fusion), ]
annt_left = annt[ grepl ( "-\\*", annt$fusion), ]

uc = read.table ( '/projects/lab.mis/ucsf500_manuscript_1/Variant_MASTER.txt' , sep="\t", header=T,stringsAsFactors = FALSE,
             na.strings=".", quote = "", fill = TRUE)

uc = uc [ uc$VariantType == "FUSION", ]

# some fusions are in sentences 

uc$fusion = ifelse ( grepl( " ", uc$Variant), 
                     str_match( uc$Variant, ".* (.*-.*?) .+")[ , 2], 
                     uc$Variant
                     )



uc$left = gsub ( "-.*$" , "",  uc$Variant)
uc$right = gsub ( "^.*-" , "",  uc$Variant)



notfound = data.frame()
uc_annt = data.frame ()

for ( r in 1:nrow ( uc)){
  f = uc[r, ]
  
  whole_fusion = annt[ annt$fusion == f$Variant, 
                       c (  "fusion", "Disease.chimerSeq", "Disease.seq.name", "ccle", "Disease.STAR", "Disease.Gao", "Disease.Hu", 
                           "Disease.yoshi" , "Disease.deepest" , "TCGA" , "Disease.pub" )
                       ]
  
  
  if ( nrow ( whole_fusion) > 0 ){
    disease =  data.frame (  table ( unlist ( stringr::str_split( 
                        gsub ( " ", "", whole_fusion$Disease.pub ) ,
                        "," 
                        ) ) ) )
    disease =disease[disease$Var1 != "NA", ]
    disease =disease[disease$Var1 != "neoplasm", ]
    disease = disease[ order ( -disease$Freq), ]
    mostlikely = max ( disease$Freq)
    mostlikely = disease[disease$Freq == mostlikely, ]
    mostlikely = paste ( mostlikely$Var1, collapse = ",")
    
    tcga =   as.vector ( whole_fusion [1, 2:10] ) 
    tcga = toString ( gsub ( " ", '', tcga) )
    tcga = gsub ( " ", "", tcga)
    tcga = data.frame ( table ( unlist ( str_split(tcga, ",") )) )
    tcga = tcga [ order ( -tcga$Freq), ]
    
    whole_fusion$disease_mostlikely = mostlikely
    whole_fusion$tcga_mostlikely = as.character ( tcga$Var1[1] )
    #disease$all_disease = paste ( paste0( disease$Var1, "(", disease$Freq, ")"), collapse = "; ")
    whole_fusion$Disease.pub = paste ( paste0( disease$Var1, "[ ", disease$Freq, " ]"), collapse = "; ")
    whole_fusion$TestOrderID = f$TestOrderID
    whole_fusion = whole_fusion[ , unique ( c( "TestOrderID", names ( whole_fusion)))]
    uc_annt = rbind ( uc_annt, whole_fusion)
  }else {
    notfound = rbind ( notfound, f )
  }
  
}


# reorder 
 uc_annt = uc_annt [ , unique ( c( "TestOrderID", "disease_mostlikely", "tcga_mostlikely",  names ( whole_fusion)))  ]

wb <- createWorkbook()

addWorksheet(wb, 'diagnostic')
writeData(wb, 'diagnostic' , uc_annt  , rowNames=F  )

saveWorkbook(wb, file = paste0("/projects/lab.mis/ucsf500_manuscript_1/diagnostics.xlsx"), overwrite = TRUE)