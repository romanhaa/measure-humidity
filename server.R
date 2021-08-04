library(shiny)
library(plotly)
library(readr)
library(dplyr)

# TODO:
# - by default show last N days
# - add trend line
# - database with proper function to add (new) data

hline <- function(y=0, color="blue") {
    list(
        type = "line",
        x0 = 0,
        x1 = 1,
        xref = "paper",
        y0 = y,
        y1 = y,
        line = list(color=color)
    )
}

load_data <- function() {
    df <- read_tsv(paste0(Sys.getenv('PATH_DATA'), '/humidity_data.tsv'), col_names=TRUE, col_types=cols()) %>%
        mutate(
            date = as.POSIXct(strptime(date, "%Y-%m-%d %H:%M:%OS")),
            humidity=humidity/100
        )
    return(df)
}

server <- function(input, output) {
    data <- reactiveValues(
        df=load_data()
    )
    observeEvent(input$refresh_data, {
        data$df <- load_data()
    })
    time_to_show <- reactiveValues(
        zoomX1=NULL,
        zoomX2=NULL
    )
    relayout_data_humidity <- reactive({
        xvals=event_data("plotly_relayout", source="plot_humidity")
        if (!is.null(xvals$`xaxis.range[0]`)) {
            time_to_show$zoomX1=xvals$`xaxis.range[0]`
            time_to_show$zoomX2=xvals$`xaxis.range[1]`
        } else {
            time_to_show$zoomX1=NULL
            time_to_show$zoomX2=NULL  
        }
    })
    relayout_data_temp <- reactive({
        xvals=event_data("plotly_relayout", source="plot_temp")
        if (!is.null(xvals$`xaxis.range[0]`)) {
            time_to_show$zoomX1=xvals$`xaxis.range[0]`
            time_to_show$zoomX2=xvals$`xaxis.range[1]`
        } else {
            time_to_show$zoomX1=NULL
            time_to_show$zoomX2=NULL  
        }
    })
    output$humidity <- plotly::renderPlotly({
        req(data$df)
        relayout_data_humidity()
        relayout_data_temp()
        df <- data$df
        plot_ly(
            x=df$date,
            y=df$humidity,
            type='scatter',
            mode='lines',
            line=list(
                color='black'
            ),
            source='plot_humidity'
        ) %>%
        layout(
            xaxis=list(
                showline=TRUE,
                mirror=TRUE,
                range = c(time_to_show$zoomX1, time_to_show$zoomX2)
            ),
            yaxis=list(
                title='Humidity',
                tickformat="%",
                fixedrange=TRUE,
                showline=TRUE,
                mirror=TRUE
            ),
            shapes = list(
                hline(0.4, color='red'),
                hline(0.6, color='red'),
                hline(mean(df$humidity, color='blue'))
            )
        ) %>%
        event_register("plotly_relayout")
    })
    output$temp <- plotly::renderPlotly({
        req(data$df)
        relayout_data_humidity()
        relayout_data_temp()
        df <- data$df
        plot_ly(
            x=df$date,
            y=df$temperature,
            type='scatter',
            mode='lines',
            line=list(
                color='black'
            ),
            source='plot_temp'
        ) %>%
        layout(
            xaxis=list(
                showline=TRUE,
                mirror=TRUE,
                range = c(time_to_show$zoomX1, time_to_show$zoomX2)
            ),
            yaxis=list(
                title='Temperature',
                ticksuffix="˚C",
                fixedrange=TRUE,
                showline=TRUE,
                mirror=TRUE
            ),
            shapes = list(
                hline(mean(df$temperature, color='blue'))
            )
        ) %>%
        event_register("plotly_relayout")
    })
}
