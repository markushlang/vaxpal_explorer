
library(tidyverse)
library(htmltools)
library(leaflet)
library(shiny)
library(leaflet)
library(sf)
library(reactable)
library(colorspace)

# load datasets
readr::read_csv("data/vaxpal_map_data.csv") %>%
  dplyr::select( -`...1`) -> vaxpal_map_data

readr::read_csv("data/vaxpal_table_date.csv") %>%
  dplyr::select(-c(`...1`,`Last Update`)) -> vaxpal_table_date

# load world map
countries <- sf::read_sf(dsn= getwd(), layer="countries")
countries <- countries %>% dplyr::filter(NAME != "Antarctica") 

# define colors
colors <- colorspace::sequential_hcl(300, palette = "RdPu")  

# server
shinyServer(function(input, output, session) {
  
  patentdata_subset <- reactive({
    if (is.null(input$vaccine)) 
      return(NULL)
    
    df <- vaxpal_map_data %>% 
      dplyr::filter(vaccine == input$vaccine) %>%
      dplyr::select(vaccine,ISO3,status = input$status)
    
    patentdata <- countries %>%
      dplyr::left_join(df, by = "ISO3")
  })
  
  output$mapAct <- renderLeaflet({
    leaflet() %>%
      setView(lat=35, lng=50 , zoom=2) 
  })
  
  
  observe({
    
    state_popup <- paste0("<strong>Country: </strong>", 
                          patentdata_subset()$NAME,"<br/>",
                          "<strong>",input$status,": </strong>",
                          patentdata_subset()$status)
    
    dat <- patentdata_subset()
    
    colorPalette <- colorBin(palette = colors, dat$status, 
                             na.color = "#e7e8e9",reverse = TRUE)
    
    
    if (is.null(dat)) 
      return(NULL)
    leafletProxy("mapAct", data = dat) %>%
      addPolygons(stroke = TRUE, smoothFactor = 0.1, fillOpacity = 1,weight = 1,
                  fillColor = ~colorPalette(status),color = "grey",popup = state_popup) 
  })
  
  # observe({
  #   colorPalette <- colorBin(palette = colors, patentdata_subset()$status,
  #                            na.color = "#e7e8e9",reverse = TRUE)
  # 
  #   leafletProxy("mapAct", data = patentdata_subset()) %>%
  #   clearControls() %>%
  #   addLegend(position = "bottomleft",
  #             pal = colorPalette, values = ~status,
  #             title = NULL)
  # 
  # })
  
  output$table <- renderReactable({
    reactable(vaxpal_table_date, 
              filterable = TRUE, 
              minRows = 10,
              searchable = TRUE)
  })
  
})
