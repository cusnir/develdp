library(shiny)

source('helpers.R')

s1 <- process_csv(2008)
s2 <- process_csv(2009)
s3 <- process_csv(2010)
s4 <- process_csv(2011)
s5 <- process_csv(2012)
s6 <- process_csv(2013)
s7 <- process_csv(2014)
s8 <- process_csv(2015)

# bind all stats in one data frame
s_all <- bind_rows(s1,s2,s3,s4,s5,s6,s7,s8)

group_by(s_all, teams_names) %>%
    filter(year>=2008 & year<=2015) %>%
    summarise(teams_scores=sum(teams_scores), win_counts=sum(nr_wins)) %>%
    arrange(desc(win_counts))

# lapply(list(s1,s2,s3,s4,s5,s6,s7,s8), head)
# lapply(list(s1,s2,s3,s4,s5,s6,s7,s8), tail)

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

