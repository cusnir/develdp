library(shiny)

source('helpers.R')

# gather all years data in one dataframe
stats_all <- data_frame()
for(i in seq(2008, 2015)){
    stats_all <- bind_rows(stats_all, process_csv(i))
}

group_by(stats_all, teams_names) %>%
    filter(year>=2008 & year<=2015) %>%
    summarise(teams_scores=sum(teams_scores), win_counts=sum(nr_wins)) %>%
    arrange(desc(win_counts))

# contest data loaded as csv files from https://fantasysupercontest.com
shinyServer(function(input, output) {
    contestData <- reactive({
        csv.file.path <- paste0("data/fantasysupercontest.com_", input$year, ".csv")
        read.csv(csv.file.path)
    })
        dataSummary <- reactive({
        summary(contestData())
    })

    output$data_summary <- renderPrint({dataSummary()})
    output$year <- renderPrint({input$year})
    output$contest_table <- renderDataTable({contestData()}, options = list(orderClasses = TRUE, pageLength = 10))
})

