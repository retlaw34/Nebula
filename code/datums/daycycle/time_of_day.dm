/datum/time_of_day
	abstract_type = /datum/time_of_day
	/// In-character descriptor (ie. 'sunrise')
	var/name
	/// Message shown to outdoors players when the daycycle moves to this period.
	var/announcement
	/// 0-1 value to indicate where in the total day/night progression this falls.
	var/period
	/// Ambient light colour during this time of day.
	var/color
	/// Ambient light power during this time of day.
	var/power
	/// Ambient temperature modifier during this time of day.
	var/temperature

/datum/time_of_day/sunrise
	name = "sunrise"
	announcement = "The sun peeks over the horizon, bathing the world in rosy light."
	period = 0.1
	color = COLOR_ORANGE
	power = 0.2

/datum/time_of_day/daytime
	name = "daytime"
	announcement = "The sun rises over the horizon, beginning another day."
	period = 0.4

/datum/time_of_day/sunset
	name = "sunset"
	announcement = "The sun begins to dip below the horizon, and the daylight fades."
	period = 0.6
	color = COLOR_RED
	power = 0.5

/datum/time_of_day/night
	name = "night"
	announcement = "Night falls, blanketing the world in darkness."
	period = 1
	color = COLOR_NAVY_BLUE
	power = 0.3

// Dummy period used by solars.
/datum/time_of_day/permanent_daytime
	name = null
	announcement = null
	color = null
	power = null
	period = 1
