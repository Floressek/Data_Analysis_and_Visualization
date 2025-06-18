import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import dash
from dash import dcc, html, Input, Output, callback
import dash_bootstrap_components as dbc
from datetime import datetime
import warnings

warnings.filterwarnings('ignore')

################################
##  PARAMETRY KONFIGURACYJNE  ##
################################

# Ładowanie danych
print("Ładowanie danych COVID-19...")
confirmed_df = pd.read_csv(
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv')
deaths_df = pd.read_csv(
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv')
recoveries_df = pd.read_csv(
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv')

# Data cutoff - 04/08/2021
CUTOFF_DATE = '4/8/21'
print(f"Ograniczanie danych do {CUTOFF_DATE}")

# Dodanie mapowania kontynentów dla treemap
CONTINENT_MAPPING = {
    'US': 'Ameryka Północna', 'Canada': 'Ameryka Północna', 'Mexico': 'Ameryka Północna',
    'Brazil': 'Ameryka Południowa', 'Argentina': 'Ameryka Południowa', 'Colombia': 'Ameryka Południowa',
    'Peru': 'Ameryka Południowa', 'Chile': 'Ameryka Południowa', 'Ecuador': 'Ameryka Południowa', \
    'Venezuela': 'Ameryka Południowa', 'Uruguay': 'Ameryka Południowa', 'Paraguay': 'Ameryka Południowa',
    'China': 'Azja', 'India': 'Azja', 'Japan': 'Azja', 'Korea, South': 'Azja', 'Indonesia': 'Azja',
    'Philippines': 'Azja', 'Vietnam': 'Azja', 'Thailand': 'Azja', 'Malaysia': 'Azja', 'Singapore': 'Azja',
    'Pakistan': 'Azja', 'Bangladesh': 'Azja', 'Iran': 'Azja', 'Iraq': 'Azja', 'Saudi Arabia': 'Azja',
    'Israel': 'Azja', 'Turkey': 'Europa/Azja', 'Russia': 'Europa/Azja',
    'United Kingdom': 'Europa', 'France': 'Europa', 'Germany': 'Europa', 'Italy': 'Europa', 'Spain': 'Europa',
    'Poland': 'Europa', 'Romania': 'Europa', 'Netherlands': 'Europa', 'Belgium': 'Europa', 'Czechia': 'Europa',
    'Greece': 'Europa', 'Portugal': 'Europa', 'Sweden': 'Europa', 'Hungary': 'Europa', 'Austria': 'Europa',
    'Belarus': 'Europa', 'Serbia': 'Europa', 'Switzerland': 'Europa', 'Bulgaria': 'Europa', 'Denmark': 'Europa',
    'Finland': 'Europa', 'Slovakia': 'Europa', 'Norway': 'Europa', 'Ireland': 'Europa', 'Croatia': 'Europa',
    'Moldova': 'Europa', 'Bosnia and Herzegovina': 'Europa', 'Albania': 'Europa', 'Lithuania': 'Europa',
    'North Macedonia': 'Europa', 'Slovenia': 'Europa', 'Latvia': 'Europa', 'Estonia': 'Europa',
    'South Africa': 'Afryka', 'Morocco': 'Afryka', 'Tunisia': 'Afryka', 'Libya': 'Afryka', 'Egypt': 'Afryka',
    'Ethiopia': 'Afryka', 'Nigeria': 'Afryka', 'Ghana': 'Afryka', 'Kenya': 'Afryka', 'Uganda': 'Afryka',
    'Algeria': 'Afryka', 'Sudan': 'Afryka', 'Angola': 'Afryka', 'Mozambique': 'Afryka', 'Madagascar': 'Afryka',
    'Cameroon': 'Afryka', 'Ivory Coast': 'Afryka', 'Niger': 'Afryka', 'Burkina Faso': 'Afryka',
    'Australia': 'Oceania', 'New Zealand': 'Oceania', 'Fiji': 'Oceania', 'Papua New Guinea': 'Oceania',
    'Dominican Republic': 'Ameryka Północna', 'Cuba': 'Ameryka Północna', 'Haiti': 'Ameryka Północna',
    'Jamaica': 'Ameryka Północna', 'Trinidad and Tobago': 'Ameryka Północna', 'Costa Rica': 'Ameryka Północna',
    'Panama': 'Ameryka Północna', 'Honduras': 'Ameryka Północna', 'Guatemala': 'Ameryka Północna',
    'El Salvador': 'Ameryka Północna', 'Nicaragua': 'Ameryka Północna', 'Bolivia': 'Ameryka Południowa',
    'Burma': 'Azja', 'Sri Lanka': 'Azja', 'Nepal': 'Azja', 'Afghanistan': 'Azja', 'Uzbekistan': 'Azja',
    'Kazakhstan': 'Azja', 'Kyrgyzstan': 'Azja', 'Tajikistan': 'Azja', 'Mongolia': 'Azja',
    'Lebanon': 'Azja', 'Jordan': 'Azja', 'Azerbaijan': 'Azja', 'Armenia': 'Azja', 'Georgia': 'Azja',
    'Kuwait': 'Azja', 'Bahrain': 'Azja', 'Qatar': 'Azja', 'United Arab Emirates': 'Azja', 'Oman': 'Azja',
    'Yemen': 'Azja', 'Syria': 'Azja', 'Ukraine': 'Europa', 'Iceland': 'Europa'
}


####################################
## FUNKCJE PRZETWARZAJĄCE DANE ##
####################################

# Funkcja do ograniczenia danych do cutoff date
def limit_to_cutoff(df, cutoff_date):
    date_columns = [col for col in df.columns if col not in ['Province/State', 'Country/Region', 'Lat', 'Long']]
    valid_dates = []

    for col in date_columns:
        try:
            date = pd.to_datetime(col)
            if date <= pd.to_datetime(cutoff_date):
                valid_dates.append(col)
        except:
            pass

    keep_columns = ['Province/State', 'Country/Region', 'Lat', 'Long'] + valid_dates
    return df[keep_columns]


# Ograniczenie danych
confirmed_df = limit_to_cutoff(confirmed_df, CUTOFF_DATE)
deaths_df = limit_to_cutoff(deaths_df, CUTOFF_DATE)
recoveries_df = limit_to_cutoff(recoveries_df, CUTOFF_DATE)


# Przygotowanie danych dla mapy i wykresów
def prepare_map_data(date_col):
    """Przygotowuje dane dla konkretnej daty z prawidłowymi współrzędnymi"""

    # STEP 1: Agregacja danych liczbowych po krajach
    conf_agg = confirmed_df.groupby('Country/Region')[date_col].sum()
    death_agg = deaths_df.groupby('Country/Region')[date_col].sum()
    recover_agg = recoveries_df.groupby('Country/Region')[date_col].sum()

    # STEP 2: Dla współrzędnych - weź pierwszy wpis dla każdego kraju (zazwyczaj główne miasto/stolica)
    # Alternatywnie możemy wziąć wpis z największą liczbą przypadków
    def get_main_coordinates(df):
        """Pobiera główne współrzędne dla każdego kraju"""
        main_coords = {}
        for country in df['Country/Region'].unique():
            country_data = df[df['Country/Region'] == country]

            # Opcja 1: Weź pierwszy wpis (często stolica lub główne miasto)
            # main_entry = country_data.iloc[0]

            # Opcja 2: Weź wpis z największą liczbą przypadków dla tego kraju
            if date_col in country_data.columns:
                max_cases_idx = country_data[date_col].idxmax()
                main_entry = country_data.loc[max_cases_idx]
            else:
                main_entry = country_data.iloc[0]

            main_coords[country] = {
                'Lat': main_entry['Lat'],
                'Long': main_entry['Long']
            }

        return main_coords

    # Pobierz główne współrzędne z datasetu confirmed (zazwyczaj najkompletniejszy)
    main_coords = get_main_coordinates(confirmed_df)

    # STEP 3: Tworzenie dataframe z prawidłowymi współrzędnymi
    countries = list(conf_agg.index)
    map_data = pd.DataFrame({
        'Country': countries,
        'Confirmed': [conf_agg[country] for country in countries],
        'Deaths': [death_agg[country] if country in death_agg.index else 0 for country in countries],
        'Recovered': [recover_agg[country] if country in recover_agg.index else 0 for country in countries],
        'Lat': [main_coords[country]['Lat'] if country in main_coords else 0 for country in countries],
        'Long': [main_coords[country]['Long'] if country in main_coords else 0 for country in countries]
    })

    # STEP 4: Obliczenia dodatkowych wskaźników
    map_data['Active'] = map_data['Confirmed'] - map_data['Deaths'] - map_data['Recovered']
    map_data['Active'] = map_data['Active'].clip(lower=0)

    params = (map_data['Confirmed'] > 0,
              (map_data['Deaths'] / map_data['Confirmed'] * 100),
              0)
    map_data['Mortality_Rate'] = np.where(
        params[0],
        params[1],
        params[2]
    )

    map_data['Recovery_Rate'] = np.where(
        params[0],
        params[1],
        params[2]
    )

    # STEP 5: Filtruj kraje z przypadkami i prawidłowymi współrzędnymi
    map_data = map_data[
        (map_data['Confirmed'] > 0) &
        (map_data['Lat'] != 0) &
        (map_data['Long'] != 0)
        ]

    return map_data


# Przygotowanie danych czasowych
def prepare_time_series():
    """Przygotowuje dane szeregów czasowych dla wszystkich krajów"""
    date_columns = [col for col in confirmed_df.columns if
                    col not in ['Province/State', 'Country/Region', 'Lat', 'Long']]

    # Agregacja po krajach
    confirmed_by_country = confirmed_df.groupby('Country/Region')[date_columns].sum()
    deaths_by_country = deaths_df.groupby('Country/Region')[date_columns].sum()
    recovered_by_country = recoveries_df.groupby('Country/Region')[date_columns].sum()

    # Dane globalne
    global_confirmed = confirmed_by_country.sum()
    global_deaths = deaths_by_country.sum()
    global_recovered = recovered_by_country.sum()

    # Tworzenie DataFrame dla globalnych danych
    global_df = pd.DataFrame({
        'Date': pd.to_datetime(date_columns),
        'Confirmed': global_confirmed.values,
        'Deaths': global_deaths.values,
        'Recovered': global_recovered.values
    })
    global_df['Active'] = global_df['Confirmed'] - global_df['Deaths'] - global_df['Recovered']

    return global_df, confirmed_by_country, deaths_by_country, recovered_by_country, date_columns


##################################
## PRZYGOTOWANIE APLIKACJI DASH ##
##################################

# Przygotowanie danych
print("Przygotowywanie danych...")
global_time_series, confirmed_by_country, deaths_by_country, recovered_by_country, date_columns = prepare_time_series()
latest_date = date_columns[-1]
map_data_latest = prepare_map_data(latest_date)

# Inicjalizacja aplikacji Dash
app = dash.Dash(__name__, external_stylesheets=[dbc.themes.DARKLY])

# Style CSS
app.layout = dbc.Container([
    dbc.Row([
        dbc.Col([
            html.H1("🦠 COVID-19 Interactive Dashboard - Szymon Florek", className="text-center mb-4"),
            html.P(f"Dane do: {latest_date}", className="text-center text-muted")
        ])
    ]),

    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    dbc.Row([
                        dbc.Col([
                            html.H4("Wybierz datę:", className="card-title"),
                        ], width=3),
                        dbc.Col([
                            dbc.ButtonGroup([
                                dbc.Button("▶️ Play", id="play-button", color="success", size="sm"),
                                dbc.Button("⏸️ Pause", id="pause-button", color="warning", size="sm"),
                                dbc.Button("⏹️ Reset", id="reset-button", color="danger", size="sm"),
                            ])
                        ], width=3),
                        dbc.Col([
                            html.Label("Typ danych na mapie:", className="me-2"),
                            dbc.RadioItems(
                                id='map-data-type',
                                options=[
                                    {'label': '🦠 Zachorowania', 'value': 'Confirmed'},
                                    {'label': '💀 Zgony', 'value': 'Deaths'},
                                    {'label': '☠️ Śmiertelność %', 'value': 'Mortality_Rate'}
                                ],
                                value='Confirmed',
                                inline=True
                            )
                        ], width=6)
                    ]),
                    html.Hr(),
                    dcc.Slider(
                        id='date-slider',
                        min=0,
                        max=len(date_columns) - 1,
                        value=len(date_columns) - 1,
                        marks={i: {'label': date_columns[i] if i % 30 == 0 else '',
                                   'style': {'transform': 'rotate(-45deg)'}}
                               for i in range(0, len(date_columns), 30)},
                        tooltip={'placement': 'bottom', 'always_visible': True}
                    ),
                    dcc.Interval(
                        id='interval-component',
                        interval=200,  # milisekundy
                        disabled=True
                    )
                ])
            ], className="mb-4")
        ])
    ]),

    dbc.Row([
        dbc.Col([
            dcc.Graph(id='world-map', style={'height': '600px'})
        ], width=8),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("📊 Statystyki globalne", className="card-title"),
                    html.Div(id='global-stats', className="mt-3")
                ])
            ], className="mb-3"),

            dbc.Card([
                dbc.CardBody([
                    html.H4("🏆 TOP 10 krajów", className="card-title"),
                    html.Div(id='top-countries', className="mt-3")
                ])
            ])
        ], width=4)
    ], className="mb-4"),

    dbc.Row([
        dbc.Col([
            dcc.Graph(id='time-series-plot', style={'height': '400px'})
        ], width=6),
        dbc.Col([
            dcc.Graph(id='country-comparison', style={'height': '400px'})
        ], width=6)
    ], className="mb-4"),

    dbc.Row([
        dbc.Col([
            dcc.Graph(id='treemap-continents', style={'height': '500px'})
        ], width=12)
    ], className="mb-4"),

    dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H4("Wybierz kraje do porównania:", className="card-title"),
                    dcc.Dropdown(
                        id='country-dropdown',
                        options=[{'label': country, 'value': country}
                                 for country in sorted(confirmed_by_country.index)],
                        value=['Poland', 'Germany', 'Italy', 'Spain', 'France'],
                        multi=True,
                        style={'color': 'black'}
                    )
                ])
            ])
        ])
    ], className="mb-4"),

    dbc.Row([
        dbc.Col([
            dcc.Graph(id='selected-countries-plot', style={'height': '500px'})
        ])
    ])
], fluid=True, style={'backgroundColor': '#1a1a1a', 'padding': '20px'})


