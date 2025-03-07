import pandas as pd
from dash import Dash, html, dcc, dash_table
import plotly.express as px

# dcc = dash-core-components (enthält visuelle Sachen wie Graph, RadioItems etc.)

### Unsere erste App mit Visualisierungen

# I. Daten für unsere App:
salaries_df = pd.read_csv('data_science_salaries.csv')
salaries_data = salaries_df.to_dict('records')

# II. Grafische Elemente:
# 1. Unser Gehälter-Säulendiagramm:
salaries_hist = px.histogram(
    salaries_df,
    title='Salary per Experience Level',
    x='experience_level',
    y='salary_in_usd',
    histfunc='count',
    category_orders=dict(
        experience_level=['Entry-level', 'Mid-level',
                          'Senior-level', 'Executive-level'],
    )
)

# 2. Unser Arbeitsmodell-Kuchen:

work_ratios = (salaries_df[salaries_df['work_year'] == 2024]
               ['work_models']
               .value_counts(normalize=True))

work_pie = px.pie(
    work_ratios,
    names=work_ratios.index,
    values='proportion',
)

# III. App-Objekt erstellen:
app = Dash(__name__)

# IV. Das Layout der App festlegen:
app.layout = [
    html.Center(html.H1('Data Science Salaries Statistics')),
    html.Hr(),
    dcc.Graph(figure=salaries_hist),
    html.Hr(),
    dcc.Graph(figure=work_pie),
    dash_table.DataTable(
        salaries_data,
        page_size=5,
        style_cell={'textAlign': 'center'}
    )
]

# V. Server starten (im debug-Modus):
if __name__ == '__main__':
    app.run_server(debug=True)
