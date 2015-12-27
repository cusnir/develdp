library(shiny)

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


filter_stats_year <- function (data_source, start_year, end_year) {
  group_by(data_source, teams_names) %>%
      filter(year>=start_year & year<=end_year) %>%
      summarise(teams_scores=sum(teams_scores), win_counts=sum(nr_wins), lose_counts=sum(nr_losses), push_nr=sum(nr_pushes)) %>%
      arrange(desc(win_counts, team_scores))
}

shinyServer(function(input, output) {
    contestData <- reactive({
        csv.file.path <- paste0("data/fantasysupercontest.com_", input$year, ".csv")
        # return only part of the col names
        read.csv(csv.file.path)[, c('game_time', 'week', 'away_city', 'away_name', 'away_line', 'away_score', 'away_ats_result', 'home_city', 'home_name', 'home_line', 'home_score', 'home_ats_result')]
    })
    teamStats <- reactive({
        filter_stats_year(stats_all, start_year = input$range[1], end_year = input$range[2])
    })

    output$data_summary <- renderPrint({dataSummary()})
    output$year <- renderPrint({input$year})
    output$contest_table <- renderDataTable({contestData()}, options = list(orderClasses = TRUE, pageLength = 10))
    output$team_stats <- renderDataTable({teamStats()}, options = list(orderClasses = TRUE, pageLength = 10))
})
