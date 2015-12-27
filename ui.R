library(shiny)

shinyUI(fluidPage(
    titlePanel("NFL contests"),
    sidebarLayout(
        sidebarPanel(
            helpText("NFL contests"),
            selectInput("year",
                        label = "Select contests year to display",
                        choices = c("2011", "2012", "2013", "2014", "2015"),
                        selected = "2011"),
            sliderInput("range", "Years Range:",
                        min=2008, max=2015, value=c(2008,2015)),
        width=2),
        mainPanel(
            dataTableOutput(outputId="contest_table"),
            dataTableOutput("team_stats")
            )
    )
))
