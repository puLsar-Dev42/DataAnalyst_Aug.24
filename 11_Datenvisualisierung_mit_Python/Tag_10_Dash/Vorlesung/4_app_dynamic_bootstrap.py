import pandas as pd
from dash import Dash, html, dcc, Input, Output
import plotly.express as px
import dash_bootstrap_components as dbc

### App mit dynamischen Visualisierungen in Zeilen und Spalten aufgeteilt

# dash-bootstrap-components bauen auf dem beliebten CSS-Framework bootstrap auf.
# Dort wird eine Webseite in 12 Spalten unterteilt. Wir werden das hier nutzen,
# um Dropdowns, Knöpfe und Grafiken nebeneinander erscheinen zu lassen!

# I. Daten für unsere App:
salaries_df = pd.read_csv('data_science_salaries.csv')
salaries_data = salaries_df.to_dict('records')
work_years = salaries_df['work_year'].unique()

# II. App-Objekt erstellen:
app = Dash(__name__,
		   external_stylesheets=[dbc.themes.BOOTSTRAP])

# III. Das Layout der App festlegen:
# Container enthält das gesamte Design oder getrennte größere Teile:
app.layout = dbc.Container([
	# Row stellt eine Zeile im Design dar:
	dbc.Row([
		# Col stellt eine Spalte mit wählbarer Breite im Design dar:
		dbc.Col(
			html.Center(html.H1('Data Science Salaries Statistics')),
		)
	
	]),
	html.Hr(),
	dbc.Row([
		dbc.Col(
			dcc.RadioItems(['min', 'max', 'avg', 'count', 'sum'], 'avg',
						   id='aggr-radio-buttons', inline=True),
			width=12, lg=6
		),
		dbc.Col(
			dcc.Dropdown(work_years, work_years.max(), id='dropdown-year',
						 clearable=False),
			width=12, lg=6
		)
	
	]),
	dbc.Row([
		dbc.Col(
			dcc.Graph(id='exp-levels-histogram'),
			width=12, lg=6
		),
		dbc.Col(
			dcc.Graph(id='year-work-pie'),
			width=12, lg=6
		)
	])
])


# IV. Callback functions:
# Callbackfunktionen steuern die Reaktion von Grafiken auf Layout-Elemente
# Z.B. je nach ausgewähltem Wert in den radio-items wird ein entsprechendes
# Säulendiagramm produziert, wo die jeweilige Metrik von den Säulen dargestellt
# wird. Zentrale Rolle spielen bei der Vermittlung component_ids, sowie
# die properties, auf die zugegriffen wird, bzw. in die das Ergebnis geschrieben wird.


@app.callback(
	Output('exp-levels-histogram', 'figure'),
	Input('aggr-radio-buttons', 'value')
)
def make_exp_histogram(agg_func):
	salaries_hist = px.histogram(
		salaries_df,
		title='Salary per Experience Level',
		x='experience_level',
		y='salary_in_usd',
		histfunc=agg_func,
		category_orders=dict(
			experience_level=['Entry-level', 'Mid-level',
							  'Senior-level', 'Executive-level'],
		),
		template='plotly_dark'
	)
	return salaries_hist


@app.callback(
	Output('year-work-pie', 'figure'),
	Input('dropdown-year', 'value')
)
def make_pie(year):
	work_ratios = (salaries_df[salaries_df['work_year'] == year]
				   ['work_models']
				   .value_counts(normalize=True))
	
	work_pie = px.pie(
		work_ratios,
		names=work_ratios.index,
		values='proportion',
		template='plotly_dark'
	)
	return work_pie


# V. Server starten (im debug-Modus):
if __name__ == '__main__':
	app.run_server(debug=True)
