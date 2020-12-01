# Python World Data Region Analysis 
## Jupiter Notebook Report

Sun, 8th Nov 2020

This project focussed on exploring World Bank data consisting of 41 indicators on 217 countries. This report will focus on the Arabian Peninsula region of the dataset, consisting of 15 countries. The purpose of the project was to conduct an exploratory analysis supported by external research. 

Collaborators: [Estrella Spaans](https://github.com/EstrellaSpaans) and [Sara Mareike Krause](https://github.com/Sara-Krause)

---
### Exploratory Analysis:

- Remove countries (rows) that aren't part of the Arabian Peninsula
- Remove columns that contain old data or unreliable data
- Formulate a strategy for null-values and outliers. 
- Flag missing values and outliers.
- Imputation for mising values 

### Business Questions: 
- Which country represents the the Arabian Peninsula the best on average? 
- Which five indicators makes the Arabian Peninsula unique compared to the world / other regions? 

---
### Python Packages Used:

- Pandas
- Matplotlib
- Seaborn

---
### Summary Findings:

Our region shines in diversity. Some countries face on-going civil war, others are economically prosperous due to their natural oil reserves.
Indicators should be closely monitored by the countries of the region to develop future strategies for the triple bottom line: social, environmental, economic sustainability.

#### Null Values / Accuracy
- Syria and West Bank / Gaza have the most null values due to political instability. 
- Turkey and Cyprus have the least values missing due to strict reporting culture enforced by the EU. 
- Due to instability in many of the countries in the Arabian Peninsula, the majority of data gathered are estimates, or collected from the latest census, which varies from 1963 to 2018, making it incomparable. 
- The Weighted Average aggregation method renders some inaccuracy as the weights are unknown. Our data shows that weighted averages increase outliers.

#### Correlations: 
- The high correlation between GNI per capita and CO2 emissions (0.9) is driven by the significant oil reserves. 
- The strong negative correlation between life expectancy and fertility (-0.79) refers to the evolutionary trade-off between reproduction and body maintenance.
- The identified positive correlation between malaria cases and tuberculosis mortality (0.92) cannot be verified by external sources. 

#### Representative Country: 
- Oman is the country which best represents the Arabian Peninsula region on average as it has the least missing values and has the least variation to the mean of the different indicators, even though the country has been reported as an outlier in some indicators. 

#### Five Unique Indicators: 
- Tuberculosis Mortality
- Tuberculosis Cases
- CO2 Emissions
- GNI per Capita
- Parliament seats held by women
