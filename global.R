## (c) Keisuke Kondo
## Date (First Version): 2022-10-28
## Date (Latest Version): 2022-10-28
## 
## - global.R
## - server.R
## - ui.R
## 

#Required Packages
if(!require(devtools)) install.packages("devtools")
if(!require(shinydashboard)) install.packages("shinydashboard")
if(!require(shinythemes)) install.packages("shinythemes")
if(!require(shinyjs)) install.packages("shinyjs")
if(!require(highcharter)) install.packages("highcharter")
if(!require(dplyr)) install.packages("dplyr")
if(!require(tibble)) install.packages("tibble")
if(!require(readr)) install.packages("readr")

#######################################
## IMPORT DATA
#######################################
dfDeltaAllMale <- read_csv("csv/table_distance_decay_parameter_allmunicipalities_male_jp.csv")
dfDeltaAllFemale <- read_csv("csv/table_distance_decay_parameter_allmunicipalities_female_jp.csv")
dfDeltaInMale <- read_csv("csv/table_distance_decay_parameter_intokyo23_male_jp.csv")
dfDeltaInFemale <- read_csv("csv/table_distance_decay_parameter_intokyo23_female_jp.csv")
dfDeltaOutMale <- read_csv("csv/table_distance_decay_parameter_outtokyo23_male_jp.csv")
dfDeltaOutFemale <- read_csv("csv/table_distance_decay_parameter_outtokyo23_female_jp.csv")

#######################################
## MODULE
#######################################

## ++++++++++++++++++++++++++++++++++++
## Module for Line Plot
## ++++++++++++++++++++++++++++++++++++
linePlotUI <- function(id) {
  ns <- NS(id)
  tagList(highchartOutput(ns("linePlot"), height = "360px"))
}
#Module for Line Plot
linePlot <-
  function(
    input,
    output,
    session,
    inputDataFrame,
    inputFlagError
  ) {
    #Highcharts
    output$linePlot <- renderHighchart({
      
      #DataFrame
      dfHc <- inputDataFrame
      
      #Benefit
      if(dfHc$stockMigrationSubsidyYen[1] != 0){
        hc <- highchart() %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockMigrationBenefitYen),
            type = "line",
            step = "center",
            color = "#2f7ed8",
            name = "移住便益（移住支援金がない場合）",
            lineWidth = 3,
            showInLegend = TRUE
          ) %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockMigrationBenefitSubsidyYen),
            type = "line",
            step = "center",
            color = "#25b086",
            name = "移住便益（移住支援金がある場合）",
            lineWidth = 3,
            showInLegend = TRUE
          ) %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockMigrationCostYen),
            type = "line",
            color = "#f45b5b",
            name = "移住費用",
            lineWidth = 3,
            showInLegend = TRUE
          ) %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockNetBenefitYen),
            type = "column",
            color = "#2f7ed8",
            name = "純便益（移住支援金がない場合）",
            borderWidth = 3,
            borderColor = "#f45b5b",
            opacity = 0.7,
            showInLegend = TRUE,
            zIndex = -1
          ) %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockNetBenefitSubsidyYen),
            type = "column",
            color = "#25b086",
            name = "純便益（移住支援金がある場合）",
            borderWidth = 3,
            borderColor = "#f45b5b",
            opacity = 0.7,
            showInLegend = TRUE,
            zIndex = -1
          ) %>%
          hc_yAxis(
            title = list(text = "金額（万円）"),
            allowDecimals = TRUE,
            plotLines = list(list(width = 2, value = 0))
          ) %>%
          hc_xAxis(
            title = list(text = "移住後の経過年数"),
            categories = dfHc$period,
            plotLines = list(list(width = 2, value = dfHc$periodCutoff[1], color = "yellow"),
                             list(width = 2, value = dfHc$periodCutoffSubsidy[1], color = "purple"))
          ) %>%
          hc_tooltip(
            valueDecimals = 0,
            crosshairs = TRUE,
            sort = FALSE,
            table = TRUE,
            backgroundColor = "#f5f5f5",
            borderColor = "#808080",
            borderWidth = 1
          ) %>%
          hc_add_theme(hc_theme_gridlight())
      }
      else{
        hc <- highchart() %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockMigrationBenefitYen),
            type = "line",
            step = "center",
            color = "#2f7ed8",
            name = "移住便益",
            lineWidth = 3,
            showInLegend = TRUE
          ) %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockMigrationCostYen),
            type = "line",
            color = "#f45b5b",
            name = "移住費用",
            lineWidth = 3,
            showInLegend = TRUE
          ) %>%
          hc_add_series(
            data = dfHc,
            hcaes(period, stockNetBenefitYen),
            type = "column",
            color = "#2f7ed8",
            name = "純便益",
            borderWidth = 3,
            borderColor = "#f45b5b",
            opacity = 0.7,
            showInLegend = TRUE,
            zIndex = -1
          ) %>%
          hc_yAxis(
            title = list(text = "金額（万円）"),
            allowDecimals = TRUE,
            plotLines = list(list(width = 2, value = 0))
          ) %>%
          hc_xAxis(
            title = list(text = "移住後の経過年数"),
            categories = dfHc$period,
            plotLines = list(list(width = 2, value = dfHc$periodCutoff[1], color = "yellow"))
          ) %>%
          hc_tooltip(
            valueDecimals = 0,
            crosshairs = TRUE,
            sort = FALSE,
            table = TRUE,
            backgroundColor = "#f5f5f5",
            borderColor = "#808080",
            borderWidth = 1
          ) %>%
          hc_add_theme(hc_theme_gridlight())
      }
      
      #plot
      hc
    })
  }
