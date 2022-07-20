/datum/species
	//This is so that if a race is using the chimera revive they can't use it more than once.
	//Shouldn't really be seen in play too often, but it's case an admin event happens and they give a non chimera the chimera revive. Only one person can use the chimera revive at a time per race.
	//var/reviving = 0 //commented out 'cause moved to mob
	holder_type = /obj/item/weapon/holder/micro //This allows you to pick up crew
	min_age = 18
	descriptors = list()

	var/organic_food_coeff = 1
	var/synthetic_food_coeff = 0
	//var/vore_numbing = 0
	var/metabolism = 0.0015
	var/lightweight = FALSE //Oof! Nonhelpful bump stumbles.
	var/trashcan = FALSE //It's always sunny in the wrestling ring.
	var/eat_minerals = FALSE //HEAVY METAL DIET
	var/base_species = null // Unused outside of a few species
	var/selects_bodytype = FALSE // Allows the species to choose from body types like custom species can, affecting suit fitting and etcetera as you would expect.

	var/is_weaver = FALSE
	var/silk_production = FALSE
	var/silk_reserve = 100
	var/silk_max_reserve = 500
	var/silk_color = "#FFFFFF"

	var/list/traits = list()
	//Vars that need to be copied when producing a copy of species.
	var/list/copy_vars = list("base_species", "icobase", "deform", "tail", "tail_animation", "icobase_tail", "color_mult", "primitive_form", "appearance_flags", "flesh_color", "base_color", "blood_mask", "damage_mask", "damage_overlays", "move_trail", "has_floating_eyes")
	var/trait_points = 0

	var/micro_size_mod = 0		// How different is our size for interactions that involve us being small?
	var/macro_size_mod = 0		// How different is our size for interactions that involve us being big?

/datum/species/proc/give_numbing_bite() //Holy SHIT this is hacky, but it works. Updating a mob's attacks mid game is insane.
	unarmed_attacks = list()
	unarmed_types += /datum/unarmed_attack/bite/sharp/numbing
	for(var/u_type in unarmed_types)
		unarmed_attacks += new u_type()

/datum/species/create_organs(var/mob/living/carbon/human/H)
	if(H.nif)
		var/type = H.nif.type
		var/durability = H.nif.durability
		var/list/nifsofts = H.nif.nifsofts
		var/list/nif_savedata = H.nif.save_data.Copy()
		..()

		var/obj/item/device/nif/nif = new type(H,durability,nif_savedata)
		nif.nifsofts = nifsofts
	else
		..()
/datum/species/proc/produceCopy(var/list/traits, var/mob/living/carbon/human/H, var/custom_base)
	ASSERT(src)
	ASSERT(istype(H))
	var/datum/species/new_copy = new src.type()
	new_copy.race_key = race_key

	if(selects_bodytype && custom_base) //If race selects a bodytype, retrieve the custom_base species and copy needed variables.
		var/datum/species/S = GLOB.all_species[custom_base]
		S.copy_variables(new_copy, copy_vars)

	for(var/organ in has_limbs) //Copy important organ data generated by species.
		var/list/organ_data = has_limbs[organ]
		new_copy.has_limbs[organ] = organ_data.Copy()

	new_copy.traits = traits
	//If you had traits, apply them
	if(new_copy.traits)
		for(var/trait in new_copy.traits)
			var/datum/trait/T = all_traits[trait]
			T.apply(new_copy, H)

	//Set up a mob
	H.species = new_copy
	H.icon_state = new_copy.get_bodytype()

	if(new_copy.holder_type)
		H.holder_type = new_copy.holder_type

	if(H.dna)
		H.dna.ready_dna(H)

	return new_copy

/datum/species/proc/copy_variables(var/datum/species/S, var/list/whitelist)
	//List of variables to ignore, trying to copy type will runtime.
	var/list/blacklist = list("type", "loc", "client", "ckey")
	//Makes thorough copy of species datum.
	for(var/i in vars)
		if(!(i in S.vars)) //Don't copy incompatible vars.
			continue
		if(S.vars[i] != vars[i] && !islist(vars[i])) //If vars are same, no point in copying.
			if(i in blacklist)
				continue
			if(whitelist)//If whitelist is provided, only vars in the list will be copied.
				if(i in whitelist)
					S.vars[i] = vars[i]
				continue
			S.vars[i] = vars[i]

/datum/species/get_bodytype()
	return base_species
