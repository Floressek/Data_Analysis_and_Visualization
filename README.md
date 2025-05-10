 # R Statistical Data Analysis Project

This repository contains a collection of statistical data analysis laboratories using R. Each lab focuses on different aspects of data exploration, visualization, and analysis techniques.

## Project Structure

```
.
├── .gitignore                 # Git ignore configuration
├── Lab1/                      # Laboratory 1-2 - Univariate & Bivariate Data Analysis
│   ├── Excel/                 # Directory for Excel files
│   └── Univariate-Bivariate-Data/
│       ├── main.R             # R script for univariate/bivariate analysis
│       └── data/              # Output directory for generated charts
├── Lab3/                      # Laboratory 3 - Correlation Analysis
│   └── main.R                 # R script for correlation analysis
├── Lab4/                      # Laboratory 4 - Visualization & Statistical Plots
│   └── main.R                 # R script for advanced data visualization
└── data/                      # Data directory
    └── LifeCycleSavings_with_additional_columns.csv  # Extended dataset
```

## Lab Descriptions

### Lab 1-2: Univariate and Bivariate Data Analysis
This lab focuses on exploring and visualizing basic relationships in the LifeCycleSavings dataset. The analysis includes:
- Pair plots to show dependencies between variables
- Histograms for univariate analysis
- Bar plots comparing countries on various metrics
- Age distribution analysis
- Scatter plots to explore relationships between variables

### Lab 3: Correlation Analysis
This lab analyzes the Eggs dataset, focusing on:
- Correlation between sales (Cases) and various price variables
- Matrix scatter plots for relationship visualization
- Advanced correlation visualization techniques
- Time-series analysis of egg sales and prices
- Factor analysis (Easter, month, etc.) affecting egg sales

### Lab 4: Statistical Visualization
This lab demonstrates various visualization techniques in R:
- Histogram comparison with different settings
- Density plots and probability distributions
- Advanced group comparison plots
- Box plots for distribution comparison
- Dual axis plots
- Pie charts for categorical data

## Key Datasets

### LifeCycleSavings Dataset
This dataset contains savings and related economic data for various countries, including:
- Savings rates (sr)
- Population demographics (pop15, pop75)
- Average income (dpi)
- Income growth (ddpi)

### Eggs Dataset
Analyzes egg sales data with related variables:
- Cases (egg sales)
- Various price indicators (Egg.Pr, Beef.Pr, Chicken.Pr, etc.)
- Seasonal factors (Month, Easter)

## Getting Started

### Prerequisites
- R (recommended version 4.0.0 or higher)
- RStudio (recommended for easier workflow)
- Required R packages:
  - corrplot
  - car
  - plotly

### Running the Analysis
1. Clone this repository
2. Open the desired lab's main.R file in RStudio
3. Install any required packages:
   ```R
   install.packages(c("corrplot", "car", "plotly"))
   ```
4. Execute the script to see the analysis results

## Output
The scripts generate various visualization files in PNG format that are saved to the respective data directories.

## Notes
- All R scripts use UTF-8 encoding
- For Lab1, the charts are automatically saved in the 'data' folder
- Interactive plots in Lab3 require the plotly package

## License
This project is provided for educational purposes.
