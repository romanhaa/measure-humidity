library(shiny)
library(plotly)

ui <- fluidPage(
    titlePanel("Humidity levels"),
    plotly::plotlyOutput("humidity"),
    plotly::plotlyOutput("temp"),
    actionButton('refresh_data', 'Refresh data')
)