##################################
## CALLBACKI I LOGIKA APLIKACJI ##
##################################

# Callbacks
@app.callback(
    [Output('world-map', 'figure'),
     Output('global-stats', 'children'),
     Output('top-countries', 'children')],
    [Input('date-slider', 'value'),
     Input('map-data-type', 'value')]
)
def update_map_and_stats(selected_date_idx, data_type):
    selected_date = date_columns[selected_date_idx]
    map_data = prepare_map_data(selected_date)

    # Konfiguracja w zależności od typu danych
    color_scales = {
        'Confirmed': 'Blues',
        'Deaths': 'Reds',
        'Recovered': 'Greens',
        'Active': 'Oranges',
        'Mortality_Rate': 'Reds'
    }

    titles = {
        'Confirmed': '🦠 Potwierdzone zachorowania',
        'Deaths': '💀 Zgony',
        'Recovered': '💚 Wyzdrowienia',
        'Active': '🔥 Aktywne przypadki',
        'Mortality_Rate': '☠️ Wskaźnik śmiertelności (%)'
    }

    # Ustaw rozmiar w zależności od typu
    if data_type == 'Mortality_Rate':
        size_col = 'Confirmed'  # Używamy liczby przypadków dla rozmiaru
        size_max = 50
    else:
        size_col = data_type
        size_max = 50

    # Mapa świata
    fig_map = px.scatter_geo(map_data,
                             lat='Lat',
                             lon='Long',
                             size=size_col,
                             color=data_type,
                             hover_name='Country',
                             hover_data={
                                 'Confirmed': ':,',
                                 'Deaths': ':,',
                                 'Recovered': ':,',
                                 'Active': ':,',
                                 'Mortality_Rate': ':.2f',
                                 'Recovery_Rate': ':.2f',
                                 'Lat': False,
                                 'Long': False
                             },
                             color_continuous_scale=color_scales[data_type],
                             size_max=size_max,
                             title=f'{titles[data_type]} - {selected_date}',
                             template='plotly_dark')

    fig_map.update_geos(
        showcoastlines=True,
        coastlinecolor="RebeccaPurple",
        showland=True,
        landcolor='rgb(40, 40, 40)',
        showcountries=True,
        countrycolor="rgb(80, 80, 80)"
    )

    fig_map.update_layout(
        height=600,
        margin={"r": 0, "t": 50, "l": 0, "b": 0}
    )

    # Statystyki globalne
    global_confirmed = map_data['Confirmed'].sum()
    global_deaths = map_data['Deaths'].sum()
    global_recovered = map_data['Recovered'].sum()
    global_active = map_data['Active'].sum()

    # Sprawdzenie czy wartości są sensowne
    if global_recovered > global_confirmed:
        global_recovered = global_confirmed - global_deaths
    if global_active < 0:
        global_active = 0

    stats_cards = dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H6("Potwierdzone", className="text-warning"),
                    html.H3(f"{global_confirmed:,}")
                ])
            ], color="warning", outline=True)
        ], width=6),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H6("Zgony", className="text-danger"),
                    html.H3(f"{global_deaths:,}")
                ])
            ], color="danger", outline=True)
        ], width=6),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H6("Wyzdrowienia", className="text-success"),
                    html.H3(f"{global_recovered:,}")
                ])
            ], color="success", outline=True)
        ], width=6, className="mt-2"),
        dbc.Col([
            dbc.Card([
                dbc.CardBody([
                    html.H6("Aktywne", className="text-info"),
                    html.H3(f"{global_active:,}")
                ])
            ], color="info", outline=True)
        ], width=6, className="mt-2")
    ])

    # TOP 10 krajów - sortuj według wybranego typu danych
    sort_column = 'Confirmed' if data_type == 'Mortality_Rate' else data_type
    top_10 = map_data.nlargest(10, sort_column)[['Country', 'Confirmed', 'Deaths', 'Recovered', 'Mortality_Rate']]

    for col in ['Confirmed', 'Deaths', 'Recovered']:
        top_10[col] = top_10[col].apply(lambda x: f"{x:,}")

    top_10['Mortality_Rate'] = top_10['Mortality_Rate'].apply(lambda x: f"{x:.2f}%")

    top_countries_table = dbc.Table.from_dataframe(
        top_10,
        striped=True,
        bordered=True,
        hover=True,
        color="dark",  # Use color="dark" instead of dark=True
        size='sm'
    )

    return fig_map, stats_cards, top_countries_table


