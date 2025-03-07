# imports
import pandas as pd
from dash import Dash, html, dcc, Input, Output
import plotly.express as px
import plotly.graph_objects as go
import dash_bootstrap_components as dbc

# data
exo_planets = pd.read_csv("cleaned_exoplanet_data.csv")
exo_data = exo_planets.to_dict("records")
disc_years = exo_planets["discovery_year"].unique()

# app
app = Dash(__name__,
		   external_stylesheets=[dbc.themes.BOOTSTRAP])

# layout
app.layout = dbc.Container([
	dbc.Row([
		dbc.Col(
			html.Center(html.H1("Data Science NASA-Exoplanets "))
		)
	]),
	html.Hr(),
	dbc.Row([
		dbc.Col(
			dcc.Dropdown(disc_years, disc_years.max(), id="dropdown-discovery-year",
						 clearable=False),
			width=12, lg=6
		),
		dbc.Col(
			dcc.RadioItems(["Terrestrial", "Super Earth",
							"Gas Giant", "Neptune-like", "Unknown"], "count",
						   id="aggregation-radio-butttons", inline=True),
			width=12, lg=6
		)
	]),
	html.Hr(),
	dbc.Row([
		dbc.Col(
			dcc.Graph(id="discovery-year-planettypes-pie"),
			width=12, lg=6
		),
		dbc.Col(
			dcc.Graph(id="discoverd-planets-hist"),
			width=12, lg=6
		)
	])
])


# callback functions
@app.callback(
	Output("discovery-year-planettypes-pie", "figure"),
	Input("dropdown-discovery-year", "value")
)
def make_pie(year):
	disc_year_ratios = (exo_planets[exo_planets["discovery_year"] == year]
						["planet_type"]
						.value_counts(normalize=True))
	
	planet_types_pie = px.pie(
		disc_year_ratios,
		names=disc_year_ratios.index,
		values="proportion",
		# template="plotly_dark"
	)
	
	return planet_types_pie


@app.callback(
	Output("discoverd-planets-hist", "figure"),
	Input("aggregation-radio-butttons", "value")
)
def make_histo(types):
	planet_types_hist = px.histogram(
		exo_planets,
		title="Discovered Planets by Planet Types",
		x="planet_type",
		histfunc=types,
		category_orders=dict(
			planet_type=["Terrestrial", "Super Earth",
						 "Gas Giant", "Neptune-like", "Unknown"],
		),
		# template="plotly_dark"
	)
	
	return planet_types_hist


# run server (debug=True)
if __name__ == '__main__':
	app.run_server(debug=True)


# ist erstmal nur der anfang
# die radio buttons machen noch keinen sinn
# will eher ein animiertes scatterplot machen
# idee wird fortgesetzt
# next step: plan ist die data direkt von der db zu holen