


"${subcode}pollfish_v1.do"

** INPUT : ${data}pollfish/* , ${data}paws/full_sample.dta

** OUTPUT : 
* ${output}pollfish_paws_diff.tex , ${output}pollfish_paws_means.tex , 
* ${output}no_info.tex , ${output}no_use.tex , ${output}bill_fixed.tex ,
* ${output}bill_split.tex , ${output}bill_usage.tex , ${output}fee_even_some.tex ,
* ${output}access_pipes.tex , ${output}access_fetch.tex , ${output}access_single_tap.tex


"${subcode}descriptives_prep.do" // primary descriptive table in the beginning

** OUTPUT :
* ${output}shr_use_from_neighbor.tex , ${output}shr_1or2hh.tex , 
* ${output}shr_individual.tex , ${output}shr_1hh.tex , ${output}shr_2hh.tex
* 


"${subcode}descriptives_prep_estimation_sample.do" // descriptive sample for the actual estimation sample


"${subcode}descriptives_paws_census.do"



"${subcode}graph_construction.do"



"${subcode}graph_construction_rate_change.do"