# Callbacks dla animacji
@app.callback(
    Output('interval-component', 'disabled'),
    [Input('play-button', 'n_clicks'),
     Input('pause-button', 'n_clicks')],
    prevent_initial_call=True
)
def toggle_animation(play_clicks, pause_clicks):
    ctx = dash.callback_context
    if not ctx.triggered:
        return True

    button_id = ctx.triggered[0]['prop_id'].split('.')[0]

    if button_id == 'play-button':
        return False  # Włącz animację
    elif button_id == 'pause-button':
        return True  # Zatrzymaj animację

    return True


@app.callback(
    Output('date-slider', 'value'),
    [Input('interval-component', 'n_intervals'),
     Input('reset-button', 'n_clicks')],
    [dash.State('date-slider', 'value'),
     dash.State('date-slider', 'max')],
    prevent_initial_call=True
)
def update_slider(n_intervals, reset_clicks, current_value, max_value):
    ctx = dash.callback_context
    if not ctx.triggered:
        return current_value

    trigger_id = ctx.triggered[0]['prop_id'].split('.')[0]

    if trigger_id == 'reset-button':
        return 0  # Reset do początku
    elif trigger_id == 'interval-component':
        # Przesuń slider do przodu
        new_value = current_value + 1
        if new_value > max_value:
            return 0  # Zacznij od początku
        return new_value

    return current_value


