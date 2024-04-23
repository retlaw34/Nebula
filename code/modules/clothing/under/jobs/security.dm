/*
 * Contains:
 *		Security
 *		Detective
 *		Head of Security
 */

/*
 * Security
 */

/obj/item/clothing/head/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force."
	icon = 'icons/clothing/head/warden.dmi'
	body_parts_covered = 0


/obj/item/clothing/under/dispatch
	name = "dispatcher's uniform"
	desc = "A dress shirt and khakis with a security patch sewn on."
	icon = 'icons/clothing/under/uniform_dispatch.dmi'
	armor = list(
		ARMOR_MELEE = ARMOR_MELEE_SMALL
		)
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY|SLOT_LEGS
	siemens_coefficient = 0.9
	matter = list(
		/decl/material/solid/metal/steel = MATTER_AMOUNT_TRACE
	)

/obj/item/clothing/jumpsuit/security2
	name = "security officer's uniform"
	desc = "It's made of a slightly sturdier material, to allow for robust protection."
	icon = 'icons/clothing/under/uniform_redshirt.dmi'
	armor = list(
		ARMOR_MELEE = ARMOR_MELEE_SMALL
		)
	siemens_coefficient = 0.9
	matter = list(
		/decl/material/solid/metal/steel = MATTER_AMOUNT_TRACE
	)

/*
 * Detective
 */
/obj/item/clothing/under/det
	name = "detective's suit"
	desc = "A rumpled white dress shirt paired with well-worn grey slacks."
	icon = 'icons/clothing/under/uniform_detective_1.dmi'
	siemens_coefficient = 0.9
	starting_accessories = list(
		/obj/item/clothing/neck/tie/blue_clip
	)
	material = /decl/material/solid/organic/cloth

/obj/item/clothing/under/det/grey
	desc = "A serious-looking tan dress shirt paired with freshly-pressed black slacks."
	icon = 'icons/clothing/under/uniform_detective_2.dmi'
	starting_accessories = list(
		/obj/item/clothing/neck/tie/long/red
	)

/obj/item/clothing/under/det/black
	desc = "An immaculate white dress shirt, paired with a pair of dark grey dress pants."
	icon = 'icons/clothing/under/uniform_detective_3.dmi'
	starting_accessories = list(
		/obj/item/clothing/neck/tie/long/red,
		/obj/item/clothing/suit/jacket/vest/black
	)

/obj/item/clothing/head/det
	name = "fedora"
	desc = "A brown fedora - either the cornerstone of a detective's style or a poor attempt at looking cool, depending on the person wearing it."
	icon = 'icons/clothing/head/detective.dmi'
	color = "#725443"
	armor = list(
		ARMOR_MELEE = ARMOR_MELEE_RESISTANT,
		ARMOR_LASER = ARMOR_LASER_SMALL,
		ARMOR_ENERGY = ARMOR_ENERGY_MINOR
		)
	siemens_coefficient = 0.9
	flags_inv = BLOCK_HEAD_HAIR
	markings_state_modifier = "band"
	markings_color = "#b2977c"
	material = /decl/material/solid/organic/leather
	matter = list(/decl/material/solid/metal/steel = MATTER_AMOUNT_REINFORCEMENT)

/obj/item/clothing/head/det/attack_self(mob/user)
	flags_inv ^= BLOCK_HEAD_HAIR
	to_chat(user, "<span class='notice'>[src] will now [flags_inv & BLOCK_HEAD_HAIR ? "hide" : "show"] hair.</span>")
	..()

/obj/item/clothing/head/det/grey
	color = COLOR_GRAY40
	markings_color = COLOR_SILVER
	desc = "A grey fedora - either the cornerstone of a detective's style or a poor attempt at looking cool, depending on the person wearing it."

/obj/item/clothing/head/det/wack
	color = COLOR_VIOLET
	markings_color = COLOR_YELLOW
	desc = "A colorful fedora - either the cornerstone of a detective's style or a poor attempt at looking disco, depending on the person wearing it."

/*
 * Head of Security
 */

/obj/item/clothing/head/HoS
	name = "Head of Security hat"
	desc = "The hat of the Head of Security. For showing the officers who's in charge."
	icon = 'icons/clothing/head/hos.dmi'
	body_parts_covered = 0
	siemens_coefficient = 0.8
	material = /decl/material/solid/organic/leather

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A greatcoat enhanced with a special alloy for some protection and style."
	icon = 'icons/clothing/suit/hos.dmi'
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY|SLOT_ARMS|SLOT_LEGS
	armor = list(
		ARMOR_MELEE = ARMOR_MELEE_MAJOR,
		ARMOR_BULLET = ARMOR_BALLISTIC_PISTOL,
		ARMOR_LASER = ARMOR_LASER_HANDGUNS,
		ARMOR_ENERGY = ARMOR_ENERGY_MINOR,
		ARMOR_BOMB = ARMOR_BOMB_PADDED
		)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.6
	material = /decl/material/solid/organic/leather
	matter = list(
		/decl/material/solid/metal/steel = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/gemstone/diamond = MATTER_AMOUNT_REINFORCEMENT
	)
	origin_tech = @'{"materials":3,"engineering":1, "combat":2}'

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for some protection and style."
	icon = 'icons/clothing/suit/jensen.dmi'
	flags_inv = 0
	siemens_coefficient = 0.6
	material = /decl/material/solid/organic/leather
	matter = list(
		/decl/material/solid/metal/steel = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/gemstone/diamond = MATTER_AMOUNT_REINFORCEMENT
	)
	origin_tech = @'{"materials":3,"engineering":1, "combat":2}'
