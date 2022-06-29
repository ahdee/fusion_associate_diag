# Predict disease based on canonical fusion
### an algorithm to associate fusions to a particular disease and not just flag as canonical. 
1. look for any sample with fusions.
2. merged with my annotations but pre-select for canonical fusions.
3. figure out what the most likely disease by ranking how many times disease was associated with fusion. 
    1. this is in columns, disease_mostlikely and tcga_mostlikely
    2. disease_mostlikely == most mentioned diseases in publication - also more reliable
    3. tcga_mostlikely based on what was found in TCGA and TARGET
4. tabulation is then flatten into a single column.  Example
    1. prostatecancer[ 31 ]; posteriorcerebralartery[ 19 ]; thromboticinfarction[ 19 ]; epithelioma[ 11 ]; erythroblastosis[ 9 ];
5. if most likely disease does not make sense then it provides a list of columns that can view across different sources.
6. I clean up the columns so that it will only show disease related stuff
