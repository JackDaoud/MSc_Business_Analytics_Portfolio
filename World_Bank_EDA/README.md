# World Bank EDA 

Sun, 8th Nov 2020

Explore World Bank data of 41 indicators (columns) on 217 countries (rows). Exploratory analysis focuses on the Arabian Peninsula region of the dataset, consisting of 15 countries. The purpose of the project was to conduct thorough EDA and share insightful conclusions. 

---
### Project Overview

- Conduct an exploratory data analysis using Python
- Formulate a strategy for missing values and identifying potential outliers
- Develop a Jupyter Notebook on their process and findings (with ample use of markdown) 

---
### Analysis Guidelines

- Introduce your region from a non-technical perspective (culture, world-famous aspects, etc.). 
- Select one country from your region that you feel best represents it "on average". Include the rationale for your choice and support it with Python code.
- Identify any obscure findings in the data. In other words "Does the data accurately reflect the region? Can your region's numbers be trusted?"
- Explain your strategy for missing values, as well as your strategy for identifying outliers.
- Select the Top 5 features (i.e. columns) of the dataset that best exemplify your region. In other words, "What makes your region unique when compared to the rest of the world?"
- Support your findings with domain knowledge (i.e. research from external sources). Make sure to site your sources.

---
### Summary Findings:

Our region shines in diversity. Some countries face on-going civil war, others are economically prosperous due to their natural oil reserves.
Indicators should be closely monitored by the countries of the region to develop future strategies for the triple bottom line: social, environmental, economic sustainability.

#### Missing Values & Accuracy Assessment
- Syria and West Bank / Gaza have the most null values due to political instability. 
- Turkey and Cyprus have the least values missing due to strict reporting culture enforced by the EU. 
- Due to instability in many of the countries in the Arabian Peninsula, the majority of data gathered are estimates, or collected from the latest census, which varies from 1963 to 2018, making it incomparable. 
- The Weighted Average aggregation method renders some inaccuracy as the weights are unknown. Our data shows that weighted averages increase outliers.

#### Correlations: 
- The high correlation between GNI per capita and CO2 emissions (0.9) is driven by the significant oil reserves. 
- The strong negative correlation between life expectancy and fertility (-0.79) refers to the evolutionary trade-off between reproduction and body maintenance.
- The identified positive correlation between malaria cases and tuberculosis mortality (0.92) cannot be verified by external sources. 

#### Representative Country: 
- **Oman** is the country which best represents the Arabian Peninsula region on average. It has the least missing values and has the least variation to the mean of the different indicators, even though the country has been reported as an outlier in some indicators. 

#### Five Unique Indicators: 
- Tuberculosis Mortality
- Tuberculosis Cases
- CO2 Emissions
- GNI per Capita
- Parliament seats held by women
