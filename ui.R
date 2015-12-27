library(shiny)

shinyUI(
    navbarPage("NFL contests Scores and Stats",
               tabPanel("Plots",
                        sidebarLayout(
                            sidebarPanel(
                                helpText("NFL contests"),
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
                                helpText("NFL contests"),
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
                                helpText("NFL contests"),
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
