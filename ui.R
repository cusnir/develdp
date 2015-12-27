library(shiny)

shinyUI(
    navbarPage("NFL contests Scores and Stats",
               tabPanel("Plots",
                        sidebarLayout(
                            sidebarPanel(
                                p("NFL contests graphs:"),
                                helpText("These graphs show top teams scores for each year and also cumulative score sum for choosed years"),
                                sliderInput("range", "Years Range:",
                                            min=2008, max=2015, value=c(2008,2015)),
                                numericInput("topn", "Top teams nr:", 3,
                                             min = 1, max = 10),
                                width=2
                            ),
                            mainPanel(
                                plotOutput("plot_cum", height = "100%"),
                                plotOutput("plot_by_year", height = "100%")
                            )
                        )
               ),
               tabPanel("Summary Table",
                        sidebarLayout(
                            sidebarPanel(
                                p("NFL contests summary table:"),
                                helpText("This table show top teams with cumulative team score, cumulative number of wins losses and pushes for choosed years,
                                         you can also do a quick search on top right by entering search key words, or bellow of the table a column based search"),
                                sliderInput("range_table", "Years Range:",
                                            min=2008, max=2015, value=c(2008,2015)),
                                width=2
                            ),
                            mainPanel(
                                dataTableOutput("team_stats")
                            )
                        )),
               tabPanel("Raw Table",
                        sidebarLayout(
                            sidebarPanel(
                                p("NFL contests Raw Table:"),
                                helpText("This table contains team contest data mostly in the same form as it was obtained from original site, 
                                         it can be used to get more detailed information about a team or any other info you are interested"),
                                selectInput("year",
                                            label = "Select contests year to display",
                                            choices = c("2011", "2012", "2013", "2014", "2015"),
                                            selected = "2011"),
                                width=2
                            ),
                            mainPanel(
                                dataTableOutput(outputId="contest_table")
                            )
                        ))
    ))
