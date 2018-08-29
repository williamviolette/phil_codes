
g INC = 10000
	g size = (hhsize+SHO)/SHH 
		
	g SHH_G=1 if SHH<1.5 
	replace SHH_G=2 if SHH>=1.5 & SHH<2.5 
	replace SHH_G=3 if SHH>=2.5 & SHH<. 