@app.callback(
    Output('time-series-plot', 'figure'),
    [Input('date-slider', 'value')]
)
def update_time_series(selected_date_idx):
    # Create a figure with make_subplots or go.Figure instead of px.line
    fig = go.Figure()

    # Add each trace manually
    fig.add_trace(go.Scatter(
        x=global_time_series['Date'],
        y=global_time_series['Confirmed'],
        mode='lines',
        name='Confirmed'
    ))

    fig.add_trace(go.Scatter(
        x=global_time_series['Date'],
        y=global_time_series['Deaths'],
        mode='lines',
        name='Deaths'
    ))

    fig.add_trace(go.Scatter(
        x=global_time_series['Date'],
        y=global_time_series['Recovered'],
        mode='lines',
        name='Recovered'
    ))

    fig.add_trace(go.Scatter(
        x=global_time_series['Date'],
        y=global_time_series['Active'],
        mode='lines',
        name='Active'
    ))

    # Add a vertical line for the selected date
    selected_date = pd.to_datetime(date_columns[selected_date_idx])
    fig.add_vline(x=selected_date, line_dash="dash", line_color="yellow", opacity=0.5)

    # Update layout
    fig.update_layout(
        title='Globalna progresja COVID-19',
        template='plotly_dark',
        hovermode='x unified',
        legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1)
    )

    return fig


