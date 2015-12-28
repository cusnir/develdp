library(shiny)
library(ggplot2)

source('helpers.R')

# contest data loaded as csv files from https://fantasysupercontest.com
# gather all years data in one dataframe
if (!file.exists("data/stats_all.txt")) {
    stats_all <- data_frame()
    for(i in seq(2008, 2015)){
        stats_all <- bind_rows(stats_all, process_csv(i))
    }
    write.table(stats_all, file = "data/stats_all.txt", row.name=FALSE)
}

stats_all <- read.table("data/stats_all.txt", header = TRUE)
stats_all <- as.tbl(stats_all)

shinyServer(function(input, output) {
    contestData <- reactive({
        csv.file.path <- paste0("data/fantasysupercontest.com_", input$year, ".csv")
        # return only part of the col names
        read.csv(csv.file.path)[, c('game_time', 'week', 'away_city', 'away_name', 'away_line', 'away_score', 'away_ats_result', 'home_city', 'home_name', 'home_line', 'home_score', 'home_ats_result')]
    })
    teamStats <- reactive({
        filter_stats_by_year(stats_all, start_year = input$range[1], end_year = input$range[2])
    })
    teamScoresTop <- reactive({
        team_scores_cum_top <- create_top_stats(stats_all, input$range[1], input$range[2], input$topn)
    })
    teamStatsTable <- reactive({
        filter_stats_by_year(stats_all, start_year = input$range_table[1], end_year = input$range_table[2])
    })
    
    output$data_summary <- renderPrint({dataSummary()})
    output$year <- renderPrint({input$year})
    output$contest_table <- renderDataTable({contestData()}, options = list(orderClasses = TRUE, pageLength = 10))
    output$team_stats <- renderDataTable({teamStatsTable()}, options = list(orderClasses = TRUE, pageLength = 10))
    
         output$plot_cum <- renderPlot({
             ggplot(data = teamScoresTop(), aes(x = year, y = score_cumulative, col = levels(teamScoresTop()$team_name))) +
                 geom_point() + geom_line() +
                 geom_text(colour = "black", size = 3,
                           aes(label = score_cumulative, hjust = 0.5, vjust = 1.5)) +
                 ggtitle("Cumulative score by year") +
                 #scale_fill_discrete(name = "Title", breaks = levels(teamScoresTop()$team_name)) +
                 theme_gray(base_family = "Avenir", base_size = 18) +
                 xlab("") + ylab("Cumulative score for teams by year")
         }, height = 600)
         
         output$plot_by_year <- renderPlot({
             ggplot(data = teamScoresTop(), aes(x = year, y = team_score, col = team_name)) +
                 geom_point() + geom_line() +
                 geom_text(colour = "black", size = 3,
                           aes(label = team_score, hjust = 0.5, vjust = 1.5)) +
                 ggtitle("Score by year") +
                 theme_gray(base_family = "Avenir", base_size = 18) +
                 xlab("") + ylab("Score for teams by year")
         }, height = 600)
})
