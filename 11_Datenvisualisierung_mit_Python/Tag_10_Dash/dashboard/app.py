# imports
from dash import Dash
import dash_bootstrap_components as dbc

# imports self creations
from config.data import load_data
from config.figures import create_earth_scatter, create_jupiter_scatter, create_bar_race
from config.layout import create_layout

# app
app = Dash(__name__,
		   external_stylesheets=[dbc.themes.BOOTSTRAP])

# load dataframes
e_df, j_df, meta_df = load_data()

# render plots
scat_earth = create_earth_scatter(e_df)
scat_jupiter = create_jupiter_scatter(j_df)
bar_race = create_bar_race(meta_df)

# load layout
app.layout = create_layout(scat_earth, scat_jupiter, bar_race)

# run server (debug=True)
if __name__ == '__main__':
	app.run_server(debug=True)
