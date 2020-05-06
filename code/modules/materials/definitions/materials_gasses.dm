// Placeholders for compile purposes.
/decl/material/gas
	name = null
	icon_colour = COLOR_GRAY80
	stack_type = null
	shard_type = SHARD_NONE
	conductive = 0
	alloy_materials = null
	alloy_product = FALSE
	sale_price = null
	hidden_from_codex = FALSE
	value = 0
	gas_burn_product = MAT_CO2
	gas_specific_heat = 20    // J/(mol*K)
	gas_molar_mass =    0.032 // kg/mol
	reflectiveness = 0
	hardness = 0
	weight = 1

/decl/material/gas/boron
	name = "boron"
	lore_text = "Boron is a chemical element with the symbol B and atomic number 5."
	is_fusion_fuel = TRUE

/decl/material/gas/lithium
	name = "lithium"
	lore_text = "A chemical element, used as antidepressant."
	chem_products = list(/decl/material/lithium = 20)
	is_fusion_fuel = TRUE

/decl/material/gas/oxygen
	name = "oxygen"
	lore_text = "An ubiquitous oxidizing agent."
	is_fusion_fuel = TRUE
	gas_specific_heat = 20	
	gas_molar_mass = 0.032	
	gas_flags = XGM_GAS_OXIDIZER | XGM_GAS_FUSION_FUEL
	gas_symbol_html = "O<sub>2</sub>"
	gas_symbol = "O2"

/decl/material/gas/helium
	name = "helium"
	lore_text = "A noble gas. It makes your voice squeaky."
	chem_products = list(/decl/material/helium = 20)
	is_fusion_fuel = TRUE
	gas_specific_heat = 80
	gas_molar_mass = 0.004
	gas_flags = XGM_GAS_FUSION_FUEL
	gas_symbol_html = "He"
	gas_symbol = "He"

/decl/material/gas/carbon_dioxide
	name = "carbon dioxide"
	lore_text = "A byproduct of respiration."
	gas_specific_heat = 30	
	gas_molar_mass = 0.044	
	gas_symbol_html = "CO<sub>2</sub>"
	gas_symbol = "CO2"

/decl/material/gas/carbon_monoxide
	name = "carbon monoxide"
	lore_text = "A highly poisonous gas."
	chem_products = list(/decl/material/carbon_monoxide = 20)
	gas_specific_heat = 30
	gas_molar_mass = 0.028
	gas_symbol_html = "CO"
	gas_symbol = "CO"

/decl/material/gas/methyl_bromide
	name = "methyl bromide"
	lore_text = "A once-popular fumigant and weedkiller."
	chem_products = list(/decl/material/toxin/methyl_bromide = 20)
	gas_specific_heat = 42.59 
	gas_molar_mass = 0.095	  
	gas_symbol_html = "CH<sub>3</sub>Br"
	gas_symbol = "CH3Br"

/decl/material/gas/sleeping_agent
	name = "sleeping agent"
	lore_text = "A mild sedative. Also known as laughing gas."
	chem_products = list(/decl/material/nitrous_oxide = 20)
	gas_specific_heat = 40	
	gas_molar_mass = 0.044	
	gas_tile_overlay = "sleeping_agent"
	gas_overlay_limit = 1
	gas_flags = XGM_GAS_OXIDIZER //N2O is a powerful oxidizer
	gas_symbol_html = "N<sub>2</sub>O"
	gas_symbol = "N2O"

/decl/material/gas/nitrogen
	name = "nitrogen"
	lore_text = "An ubiquitous noble gas."
	gas_specific_heat = 20	
	gas_molar_mass = 0.028	
	gas_symbol_html = "N<sub>2</sub>"
	gas_symbol = "N2"

/decl/material/gas/nitrodioxide
	name = "nitrogen dioxide"
	chem_products = list(/decl/material/toxin = 20)
	icon_colour = "#ca6409"
	gas_specific_heat = 37
	gas_molar_mass = 0.054
	gas_flags = XGM_GAS_OXIDIZER
	gas_symbol_html = "NO<sub>2</sub>"
	gas_symbol = "NO2"

/decl/material/gas/nitricoxide
	name = "nitric oxide"
	gas_specific_heat = 10
	gas_molar_mass = 0.030
	gas_flags = XGM_GAS_OXIDIZER
	gas_symbol_html = "NO"
	gas_symbol = "NO"

/decl/material/gas/methane
	name = "methane"
	gas_specific_heat = 30	
	gas_molar_mass = 0.016	
	gas_flags = XGM_GAS_FUEL
	gas_symbol_html = "CH<sub>4</sub>"
	gas_symbol = "CH4"

/decl/material/gas/alien
	name = "alien gas"
	hidden_from_codex = TRUE
	gas_symbol_html = "X"
	gas_symbol = "X"

/decl/material/gas/alien/New()
	var/num = rand(100,999)
	name = "compound #[num]"
	gas_specific_heat = rand(1, 400)	
	gas_molar_mass = rand(20,800)/1000	
	if(prob(40))
		gas_flags |= XGM_GAS_FUEL
	else if(prob(40)) //it's prooobably a bad idea for gas being oxidizer to itself.
		gas_flags |= XGM_GAS_OXIDIZER
	if(prob(40))
		gas_flags |= XGM_GAS_CONTAMINANT
	if(prob(40))
		gas_flags |= XGM_GAS_FUSION_FUEL
	gas_symbol_html = "X<sup>[num]</sup>"
	gas_symbol = "X-[num]"
	if(prob(50))
		icon_colour = RANDOM_RGB
		gas_overlay_limit = 0.5

