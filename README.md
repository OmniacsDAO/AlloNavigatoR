# AlloNavigatoR
An awesome tool to visualise Allo Protocol Data in R+Shiny

## [App Walkthrough on YouTube](https://www.youtube.com/watch?v=8d8SEt) <<< Click Here

## [App deployed on a tiny droplet](http://143.198.107.189:4539) <<< Click Here

<hr>

### Walkthrough

#### 1. Open R and install the requirements using

```
install.packages("shiny")
install.packages("shinyjs")
install.packages("bslib")
install.packages("bsicons")
install.packages("readr")
install.packages("lubridate")
install.packages("shinyWidgets")
devtools::install_github("OmniacsDAO/alloDataR")
```
#### 2. Clone this repo and set the R path to the repo.

```
setwd("~/Desktop/AlloNavigatoR)
```

#### 3. Download the fresh Allo Protocol Data

```
Rscript collectData.R
```

#### 4. Run the Shiny Dashboard

```
library(shiny)
runApp()
```

<img src="www/AlloNavigatoR.jpg" align="center"/>
<div align="center">Dashboard</div>

<hr>