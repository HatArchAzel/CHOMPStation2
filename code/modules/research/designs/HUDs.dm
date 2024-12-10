// HUDs

/datum/design/item/hud
	materials = list(MAT_STEEL = 50, MAT_GLASS = 50)

/datum/design/item/hud/AssembleDesignName()
	..()
	name = "HUD glasses prototype ([item_name])"

/datum/design/item/hud/AssembleDesignDesc()
	desc = "Allows for the construction of \a [item_name] HUD glasses."

/datum/design/item/hud/health
	name = "health scanner"
	id = "health_hud"
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 3)
	build_path = /obj/item/clothing/glasses/hud/health
	sort_string = "EAAAA"
	department = LATHE_ALL | LATHE_MEDICAL // CHOMPAdd

/datum/design/item/hud/security
	name = "security records"
	id = "security_hud"
	req_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 2)
	build_path = /obj/item/clothing/glasses/hud/security
	sort_string = "EAAAB"
	department = LATHE_ALL | LATHE_SECURITY // CHOMPAdd

/datum/design/item/hud/janitor
	name = "contaminant detector"
	id = "janitor_hud"
	req_tech = list(TECH_MAGNET = 2)
	build_path = /obj/item/clothing/glasses/hud/janitor
	sort_string = "EAAAC"
	department = LATHE_ALL | LATHE_SERVICE // CHOMPAdd

/datum/design/item/hud/mesons
	name = "optical meson scanner"
	id = "mesons"
	req_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)
	build_path = /obj/item/clothing/glasses/meson
	sort_string = "EAAAD"
	department = LATHE_ALL | LATHE_CARGO // CHOMPAdd

/datum/design/item/hud/material
	name = "optical material scanner"
	id = "material"
	req_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 3)
	build_path = /obj/item/clothing/glasses/material
	sort_string = "EAAAE"
	department = LATHE_ALL | LATHE_CARGO // CHOMPAdd

/datum/design/item/hud/graviton_visor
	name = "graviton visor"
	id = "graviton_goggles"
	req_tech = list(TECH_MAGNET = 5, TECH_ENGINEERING = 3, TECH_BLUESPACE = 3, TECH_PHORON = 3) //CHOMP Edit
	materials = list(MAT_PLASTEEL = 2000, MAT_GLASS = 3000, MAT_PHORON = 1500) //CHOMP Edit
	build_path = /obj/item/clothing/glasses/graviton
	sort_string = "EAAAF"
	department = LATHE_ALL | LATHE_CARGO