/decl/material/gas/argon
	name = "argon"
	lore_text = "Just when you need it, all of your supplies argon."
	gas_specific_heat = 10
	gas_molar_mass = 0.018
	gas_symbol_html = "Ar"
	gas_symbol = "Ar"

// If narcosis is ever simulated, krypton has a narcotic potency seven times greater than regular airmix.
/decl/material/gas/krypton
	name = "krypton"
	gas_specific_heat = 5
	gas_molar_mass = 0.036
	gas_symbol_html = "Kr"
	gas_symbol = "Kr"

/decl/material/gas/neon
	name = "neon"
	gas_specific_heat = 20
	gas_molar_mass = 0.01
	gas_symbol_html = "Ne"
	gas_symbol = "Ne"

/decl/material/gas/xenon
	name = "xenon"
	chem_products = list(/decl/material/nitrous_oxide/xenon = 20)
	gas_specific_heat = 3
	gas_molar_mass = 0.054
	gas_symbol_html = "Xe"
	gas_symbol = "Xe"

/decl/material/gas/ammonia
	name = "ammonia"
	chem_products = list(/decl/material/ammonia = 20)
	gas_specific_heat = 20
	gas_molar_mass = 0.017
	gas_symbol_html = "NH<sub>3</sub>"
	gas_symbol = "NH3"

/decl/material/gas/chlorine
	name = "chlorine"
	chem_products = list(/decl/material/toxin/chlorine = 20)
	icon_colour = "#c5f72d"
	gas_overlay_limit = 0.5
	gas_specific_heat = 5
	gas_molar_mass = 0.017
	gas_flags = XGM_GAS_CONTAMINANT
	gas_symbol_html = "Cl"
	gas_symbol = "Cl"

/decl/material/gas/sulfurdioxide
	name = "sulfur dioxide"
	chem_products = list(/decl/material/sulfur = 20)
	gas_specific_heat = 30
	gas_molar_mass = 0.044
	gas_symbol_html = "SO<sub>2</sub>"
	gas_symbol = "SO2"

/decl/material/gas/water
	name = "water vapour"
	chem_products = list(/decl/material/water = 20)
	gas_tile_overlay = "generic"
	gas_overlay_limit = 0.5
	gas_specific_heat = 30
	gas_molar_mass = 0.020
	melting_point = T0C
	boiling_point = T100C
	gas_symbol_html = "H<sub>2</sub>O"
	gas_symbol = "H2O"

/decl/material/hydrogen
	name = "hydrogen"
	lore_text = "A colorless, flammable gas."
	is_fusion_fuel = TRUE
	sheet_singular_name = "ingot"
	sheet_plural_name = "ingots"
	is_fusion_fuel = 1
	wall_name = "bulkhead"
	construction_difficulty = MAT_VALUE_HARD_DIY
	gas_specific_heat = 100
	gas_molar_mass = 0.002
	gas_flags = XGM_GAS_FUEL|XGM_GAS_FUSION_FUEL
	gas_burn_product = MAT_STEAM
	gas_symbol_html = "H<sub>2</sub>"
	gas_symbol = "H2"
	chem_products = list(/decl/material/fuel/hydrazine = 20)

/decl/material/hydrogen/tritium
	name = "tritium"
	lore_text = "A radioactive isotope of hydrogen. Useful as a fusion reactor fuel material."
	mechanics_text = "Tritium is useable as a fuel in some forms of portable generator. It can also be converted into a fuel rod suitable for a R-UST fusion plant injector by clicking a stack on a fuel compressor. It fuses hotter than deuterium but is correspondingly more unstable."
	stack_type = /obj/item/stack/material/tritium
	icon_colour = "#777777"
	stack_origin_tech = "{'materials':5}"
	value = 300
	gas_symbol_html = "T"
	gas_symbol = "T"

/decl/material/hydrogen/deuterium
	name = "deuterium"
	lore_text = "One of the two stable isotopes of hydrogen; also known as heavy hydrogen. Useful as a chemically synthesised fusion reactor fuel material."
	mechanics_text = "Deuterium can be converted into a fuel rod suitable for a R-UST fusion plant injector by clicking a stack on a fuel compressor. It is the most 'basic' fusion fuel."
	stack_type = /obj/item/stack/material/deuterium
	icon_colour = "#999999"
	stack_origin_tech = "{'materials':3}"
	gas_symbol_html = "D"
	gas_symbol = "D"

/decl/material/hydrogen/metallic
	name = "metallic hydrogen"
	lore_text = "When hydrogen is exposed to extremely high pressures and temperatures, such as at the core of gas giants like Jupiter, it can take on metallic properties and - more importantly - acts as a room temperature superconductor. Achieving solid metallic hydrogen at room temperature, though, has proven to be rather tricky."
	stack_type = /obj/item/stack/material/mhydrogen
	icon_colour = "#e6c5de"
	stack_origin_tech = "{'materials':6,'powerstorage':6,'magnets':5}"
	ore_smelts_to = MAT_TRITIUM
	ore_compresses_to = MAT_METALLIC_HYDROGEN
	ore_name = "raw hydrogen"
	ore_scan_icon = "mineral_rare"
	ore_icon_overlay = "gems"
	sale_price = 5
	value = 100
	gas_symbol_html = "H*"
	gas_symbol = "H*"
