import pandas as pd
from dash import Dash, html, dcc, Input, Output
import plotly.express as px

### App mit dynamischen Visualisierungen

# I. Daten für unsere App:
salaries_df = pd.read_csv('data_science_salaries.csv')
salaries_data = salaries_df.to_dict('records')
work_years = salaries_df["work_year"].unique()

# II. App-Objekt erstellen:
app = Dash(__name__)

# III. Das Layout der App festlegen:
app.layout = [
	html.Center(html.H1('Data Science Salaries Statistics')),
	html.Hr(),
	# Radio-Items bietet Auswahloptionen, die angeklickt werden können:
	dcc.RadioItems(['min', 'max', 'avg', 'count', 'sum'], 'avg',
				   id='aggr-radio-buttons'),
	# Wenn Grafik aus einer Callback-Funktion kommt, dann läuft das Einfügen
	# über eine ID und nicht über figure!
	dcc.Graph(id='exp-levels-histogram'),
	html.Hr(),
	# Füge hier ein Dropdownmenü mit den Jahren aus dem Datensatz hinzu (unique):
	dcc.Dropdown(work_years, work_years.max(),
				 id="dropdown-work-years"),
	# Verändere das nachfolgende Kuchendiagramm so, dass es je nach ausgewähltem Jahr
	# verschiedene Kuchen zeigt:
	dcc.Graph(id="pie-work-years"),
]


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
		)
	)
	return salaries_hist


@app.callback(
	Output("pie-work-years", "figure"),
	Input("dropdown-work-years", "value")
)
def make_pie(year):
	work_ratios = (salaries_df[salaries_df['work_year'] == year]
				   ['work_models']
				   .value_counts(normalize=True))
	
	work_pie = px.pie(
		work_ratios,
		names=work_ratios.index,
		values='proportion',
	)
	return work_pie


# V. Server starten (im debug-Modus):
if __name__ == '__main__':
	app.run_server(debug=True)