@app.callback(
    Output('country-comparison', 'figure'),
    [Input('date-slider', 'value')]
)
def update_country_comparison(selected_date_idx):
    selected_date = date_columns[selected_date_idx]
    map_data = prepare_map_data(selected_date)
    top_20 = map_data.nlargest(20, 'Confirmed')

    fig = px.scatter(top_20,
                     x='Recovery_Rate',
                     y='Mortality_Rate',
                     size='Confirmed',
                     color='Active',
                     hover_name='Country',
                     title='Wskaźnik śmiertelności vs Wskaźnik wyzdrowień',
                     template='plotly_dark',
                     color_continuous_scale='Viridis')

    fig.update_layout(
        xaxis_title="Wskaźnik wyzdrowień (%)",
        yaxis_title="Wskaźnik śmiertelności (%)"
    )

    return fig


@app.callback(
    Output('selected-countries-plot', 'figure'),
    [Input('country-dropdown', 'value')]
)
def update_selected_countries(selected_countries):
    if not selected_countries:
        return px.line(title="Wybierz kraje do porównania", template='plotly_dark')

    # Przygotowanie danych dla wybranych krajów
    data_list = []
    for country in selected_countries:
        if country in confirmed_by_country.index:
            country_data = pd.DataFrame({
                'Date': pd.to_datetime(date_columns),
                'Confirmed': confirmed_by_country.loc[country].values,
                'Deaths': deaths_by_country.loc[country].values,
                'Recovered': recovered_by_country.loc[country].values,
                'Country': country
            })
            country_data['Active'] = country_data['Confirmed'] - country_data['Deaths'] - country_data['Recovered']
            # Aktywne nie mogą być ujemne
            country_data['Active'] = country_data['Active'].clip(lower=0)
            data_list.append(country_data)

    if not data_list:
        return px.line(title="Brak danych dla wybranych krajów", template='plotly_dark')

    combined_data = pd.concat(data_list)

    # Tworzenie subplotów
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Potwierdzone przypadki', 'Zgony', 'Wyzdrowienia', 'Aktywne przypadki'),
        shared_xaxes=True
    )

    for country in selected_countries:
        country_data = combined_data[combined_data['Country'] == country]

        fig.add_trace(
            go.Scatter(x=country_data['Date'], y=country_data['Confirmed'],
                       name=country, showlegend=True),
            row=1, col=1
        )

        fig.add_trace(
            go.Scatter(x=country_data['Date'], y=country_data['Deaths'],
                       name=country, showlegend=False),
            row=1, col=2
        )

        fig.add_trace(
            go.Scatter(x=country_data['Date'], y=country_data['Recovered'],
                       name=country, showlegend=False),
            row=2, col=1
        )

        fig.add_trace(
            go.Scatter(x=country_data['Date'], y=country_data['Active'],
                       name=country, showlegend=False),
            row=2, col=2
        )

    fig.update_layout(
        title_text="Porównanie wybranych krajów",
        height=500,
        template='plotly_dark',
        hovermode='x unified'
    )

    return fig


