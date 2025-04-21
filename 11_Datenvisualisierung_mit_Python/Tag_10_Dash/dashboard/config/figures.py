# imports
import plotly.express as px


# create figures
def create_earth_scatter(e_df):
	e_df = e_df.dropna(subset=["mass_multiplier", "radius_multiplier"])
	scat_earth = px.scatter(
		e_df,
		x="mass_multiplier",
		y="radius_multiplier",
		size="mass_multiplier",
		color="planet_type",
		hover_data=["name", "discovery_year", "detection_method"],
		animation_frame="discovery_year",
		animation_group="name",
		title="Animated Scatter: Years of Discovery for Earth-Referenced Planets (Mass vs. Radius)"
	)
	scat_earth.update_layout(
		template="plotly_dark",
		xaxis_title="Mass (Mass Earth)",
		yaxis_title="Radius (Radius Earth)"
	)
	return scat_earth


def create_jupiter_scatter(j_df):
	j_df = j_df.dropna(subset=["mass_multiplier", "radius_multiplier"])
	scat_jupiter = px.scatter(
		j_df,
		x="mass_multiplier",
		y="radius_multiplier",
		size="mass_multiplier",
		color="planet_type",
		hover_data=["name", "discovery_year", "detection_method"],
		animation_frame="discovery_year",
		animation_group="name",
		title="Animated Scatter: Years of Discovery for Jupiter-Referenced Planets (Mass vs. Radius)"
	)
	scat_jupiter.update_layout(
		template="plotly_dark",
		xaxis_title="Mass (Mass Jupiter)",
		yaxis_title="Radius (Radius Jupiter)"
	)
	return scat_jupiter


def create_bar_race(meta_df):
	counted_discoveries = (
		meta_df.groupby(["planet_type", "discovery_year"])
		.size()
		.reset_index(name="counted_discoveries")
	)
	
	counted_discoveries = counted_discoveries.sort_values(by=["planet_type", "discovery_year"])
	counted_discoveries["cumulative_count"] = (
		counted_discoveries.groupby("planet_type")["counted_discoveries"].cumsum()
	)
	
	bar_race = px.bar(
		counted_discoveries,
		x="planet_type",
		y="cumulative_count",
		color="planet_type",
		animation_frame="discovery_year",
		title="Animated Bar Chart: Cumulative Count of discovered Planet types over years"
	)
	
	bar_race.update_layout(
		template="plotly_dark",
		xaxis_title="Planet Types",
		yaxis_title="Cumulative Counts",
	)
	
	planet_type_totals = (
		counted_discoveries
		.groupby("planet_type")["cumulative_count"]
		.max()
		.sort_values(ascending=False)
	)
	
	sorted_types = planet_type_totals.index.tolist()
	bar_race.update_xaxes(categoryorder="array", categoryarray=sorted_types)
	
	return bar_race
