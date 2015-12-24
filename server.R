library(shiny)

# contest data loaded as csv files from https://fantasysupercontest.com
shinyServer(function(input, output) {
    contestData <- reactive({
        csv.file.path <- paste0("data/fantasysupercontest.com_", input$year, ".csv")
        data <- read.csv(csv.file.path)
    })
   output$year <- renderText({input$year})
   output$contest_table <- renderDataTable({contestData()}, options = list(orderClasses = TRUE, pageLength = 10))
})
