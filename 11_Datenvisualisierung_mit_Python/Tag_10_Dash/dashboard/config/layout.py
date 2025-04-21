# imports
from dash import dcc, html
import dash_bootstrap_components as dbc


# create layout
def create_layout(scat_earth, scat_jupiter, bar_race):
	return dbc.Container([
		dbc.Row([
			dbc.Col(html.H1("ExoPlanet DashBoard: Earth & Jupiter Referenced Planets",
							style={"textAlign": "center"}), width=12)
		]),
		html.Hr(),
		dbc.Row([
			dbc.Col(dcc.Graph(figure=scat_earth), width=12)
		]),
		html.Hr(),
		dbc.Row([
			dbc.Col(dcc.Graph(figure=scat_jupiter), width=12)
		]),
		html.Hr(),
		dbc.Row([
			dbc.Col(dcc.Graph(figure=bar_race), width=12)
		]),
	], fluid=True)