# Nowy callback dla treemap
@app.callback(
    Output('treemap-continents', 'figure'),
    [Input('date-slider', 'value'),
     Input('map-data-type', 'value')]
)
def update_treemap(selected_date_idx, data_type):
    selected_date = date_columns[selected_date_idx]
    map_data = prepare_map_data(selected_date)

    # Dodaj kontynenty
    map_data['Continent'] = map_data['Country'].map(CONTINENT_MAPPING).fillna('Inne')
    map_data['World'] = 'Świat'

    # Filtruj tylko kraje z danymi
    treemap_data = map_data[map_data[data_type] > 0].copy()

    # Tytuły dla różnych typów danych
    titles = {
        'Confirmed': 'Potwierdzone przypadki',
        'Deaths': 'Zgony',
        'Recovered': 'Wyzdrowienia',
        'Active': 'Aktywne przypadki',
        'Mortality_Rate': 'Wskaźnik śmiertelności'
    }

    # Dla wskaźnika śmiertelności używamy innej logiki
    if data_type == 'Mortality_Rate':
        # Używamy liczby zgonów jako wartości dla wielkości
        fig = px.treemap(treemap_data,
                         path=['World', 'Continent', 'Country'],
                         values='Deaths',
                         color='Mortality_Rate',
                         hover_data={'Confirmed': ':,', 'Deaths': ':,', 'Recovered': ':,', 'Mortality_Rate': ':.2f%'},
                         color_continuous_scale='Reds',
                         title=f'Hierarchiczny rozkład - {titles[data_type]} - {selected_date}')
    else:
        fig = px.treemap(treemap_data,
                         path=['World', 'Continent', 'Country'],
                         values=data_type,
                         color=data_type,
                         hover_data={'Confirmed': ':,', 'Deaths': ':,', 'Recovered': ':,', 'Active': ':,'},
                         color_continuous_scale='Viridis',
                         title=f'Hierarchiczny rozkład - {titles[data_type]} - {selected_date}')

    fig.update_traces(
        textposition="middle center",
        textfont_size=12,
        hovertemplate='<b>%{label}</b><br>' +
                      '%{customdata[0]:,} potwierdzonych<br>' +
                      '%{customdata[1]:,} zgonów<br>' +
                      '%{customdata[2]:,} wyzdrowień<br>' +
                      '<extra></extra>'
    )

    fig.update_layout(
        template='plotly_dark',
        height=500,
        margin=dict(t=50, l=0, r=0, b=0)
    )

    return fig


###############################
## URUCHOMIENIE APLIKACJI ##
###############################

# Uruchomienie serwera
if __name__ == '__main__':
    print("\n🚀 Uruchamianie serwera...")
    print("📍 Otwórz przeglądarkę i przejdź do: http://127.0.0.1:8050/")
    print("🛑 Aby zatrzymać serwer, naciśnij Ctrl+C\n")
    app.run(debug=True, port=8050)
