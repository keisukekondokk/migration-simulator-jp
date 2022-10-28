## (c) Keisuke Kondo
## Date (First Version): 2022-10-28
## Date (Latest Version): 2022-10-28
## 
## - global.R
## - server.R
## - ui.R
## 

server <- function(input, output, session){
  ####################################
  ## VISUALIZE SIMULATION
  ####################################

  ## ++++++++++++++++++++++++++++++++++++++++++
  ## VISUALIZE SIMULATION RESULTS
  ## ++++++++++++++++++++++++++++++++++++++++++
  observeEvent(input$buttonSimulation, {
    #Parameter Setting
    # - delta: distance decay parameter
    #Input Data
    # - delta: distance decay parameter
    #Output Data
    # - delta: distance decay parameter
    
    ## ++++++++++++++++++++++++++++++++++++++++++
    ## LOAD SIMULATION RESULTS
    ## ++++++++++++++++++++++++++++++++++++++++++
    
    #######################################
    ## Parameter Setting
    #######################################
    
    #++++++++++++++++++++++++++++++++++++++
    #Variables Imported
    flowPreNominalIncomeYen <- input$preincome
    flowPostNominalIncomeYen <- input$postincome
    flowRelativeCostOfLiving <- input$costofliving
    migrationDistance <- input$distance
    stockNominalSubsidyYen <- input$subsidy

    #++++++++++++++++++++++++++++++++++++++
    #Parameter Imported
    delta <- input$delta
    
    #++++++++++++++++++++++++++++++++++++++
    #Results
    stockMigrationCost <- migrationDistance^(delta)
    stockMigrationCostYen <- (stockMigrationCost - 1) * flowRelativeCostOfLiving * flowPreNominalIncomeYen
    flowRelativeRealIncome <- (flowPostNominalIncomeYen / flowPreNominalIncomeYen) / flowRelativeCostOfLiving

    #Case 1: Relative Real Wage > 1
    if( flowRelativeRealIncome - 1 > 0 ){
      flagError <- 0
      periodPayout <- ceiling( (stockMigrationCost - 1) / (flowRelativeRealIncome - 1) )
      if( stockNominalSubsidyYen > 0 ){
        if( stockNominalSubsidyYen > stockMigrationCostYen ){
          periodPayoutSubsidy <- 0
        }
        else{
          periodPayoutSubsidy <- ceiling( (stockMigrationCost - 1) / (flowRelativeRealIncome - 1) -  ((stockNominalSubsidyYen / flowPreNominalIncomeYen) / (flowRelativeCostOfLiving)) / (flowRelativeRealIncome - 1) )
        }
      }
      else{
        periodPayoutSubsidy <- NA_real_
      }
      timeRange <- ceiling( periodPayout * 1.1 ) + 3
    }
    #Case 2: Relative Real Wage = 1
    else if( flowRelativeRealIncome - 1 == 0 ){
      flagError <- 1
      periodPayout <- NA_real_
      if( stockNominalSubsidyYen > stockMigrationCostYen ){
        periodPayoutSubsidy <- 0
      }
      else{
        periodPayoutSubsidy <- NA_real_
      }
      timeRange <- 5
    }
    #Case 3: Relative Real Wage < 1
    else if( flowRelativeRealIncome - 1 < 0 ){
      flagError <- 1
      periodPayout <-  NA_real_
      if( stockNominalSubsidyYen > 0 ){
        if( stockNominalSubsidyYen > stockMigrationCostYen ){
          periodPayoutSubsidy <- ceiling( (stockMigrationCost - 1) / (flowRelativeRealIncome - 1) - ((stockNominalSubsidyYen / flowPreNominalIncomeYen) / (flowRelativeCostOfLiving)) / (flowRelativeRealIncome - 1) ) - 1
          timeRange <- ceiling( periodPayoutSubsidy * 1.1 ) + 5
        }
        else{
          periodPayoutSubsidy <- NA_real_
          timeRange <- 5
        }
      }
      else{
        periodPayoutSubsidy <- NA_real_
        timeRange <- 5
      }
    }
    
    #++++++++++++++++++++++++++++++++++++++
    #Variables
    time <- timeRange
    flowMigrationBenefitYen <- (flowRelativeRealIncome - 1) * flowRelativeCostOfLiving * flowPreNominalIncomeYen
    stockMigrationBenefitYen <- flowMigrationBenefitYen * time
    stockMigrationBenefitSubsidytYen <- flowMigrationBenefitYen * time + stockNominalSubsidyYen
    
    #++++++++++++++++++++++++++++++++++++++
    #DataFrame
    if( flowRelativeRealIncome - 1 == 0 ){
      df <- tibble(
        period = seq(0, time, by = 1),
        periodCutoff = periodPayout,
        periodCutoffSubsidy = periodPayoutSubsidy,
        stockMigrationBenefitYen = 0,
        stockMigrationSubsidyYen = stockNominalSubsidyYen,
        stockMigrationBenefitSubsidyYen = stockNominalSubsidyYen,
        stockMigrationCostYen = stockMigrationCostYen,
        stockNetBenefitYen = stockMigrationBenefitYen - stockMigrationCostYen,
        stockNetBenefitSubsidyYen = stockMigrationBenefitYen - stockMigrationCostYen + stockNominalSubsidyYen
      )
    }
    else{
      df <- tibble(
        period = seq(0, time, by = 1),
        periodCutoff = periodPayout,
        periodCutoffSubsidy = periodPayoutSubsidy,
        stockMigrationBenefitYen = seq(0, stockMigrationBenefitYen, by = flowMigrationBenefitYen),
        stockMigrationSubsidyYen = stockNominalSubsidyYen,
        stockMigrationBenefitSubsidyYen = seq(stockNominalSubsidyYen, stockMigrationBenefitSubsidytYen, by = flowMigrationBenefitYen),
        stockMigrationCostYen = stockMigrationCostYen,
        stockNetBenefitYen = stockMigrationBenefitYen - stockMigrationCostYen,
        stockNetBenefitSubsidyYen = stockMigrationBenefitYen - stockMigrationCostYen + stockNominalSubsidyYen
      )
    }

    ## ++++++++++++++++++++++++++++++++++++++++++
    ## MAKE FIGURES USING SIMULATION RESULTS
    ## ++++++++++++++++++++++++++++++++++++++++++
    
    #++++++++++++++++++++++++++++++++++++++
    #valueBox
    output$vBox1 <- renderValueBox({
      valueBox(
        paste0(round(flowMigrationBenefitYen)),
        "毎期の移住便益（万円）",
        icon = icon("money-check"),
        color = "light-blue"
      )
    })
    
    #valueBox
    output$vBox2 <- renderValueBox({
      valueBox(
        paste0(round(stockMigrationCostYen)),
        "移住費用（万円）",
        icon = icon("money-check"),
        color = "red"
      )
    })

    #valueBox
    output$vBox3 <- renderValueBox({
      valueBox(
        paste0(round(stockNominalSubsidyYen)),
        "移住支援金（万円）",
        icon = icon("money-check"),
        color = "olive"
      )
    })
    
    #valueBox
    output$vBox4 <- renderValueBox({
      valueBox(
        paste0(periodPayout),
        "投資回収に必要な居住年数（移住支援金がない場合）",
        icon = icon("chart-line"),
        color = "yellow"
      )
    })
    
    #valueBox
    output$vBox5 <- renderValueBox({
      valueBox(
        paste0(round(periodPayoutSubsidy)),
        "投資回収に必要な居住年数（移住支援金がある場合）",
        icon = icon("chart-line"),
        color = "purple"
      )
    })
    
    ## ++++++++++++++++++++++++++++++++++++++++++
    ## MAKE FIGURES USING SIMULATION RESULTS
    ## ++++++++++++++++++++++++++++++++++++++++++
    
    #++++++++++++++++++++++++++++++++++++++
    #Table
    output$tableDeltaAllMale <- renderTable(
      dfDeltaAllMale,
      hover = TRUE,
      bordered = TRUE,
      digits = 3
    )
    #Table
    output$tableDeltaAllFemale <- renderTable(
      dfDeltaAllFemale,
      hover = TRUE,
      bordered = TRUE,
      digits = 3
    )
    #Table
    output$tableDeltaInMale <- renderTable(
      dfDeltaInMale,
      hover = TRUE,
      bordered = TRUE,
      digits = 3
    )
    #Table
    output$tableDeltaInFemale <- renderTable(
      dfDeltaInFemale,
      hover = TRUE,
      bordered = TRUE,
      digits = 3
    )
    #Table
    output$tableDeltaOutMale <- renderTable(
      dfDeltaOutMale,
      hover = TRUE,
      bordered = TRUE,
      digits = 3
    )
    #Table
    output$tableDeltaOutFemale <- renderTable(
      dfDeltaOutFemale,
      hover = TRUE,
      bordered = TRUE,
      digits = 3
    )
    
    
    #++++++++++++++++++++++++++++++++++++++
    
    ## ++++++++++++++++++++++++++++++++++++++++++
    ## MAKE FIGURES USING SIMULATION RESULTS
    ## ++++++++++++++++++++++++++++++++++++++++++
    
    #++++++++++++++++++++++++++++++++++++++
    #Update Line Plot
    callModule(
      linePlot,
      "linePlot",
      df,
      flagError
    )    
      
    ###############################
    #buttonSimulation
  }, ignoreNULL = FALSE)
  
}